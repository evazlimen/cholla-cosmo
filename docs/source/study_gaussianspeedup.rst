.. _study-gauss-speed:

Gaussian Optical Depth Speedup
=====

.. _email_diego: digarza@ucsc.edu

.. _general:
   General
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

For each skewer output we 1) calculate the local optical depth, 2) calculate the flux power spectrum, and 3) calculate the relative difference against the on-the-fly flux power spectrum, showing the effect of using the following optical depth methods

1. Use the entire line of sight
2. Use cells falling within :math:`3 v_{\textrm{th}}` of cell-centered Hubble flow velocity
3. Use cells falling within :math:`5 v_{\textrm{th}}` of cell-centered Hubble flow velocity
4. Use cells falling within :math:`8 v_{\textrm{th}}` of cell-centered Hubble flow velocity
5. Use cells falling within :math:`10 v_{\textrm{th}}` of cell-centered Hubble flow velocity
6. Use cells falling within :math:`12 v_{\textrm{th}}` of cell-centered Hubble flow velocity

The full results are shown in the lux directory, so I will summarize by plotting the relative difference at some redshifts (6., 5.5, 5., 4.5, 4., 3.5, 3., 2.5, 2., 1.5, 1., 0.95) for each simulation.


Simulation 1 Results -- :math:`512^3` cells & `lya_skewers_stride=16`
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Results





