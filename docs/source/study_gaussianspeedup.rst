.. _study-gauss-speed:
Gaussian Optical Depth Speedup
=====

.. _email_diego: digarza@ucsc.edu

.. _Overview:
Overview
-----------

Most of the motivation comes from :ref:`opt-depth`. 

In this study, we look at a couple factors:

1. How does the on-the-fly flux power spectrum (from analysis files) compare with the post-simulation flux power spectrum for different number of :math:`v_{\textrm{th}}` units around the mean?
2. How does the mean flux and mean optical depth change for different number of :math:`v_{\textrm{th}}` units around the mean?
3. How does the average calculation time per skewer change for different number of :math:`v_{\textrm{th}}` units around the mean?
4. How does the total calculation time at some snapshot change for different number of :math:`v_{\textrm{th}}` units around the mean?
5. How does the relative difference of the optical depth from using the entire line of sight and using this speedup method change for different number of :math:`v_{\textrm{th}}` units around the mean?

We are also interested in seeing how these vary with the number of skewers that are used in the calculation -- inputed into the Cholla param file with `n_stride`.

The code to generate this study is found `here <https://github.com/astrodiegog/cholla_lya_scripts/tree/speedup-study>`_.

This study was calculated on lux and the outputs can be found `/data/groups/comp-astro/digarza/optdepth_skewtest`.

To study these effects with respect to resolution and skewer count, we run a total of 6 :math:`L=50 h^{-1} \rm{Mpc}` simulations with the same `Planck 2018 <https://ui.adsabs.harvard.edu/abs/2024arXiv240403002D/abstract>`_ cosmology:

1. :math:`512^3` cells & `lya_skewers_stride=16` :math:`\rightarrow 3072` skewers
2. :math:`512^3` cells & `lya_skewers_stride=8` :math:`\rightarrow 12288` skewers
3. :math:`512^3` cells & `lya_skewers_stride=4` :math:`\rightarrow 49152` skewers
4. :math:`1024^3` cells & `lya_skewers_stride=16` :math:`\rightarrow 12288` skewers
5. :math:`1024^3` cells & `lya_skewers_stride=8` :math:`\rightarrow 49152` skewers
6. :math:`1024^3` cells & `lya_skewers_stride=4` :math:`\rightarrow 196608` skewers

We set skewer outputs at the following redshifts: 10. ,  9.5 ,  9. ,  8.5 ,  8. ,  7.5 ,  7. ,  6.5 ,  6. , 5.5 ,  5. ,  4.5 ,  4. ,  3.5 ,  3. ,  2.5 ,  2. ,  1.5 , 1. ,  0.95,  0.75,  0.5 , 0.25,  0.15, 0.1 , 0.05.


Flux Power Spectrum Results
____________________________

For each skewer output we 1) calculate the local optical depth, 2) calculate the flux power spectrum, and 3) calculate the relative difference against the on-the-fly flux power spectrum, showing the effect of using the following optical depth methods

1. Use the entire line of sight
2. Use cells falling within :math:`3-v_{\textrm{th}}` of cell-centered Hubble flow velocity
3. Use cells falling within :math:`5-v_{\textrm{th}}` of cell-centered Hubble flow velocity
4. Use cells falling within :math:`8-v_{\textrm{th}}` of cell-centered Hubble flow velocity
5. Use cells falling within :math:`10-v_{\textrm{th}}` of cell-centered Hubble flow velocity
6. Use cells falling within :math:`12-v_{\textrm{th}}` of cell-centered Hubble flow velocity

The full results are shown in the lux directory, so I will summarize by plotting the relative difference at some redshifts (6., 5.5, 5., 4.5, 4., 3.5, 3., 2.5, 2., 1.5, 1., 0.95) for each simulation.


Simulation 1 Results -- :math:`512^3` cells & `lya_skewers_stride=16`
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. image:: ../visualizations/gauss_speedup_study/512_nstride16/PowerSpectraDiff_ALL.png

.. image:: ../visualizations/gauss_speedup_study/512_nstride16/PowerSpectraLogDiff_ALL.png



Simulation 2 Results -- :math:`512^3` cells & `lya_skewers_stride=8`
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. image:: ../visualizations/gauss_speedup_study/512_nstride8/PowerSpectraDiff_ALL.png

.. image:: ../visualizations/gauss_speedup_study/512_nstride8/PowerSpectraLogDiff_ALL.png



Simulation 3 Results -- :math:`512^3` cells & `lya_skewers_stride=4`
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. image:: ../visualizations/gauss_speedup_study/512_nstride4/PowerSpectraDiff_ALL.png

.. image:: ../visualizations/gauss_speedup_study/512_nstride4/PowerSpectraLogDiff_ALL.png


Simulation 4 Results -- :math:`1024^3` cells & `lya_skewers_stride=16`
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. image:: ../visualizations/gauss_speedup_study/1024_nstride16/PowerSpectraDiff_ALL.png

.. image:: ../visualizations/gauss_speedup_study/1024_nstride16/PowerSpectraLogDiff_ALL.png


Simulation 5 Results -- :math:`1024^3` cells & `lya_skewers_stride=8`
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. image:: ../visualizations/gauss_speedup_study/1024_nstride8/PowerSpectraDiff_ALL.png

.. image:: ../visualizations/gauss_speedup_study/1024_nstride8/PowerSpectraLogDiff_ALL.png


Simulation 6 Results -- :math:`1024^3` cells & `lya_skewers_stride=4`
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. image:: ../visualizations/gauss_speedup_study/1024_nstride4/PowerSpectraDiff_ALL.png

.. image:: ../visualizations/gauss_speedup_study/1024_nstride4/PowerSpectraLogDiff_ALL.png


Discussion
^^^^^^^^^^^^^

The redshift evolution is more easily shown in the plots with logarithmic scale. The relative difference increases as a function of redshift for all except the entire line of sight -- it actually decreases over time. In general, the flux power spectrum we calculate under predicts until it hits zero around :math:`k \in (10^{-2}, 4\cdot10^{-2}) \textrm{s\ km}^{-1}`. For a set number of :math:`v_{\textrm{th}}`, the k-mode of that turnover is not a strong function of redshift. The k-mode turnover shifts to lower k-modes for higher :math:`v_{\textrm{th}}`.

For all simulations of the same cell number, having more skewers doesn't really decrease the relative difference at some redshift. It does create a smoother relative difference as a function of k-mode.




Mean Flux and Optical Depth Results
-------------------------------

Great ! We've covered Question 1, but what are the flux and optical depth calculations that lead to that flux power spectrum. To answer this, we plot the mean (with 1 standard deviation bands) transmitted flux and the associated optical depth from the mean transmitted flux. Since these plots are specific to the simulation, they are not included in the github repository, but can be found in the lux directory.


Mean Transmitted Flux -- :math:`512^3`
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. image:: ../visualizations/gauss_speedup_study/512_meanF.png


Mean Transmitted Flux -- :math:`1024^3`
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. image:: ../visualizations/gauss_speedup_study/1024_meanF.png


Mean Optical Depth -- :math:`512^3`
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. image:: ../visualizations/gauss_speedup_study/512_meantau.png


Mean Optical Depth -- :math:`1024^3`
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. image:: ../visualizations/gauss_speedup_study/1024_meantau.png









