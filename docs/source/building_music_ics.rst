.. _email_brant: brant@ucsc.edu

.. _building_music_ics:

How to build Cholla ICs using MUSIC
=========================

These instructions will provide info on how to
build ``cholla`` cosmological initial conditions
using the ``MUSIC`` code on the ``andes`` system.

.. _bmi_login_to_andes:


What is MUSIC
--------------------------------------------------------------
`MUSIC <https://www-n.oca.eu/ohahn/MUSIC/>`_ is the MUlti Scale Initial Conitions generator



Log into Andes or Frontier
---------------------------------------------------------------

Use ``ssh`` to log into ``andes.olcf.ornl.gov``:

  ssh [username]@andes.olcf.ornl.gov


Software installation and packages
---------------------------------------------------------------

As mentioned in the `wiki <https://github.com/cosmo-sims/MUSIC2/wiki/Installing-MUSIC>`_ for MUSIC, users need to use FFTW, GSL, HDF5, and CMake to build and install the software. The software also requires the ``rpc`` library.


Loading prereqs on Frontier
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The modules we want to load are ``cray-hdf5``, ``cray-fftw``, and ``gsl``. In order to load the HDF5 module, we first need to load ``PrgEnv-cray``. Before loading the FFTW module, we need to load ``craype-x86-trento``. Lastly, to load in the GNU Science Library, we need to load ``Core``.

The setup file ``/lustre/orion/ast206/proj-shared/ics_dg/setup.frontier.cce.sh`` can be ``source``-ed to help in doing the module loading, while also setting GPU-aware MPI.

To load in ``rpc``, an implementation is available that can be downloaded using the ``wget`` command

``wget https://downloads.sourceforge.net/libtirpc/libtirpc-1.3.4.tar.bz2``

We can ``configure`` this library to have a prefix pointed to somewhere in ``$HOME`` and then add the ``include`` and ``lib``
directories to the ``Makefile``.


Loading prereqs on Andes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The modules we want to load are ``hdf5``, ``fftw``, and ``gsl``. We can simply ``module load`` each package individually and be set to go.

The setup file ``/lustre/orion/ast206/proj-shared/ics_dg/setup.andes.cce.sh`` can be ``source``-ed to help in doing the module loading.


Building MUSIC
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now that we have all of the prerequisite software, we can finally build and compile the software. We can clone the `github repository<https://github.com/cosmo-sims/MUSIC2>`_

.. code-block:: console

   $ git clone git@github.com:cosmo-sims/MUSIC2.git
   $ cd MUSIC2

Following the build instructions from the ``README``, we want to create the directory that will house the build and move in there

.. code-block:: console

    [MUSIC2]$ mkdir build
    [MUSIC2]$ cd build

We will use ``CMake`` to build the project, which can be loaded in both andes and frontier with ``module load cmake``. We bring up the program menu with

.. code-block:: console

   [MUSIC2/build]$ ccmake ..

We start the configuration process with the ``c`` input. We currently have an issue compiling which can be fixed by setting ``ENABLE_PANPHASIA`` to ``OFF``. We then generate the appropriate Makefiles with the ``g`` input. Finally, we compile with ``make``

.. code-block:: console

   [MUSIC2/build]$ make -j

where the ``j`` flag says to compile in parallel.



Using MUSIC
---------------------------------------------------------------

Request a node
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To use this software, we first want to request a compute node

.. code-block:: console

    $ salloc -A AST206 -N 1 -t 3:00:00

Change to the project ics directory
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We currently have a directory specifically for building initial conditions

.. code-block:: console
    $ cd /lustre/orion/ast206/proj-shared/ics

We have ``MUSIC.frontier`` subdirectory that holds the compiled program.

The ``MUSIC`` is in this subdirectory, and there default builds for Andes and Frontier 
nodes in that directory.


Run MUSIC
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We have a couple test initial conditions generator in the ``testing`` subdirectory. To create initial conditions for a 50 :math:`h^{-1} \textrm{Mpc}`, 1024 cell box, we can move into that specific testing directory from ``ics`` and run the program on the configuration file

.. code-block:: console
   
   (ics)$ cd testing/1024-50Mpc
   (ics/testing/1024-50Mpc)$ ./MUSIC ics_enzo_1024_50Mpc.conf
 
which will place the initital conditions in a ``raw`` subdirectory.

To read more on how to create and read a configuration file, the details can be found starting on Page 8 of the `MUSIC - User's Manual <https://bitbucket.org/ohahn/music/downloads/MUSIC_Users_Guide.pdf>`_.


Convert the MUSIC ICs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

On ``frontier`` I made a python3 virtual environment.  After sourcing the Cholla frontier build setup file, this is the python3:

``/opt/cray/pe/python/3.9.13.1/bin/python3``

I then just

``python3 -m venv cci``
``source cci/bin/activate``
``python3 -m pip install h5py``

Then to convert the hydro and particle files, one can run:

``python3 generate_ics_from_enzo_raw.py --particles -v --n_points 1024 --n_boxes 8``
``python3 generate_ics_from_enzo_raw.py --hydro -v --n_points 1024 --n_boxes 8``
