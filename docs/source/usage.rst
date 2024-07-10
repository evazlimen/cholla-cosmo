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

where the ``-j`` flag specifies to use 20 cores for compilation. 

From this command, there will be a binary file in ``bin``

.. code-block:: console
    [cholla]$ ls bin
    cholla.cosmology.frontier



[in development]



