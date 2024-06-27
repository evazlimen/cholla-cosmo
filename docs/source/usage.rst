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

An example run can be found in :ref:`Cholla-Example-Run`


How to build Cholla on Frontier
------------------------------
Coming soon
