Usage
=====

.. _installation:

Installation
------------

To use Cholla, first clone the repository

.. code-block:: console

   git clone https://github.com/cholla-hydro/cholla.git

The existing Cholla wiki (https://github.com/cholla-hydro/cholla/wiki) can be used to help set up Cholla.

.. _build-lux:

How to build Cholla on Lux
--------------------------
Log into Cholla
^^^^^^^^^^^^^^^
Use ``ssh`` to log into ``lux.ucsc.edu``:

  ssh [username]@lux.ucsc.edu

Updates
^^^^^^^^^

After cloning Cholla, we will need to update a few things (as of 6/20/2024).

1. In ``cholla/builds/make.type.hydro``, we need to make sure that the spatial reconstruction method is PPMP (not PLMC, which fails on Lux with this version of the code). This is the third flag down. 

We also need to add some setup and host files. These can all be found in the repo for this `website <https://github.com/evazlimen/cholla-cosmo/tree/main/docs/setup_filesl>`_.

2. Add ``setup.lux.sh`` to the cholla/ directory:

.. literalinclude:: ../setup_files/setup.lux.sh
  :language: shell

3. Add ``make_cholla.sh`` to the cholla/ directory:

.. literalinclude:: ../setup_files/make_cholla.sh
  :language: shell

4. Add ``make.host.lux`` to the cholla/builds/ directory:

.. literalinclude:: ../setup_files/make.host.lux
  :language: text

5. In the cholla/ directory, run

``source setup.lux.sh``

``sh make_cholla.sh``

You should now have ``cholla.cosmology.lux`` in cholla/bin/.

An example run can be found in :ref:`cholla-test-run`


How to build Cholla on Frontier
------------------------------

Log into Frontier
^^^^^^^^^^^^^^^^^

Use ``ssh`` to log into `Frontier <https://docs.olcf.ornl.gov/systems/frontier_user_guide.html>`_ :


.. code-block:: console
    
   $ ssh [username]@frontier.olcf.ornl.gov


which will place you in your user home directory ``/css/home/[username]`` using a random login node.


Clone Cholla
^^^^^^^^^^^^

A helpful organization is to create a ``github`` directory in your user home directory to keep track of all repositories cloned.

After cloning Cholla, you have the opportunity to list all remote branches with `git branch <https://git-scm.com/docs/git-branch>`_ :

.. code-block:: console

    [cholla]$ git branch -r

As well as the ability to switch into any of these branches with `git switch <https://git-scm.com/docs/git-switch>`_. To switch to the ``dev`` branch, you can run

.. code-block:: console

    [cholla]$ git switch dev

Note: currently ``non-standard-cosmologies`` has not been merged with ``dev`` yet, so this is a seperate branch itself.


Building Cholla
^^^^^^^^^^^^^^^

To build Cholla on Frontier, we want to load helpful modules and export some required variables as well. This is completed by running the ``setup.frontier.cce.sh`` script that is in the ``cholla/builds`` directory:

.. code-block:: console

    [cholla]$ source builds/setup.frontier.cce.sh

Apart from loading helpful modules, this bash script will set ``MPICH_GPU_SUPPORT_ENABLED`` to True, as well as prepend the `Cray link editor <https://developer.hpe.com/platform/hpe-cray-programming-environment/home/>`_ library path to the default link editor library path. Lastly, this script will also set the read-write user-level cache location of AMD's `rocFFT RunTimeCompiler <https://rocm.docs.amd.com/projects/rocFFT/en/latest/design/runtime_compilation.html#cache-location>`_ to ``/dev/null``.

Next we compile the program with make using the ``TYPE`` flag of cosmology and the ``HOST`` flag of frontier:

.. code-block:: console

    [cholla]$ make HOST=frontier TYPE=cosmology -j 20

where the ``-j`` flag specifies to use 20 cores for compilation. From this command, there will be a binary executable in the ``bin`` directory. The ``HOST`` flag will tell the Makefile to include ``builds/make.host.frontier`` and the ``TYPE`` flag tells the Makefile to include ``builds/make.type.cosmology`` when compiling the program. The ``builds/make.host.frontier`` file will define the compiler as well as helpful compiler flags. It will also provide information regarding the root path to MPI, FFTW, and GOOGLETEST. The ``builds/make.type.cosmology`` file will provide additional macro flags that will specify to the source code to build the program for cosmology.

Cosmology Flags
^^^^^^^^^^^^^^^

**TODO: PROVIDE DESCRIPTION FOR ALL MACRO FLAGS INCLUDED IN MAKE.TYPE.COSMOLOGY**

Running Cholla
^^^^^^^^^^^^^^

The project directory for the cosmological simulations study is saved at ``/lustre/orion/ast206/``. The simulation runs are computed and saved within the project directory in ``/lustre/orion/ast206/proj-shared/runs``. Within this directory, subdirectories should be created with the following naming scheme ``[dims3]_[boxsize]_[uvb-rate]_[descr1]_[descr2]``. With this scheme, ``dims3`` is the number of cells in one dimension, ``boxsize`` is the physical size of one dimension, and ``uvb-rate`` details the UV-background rate, and ``descrX`` is just any extra descriptors of the specific simulation run.

For example, the subdirectory ``2048_50Mpc_v22_dmo`` is a simulation of 2048^3 total cells in which one side is 50 Mpc with a v22 UV-background rate ran on only dark matter.

After creating a directory to hold information for a specific simulation run, we have to prepare some input files in this directory before running a batch script using Slurm.

* **ics**: this is a symbolic link to the initial conditions for the simulation (a set of different initial conditions are currently being held in ``/lustre/orion/ast206/proj-shared-ics/``)
* **param.txt**: this is a `parameter text file <https://github.com/cholla-hydro/cholla/wiki/Input-File-Parameters>`_ that holds the input information required for Cholla to run a simulation box
* **data**: this is a directory to hold the output snapshots
* **scale_outputs.txt**: this is a text file that holds the scale factor at which to save snapshots
* **uvb_rates_V22.txt**: this is an hdf5 file that contains details for the UV-background rate


With these details, we can finally detail the batch script with this template slurm file:

.. literalinclude:: ../setup_files/2048-50Mpc-v22.slurm
  :language: shell


The Slurm directive flags detail:

* ``-J``: the job name
* ``-N``: number of compute nodes requested
* ``-t``: walltime requested
* ``-A``: OLCF project to charge
* ``-o``: standard output file for the job (``%j`` is placeholder for job number)

After setting the location to the Cholla executable and running the frontier setup file, the script exports some helpful macros. The script will set both ``MPICH_ALLTOALL_SYNC_FREQ`` (details `here <https://cpe.ext.hpe.com/docs/mpt/mpich/intro_mpi_ucx.html>`_) and ``MPICH_OFI_CXI_COUNTER_REPORT`` (details `here <https://cpe.ext.hpe.com/docs/mpt/mpich/intro_mpi.html>`_) to 2. It will also set ``OMP_NUM_THREADS`` (details `here <https://www.openmp.org/spec-html/5.0/openmpse50.html>`_) to 7.

Next, the script will redirect the environment variables into a ``job.environ`` file. It will also place the ``SLURM_JOB_NODELIST`` environment variable, listing the name of all host names line-by-line, into a ``job.nodes`` file. The script will also print all shared object dependencies of the Cholla executable into a ``job.exec.ldd`` file.

Finally, the script will call ``srun`` on the Cholla executable and the parameter text file with the following flags

* ``-u``: executable is run with a pseudo terminal such that the output is not buffered
* ``-N``: number of nodes
* ``-n``: total number of MPI tasks
* ``-c``: CPU cores per MPI task
* ``--gpu-bind=closest``: binds each task to GPU on same NUMA domain as MPI rank's CPU core
* ``--gpus-per-task``: number of GPUs to use on each task

The last part of the ``srun`` pipes the executable output and calls ``tee`` which will read from the standard input and write to standard output specified to a file called ``STDOUT``.

The last two commented out lines in the script detail how to start a simulation run from a snapshot (here, snapshot 167).


[in development]



