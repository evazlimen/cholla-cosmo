.. _cholla-test-run:

Running a test calculation on Lux
=====
Run
-----
For build information, go to :ref:`build-lux`

1. Create a directory outside of cholla/ to run the test calculation in. We'll call this run/

In the run/ directory:

2. Add ``run.sh``:

.. literalinclude:: ../setup_files/run.sh
  :language: shell

3. Add parameter_file.txt

.. literalinclude:: ../setup_files/parameter_file.txt
  :language: text


A full explanation of the required parameters is given `here <https://github.com/cholla-hydro/cholla/wiki/Input-File-Parameters>`_. Additional cosmological parameters can be set if desired. Note that you must add the path to your installation of Cholla for the scale_outputs_file and UVB_rates_file. The scale_outputs_file simply has a list of scale factors at which outputs are written to hdf5 files. For this example, there is a single output when a=1. 


4. Link the executable (still within the /run directory): ``ln -s /path-to-cholla/cholla/bin/cholla.cosmology.lux``

5. Create an output directory, ``data``.

6. Run the code

After getting a GPU node on Lux, and ensuring that we are in the run/ directory, we can run the code by using ``./run.sh``

See ``cosmo-cholla/setup_files/gpuq.sh`` for an example of how to get a node on Lux.

Outputs
------

After the simulation is complete (~ 1 minute), there will be one set of outputs (in run/data/1). In general, a directory will be created inside of the ``run/data`` directory for each output time given in the scale outputs file. Here we find six hdf5 files:

- 1_gravity.h5.0
- 1_gravity.h5.1
- 1.h5.0
- 1.h5.1
- 1_particles.h5.0
- 1_particles.h5.1

As there is one type of output (gravity, hydro, particles) per processor, we need to concatenate each type. This can be done by using the python scripts provided in the main Cholla repo, within ``cholla/python_scripts``. If you have the files concat_3d_data.py, concat_internals.py, and concat_particles.py from ``cholla/python_scripts`` either in your run directory or added to your path, you can run the concatenation with ``sbatch concat_h5.sbatch``.

concat_h5.sbatch is provided below and also included in ``cholla-cosmo/docs/visualizations``.

.. literalinclude:: ../visualizations/concat_h5.sbatch
  :language: sbatch

Note that NUM is set to 1 as there was only one output time, and we set -n 2 as there were two processors.

This will concatentate 1.h5.0 and 1.h5.1 into 1.h5, the complete hydro data file. 1_particles.h5.0 and 1_particles.h5.1 will be concatentated into 1_particles.h5, the complete particle data file. From here, we can visualize the results. An example notebook is provided `here <https://github.com/evazlimen/cholla-cosmo/tree/main/docs/visualizations>`_ and the density projection along the z-axis of the hydro data is shown below.

.. image:: ../visualizations/hydro_density.png
  :width: 400
  :alt: A 2D histogram showing density fluctuations over a 120 by 120 cell square.




