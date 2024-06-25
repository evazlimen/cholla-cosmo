Running a test calculation on Lux
=====
After cloning Cholla, we will need to add the updated (as of 6/20/2024) setup and host files. These can all be found in ``cholla-cosmo/docs/setup_files``.

1. Add ``setup.lux.sh`` to the cholla/ directory:

.. literalinclude:: ../setup_files/setup.lux.sh
  :language: shell

2. Add ``make_cholla.sh`` to the cholla/ directory:

.. literalinclude:: ../setup_files/make_cholla.sh
  :language: shell

3. Add ``make.host.lux`` to the cholla/builds/ directory:

.. literalinclude:: ../setup_files/make.host.lux
  :language: text


4. Create a directory outside of cholla/ to run the test calculation in. We'll call this run/

5. In the cholla/ directory, run

``source setup.lux.sh``

``sh make_cholla.sh``

You should now have ``cholla.cosmology.lux`` in cholla/bin/.

In the run/ directory:

6. Add ``run.sh``:

.. literalinclude:: ../setup_files/run.sh
  :language: shell

7. Add parameter_file.txt

.. literalinclude:: ../setup_files/parameter_file.txt
  :language: text



If the path for indir is not working, there is a copy of the input directory in this repo, in ``cholla-cosmo/docs/setup_files/input``

8. Link the executable:
``ln -s /cholla-path/cholla/bin/cholla.cosmology.lux``

9. Run the code
After getting a GPU node on Lux, and ensuring that we are in the run/ directory, we can run the code by using ``./run.sh``

See ``cosmo-cholla/setup_files/gpuq.sh`` for an example of how to get a node on Lux.
