
Optical Depth Calculation
=====

.. _email_diego: digarza@ucsc.edu

.. _general:
General
-----------

The calculation of the optical depth is computed as the interaction cross section multiplied by the physical column number density of neutral hydrogen along the line of sight

.. math::
    \tau_\nu = \int n_{\textrm{HI}} \sigma_\nu \textrm{d}r


.. _gaussian:
Gaussian Profile
----------
We can follow `Villasenor et al. <https://ui.adsabs.harvard.edu/abs/2021ApJ...912..138V/abstract>`_ and `Lukic et al. <https://ui.adsabs.harvard.edu/abs/2015MNRAS.446.3697L/abstract>`_ in assuming that the Voigt profile is well-approximated by inheriting only the Gaussian core, such that the cross section is

.. math::
   \sigma_\nu = \frac{\pi e^2}{m_e c} f_{12} \frac{1}{\Delta \nu_D}  \frac{1}{\pi^{1/2}} \exp\left(-x^2 \right)

which includes the fundamental electron charge, the oscillator strength, speed of light, and mass of the electron. We assume that the broadening term comes purely from thermal effects, such that

.. math::
    \Delta \nu_D = (v_{\rm{th}} / c) \nu_0

The exponential argument is the line shift from the Lyman alpha line-center.

.. math::
    x = (\nu - \nu_0 ) / \Delta \nu_D

For some gas moving at velocity :math:`u_0`, its doppler shifted Lyman line-center :math:`\nu` from another piece of gas moving at velocity :math:`u` is 

.. math::
   \nu = \nu_0 \left(1 + \frac{u_0 - u}{c} \right)

We apply the comoving units

.. math::
   \textrm{d} r  = a \textrm{d} x = \textrm{d} u / H

so that we find the optical depth as 

.. math::
    \tau_{u_0} = \frac{\pi e^2}{m_e c} f_{12} \frac{\lambda_0}{H} \int  \frac{n_{\textrm{HI}}}{v_{\textrm{th}} \pi^{1/2}}   \exp\left[-\left(\frac{u - u_0}{v_{\textrm{th}}} \right)^2 \right] \textrm{d}u

We set :math:`u_0` as the cell-centered Hubble flow velocity. The contribution from the i-th cell to the optical depth at the j-th cell is

.. math::
   \tau_{j} = \frac{\pi e^2}{m_e c} f_{12} \frac{\lambda_0}{H} \sum_{i} n_{\textrm{HI},i} \int_{u_{i - 1/2}}^{u_{i + 1/2}} \frac{1}{v_{i,\textrm{th}} \pi^{1/2}}   \exp\left[-\left(\frac{u_i - u_j}{v_{i,\textrm{th}}} \right)^2 \right] \textrm{d}u_i

We evaluate this integral analytically using the error function

.. math::
    \tau_j = \frac{\pi e^2 f_{12} \lambda_0}{m_e c H} \sum_i  \frac{n_{\textrm{HI},i}}{2} \left(\textrm{erf}(y_{\textrm{R},i}) - \textrm{erf}(y_{\textrm{L},i})\right)

The error function argument is the contribution difference from the cell interface Hubble flow and the gas velocity. The arguments are

1. Right interface: :math:`y_{\textrm{R},i} = (v_{j,H,R} - (v_{i,H,C} + u_i)) / v_{i,\textrm{th}}`
2. Left interface: :math:`y_{\textrm{L},i} = (v_{j,H,L} - (v_{i,H,C} + u_i)) / v_{i,\textrm{th}}`

The velocity with subscript :math:`H,R` refers to the Hubble flow along the right interface and :math:`H,L` is along the left interface. The velocity :math:`u` refers to the peculiar velocity.



