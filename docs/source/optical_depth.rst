
Optical Depth Calculation
=====

.. _email_diego: digarza@ucsc.edu

.. _general:
General
-----------

The calculation of the optical depth is computed as the interaction cross section multiplied by the physical column number density of neutral hydrogen along the line of sight

.. math::
    \tau_\nu = \int n_{\textrm{HI}} \sigma_\nu \textrm{d}r

The optical depth is calculated along the line of sight of a 'skewer' - a line along the entire cosmological simulation box at a grid cell.


.. _gaussian:
Gaussian Profile
----------
We can follow `Villasenor et al. <https://ui.adsabs.harvard.edu/abs/2021ApJ...912..138V/abstract>`_ and `Lukic et al. <https://ui.adsabs.harvard.edu/abs/2015MNRAS.446.3697L/abstract>`_ in assuming that the Voigt profile is well-approximated by inheriting only the Gaussian core, such that the cross section is

.. math::
   \sigma_\nu = \frac{\pi e^2}{m_e c} f_{12} \frac{1}{\Delta \nu_D}  \frac{1}{\pi^{1/2}} \exp\left(-x^2 \right)

which includes the fundamental electron charge, the oscillator strength, speed of light, and mass of the electron. We assume that the broadening term comes purely from thermal effects, such that

.. math::
    \Delta \nu_D = (v_{\rm{th}} / c) \nu_0

The exponential argument is the line shift from the Lyman alpha line-center.

.. math::
    x = (\nu - \nu_0 ) / \Delta \nu_D

For some gas moving at velocity :math:`u_0`, its doppler shifted Lyman line-center :math:`\nu` from another piece of gas moving at velocity :math:`u` is 

.. math::
   \nu = \nu_0 \left(1 + \frac{u_0 - u}{c} \right)

We apply the comoving units

.. math::
   \textrm{d} r  = a \textrm{d} x = \textrm{d} u / H

so that we find the optical depth as 

.. math::
    \tau_{u_0} = \frac{\pi e^2}{m_e c} f_{12} \frac{\lambda_0}{H} \int  \frac{n_{\textrm{HI}}}{v_{\textrm{th}} \pi^{1/2}}   \exp\left[-\left(\frac{u - u_0}{v_{\textrm{th}}} \right)^2 \right] \textrm{d}u

We set :math:`u_0` as the cell-centered Hubble flow velocity. The contribution from the i-th cell to the optical depth at the j-th cell is

.. math::
   \tau_{j} = \frac{\pi e^2}{m_e c} f_{12} \frac{\lambda_0}{H} \sum_{i} n_{\textrm{HI},i} \int_{u_{i - 1/2}}^{u_{i + 1/2}} \frac{1}{v_{i,\textrm{th}} \pi^{1/2}}   \exp\left[-\left(\frac{u_i - u_j}{v_{i,\textrm{th}}} \right)^2 \right] \textrm{d}u_i

We evaluate this integral analytically using the error function

.. math::
    \tau_j = \frac{\pi e^2 f_{12} \lambda_0}{m_e c H} \sum_i  \frac{n_{\textrm{HI},i}}{2} \left(\textrm{erf}(y_{\textrm{R},i}) - \textrm{erf}(y_{\textrm{L},i})\right)

The error function argument is the contribution difference from the cell interface Hubble flow and the gas velocity. The arguments are

1. Right interface: :math:`y_{\textrm{R},i} = (v_{j,H,R} - (v_{i,H,C} + u_i)) / v_{i,\textrm{th}}`
2. Left interface: :math:`y_{\textrm{L},i} = (v_{j,H,L} - (v_{i,H,C} + u_i)) / v_{i,\textrm{th}}`

The velocity with subscript :math:`H,R` refers to the Hubble flow along the right interface and :math:`H,L` is along the left interface. The velocity :math:`u` refers to the peculiar velocity.


Implementation
^^^^^^^^^^^^^^^

We need three variables for each cell along the line of sight:

1. density of hydrogen
2. line of sight velocity
3. temperature

Once we know the cosmology information and the spacing between cells, the general pseudocode for the optical depth calculation is

.. code-block:: python

    import numpy as np
    from scipy.special import erf
    
    densityHI = # ionized Hydrogen density
    velocity_pec = # line of sight velocity
    temp = # temperature

    n_los = # number of line of sight cells
    dvHubble = # calculate Hubble flow through one cell using cosmology info

    # create Hubble flow arrays along left, right, adn center of each cell
    vHubbleL = np.range(0, n_los) * dvHubble
    vHubbleR = vHubbleL + dvHubble
    vHubbleC = vHubbleL + 0.5 * dvHubble

    nHI = # calculate physical number density
    velocity_phys = # add vHubbleC to velocity_pec to get physical velocity
    doppler_param = # calculate doppler broadening term
    
    sigma_Lya = # create a variable to hold all coefficients

    tau_arr = # array of optical depths

    for losid in range(n_los):
        vH_L, vH_R = vHubbleL[losid], vHubbleR[losid]
        y_L = (vH_L - velocity_phys) / doppler_param
        y_R = (vH_R - velocity_phys) / doppler_param
        tau_arr[losid] = (sigma_Lya) * np.sum(nHI * (erf(y_R) - erf(y_L)) )


Implementation Speed Up
^^^^^^^^^^^^^^^^^^^^^^^

There is something that makes this previous implementation very not efficient. When taking a look at the argument to numpy's summation function, we notice that we multiply ``nHI``, an array of size ``n_los``, with the difference between the error functions. Once we convert the ionized Hydrogen density to a physical column density, the array does not change, and it has actual values throughout most of the array. 

On the other hand, the `error function <https://en.wikipedia.org/wiki/Error_function>`_ is funky. Most of the fun changes actually occurs when :math:`x \sim 0`. When the argument is far from zero (:math:`|x| >> 1`), the output is approximated as :math:`\rm{sgn}(x) * 1` so the error difference for velocities far from :math:`v_{\textrm{th}}` will be approximately zero. The physical interpretation is that the optical depth has most of its contribution occuring from cells with velocities near its thermal velocity. Indeed, most of the time ``nHI`` is being multiplied by an array that only has a handful of non-zero entries, but the code implementation is 1) multiplying two arrays of size ``n_los`` and 2) collapsing the array to one number with summation. Most of the time spent in the calculation of the optical depth is with the multiplication of the two ``n_los`` arrays.

In effect, we complete a small study to discuss the effects of approximating the optical depth by only including cells that are within a couple :math:`v_{\textrm{th}}` units away from the cell-centered Hubble flow. The code is changed as the following


.. code-block:: python

    import numpy as np
    from scipy.special import erf

    densityHI = # ionized Hydrogen density
    velocity_pec = # line of sight velocity
    temp = # temperature

    n_los = # number of line of sight cells
    dvHubble = # calculate Hubble flow through one cell using cosmology info

    num_sigs = # set number of sigma to look around

    # create Hubble flow arrays along left, right, adn center of each cell
    vHubbleL = np.range(0, n_los) * dvHubble
    vHubbleR = vHubbleL + dvHubble
    vHubbleC = vHubbleL + 0.5 * dvHubble

    nHI = # calculate physical number density
    velocity_phys = # add vHubbleC to velocity_pec to get physical velocity
    doppler_param = # calculate doppler broadening term

    sigma_Lya = # create a variable to hold all coefficients

    xsig_dopplerparam = num_sigs * doppler_param # calculate doppler param window
    vHubbleC_xsig_upp = vHubbleC + xsig_dopplerparam
    vHubbleC_xsig_low = vHubbleC - xsig_dopplerparam

    tau_arr = # array of optical depths

    for losid in range(n_los):
        vH_L, vH_R = vHubbleL[losid], vHubbleR[losid]
        vH_C_low, vH_C_upp = vHubbleC_xsig_low[losid], vHubbleC_xsig_upp[losid]
        xsig_mask = (velocity_phys < vH_C_upp) & (velocity_phys > vH_C_low)
        vel_xsig = velocity_phys[xsig_mask]
        doppler_xsig = doppler_param[xsig_mask]
        nHI_xsig = nHI[xsig_mask]
        y_L = (vH_L - vel_xsig) / doppler_xsig
        y_R = (vH_R - vel_xsig) / doppler_xsig
        tau_arr[losid] = (sigma_Lya) * np.sum(nHI_xsig * (erf(y_R) - erf(y_L)) )

In this study, we look at a couple factors:

1. How does the on-the-fly flux power spectrum (from analysis files) compare with the post-simulation flux power spectrum for different number of :math:`v_{\textrm{th}}` units around the mean?
2. How does the mean flux and mean optical depth change for different number of :math:`v_{\textrm{th}}` units around the mean?
3. How does the average calculation time per skewer change for different number of :math:`v_{\textrm{th}}` units around the mean?
4. How does the total calculation time at some snapshot change for different number of :math:`v_{\textrm{th}}` units around the mean?
5. How does the relative difference of the optical depth from using the entire line of sight and using this speedup method change for different number of :math:`v_{\textrm{th}}` units around the mean?



