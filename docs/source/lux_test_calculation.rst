Running a test calculation on Lux
=====
Setup + Compilation
----------

After cloning Cholla, we will need to update a few things (as of 6/20/2024).

1. In ``cholla/builds/make.type.hydro`` we need to make sure that the spatial reconstruction method is PPMP (not PLMC, which fails on Lux with this version of the code). This is the third flag down. 

We also need to add some setup and host files. These can all be found in ``cholla-cosmo/docs/setup_files``.

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

6. Create a directory outside of cholla/ to run the test calculation in. We'll call this run/

In the run/ directory:

7. Add ``run.sh``:

.. literalinclude:: ../setup_files/run.sh
  :language: shell

8. Add parameter_file.txt

.. literalinclude:: ../setup_files/parameter_file.txt
  :language: text


If the path for scale_outputs_file and UVB_rates_file is not working, there is a copy of the input directory in which these files are located in this repo, in ``cholla-cosmo/docs/setup_files/input``.

9. Link the executable (still within the /run directory): ``ln -s /path-to-cholla/cholla/bin/cholla.cosmology.lux``

10. Create an output directory, ``data``.

11. Run the code

After getting a GPU node on Lux, and ensuring that we are in the run/ directory, we can run the code by using ``./run.sh``

See ``cosmo-cholla/setup_files/gpuq.sh`` for an example of how to get a node on Lux.

Outputs
------
