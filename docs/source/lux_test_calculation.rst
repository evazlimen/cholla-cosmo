Running a test calculation on Lux
=====
After cloning cholla, we will need to add the updated (as of 6/20/2024) setup and host files. These can all be found in ``cholla-cosmo/docs/setup_files``.

Add ``setup.lux.sh`` to the cholla/ directory:

.. literalinclude:: ../setup_files/setup.lux.sh
  :language: shell

Add ``make_cholla.sh`` to the cholla/ directory:

.. literalinclude:: ../setup_files/make_cholla.sh
  :language: shell

Add ``make.host.lux`` to the cholla/builds/ directory:

.. literalinclude:: ../setup_files/make.host.lux
  :language: text


Create a directory outside of cholla/ to run the test calculation in. We'll call this run/

In the cholla/ directory, run
``source setup.lux.sh``
``sh make_cholla.sh``

You should now have ``cholla.cosmology.lux`` in cholla/bin/.

In the run/ directory:

Add ``run.sh``:

.. literalinclude:: ../setup_files/run.sh
  :language: shell

Add parameter_file.txt

.. literalinclude:: ../setup_files/parameter_file.txt
  :language: text

We also need to add the directory containing the initial conditions (ics_2_z100) and other inputs (input). (Links to be added)

Link the executable:
``ln -s /cholla-path/cholla/bin/cholla.cosmology.lux``

After getting a GPU node on lux, and ensuring that we are in the run/ directory, we can run the code by using ``./run.sh``

A shell script to get a GPU node will be added shortly
