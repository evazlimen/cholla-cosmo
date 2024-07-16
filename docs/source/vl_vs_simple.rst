Comparison of the Van Leer and Simple Integrators
=====

.. _introduction:

Introduction
------------

Historically, the cosmology functionality of Cholla was developed with the SIMPLE integration method. This integrator has been shown to be unstable in certain hydrodynamical tests, with the Van Leer (VL) integration scheme performing as expected. Here we compare the two integration methods, including the dual energy synchronization steps.

.. _simple:

Overview of the SIMPLE integrator
--------------------------

The simple integrator ``src/integrators/simple_3D_cuda.cu`` takes as arguments the conserved quantities, device and host gravitational potential, the box's cell location information, the boundaries, the time step, and density floor.

Algorithm
^^^^^^^^^^

1. Memory on the GPU is allocated to contain the left and right states on the x, y, and z cell interfaces (``Q_Lx``, ``Q_Rx``, ``Q_Ly``, ``Q_Ry``, etc.), the x, y, z fluxes (e.g., ``F_x``) and the gravitational potential on the device.

2. For each direction, the left and right states of the conserved variables are computed using the reconstruction method (e.g., ``PPMP_cuda()``), extrapolated to the full timestep.

3. Fluxes are computed from the left and right states for each direction (e.g., ``Calculated_HLLC_Fluxes_CUDA()``).

4. A ``GPU_Error_Check()`` is called.

5. If using dual energy, there is a partial update of the advected internal energy.  The function ``Partial_Update_Advected_Internal_Energy_3D()`` is called using the full time step, taking both the conserved quantities ``dev_conserved`` and the left and right states in each direction (e.g., ``Q_Ly`` and ``Q_Ry``). A ``GPU_Error_Check()`` is called.

6. The conserved variables are updated using ``Update_Conserved_Variables_3D()`` with the full timestep.

7. A ``GPU_Error_Check()`` is called.

9. If dual energy is being used, we then call ``Select_Internal_Energy_3D()``.

9. If dual energy is being used, we then call ``Sync_Energies_3D()`` followed by a ``GPU_Error_Check()``.

.. _vl:

 Overview of the VL integrator
--------------------------

The Van Leer (VL) integrator ``src/integrators/VL3D_cuda.cu`` takes as arguments the conserved quantities, device and host gravitational potential, the box's cell location information, the boundaries, the time step, and density floor.

Algorithm
^^^^^^^^^^

1. Memory on the GPU is allocated to contain the left and right states on the x, y, and z cell interfaces (``Q_Lx``, ``Q_Rx``, ``Q_Ly``, ``Q_Ry``, etc.), the x, y, z fluxes (e.g., ``F_x``) and the device's conserved variables at the half time step (``dev_conserved_half``). -- *CHECK* on gravitational potential

2. Compute the first order upwind fluxes. To do this, automatic launch paramters are specified using ``cuda_utilites::AutomaticLaunchParams static const hllc_pcm_launch_params()`` Then, the method ``Calculate_HLLC_Fluxes_CUDA<reconstruction::Kind::pcm, 0>)`` is called. This computes interface arrays for the primitive variables in each direction (``0`` in this example).

3. ``GPU_Error_Check()`` is called.


4. The conserved variables are updated at the half time step. Automatic cuda launch parameters are set and then ``Update_Conserved_Variables_3D_half()`` is called, passing ``0.5*dt`` as the timestep.

5. ``GPU_Error_Check()`` is called.


6. The left at right states are computed using the conserved variables updated at the 1/2 time step.  For instance, ``PPMP_cuda()``, passing the full timestep ``dt`` and the half-updated variables ``dev_conserved_half``. This updates the interface states (e.g., ``Q_Lx`` and ``Q_Rx``).

7. ``GPU_Error_Check()`` is called.

8. The fluxes are recomputed (e.g., ``Calculate_HLLC_Fluxes_CUDA<reconstruction::Kind::chosen, 0>)``), now with ``chosen`` to indicate which reconstruction to use and ``0`` indicating the direction. The conserved variables at the half-step are used here.  This updates the fluxes, e.g., ``F_x``.

9. ``GPU_Error_Check()`` is called.
 

10. If using dual energy, ``Partial_Update_Advected_Internal_Energy_3D()`` is called, using the previous conserved variables, the full timestep, and the half timestep integrated interface states. Then another ``GPU_Error_Check()``.

11 The conserved variable array is updated ustin ghte full time step, the half step interface states and fluxes. This is performed by calling ``Update_Conserved_Variables_3D()``.  This updates ``dev_conserved``.

12. ``GPU_Error_Check()`` is called.

13. If using dual energy, we call ``Select_Internal_Energy_3D()`` and ``Synch_Energies_3D()`` using the updated conserved variables ``dev_conserved``.  A ``GPU_Error_Check()`` is called.

.. _dual_energy:


Overview of Dual Energy functions
--------------------------

There are four main dual energy functions that are used by the integrators. Here we provide a brief description of each function.

``Get_Pressure_From_DE()``
^^^^^^^^^^^^^^^^^^^^^^^^^^^

This function is defined in ``utils/hydro_utilities.h``.  It takes the total energy, the internal energy computed from the total and kinetic energy, the advected "dual" internal energy, and gamma.

1. It sets ``Real eta = DE_ETA_1``.

2. If the internal energy computed from the total energy is greater than eta * the total energy, use the total internal energy for the operative internal energy ``U``.  Otherwise use the advected dual energy for the operative internal energy ``U``.

3. Return the pressure as ``P = U * (gamma-1.0)``, where ``U`` is the operative internal energy determined in part 2.

Note that ``#ifdef COSMOLOGY`` then in ``global/global.h`` we ``#define DE_ETA_1 10.0``.  This means the advected internal energy is effectively always used?

``Partial_Update_Advected_Internal_Energy_3D()``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This function is defined in ``hydro/hydro_cuda.cu``.  It takes a conserved variable array ``dev_conserved``, the interface states (e.g., ``Q_Lx`` and ``Q_Rx``), and a timestep ``dt``.

1. The cells performing the calculation are limited to the real cells.  The density, inverse of the density, the velocities in each direction, the total energy, gas energy, and kinetic energies are defined from the conserved variables.

2. The pressure is computed using ``Get_Pressure_From_DE()``, which receives the total energy, the gas internal energy computed from the total energy and kinetic energy, the advected gas energy, and gamma.

3. The divergence of the velocity field is computed by retrieving the +/- conserved momenta and densities. The quantity (1/2) * P * (dt/dx * dv + dt/dy * dv + dt/dz*dv) is added to the ``(n_fields -1)`` conserved variable.

``Select_Internal_Energy_3D()``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This function is defined in ``hydro/hydro_cuda.cu``.  It takes the conserved variables as input.

1. It sets ``Real eta_1 = DE_ETA_1`` and It sets ``Real eta_2 = DE_ETA_2``.

2. For real cells, the density, velocity, total energy, internal energy computed from total and kinetic energy, and the advected dual energy are determined.

3. The max ``E_max`` of the total energy in nearby cells are recorded.

4. If the internal energy computed from the total is greater than ``eta_1 * E``, *OR* the total energy is greater than ``eta_2 * E_max``, then the operative internal energy is the internal energy computed from the total.  Otherwise, used the advected dual internal energy as the operative internal energy.

5. The internal energy stored in the advected internal energy field in the conserved quantities is updated to the operative internal energy.

``Sync_Energies_3D()``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This function is defined in ``hydro/hydro_cuda.cu``. It updates the total energy to reflect the kinetic energy + the currently operative internal energy.

1. For real cells, find the density, inverse density, velocities, and the internal energy pulled from the operative internal energy.

2. The total energy is synchronized to reflect the current kinetic energy and whatever internal energy is stored in the advected internal energy field.

