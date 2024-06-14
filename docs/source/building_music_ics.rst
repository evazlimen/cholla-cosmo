.. _email_brant: brant@ucsc.edu

.. _building_music_ics:

How to build Cholla ICs using MUSIC
=========================

These instructions will provide info on how to
build ``cholla`` cosmological initial conditions
using the ``MUSIC`` code on the ``andes`` system.

.. _bmi_login_to_andes:

Log into Andes or Frontier
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use ``ssh`` to log into ``andes.olcf.ornl.gov``:

  ssh [username]@andes.olcf.ornl.gov


Software installation and packages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following packages are helpful:

``module load cray-hdf``
``module load cray-hdf``

``MUSIC`` requires the ``rpc`` library. The ``andes`` system has the ``tirpc`` implmentation in ``/opt`` but
``frontier`` does not. There is an implementation available via

``wget https://downloads.sourceforge.net/libtirpc/libtirpc-1.3.4.tar.bz2``

You can ``configure`` this library to have a prefix pointed to somewhere in ``$HOME`` and then add the ``include`` and ``lib``
directories to the ``Makefile``.



Request a node
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``salloc -A AST206 -N 1 -t 3:00:00``

Change to the project ics directory
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``cd /lustre/orion/ast206/proj-shared/ics``

``MUSIC`` is in this subdirectory, and there default builds for Andes and Frontier 
nodes in that directory.


Run MUSIC
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here is an example from ``/lustre/orion/ast206/proj-shared/ics/testing/1024-50Mpc``:

``/MUSIC ics_enzo_1024_50Mpc.conf``

Convert the MUSIC ICs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

On frontier I made a python3 virtual environment.  After sourcing the choll frontier build setup file, this is the python3:

``/opt/cray/pe/python/3.9.13.1/bin/python3``

I then just

``python3 -m venv cci``
``source cci/bin/activate``
``python3 -m pip install h5py``

Then to convert the hydro and particle files, one can run:

``python3 generate_ics_from_enzo_raw.py --particles -v --n_points 1024 --n_boxes 8``
``python3 generate_ics_from_enzo_raw.py --hydro -v --n_points 1024 --n_boxes 8``
