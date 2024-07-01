.. _cosmo-chem-debugging-notes:

Debugging notes from cosmology+chemistry
=====


###############################################################
# 
# chemistry_gpu.h -- nothing important
#
###############################################################

###############################################################
# 
# chemistry_functions.cpp
#
###############################################################

************************************************************************************************
COUCHED WITHIN DE, SO UNLIKELY TO BE THE ISSUE -- these are identical using GasEnergy with DE def'd.

>   #ifdef DE
256,259c260,266
<         #else
<         GE = (dev_conserved[4*n_cells + id] - 0.5*d*(vx*vx + vy*vy + vz*vz));
<         #endif
<
---
>   #else
>         GE = E - hydro_utilities::Calc_Kinetic_Energy_From_Velocity(d, vx, vy, vz);
>     #ifdef MHD
>         GE -= mhd::utils::computeMagneticEnergy(C.magnetic_x[id], C.magnetic_y[id], C.magnetic_z[id]);
>     #endif  // MHD
>   #endif
>

************************************************************************************************

CONVERT_COSMO_UNITS SET THE SAME WAY, so unlikely to be the ISSUE
264c271
<         cell_n =  dens_HI + dens_HII + ( dens_HeI + dens_HeII + dens_HeIII )/4 + dens_e;
<         mu = cell_dens / cell_n;
<
<         #ifdef COSMOLOGY
<         if ( convert_cosmo_units ){
---
>         cell_n    = dens_HI + dens_HII + (dens_HeI + dens_HeII + dens_HeIII) / 4 + dens_e;
>         mu        = cell_dens / cell_n;
>
>   #ifdef COSMOLOGY
>         if (convert_cosmo_units) {
274,275c281,282
<           a2 = current_a * current_a;
<           GE *= Chem.H.energy_conversion / a2;
---
>           a2        = current_a * current_a;
>           GE *= Chem.H.energy_conversion / a2;
277c284
<           GE *= 1e10; // convert from (km/s)^2 to (cm/s)^2
---
>           GE *= 1e10;  // convert from (km/s)^2 to (cm/s)^2
279,281c286,289
<         #endif
<
<         temp = GE * MP  * mu / d / KB * (gamma - 1.0);  ;
---
>   #endif
>
>         temp = GE * MP * mu / d / KB * (gamma - 1.0);
>         ;
284,285c292,293
<         // if ( temp > 1e7 ) chprintf( "Temperature: %e   mu: %e \n", temp, mu );
<
---
>         // if ( temp > 1e7 ) chprintf( "Temperature: %e   mu: %e \n", temp, mu
>         // );
287,289c295,296
<     }
<   }
<
---
>     }
>   }



###############################################################
# 
# chemistry_functions_gpu.cpp
#
###############################################################

GRID ENUM is the only possible issue

464,471c481,496
<     current_a = 1 / ( current_z + 1);
<     a2 = current_a * current_a;
<     a3 = a2 * current_a;
<     d  *= density_conv / a3;
<     GE *= energy_conv  / a2;
<     dt_hydro = dt_hydro * current_a * current_a / Chem_H.H0 * 1000 * KPC / Chem_H.time_units;
<     // delta_a = Chem_H.H0 * sqrt( Chem_H.Omega_M/current_a + Chem_H.Omega_L*pow(current_a, 2) ) / ( 1000 * KPC ) * dt_hydro * Chem_H.time_units;
<
---
>     current_a = 1 / (current_z + 1);
>     a2        = current_a * current_a;
>     a3        = a2 * current_a;
>     d *= density_conv / a3;
>     GE *= energy_conv / a2;
>     dt_hydro = dt_hydro / Chem_H.time_units;
>
>   #ifdef COSMOLOGY
>     dt_hydro *= current_a * current_a / Chem_H.H0 * 1000 * KPC;
>   #endif  // COSMOLOGY
>     // dt_hydro = dt_hydro * current_a * current_a / Chem_H.H0 *
>     // 1000 * KPC / Chem_H.time_units;
>     //  delta_a = Chem_H.H0 * sqrt( Chem_H.Omega_M/current_a +
>     //  Chem_H.Omega_L*pow(current_a, 2) ) / ( 1000 * KPC ) *
>     //  dt_hydro * Chem_H.time_units;


561,583c583,604
<     dev_conserved[ 5*n_cells + id] = TS.d_HI    * a3;
<     dev_conserved[ 6*n_cells + id] = TS.d_HII   * a3;
<     dev_conserved[ 7*n_cells + id] = TS.d_HeI   * a3;
<     dev_conserved[ 8*n_cells + id] = TS.d_HeII  * a3;
<     dev_conserved[ 9*n_cells + id] = TS.d_HeIII * a3;
<     dev_conserved[10*n_cells + id] = TS.d_e     * a3;
<     d = d / density_conv * a3;
<     GE = TS.U / d_inv / energy_conv * a2 / 1e-10;
<     dev_conserved[4*n_cells + id]  = GE + E_kin;
<     #ifdef DE
<     dev_conserved[(n_fields-1)*n_cells + id] = GE;
<     #endif
<
<     if ( print ) printf("###########################################\n" );
<     if ( print ) printf("Updated HI:  %e\n",    TS.d_HI    * a3  );
<     if ( print ) printf("Updated HII:  %e\n",   TS.d_HII   * a3  );
<     if ( print ) printf("Updated HeI:  %e\n",   TS.d_HeI   * a3  );
<     if ( print ) printf("Updated HeII:  %e\n",  TS.d_HeII  * a3  );
<     if ( print ) printf("Updated HeIII:  %e\n", TS.d_HeIII * a3  );
<     if ( print ) printf("Updated e:  %e\n",     TS.d_e     * a3  );
<     if ( print ) printf("Updated GE:  %e\n", dev_conserved[(n_fields-1)*n_cells + id]  );
<     if ( print ) printf("Updated E:   %e\n", dev_conserved[4*n_cells + id]  );
<
---
>     dev_conserved[id + n_cells * grid_enum::HI_density]    = TS.d_HI * a3;
>     dev_conserved[id + n_cells * grid_enum::HII_density]   = TS.d_HII * a3;
>     dev_conserved[id + n_cells * grid_enum::HeI_density]   = TS.d_HeI * a3;
>     dev_conserved[id + n_cells * grid_enum::HeII_density]  = TS.d_HeII * a3;
>     dev_conserved[id + n_cells * grid_enum::HeIII_density] = TS.d_HeIII * a3;
>     dev_conserved[id + n_cells * grid_enum::e_density]     = TS.d_e * a3;
>     d                                                      = d / density_conv * a3;
>     GE                                                     = TS.U / d_inv / energy_conv * a2 / 1e-10;
>     dev_conserved[4 * n_cells + id]                        = GE + E_kin;
>   #ifdef DE
>     dev_conserved[(n_fields - 1) * n_cells + id] = GE;
>   #endif



###############################################################
# 
# chemistry_io.cpp -- nothing important
#
###############################################################









Nothing in chemistry that makes a lot of sense as the culprit.


###############################################################
# 
# cosmology_functions.cpp
#
###############################################################









grid/initial_conditions has a test that might be useful.

j




Interesting comparison




Bruno:

n_step: 83   sim time: 12.2414972   sim timestep: 1.2002e-01  timestep time =   874.872 ms   total time =   88.1571 s

 Density  Mean: 0.159767   Min: 0.079963   Max: 0.385387      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.923938   Min: 0.000000   Max: 6.161793      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.965213   Min: 0.000000   Max: 7.295122      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.874374   Min: 0.000000   Max: 6.374808      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 11.894825   Min: 0.002863   Max: 111.566389      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 GasEnergy  Mean: 0.005467   Min: 0.002096   Max: 0.092323      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 Temperature  Mean: 2.750058   Min: 1.673956   Max: 20.017001      [ K ]
Current_z: 43.372461
 Delta_a_particles: 0.001499      Delta_a_gas: 0.001502
 Seting max delta_a: 0.000225
 Current_a: 0.022537    delta_a: 0.000225     dt:  0.119427
 t_physical: 42.228643 Myr   dt_physical: 0.877266 Myr

n_step: 83   sim time: 12.2719781   sim timestep: 1.2032e-01  timestep time =  1376.525 ms   total time =  218.1401 s
  Density  Mean: 0.159767   Min: 0.079970   Max: 0.386192      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.925534   Min: 0.000000   Max: 6.169384      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.966881   Min: 0.000000   Max: 7.298758      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.875884   Min: 0.000000   Max: 6.368227      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 11.939104   Min: 0.006149   Max: 111.336936      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 GasEnergy  Mean: 0.008722   Min: 0.004133   Max: 0.021554      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 Temperature  Mean: 4.408620   Min: 4.005670   Max: 4.891110      [ K ]
Current_z: 43.372461
 Delta_a_particles: 0.001579      Delta_a_gas: 0.001496
 Seting max delta_a: 0.000225
 Current_a: 0.022537    delta_a: 0.000225     dt:  0.119725
 t_physical: 59.364218 Myr   dt_physical: 0.879456 Myr

 Density and momenta and energy are pretty comparable, but GasEnergy and Tempearture are not

dev branch:


 dust/dust_cuda.cu:  #else  // DE is not enabled
io/io.cpp:  #else  // DE is not defined
io/io.cpp:  #else  // DE is not defined
io/io.cpp:  #else  // DE is not defined
reconstruction/reconstruction_internals.h:#ifdef DE  // DE
reconstruction/ppmp_cuda.cu:  #ifdef DE  // PRESSURE_DE
reconstruction/ppmp_cuda.cu:  #ifdef DE  // PRESSURE_DE
reconstruction/ppmp_cuda.cu:  #ifdef DE  // PRESSURE_DE
reconstruction/ppmp_cuda.cu:  #ifdef DE  // PRESSURE_DE
reconstruction/ppmp_cuda.cu:  #ifdef DE  // PRESSURE_DE
reconstruction/ppmp_cuda.cu:  #ifdef DE  // PRESSURE_DE
reconstruction/ppmc_cuda.cu:#ifdef DE  // PRESSURE_DE
reconstruction/plm_cuda.cu:#ifdef DE  // PRESSURE_DE
reconstruction/ppmc_cuda_tests.cu:  /// This test doesn't support Dual Energy. It wouldn't be that hard to add support for DE but the DE parts of the
riemann_solvers/hlld_cuda.cu:#ifdef DE  // PRESSURE_DE
riemann_solvers/exact_cuda.cu:#ifdef DE  // PRESSURE_DE
riemann_solvers/exact_cuda.cu:#ifdef DE  // PRESSURE_DE
riemann_solvers/hllc_cuda.cu:#ifdef DE  // PRESSURE_DE
riemann_solvers/hllc_cuda.cu:#ifdef DE  // PRESSURE_DE
riemann_solvers/hll_cuda.cu:#ifdef DE  // PRESSURE_DE
riemann_solvers/hll_cuda.cu:#ifdef DE  // PRESSURE_DE
riemann_solvers/roe_cuda.cu:#ifdef DE  // PRESSURE_DE
riemann_solvers/roe_cuda.cu:#ifdef DE  // PRESSURE_DE
utils/hydro_utilities_tests.cpp:#endif  // DE and COSMOLOGY
utils/hydro_utilities.h: * \brief Compute the temperature when DE is turned on
utils/hydro_utilities.h:#ifdef DE  // DE
hydro_cuda.cu:#ifdef DE
hydro_cuda.cu:#ifdef DE
hydro_cuda.cu:#ifdef DENSITY_FLOOR
hydro_cuda.cu:#ifdef DE
hydro_cuda.cu:#ifdef DENSITY_FLOOR
hydro_cuda.cu:  #ifdef DE
hydro_cuda.cu:#endif  // DENSITY_FLOOR
hydro_cuda.cu:#if !(defined(DENSITY_FLOOR) && defined(TEMPERATURE_FLOOR))
hydro_cuda.cu:#endif  // DENSITY_FLOOR
hydro_cuda.cu:#ifdef DE
hydro_cuda.cu:#endif  // DE
hydro_cuda.cu:      temp   = (gamma - 1) * (E - 0.5 * (speed * speed) * d) * ENERGY_UNIT / (d * DENSITY_UNIT / 0.6 / MP) / KB;
hydro_cuda.cu:          x, y, z, 1. / max_dti, 1. / max_dti_slow, dev_conserved[id] * DENSITY_UNIT / 0.6 / MP, temp,
hydro_cuda.cu:#ifdef DE
hydro_cuda.cu:    // PRESSURE_DE
hydro_cuda.cu:    P     = hydro_utilities::Get_Pressure_From_DE(E, E - E_kin, GE, gamma);
hydro_cuda.cu:    // PRESSURE_DE
hydro_cuda.cu:    P     = hydro_utilities::Get_Pressure_From_DE(E, E - E_kin, GE, gamma);
hydro_cuda.cu:    // PRESSURE_DE
hydro_cuda.cu:    P = hydro_utilities::Get_Pressure_From_DE(E, E - E_kin, GE, gamma);
hydro_cuda.cu:  Real eta_1 = DE_ETA_1;
hydro_cuda.cu:  Real eta_2 = DE_ETA_2;
hydro_cuda.cu:  Real eta_1 = DE_ETA_1;
hydro_cuda.cu:  Real eta_2 = DE_ETA_2;
hydro_cuda.cu:  Real eta_1 = DE_ETA_1;
hydro_cuda.cu:  Real eta_2 = DE_ETA_2;
hydro_cuda.cu:#endif  // DE
hydro_cuda.cu:#ifdef DE
hydro_cuda.cu:#ifdef DE

Macro Flags     = -DMPI_CHOLLA -DPRECISION=2 -DPPMP -DHLLC -DSIMPLE -DDENSITY_FLOOR -DTEMPERATURE_FLOOR -DOUTPUT -DHDF5  -DGRAVITY -DPARIS -DGRAVITY_GPU -DGR
AVITY_5_POINTS_GRADIENT -DPARALLEL_OMP -DN_OMP_THREADS=10 -DPARIS_NO_GPU_MPI -DPARTICLES -DPARTICLES_GPU -DPARTICLE_IDS -DSINGLE_PARTICLE_MASS -DPARALLEL_OMP
 -DN_OMP_THREADS=10 -DCOSMOLOGY -DCHEMISTRY_GPU -DOUTPUT_TEMPERATURE -DOUTPUT_CHEMISTRY -DAVERAGE_SLOW_CELLS -DDE -DPRINT_INITIAL_STATS -DN_OUTPUT_COMPLETE=1
 -DPARIS_5PT -DSCALAR -DGIT_HASH=8a35d5e8bd4a3d434dda4970822643fe8c521500

bruno's

reconstruction/ppmp_cuda.cu:#ifdef DE //PRESSURE_DE
reconstruction/ppmp_cuda.cu:    #ifdef DE //PRESSURE_DE
reconstruction/ppmp_cuda.cu:    #ifdef DE //PRESSURE_DE
reconstruction/ppmp_cuda.cu:    #ifdef DE //PRESSURE_DE
reconstruction/ppmp_cuda.cu:    #ifdef DE //PRESSURE_DE
reconstruction/ppmp_cuda.cu:    #ifdef DE //PRESSURE_DE
reconstruction/plmc_cuda.cu:#ifdef DE //PRESSURE_DE
reconstruction/plmc_cuda.cu:    #ifdef DE //PRESSURE_DE
reconstruction/plmc_cuda.cu:    #ifdef DE //PRESSURE_DE
reconstruction/plmc_cuda.cu:    #ifdef DE //PRESSURE_DE
reconstruction/ppmc_cuda.cu:#ifdef DE //PRESSURE_DE
reconstruction/ppmc_cuda.cu:    #ifdef DE //PRESSURE_DE
reconstruction/ppmc_cuda.cu:    #ifdef DE //PRESSURE_DE
reconstruction/ppmc_cuda.cu:    #ifdef DE //PRESSURE_DE
reconstruction/ppmc_cuda.cu:    #ifdef DE //PRESSURE_DE
reconstruction/ppmc_cuda.cu:    #ifdef DE //PRESSURE_DE
reconstruction/plmp_cuda.cu:#ifdef DE //PRESSURE_DE
reconstruction/plmp_cuda.cu:    #ifdef DE //PRESSURE_DE
reconstruction/plmp_cuda.cu:    #ifdef DE //PRESSURE_DE
reconstruction/plmp_cuda.cu:    #ifdef DE //PRESSURE_DE
riemann_solvers/hlld_cuda.cu:#ifdef DE //PRESSURE_DE
riemann_solvers/hlld_cuda.cu:            #ifdef DE //PRESSURE_DE
riemann_solvers/hlld_cuda.cu:            #ifdef DE //PRESSURE_DE
riemann_solvers/exact_cuda.cu:#ifdef DE //PRESSURE_DE
riemann_solvers/exact_cuda.cu:    #ifdef DE //PRESSURE_DE
riemann_solvers/exact_cuda.cu:    #ifdef DE //PRESSURE_DE
riemann_solvers/hllc_cuda.cu:#ifdef DE //PRESSURE_DE
riemann_solvers/hllc_cuda.cu:    #ifdef DE //PRESSURE_DE
riemann_solvers/hllc_cuda.cu:    #ifdef DE //PRESSURE_DE
riemann_solvers/hll_cuda.cu:#ifdef DE //PRESSURE_DE
riemann_solvers/hll_cuda.cu:    #ifdef DE //PRESSURE_DE
riemann_solvers/hll_cuda.cu:    #ifdef DE //PRESSURE_DE
riemann_solvers/roe_cuda.cu:#ifdef DE //PRESSURE_DE
riemann_solvers/roe_cuda.cu:    #ifdef DE //PRESSURE_DE
riemann_solvers/roe_cuda.cu:    #ifdef DE //PRESSURE_DE
[brant@lux-1 hydro]$ grep DE *
hydro_cuda.cu:    #ifdef DE
hydro_cuda.cu:    #ifdef DE
hydro_cuda.cu:  #ifdef DENSITY_FLOOR
hydro_cuda.cu:  #ifdef COUPLE_DELTA_E_KINETIC
hydro_cuda.cu:  #endif//COUPLE_DELTA_E_KINETIC
hydro_cuda.cu:    #ifdef DE
hydro_cuda.cu:    #ifdef DENSITY_FLOOR
hydro_cuda.cu:        #ifdef DE
hydro_cuda.cu:    #endif//DENSITY_FLOOR
hydro_cuda.cu:    #ifdef COUPLE_DELTA_E_KINETIC
hydro_cuda.cu:    #ifdef COUPLE_DELTA_E_KINETIC
hydro_cuda.cu:    #if !( defined(DENSITY_FLOOR) && defined(TEMPERATURE_FLOOR) )
hydro_cuda.cu:    #endif//DENSITY_FLOOR
hydro_cuda.cu:#ifdef DE
hydro_cuda.cu:    //PRESSURE_DE
hydro_cuda.cu:    P = hydro_utilities::Get_Pressure_From_DE( E, E - E_kin, GE, gamma );
hydro_cuda.cu:    //PRESSURE_DE
hydro_cuda.cu:    P = hydro_utilities::Get_Pressure_From_DE( E, E - E_kin, GE, gamma );
hydro_cuda.cu:    //PRESSURE_DE
hydro_cuda.cu:    P = hydro_utilities::Get_Pressure_From_DE( E, E - E_kin, GE, gamma );
hydro_cuda.cu:  Real eta_2 = DE_ETA_2;
hydro_cuda.cu:  Real eta_2 = DE_ETA_2;
hydro_cuda.cu:  Real eta_2 = DE_ETA_2;
hydro_cuda.cu:#endif //DE
hydro_cuda.cu:    #ifdef DE
hydro_cuda.cu:  #ifdef DE
hydro_cuda.cu:  #endif  //DE



Git Commit Hash = 640cd4e946d6e2eb3f4a57a83b51f68c0fc9f31e
Macro Flags     = -DCUDA -DMPI_CHOLLA -DPRECISION=2 -DPPMP -DHLLC -DSIMPLE -DDENSITY_FLOOR -DTEMPERATURE_FLOOR -DDE -D
CPU_TIME -DOUTPUT -DHDF5  -DPARALLEL_OMP -DN_OMP_THREADS=10 -DGRAVITY -DPARIS -DGRAVITY_GPU -DGRAVITY_5_POINTS_GRADIEN
T -DPARALLEL_OMP -DPARIS_NO_GPU_MPI -DPARTICLES -DPARTICLES_GPU -DSINGLE_PARTICLE_MASS -DPARALLEL_OMP -DN_OMP_THREADS=
10 -DCOSMOLOGY -DCHEMISTRY_GPU -DOUTPUT_TEMPERATURE -DOUTPUT_CHEMISTRY  -DAVERAGE_SLOW_CELLS -DPRINT_INITIAL_STATS -DN
_OUTPUT_COMPLETE=1 -DPARIS_5PT -DSCALAR -DGIT_HASH=640cd4e946d6e2eb3f4a57a83b51f68c0fc9f31e
Parameter values:  nx = 512, ny = 512, nz = 512, tout = 1000.000000, init = Read_Grid, boundaries = 1 1 1 1 1 1



STATUS -- likely something up internal energy and DE.  This occurs before redshift ~50.




BIG Change at z~70 when the simulation snapshot is written.

Here's before and after for testing code:

BEFORE
n_step: 70   sim time: 10.7038053   sim timestep: 1.2815e-01  timestep time =  1596.583 ms   total time =  192.0996 s

 Density  Mean: 0.159767   Min: 0.106751   Max: 0.269811      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.321635   Min: 0.000000   Max: 1.650737      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.335955   Min: 0.000000   Max: 2.074174      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.304391   Min: 0.000000   Max: 1.641198      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 1.444899   Min: 0.003617   Max: 12.174517      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 GasEnergy  Mean: 0.004488   Min: 0.002999   Max: 0.007580      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 Temperature  Mean: 2.268873   Min: 2.268873   Max: 2.268873      [ K ]
Current_z: 49.329801
 Delta_a_particles: 0.001587      Delta_a_gas: 0.001496

 AFTER
 n_step: 71   sim time: 10.7878395   sim timestep: 8.4034e-02  timestep time =  1366.216 ms   total time =  193.4663 s


Saving Snapshot: 1
 Writing all data ( Restart File ).
 Converting to Cosmological Physical System
 Total Particles: 134217728
 Saved Snapshot: 1     z:49.000000   next_output: 16.000000
 Converting to Cosmological Comoving System

 Density  Mean: 0.159767   Min: 0.079970   Max: 0.386192      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.925534   Min: 0.000000   Max: 6.169384      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.966881   Min: 0.000000   Max: 7.298758      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.875884   Min: 0.000000   Max: 6.368227      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 11.939104   Min: 0.006149   Max: 111.336936      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 GasEnergy  Mean: 0.008722   Min: 0.004133   Max: 0.021554      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 Temperature  Mean: 4.408620   Min: 4.005670   Max: 4.891110      [ K ]
Current_z: 49.000000
 Delta_a_particles: 0.001587      Delta_a_gas: 0.001496


 NOW IN BRUNO's:


BEFORE
 n_step: 70   sim time: 10.6771573   sim timestep: 1.2783e-01  timestep time =   877.991 ms   total time =   68.9288 s

 Density  Mean: 0.159767   Min: 0.106751   Max: 0.269811      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.321635   Min: 0.000000   Max: 1.650737      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.335955   Min: 0.000000   Max: 2.074174      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.304391   Min: 0.000000   Max: 1.641198      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 1.444899   Min: 0.003617   Max: 12.174517      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 GasEnergy  Mean: 0.004488   Min: 0.002999   Max: 0.007580      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 Temperature  Mean: 2.268873   Min: 2.268873   Max: 2.268873      [ K ]
Current_z: 49.329801
 Delta_a_particles: 0.001497      Delta_a_gas: 0.001501

AFTER 
Saving Snapshot: 1
 Writing all data ( Restart File ).
 Converting to Cosmological Physical System
 Total Particles: 134217728
 Saved Snapshot: 1     z:49.000000   next_output: 16.000000
 Converting to Cosmological Comoving System

 Density  Mean: 0.159767   Min: 0.079963   Max: 0.385387      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.923938   Min: 0.000000   Max: 6.161793      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.965213   Min: 0.000000   Max: 7.295122      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.874374   Min: 0.000000   Max: 6.374808      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 11.894825   Min: 0.002863   Max: 111.566389      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 GasEnergy  Mean: 0.005467   Min: 0.002096   Max: 0.092323      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 Temperature  Mean: 2.750058   Min: 1.673956   Max: 20.017001      [ K ]
Current_z: 49.000000
 Delta_a_particles: 0.001497      Delta_a_gas: 0.001501


 DOES CHANGING THE OUTPUT TIME CHANGE THE DIFFERENCES?  PROBABLY -- DE SYNCH ISSUE AFTER SNAPSHOT WRITTEN?


 OK, shifting first snapshot to earlier

 TESTING:
 BEFORE:
 n_step: 29   sim time:  4.8900927   sim timestep: 1.5714e-01  timestep time =  2808.469 ms   total time =  106.4887 s

 Density  Mean: 0.159767   Min: 0.106751   Max: 0.269811      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.321635   Min: 0.000000   Max: 1.650737      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.335955   Min: 0.000000   Max: 2.074174      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.304391   Min: 0.000000   Max: 1.641198      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 1.444899   Min: 0.003617   Max: 12.174517      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 GasEnergy  Mean: 0.004488   Min: 0.002999   Max: 0.007580      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 Temperature  Mean: 2.268873   Min: 2.268873   Max: 2.268873      [ K ]
Current_z: 74.683558
 Delta_a_particles: 0.001622      Delta_a_gas: 0.001484
 AFTER:
 n_step: 30   sim time:  5.0325716   sim timestep: 1.4248e-01  timestep time =  2593.912 ms   total time =  109.0833 s


Saving Snapshot: 1
 Writing all data ( Restart File ).
 Converting to Cosmological Physical System
 Total Particles: 134217728
 Saved Snapshot: 1     z:74.000000   next_output: 49.000000
 Converting to Cosmological Comoving System

 Density  Mean: 0.159767   Min: 0.095696   Max: 0.307161      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.503168   Min: 0.000000   Max: 2.801103      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.525597   Min: 0.000000   Max: 3.503315      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.476185   Min: 0.000000   Max: 2.778188      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 3.530452   Min: 0.004383   Max: 29.558408      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 GasEnergy  Mean: 0.005786   Min: 0.003219   Max: 0.011870      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 Temperature  Mean: 2.924785   Min: 2.662808   Max: 3.253750      [ K ]
Current_z: 74.000000
 Delta_a_particles: 0.001621      Delta_a_gas: 0.001484



 BRUNO:
 BEFORE:
 n_step: 29   sim time:  4.8779183   sim timestep: 1.5675e-01  timestep time =   857.425 ms   total time =   33.9049 s

 Density  Mean: 0.159767   Min: 0.106751   Max: 0.269811      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.321635   Min: 0.000000   Max: 1.650737      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.335955   Min: 0.000000   Max: 2.074174      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.304391   Min: 0.000000   Max: 1.641198      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 1.444899   Min: 0.003617   Max: 12.174517      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 GasEnergy  Mean: 0.004488   Min: 0.002999   Max: 0.007580      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 Temperature  Mean: 2.268873   Min: 2.268873   Max: 2.268873      [ K ]
Current_z: 74.683558
 Delta_a_particles: 0.001490      Delta_a_gas: 0.001485

 AFTER:
 n_step: 30   sim time:  5.0200738   sim timestep: 1.4216e-01  timestep time =   856.862 ms   total time =   34.7618 s


Saving Snapshot: 1
 Writing all data ( Restart File ).
 Converting to Cosmological Physical System
 Total Particles: 134217728
 Saved Snapshot: 1     z:74.000000   next_output: 49.000000
 Converting to Cosmological Comoving System

 Density  Mean: 0.159767   Min: 0.095700   Max: 0.307162      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.502707   Min: 0.000000   Max: 2.802146      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.525116   Min: 0.000000   Max: 3.503654      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.475749   Min: 0.000000   Max: 2.777006      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 3.523644   Min: 0.003919   Max: 29.537053      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 GasEnergy  Mean: 0.005418   Min: 0.002834   Max: 0.017140      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 Temperature  Mean: 2.736481   Min: 2.147386   Max: 5.754899      [ K ]
Current_z: 74.000000
 Delta_a_particles: 0.001490      Delta_a_gas: 0.001486



 CONVERTIING SYSTEMS CHANGES SIMULATION -- WHY?  DE ISSUE?  Maybe turn off DE and check if this persists?
 YES, it persists (with different values)

 IN TESTING:

 BEFORE:
 n_step: 29   sim time:  4.8900927   sim timestep: 1.5714e-01  timestep time =  2770.115 ms   total time =  104.6699 s

 Density  Mean: 0.159767   Min: 0.106751   Max: 0.269811      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.321635   Min: 0.000000   Max: 1.650737      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.335955   Min: 0.000000   Max: 2.074174      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.304391   Min: 0.000000   Max: 1.641198      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 1.444899   Min: 0.003617   Max: 12.174517      [ h^2 Msun kpc^-3 km^2 s^-2 ]
Current_z: 74.683558
 Delta_a_particles: 0.001622      Delta_a_gas: 0.001483
AFTER:
n_step: 30   sim time:  5.0325716   sim timestep: 1.4248e-01  timestep time =  2545.367 ms   total time =  107.2164 s


Saving Snapshot: 1
 Writing all data ( Restart File ).
 Converting to Cosmological Physical System
 Total Particles: 134217728
 Saved Snapshot: 1     z:74.000000   next_output: 49.000000
 Converting to Cosmological Comoving System

 Density  Mean: 0.159767   Min: 0.095699   Max: 0.307128      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.503167   Min: 0.000000   Max: 2.800991      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.525597   Min: 0.000000   Max: 3.502224      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.476185   Min: 0.000000   Max: 2.777179      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 3.530449   Min: 0.004393   Max: 29.558284      [ h^2 Msun kpc^-3 km^2 s^-2 ]
Current_z: 74.000000
 Delta_a_particles: 0.001621      Delta_a_gas: 0.001484


 PERSISTS IN BRUNOs:
 BEFORE:
 n_step: 29   sim time:  4.8779183   sim timestep: 1.5675e-01  timestep time =  1088.953 ms   total time =   37.2233 s

 Density  Mean: 0.159767   Min: 0.106751   Max: 0.269811      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.321635   Min: 0.000000   Max: 1.650737      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.335955   Min: 0.000000   Max: 2.074174      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.304391   Min: 0.000000   Max: 1.641198      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 1.444899   Min: 0.003617   Max: 12.174517      [ h^2 Msun kpc^-3 km^2 s^-2 ]
Current_z: 74.683558
 Delta_a_particles: 0.001490      Delta_a_gas: 0.001502
 Seting max delta_a: 0.000132
 Current_a: 0.013213    delta_a: 0.000120     dt:  0.142156
 AFTER:
 n_step: 30   sim time:  5.0200738   sim timestep: 1.4216e-01  timestep time =  1111.107 ms   total time =   38.3347 s


Saving Snapshot: 1
 Writing all data ( Restart File ).
 Converting to Cosmological Physical System
 Total Particles: 134217728
 Saved Snapshot: 1     z:74.000000   next_output: 49.000000
 Converting to Cosmological Comoving System

 Density  Mean: 0.159767   Min: 0.095700   Max: 0.307164      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.502708   Min: 0.000000   Max: 2.802235      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.525117   Min: 0.000000   Max: 3.503971      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.475750   Min: 0.000000   Max: 2.777059      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 3.518688   Min: 0.003919   Max: 29.530030      [ h^2 Msun kpc^-3 km^2 s^-2 ]
Current_z: 74.000000
 Delta_a_particles: 0.001490      Delta_a_gas: 0.001503



 OK -- converting physical systems boosts energy, similarly in both.  Not identical. But much closer than before.  And also happens again after the snapshot 2 in both cases.  Probably a bug in Conversion?


 Check that the outputs at the same redshift differ based on the number of outputs....



 Properties of TESTING timestep 35

 FEWER:
 n_step: 21   sim time:  3.6107890   sim timestep: 1.6352e-01  timestep time =  3132.613 ms   total time =   81.5043 s

 Density  Mean: 0.159767   Min: 0.106751   Max: 0.269811      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.321635   Min: 0.000000   Max: 1.650737      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.335955   Min: 0.000000   Max: 2.074174      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.304391   Min: 0.000000   Max: 1.641198      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 1.444899   Min: 0.003617   Max: 12.174517      [ h^2 Msun kpc^-3 km^2 s^-2 ]
Current_z: 80.954448
 Delta_a_particles: 0.001630      Delta_a_gas: 0.001476
 Seting max delta_a: 0.000122
 Current_a: 0.012202    delta_a: 0.000122     dt:  0.162711
 t_physical: 23.650265 Myr   dt_physical: 0.350373 Myr
 Particles GPU Memory: N_local_max: 16898169  (12.6 %)  mem_usage: 1216 MB     global_free_min: 13104.1 MB

 n_step: 30   sim time:  5.0325716   sim timestep: 1.4248e-01  timestep time =  2545.367 ms   total time =  107.2164 s


Saving Snapshot: 1
 Writing all data ( Restart File ).
 Converting to Cosmological Physical System
 Total Particles: 134217728
 Saved Snapshot: 1     z:74.000000   next_output: 49.000000
 Converting to Cosmological Comoving System

 Density  Mean: 0.159767   Min: 0.095699   Max: 0.307128      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.503167   Min: 0.000000   Max: 2.800991      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.525597   Min: 0.000000   Max: 3.502224      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.476185   Min: 0.000000   Max: 2.777179      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 3.530449   Min: 0.004393   Max: 29.558284      [ h^2 Msun kpc^-3 km^2 s^-2 ]
Current_z: 74.000000
 Delta_a_particles: 0.001621      Delta_a_gas: 0.001484
 Seting max delta_a: 0.000133
 Current_a: 0.013333    delta_a: 0.000133     dt:  0.155655
 t_physical: 27.014889 Myr   dt_physical: 0.400218 Myr
 Particles GPU Memory: N_local_max: 16908129  (12.6 %)  mem_usage: 1217 MB     global_free_min: 12969.9 MB

 n_step: 42   sim time:  6.8502765   sim timestep: 1.4736e-01  timestep time =  2266.374 ms   total time =  143.3599 s

 Density  Mean: 0.159767   Min: 0.095699   Max: 0.307128      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.503167   Min: 0.000000   Max: 2.800991      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.525597   Min: 0.000000   Max: 3.502224      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.476185   Min: 0.000000   Max: 2.777179      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 3.530449   Min: 0.004393   Max: 29.558284      [ h^2 Msun kpc^-3 km^2 s^-2 ]
Current_z: 65.558692
 Delta_a_particles: 0.001610      Delta_a_gas: 0.001491
 Seting max delta_a: 0.000150
 Current_a: 0.015024    delta_a: 0.000150     dt:  0.146634
 t_physical: 32.313811 Myr   dt_physical: 0.478719 Myr
 Particles GPU Memory: N_local_max: 16923825  (12.6 %)  mem_usage: 1218 MB     global_free_min: 12969.9 MB

 MORE:
 n_step: 21   sim time:  3.4998428   sim timestep: 1.6407e-01  timestep time =  3167.782 ms   total time =   88.2647 s

 Density  Mean: 0.159767   Min: 0.099706   Max: 0.292962      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.429462   Min: 0.000000   Max: 2.305795      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.448597   Min: 0.000000   Max: 2.893250      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.406434   Min: 0.000000   Max: 2.297015      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 2.572924   Min: 0.004072   Max: 21.561261      [ h^2 Msun kpc^-3 km^2 s^-2 ]
Current_z: 81.508251
 Delta_a_particles: 0.001631      Delta_a_gas: 0.001477
 Seting max delta_a: 0.000121
 Current_a: 0.012120    delta_a: 0.000121     dt:  0.163260
 t_physical: 23.412550 Myr   dt_physical: 0.346851 Myr
 Particles GPU Memory: N_local_max: 16897422  (12.6 %)  mem_usage: 1216 MB     global_free_min: 12969.9 MB

 n_step: 31   sim time:  5.0319632   sim timestep: 9.1612e-02  timestep time =  1942.214 ms   total time =  116.4045 s


Saving Snapshot: 2
 Writing all data ( Restart File ).
 Converting to Cosmological Physical System
 Total Particles: 134217728
 Saved Snapshot: 2     z:74.000000   next_output: 65.666667
 Converting to Cosmological Comoving System

 Density  Mean: 0.159767   Min: 0.095700   Max: 0.307128      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.503167   Min: 0.000000   Max: 2.801016      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.525597   Min: 0.000000   Max: 3.502228      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.476185   Min: 0.000000   Max: 2.777242      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 3.530478   Min: 0.004302   Max: 29.559201      [ h^2 Msun kpc^-3 km^2 s^-2 ]
Current_z: 74.000000
 Delta_a_particles: 0.001621      Delta_a_gas: 0.001484
 Seting max delta_a: 0.000133
 Current_a: 0.013333    delta_a: 0.000133     dt:  0.155655
 t_physical: 27.014889 Myr   dt_physical: 0.400218 Myr
 Particles GPU Memory: N_local_max: 16908129  (12.6 %)  mem_usage: 1217 MB     global_free_min: 12969.9 MB



 n_step: 43   sim time:  6.8255117   sim timestep: 1.2321e-01  timestep time =  2021.312 ms   total time =  152.1750 s


Saving Snapshot: 3
 Writing all data ( Restart File ).
 Converting to Cosmological Physical System
 Total Particles: 134217728
 Saved Snapshot: 3     z:65.666667   next_output: 49.000000
 Converting to Cosmological Comoving System

 Density  Mean: 0.159767   Min: 0.091152   Max: 0.324628      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.600622   Min: 0.000000   Max: 3.485119      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.627412   Min: 0.000000   Max: 4.324078      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.568410   Min: 0.000000   Max: 3.528419      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 5.029053   Min: 0.004809   Max: 43.289757      [ h^2 Msun kpc^-3 km^2 s^-2 ]
Current_z: 65.666667
 Delta_a_particles: 0.001610      Delta_a_gas: 0.001490
 Seting max delta_a: 0.000150
 Current_a: 0.015000    delta_a: 0.000150     dt:  0.146752
 t_physical: 32.235339 Myr   dt_physical: 0.477557 Myr
 Particles GPU Memory: N_local_max: 16923596  (12.6 %)  mem_usage: 1218 MB     global_free_min: 12969.9 MB





 BRUNOs:

 FEWER:

 n_step: 31   sim time:  5.1753409   sim timestep: 1.5527e-01  timestep time =  1119.064 ms   total time =   46.9780 s

 Density  Mean: 0.159767   Min: 0.095700   Max: 0.307164      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.502708   Min: 0.000000   Max: 2.802235      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.525117   Min: 0.000000   Max: 3.503971      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.475750   Min: 0.000000   Max: 2.777059      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 3.518688   Min: 0.003919   Max: 29.530030      [ h^2 Msun kpc^-3 km^2 s^-2 ]
Current_z: 73.257426
 Delta_a_particles: 0.001491      Delta_a_gas: 0.001503
 Seting max delta_a: 0.000135
 Current_a: 0.013467    delta_a: 0.000135     dt:  0.154497
 t_physical: 10.364748 Myr   dt_physical: 0.405225 Myr
 Particles GPU Memory: N_local_max: 16909229  (12.6 %)  mem_usage: 1217 MB     global_free_min: 13276.1 MB

n_step: 42   sim time:  6.8332533   sim timestep: 1.4700e-01  timestep time =  1050.148 ms   total time =   58.7241 s

 Density  Mean: 0.159767   Min: 0.095700   Max: 0.307164      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.502708   Min: 0.000000   Max: 2.802235      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.525117   Min: 0.000000   Max: 3.503971      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.475750   Min: 0.000000   Max: 2.777059      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 3.518688   Min: 0.003919   Max: 29.530030      [ h^2 Msun kpc^-3 km^2 s^-2 ]
Current_z: 65.558692
 Delta_a_particles: 0.001493      Delta_a_gas: 0.001507
 Seting max delta_a: 0.000150
 Current_a: 0.015024    delta_a: 0.000150     dt:  0.146268
 t_physical: 15.245253 Myr   dt_physical: 0.477528 Myr
 Particles GPU Memory: N_local_max: 16923821  (12.6 %)  mem_usage: 1218 MB     global_free_min: 13276.1 MB


 MORE:
 n_step: 32   sim time:  5.1748856   sim timestep: 1.5527e-01  timestep time =  1101.896 ms   total time =   55.3767 s

 Density  Mean: 0.159767   Min: 0.095701   Max: 0.307164      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.502714   Min: 0.000000   Max: 2.802174      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.525124   Min: 0.000000   Max: 3.503925      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.475756   Min: 0.000000   Max: 2.777114      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 3.518788   Min: 0.003919   Max: 29.530061      [ h^2 Msun kpc^-3 km^2 s^-2 ]
Current_z: 73.257426
 Delta_a_particles: 0.001491      Delta_a_gas: 0.001503
 Seting max delta_a: 0.000135
 Current_a: 0.013467    delta_a: 0.000135     dt:  0.154497
 t_physical: 10.365092 Myr   dt_physical: 0.405225 Myr
 Particles GPU Memory: N_local_max: 16909229  (12.6 %)  mem_usage: 1217 MB     global_free_min: 13276.1 MB


 n_step: 43   sim time:  6.8087518   sim timestep: 1.2295e-01  timestep time =  1041.305 ms   total time =   67.1368 s


Saving Snapshot: 3
 Writing all data ( Restart File ).
 Converting to Cosmological Physical System
 Total Particles: 134217728
 Saved Snapshot: 3     z:65.666667   next_output: 49.000000
 Converting to Cosmological Comoving System

 Density  Mean: 0.159767   Min: 0.091157   Max: 0.324689      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.599916   Min: 0.000000   Max: 3.488848      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.626674   Min: 0.000000   Max: 4.323378      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.567742   Min: 0.000000   Max: 3.529602      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 5.010973   Min: 0.003621   Max: 43.277539      [ h^2 Msun kpc^-3 km^2 s^-2 ]
Current_z: 65.666667
 Delta_a_particles: 0.001493      Delta_a_gas: 0.001507
 Seting max delta_a: 0.000150
 Current_a: 0.015000    delta_a: 0.000150     dt:  0.146387
 t_physical: 15.167480 Myr   dt_physical: 0.476368 Myr
 Particles GPU Memory: N_local_max: 16923596  (12.6 %)  mem_usage: 1218 MB     global_free_min: 13276.1 MB




 SO both conversion and DE issues perhaps

 NEXT TEST -- turn off conversion in snapshot writing


TURNED OFF COSMO UNIT CHANGE


PROPERTY CHANGE HAPPENS WITHOUT CONVERSION


VERY SIMILAR CHANGE TO WITHOUT CONVERSION. 

TURN CONVERSION BACK ON.


LOOK AT IO

LOOK AT DE







IO ISSUE:

TESTING:

Before output.
 Density  Mean: 0.159767   Min: 0.106751   Max: 0.269811      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.321635   Min: 0.000000   Max: 1.650737      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.335955   Min: 0.000000   Max: 2.074174      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.304391   Min: 0.000000   Max: 1.641198      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 1.444899   Min: 0.003617   Max: 12.174517      [ h^2 Msun kpc^-3 km^2 s^-2 ]

Saving Snapshot: 1
 Writing all data ( Restart File ).
 Converting to Cosmological Physical System
 Total Particles: 134217728
 Saved Snapshot: 1     z:82.333333   next_output: 74.000000
 Converting to Cosmological Comoving System

After output.
 Density  Mean: 0.159767   Min: 0.099706   Max: 0.292962      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.429462   Min: 0.000000   Max: 2.305788      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.448597   Min: 0.000000   Max: 2.893251      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.406434   Min: 0.000000   Max: 2.297019      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 2.572923   Min: 0.004128   Max: 21.561514      [ h^2 Msun kpc^-3 km^2 s^-2 ]

BRUNO's CODE:
Before output
 Density  Mean: 0.159767   Min: 0.106751   Max: 0.269811      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.321635   Min: 0.000000   Max: 1.650737      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.335955   Min: 0.000000   Max: 2.074174      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.304391   Min: 0.000000   Max: 1.641198      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 1.444899   Min: 0.003617   Max: 12.174517      [ h^2 Msun kpc^-3 km^2 s^-2 ]

Saving Snapshot: 1
 Writing all data ( Restart File ).
 Converting to Cosmological Physical System
 Total Particles: 134217728
 Saved Snapshot: 1     z:82.333333   next_output: 74.000000
 Converting to Cosmological Comoving System

After output
 Density  Mean: 0.159767   Min: 0.099704   Max: 0.292998      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.429195   Min: 0.000000   Max: 2.308075      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.448317   Min: 0.000000   Max: 2.894769      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.406181   Min: 0.000000   Max: 2.297527      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 2.565466   Min: 0.004129   Max: 21.566440      [ h^2 Msun kpc^-3 km^2 s^-2 ]


******************************************************************************

 In io.cpp/Write_Data --

G.Change_Cosmological_Frame_System(false);
Output_Data
G.WriteData_Particles(P, nfile);
  if (G.H.OUTPUT_SCALE_FACOR || G.H.Output_Initial) {
    G.Cosmo.Set_Next_Scale_Output();
    if (!G.Cosmo.exit_now) {
      chprintf(" Saved Snapshot: %d     z:%f   next_output: %f\n", nfile, G.Cosmo.current_z,
               1 / G.Cosmo.next_output - 1);
      G.H.Output_Initial = false;
    } else {
      chprintf(" Saved Snapshot: %d     z:%f   Exiting now\n", nfile, G.Cosmo.current_z);
    }

  } else {
    chprintf(" Saved Snapshot: %d     z:%f\n", nfile, G.Cosmo.current_z);
  }
  G.Change_Cosmological_Frame_System(true);
  chprintf("\n");
  G.H.Output_Now = false;
#endif

#ifdef HDF5
  // Cleanup HDF5
  H5close();
******************************************************************************

Change_Cosmological_Frame_System(false) -> moves to physical
Change_Cosmological_Frame_System(true) -> moves to comoving


For hydro
G.Write_Grid_HDF5



# COMMENT OUT OUTPUT_DATA.....


Output_Data is not the issue

Output_Data_Particles is not the issue

Output_Gravity is not the issue because Bruno's code doesn't do it. Also checked directly.

Probably the     G.Cosmo.Set_Next_Scale_Output();? Maybe?

Seems unlikely


Unit conversion after commenting out Set_Next_Scale.....


Bad things happen, but the unit change is still there.  So NOT G.Cosmo.Set_Next_Scale_Output();


Comment out these two conversions.

Only other functions are

  cudaMemcpy(G.C.density, G.C.device, G.H.n_fields*G.H.n_cells*sizeof(Real), cudaMemcpyDeviceToHost);
  H5_Open
  H5_Close

Conversions commented out -- Still happening

cudMemcpy???

Could just be that things aren't synched.........


Try synching each timestep.....


OK, remove Synch, should be the same...........



Since not unit conversion, go back to checking evolution using synchronization -- slow but necessary.




OK -- Let's try synchronizing and printing the grid stats








OK Near snapshot 5, redshift 16-14:


TESTING:
n_step: 183   sim time: 21.4311586   sim timestep: 3.7168e-02  timestep time =  1552.056 ms   total time =  419.2224 s

 Density  Mean: 0.159767   Min: 0.035846   Max: 4.868415      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 4.668597   Min: 0.000000   Max: 214.951081      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 4.878742   Min: 0.000000   Max: 257.338550      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 4.418244   Min: 0.000000   Max: 283.384611      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 304.861157   Min: 0.016043   Max: 21435.628704      [ h^2 Msun kpc^-3 km^2 s^-2 ]
Current_z: 16.069837
 Delta_a_particles: 0.001525      Delta_a_gas: 0.001482
 Seting max delta_a: 0.000586
 Starting UVB. Limiting delta_a:  0.000293
 Current_a: 0.058583    delta_a: 0.000241     dt:  0.030455
 t_physical: 246.609480 Myr   dt_physical: 1.511650 Myr
 Particles GPU Memory: N_local_max: 17360835  (12.9 %)  mem_usage: 1249 MB     global_free_min: 12969.9 MB

n_step: 209   sim time: 22.3594180   sim timestep: 3.4846e-02  timestep time =  4153.302 ms   total time =  495.0921 s

 Density  Mean: 0.159767   Min: 0.031579   Max: 8.707438      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 5.672328   Min: 0.000000   Max: 580.491664      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 5.927897   Min: 0.000000   Max: 631.073224      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 5.368253   Min: 0.000000   Max: 789.522038      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 461.504668   Min: 3.887519   Max: 70091.876531      [ h^2 Msun kpc^-3 km^2 s^-2 ]
Current_z: 14.007121
 Delta_a_particles: 0.001515      Delta_a_gas: 0.001416
 Seting max delta_a: 0.000666
 Current_a: 0.066635    delta_a: 0.000666     dt:  0.069604
 t_physical: 301.788694 Myr   dt_physical: 4.469917 Myr
 Particles GPU Memory: N_local_max: 17444562  (13.0 %)  mem_usage: 1256 MB     global_free_min: 12969.9 MB

 BRUNO:
 n_step: 183   sim time: 21.3783495   sim timestep: 3.7121e-02  timestep time =   916.579 ms   total time =  232.5285 s

 Density  Mean: 0.159767   Min: 0.035920   Max: 4.731580      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 4.656060   Min: 0.000000   Max: 215.215934      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 4.865655   Min: 0.000000   Max: 257.966482      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 4.406395   Min: 0.000000   Max: 286.626831      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 303.232156   Min: 0.001886   Max: 22708.972418      [ h^2 Msun kpc^-3 km^2 s^-2 ]
Current_z: 16.069837
 Delta_a_particles: 0.001494      Delta_a_gas: 0.001488
 Seting max delta_a: 0.000586
 Starting UVB. Limiting delta_a:  0.000293
 Current_a: 0.058583    delta_a: 0.000241     dt:  0.030423
 t_physical: 229.023883 Myr   dt_physical: 1.510102 Myr
 Particles GPU Memory: N_local_max: 17360680  (12.9 %)  mem_usage: 1249 MB     global_free_min: 13276.1 MB

n_step: 209   sim time: 22.3054597   sim timestep: 3.4803e-02  timestep time =  1508.291 ms   total time =  272.1763 s

 Density  Mean: 0.159767   Min: 0.031604   Max: 8.162690      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 5.658370   Min: 0.000000   Max: 568.994668      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 5.913335   Min: 0.000000   Max: 644.220773      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 5.355111   Min: 0.000000   Max: 804.191202      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 448.595801   Min: 0.202927   Max: 70482.761465      [ h^2 Msun kpc^-3 km^2 s^-2 ]
Current_z: 14.007121
 Delta_a_particles: 0.001489      Delta_a_gas: 0.001479
 Seting max delta_a: 0.000666
 Current_a: 0.066635    delta_a: 0.000666     dt:  0.069431
 t_physical: 284.128841 Myr   dt_physical: 4.458811 Myr
 Particles GPU Memory: N_local_max: 17444375  (13.0 %)  mem_usage: 1255 MB     global_free_min: 13276.1 MB


***************** DIFFERENT MINIMUM TEMPERATURE -- adjust tmin ******



# COMPARE z=16 SNAPSHOT, NO DE

TESTING:
print(np.min(temperature),np.max(temperature))
42.0703190689636 50.27771618821374

print(np.min(density),np.max(density))
3.6630505725787796 299.9868658601988

print(np.min(HII_density),np.max(HII_density))
0.000486253098792747 0.03095793660546234

print(np.min(Energy),np.max(Energy))
0.545976583554797 3401598.338887122

BRUNO:
print(np.min(temperature),np.max(temperature))
0.001314009966108819 16511.132422182138

print(np.min(density),np.max(density))
3.66162386685365 296.4504801234643

print(np.min(HII_density),np.max(HII_density))
0.00014268544451036987 0.5305797412328469

print(np.min(Energy),np.max(Energy))
0.545976583554797 3401598.338887122

Snapshot data for temperature is very different.

at z= 16

TESTING:
 Density  Mean: 0.159767   Min: 0.035703   Max: 4.947985      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 4.697615   Min: 0.000000   Max: 219.318120      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 4.909072   Min: 0.000000   Max: 268.535870      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 4.445708   Min: 0.000000   Max: 291.370835      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 308.672016   Min: 0.015941   Max: 21956.649373      [ h^2 Msun kpc^-3 km^2 s^-2 ]
Current_z: 16.000000
 Delta_a_particles: 0.001525      Delta_a_gas: 0.001482
 Seting max delta_a: 0.000588
 Starting UVB. Limiting delta_a:  0.000294
 Current_a: 0.058824    delta_a: 0.000294     dt:  0.036999
 t_physical: 248.461081 Myr   dt_physical: 1.851601 Myr
 Particles GPU Memory: N_local_max: 17363339  (12.9 %)  mem_usage: 1250 MB     global_free_min: 12969.9 MB
BRUNO:
 Density  Mean: 0.159767   Min: 0.035777   Max: 4.808131      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 4.685030   Min: 0.000000   Max: 216.186786      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 4.895936   Min: 0.000000   Max: 261.378346      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 4.433815   Min: 0.000000   Max: 295.348963      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 307.027162   Min: 0.001887   Max: 23286.028235      [ h^2 Msun kpc^-3 km^2 s^-2 ]
Current_z: 16.000000
 Delta_a_particles: 0.001494      Delta_a_gas: 0.001488
 Seting max delta_a: 0.000588
 Starting UVB. Limiting delta_a:  0.000294
 Current_a: 0.058824    delta_a: 0.000294     dt:  0.036953
 t_physical: 230.873178 Myr   dt_physical: 1.849295 Myr
 Particles GPU Memory: N_local_max: 17363206  (12.9 %)  mem_usage: 1250 MB     global_free_min: 13276.1 MB


*** CHECK TEMPERATURE CALCULATION


TESTING:

      #ifdef OUTPUT_TEMPERATURE
        #ifdef CHEMISTRY_GPU
  Compute_Gas_Temperature(Chem.Fields.temperature_h, false);
  Write_Grid_HDF5_Field_CPU(H, file_id, dataset_buffer, Chem.Fields.temperature_h, "/temperature");
        #elif defined(COOLING_GRACKLE)
  Write_Grid_HDF5_Field_CPU(H, file_id, dataset_buffer, Cool.temperature, "/temperature");
        #endif
      #endif


BRUNO:
    #ifdef OUTPUT_TEMPERATURE

    #ifdef CHEMISTRY_GPU
    Compute_Gas_Temperature( Chem.Fields.temperature_h, false );
    #endif  //CHEMISTRY_GPU

    // Copy the internal energy array to the memory buffer
    for (k=0; k<H.nz_real; k++) {
      for (j=0; j<H.ny_real; j++) {
        for (i=0; i<H.nx_real; i++) {
          id = (i+H.n_ghost) + (j+H.n_ghost)*H.nx + (k+H.n_ghost)*H.nx*H.ny;
          buf_id = k + j*H.nz_real + i*H.nz_real*H.ny_real;
          #ifdef COOLING_GRACKLE
          dataset_buffer[buf_id] = Cool.temperature[id];
          #endif
          #ifdef CHEMISTRY_GPU
          dataset_buffer[buf_id] = Chem.Fields.temperature_h[id];
          #endif
        }
      }
    }
    // Create a dataset id for density
    dataset_id = H5Dcreate(file_id, "/temperature", H5T_IEEE_F64BE, dataspace_id, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
    // Write the density array to file  // NOTE: NEED TO FIX FOR FLOAT REAL!!!
    status = H5Dwrite(dataset_id, H5T_NATIVE_DOUBLE, H5S_ALL, H5S_ALL, H5P_DEFAULT, dataset_buffer);
    // Free the dataset id
    status = H5Dclose(dataset_id);

    #endif //OUTPUT_TEMPERATURE



*** CHECK TEMPERATURE CALCULATION


TESTING:
  #ifdef DE
        GE = C.GasEnergy[id];
  #else
        //GE = E - hydro_utilities::Calc_Kinetic_Energy_From_Velocity(d, vx, vy, vz);
        GE = E - 0.5*d*(vx*vx + vy*vy + vz*vz);
    #ifdef MHD
        GE -= mhd::utils::computeMagneticEnergy(C.magnetic_x[id], C.magnetic_y[id], C.magnetic_z[id]);
    #endif  // MHD
  #endif
BRUNO:

    #ifdef CHEMISTRY_GPU
    Compute_Gas_Temperature( Chem.Fields.temperature_h, false );
    #endif  //CHEMISTRY_GPU


        #ifdef DE
        GE = C.GasEnergy[id];
        #else
        //GE = (dev_conserved[4*n_cells + id] - 0.5*d*(vx*vx + vy*vy + vz*vz));
        GE = E - 0.5*d*(vx*vx + vy*vy + vz*vz);
        #endif



*** TRY OUT PUTTING THE GE (gas energy) instead of temperature, to ensure those are the same


Compute_Gas_Temperature is only used in io.


LOOK AT SNAPSHOT 5

TESTING: using hydro utility function
print(np.min(temperature),np.max(temperature))
16181790399.455168 1356419790692.1619
print(np.min(density),np.max(density))
3.663008372731994 299.9843673764688
print(np.min(HII_density),np.max(HII_density))
0.00048624782337574533 0.030957703536220762
print(np.min(Energy),np.max(Energy))
3.944644468106644 3348570.3892264375

Done by hand, subtracting KE from total E
print(np.min(temperature),np.max(temperature))
16570002388.261856 1356291326670.9075
print(np.min(density),np.max(density))
3.66300541240733 299.98577889745354
print(np.min(HII_density),np.max(HII_density))
0.0004862476189194445 0.030957858002378536
print(np.min(Energy),np.max(Energy))
4.247809657339057 3348550.7245519133

Give the same answer for testing, different from bruno

BRUNO:

print(np.min(temperature),np.max(temperature))
547525.9422382805 380657575485822.75
print(np.min(density),np.max(density))
3.6616238668536476 296.4504801234651
print(np.min(HII_density),np.max(HII_density))
0.0001426854445103706 0.5305797412328456
print(np.min(Energy),np.max(Energy))
0.5459765835542607 3401598.338887121

Why is GE so drastically different?  Should be the same.

Compute GE from gas properties after the fact
Then try temp from gas properties after the fact





********************************************************
* computation of temperature


        temp = GE * MP * mu / d / KB * (gamma - 1.0);


let's store mu instead, just to check. -- it's probably GE, but let's check mu just in case


TESTING:
print(np.min(temperature),np.max(temperature))
1.2193138678643167 1.2193587380996647
print(np.min(density),np.max(density))
3.663016127624399 299.9843251033746
print(np.min(HII_density),np.max(HII_density))
0.0004862489379924568 0.030957643734300946
print(np.min(Energy),np.max(Energy))
3.9650193116023065 3348588.4039764036

BRUNO:
print(np.min(temperature),np.max(temperature))
1.2161977140653855 1.2194872144387046
print(np.min(density),np.max(density))
3.6616238668536294 296.4504801234651
print(np.min(HII_density),np.max(HII_density))
0.0001426854445103696 0.530579741232838
print(np.min(Energy),np.max(Energy))
0.5459765835547238 3401598.3388871094



*************************************************************
** Gas energy is wrong.  Momenta and density look ok. Total
** E is similar but difference has to come in there. Try
** switching integrators for the testing code. Obvious differences

#        temp = GE * MP * mu / d / KB * (gamma - 1.0);
# GE in (cm/s)**2 * density
# MP in g
# mu ~ 1.21
# divide out density
# KB in cgs
# gamma = 1.66666
# GE computed from d and momenta and E needs a factor 1e10 to go from km/s to cm/s system


# GE itself is wrong in the new calculations.  Double check that
# we can compute the temperature correctly by running sims outputting temperature again


######################################
# Temperature calculation is done self-consistently
# with the above from the snapshots
# GE is really different
# Add GE to monitoring in Print_Stats


TESTING:

n_step: 1   sim time:  0.1806312   sim timestep: 1.8063e-01  timestep time =  4382.200 ms   total time =   10.8155 s

 Density  Mean: 0.159767   Min: 0.106396   Max: 0.270949      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.326485   Min: 0.000000   Max: 1.679998      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.341021   Min: 0.000000   Max: 2.111703      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.308981   Min: 0.000000   Max: 1.669915      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 1.864664   Min: 0.262737   Max: 13.138986      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 GasEnergyCalc  Mean: 0.380513   Min: 0.233977   Max: 0.675669      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 TemperatureCalc  Mean: 192.348302   Min: 172.271973   Max: 210.534537      [ K ]
Current_z: 99.000002
 Delta_a_particles: 0.001652      Delta_a_gas: 0.001287
 Seting max delta_a: 0.000100
 Current_a: 0.010000    delta_a: 0.000100     dt:  0.179735
 t_physical: 17.546637 Myr   dt_physical: 0.259950 Myr
 Particles GPU Memory: N_local_max: 16871827  (12.6 %)  mem_usage: 1214 MB     global_free_min: 13104.1 MB

n_step: 6   sim time:  1.0704292   sim timestep: 1.7619e-01  timestep time =  3928.977 ms   total time =   30.7566 s

 Density  Mean: 0.159767   Min: 0.104612   Max: 0.276671      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.351848   Min: 0.000000   Max: 1.833923      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.367516   Min: 0.000000   Max: 2.308051      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.332984   Min: 0.000000   Max: 1.818799      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 1.728228   Min: 0.003362   Max: 14.587832      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 GasEnergyCalc  Mean: 0.004633   Min: 0.002824   Max: 0.008024      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 TemperatureCalc  Mean: 2.342020   Min: 2.097016   Max: 2.562728      [ K ]
Current_z: 94.146570
 Delta_a_particles: 0.001646      Delta_a_gas: 0.001463
 Seting max delta_a: 0.000105
 Current_a: 0.010510    delta_a: 0.000105     dt:  0.175319
 t_physical: 18.906209 Myr   dt_physical: 0.280091 Myr
 Particles GPU Memory: N_local_max: 16878872  (12.6 %)  mem_usage: 1215 MB     global_free_min: 13104.1 MB


 BRUNO:

 n_step: 1   sim time:  0.1801815   sim timestep: 1.8018e-01  timestep time =  1084.200 ms   total time =    7.2337 s

 Density  Mean: 0.159767   Min: 0.106396   Max: 0.270947      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.326473   Min: 0.000000   Max: 1.680026      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.341008   Min: 0.000000   Max: 2.111695      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.308969   Min: 0.000000   Max: 1.669891      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 1.489136   Min: 0.004408   Max: 12.549310      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 GasEnergyCalc  Mean: 0.005094   Min: 0.002865   Max: 0.008804      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 TemperatureCalc  Mean: 2.577225   Min: 1.507400   Max: 2.808639      [ K ]
Current_z: 99.000002
 Delta_a_particles: 0.001482      Delta_a_gas: 0.001462
 Seting max delta_a: 0.000100
 Current_a: 0.010000    delta_a: 0.000100     dt:  0.179287
 t_physical: 0.514764 Myr   dt_physical: 0.259303 Myr
 Particles GPU Memory: N_local_max: 16871827  (12.6 %)  mem_usage: 1214 MB     global_free_min: 13276.1 MB

 n_step: 6   sim time:  1.0677643   sim timestep: 1.7575e-01  timestep time =  1145.721 ms   total time =   12.4160 s

 Density  Mean: 0.159767   Min: 0.104603   Max: 0.276717      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.351774   Min: 0.000000   Max: 1.835001      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.367439   Min: 0.000000   Max: 2.307890      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.332914   Min: 0.000000   Max: 1.818849      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 1.726272   Min: 0.004318   Max: 14.586617      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 GasEnergyCalc  Mean: 0.003401   Min: 0.000004   Max: 0.009288      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 TemperatureCalc  Mean: 1.724719   Min: 0.001808   Max: 3.182699      [ K ]
Current_z: 94.146570
 Delta_a_particles: 0.001483      Delta_a_gas: 0.001485
 Seting max delta_a: 0.000105
 Current_a: 0.010510    delta_a: 0.000105     dt:  0.174882
 t_physical: 1.870951 Myr   dt_physical: 0.279394 Myr
 Particles GPU Memory: N_local_max: 16878872  (12.6 %)  mem_usage: 1215 MB     global_free_min: 13276.1 MB


################### CHANGING TEMP FLOOR TO 1e-13....

TESTING:
n_step: 1   sim time:  0.1806312   sim timestep: 1.8063e-01  timestep time =  4379.897 ms   total time =   10.7817 s

 Density  Mean: 0.159767   Min: 0.106396   Max: 0.270949      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.326485   Min: 0.000000   Max: 1.679998      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.341021   Min: 0.000000   Max: 2.111703      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.308981   Min: 0.000000   Max: 1.669915      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 1.864664   Min: 0.262737   Max: 13.138986      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 GasEnergyCalc  Mean: 0.380513   Min: 0.233977   Max: 0.675669      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 TemperatureCalc  Mean: 192.348302   Min: 172.271973   Max: 210.534537      [ K ]
n_step: 6   sim time:  1.0704292   sim timestep: 1.7619e-01  timestep time =  3953.906 ms   total time =   30.7572 s

 Density  Mean: 0.159767   Min: 0.104612   Max: 0.276671      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 0.351848   Min: 0.000000   Max: 1.833922      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 0.367516   Min: 0.000000   Max: 2.308050      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 0.332984   Min: 0.000000   Max: 1.818751      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 1.728228   Min: 0.003686   Max: 14.587880      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 GasEnergyCalc  Mean: 0.004633   Min: 0.002831   Max: 0.008344      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 TemperatureCalc  Mean: 2.342009   Min: 2.097017   Max: 2.562728      [ K ]
Current_z: 94.146570
 Delta_a_particles: 0.001646      Delta_a_gas: 0.001463
 Seting max delta_a: 0.000105
 Current_a: 0.010510    delta_a: 0.000105     dt:  0.175319
 t_physical: 18.906209 Myr   dt_physical: 0.280091 Myr
 Particles GPU Memory: N_local_max: 16878872  (12.6 %)  mem_usage: 1215 MB     global_free_min: 13104.1 MB

 NO EFFECT -- temp floor not engaged


 SET TEMP FLOOR VERY SMALL FOR TESTING



 NEXT -- TRY ADIABATIC SIMULATION



 #######################
 Adiabatic simulations look good -- not identical but not ridiculously different

 TESTING:

 n_step: 181   sim time: 21.4627300   sim timestep: 3.1009e-02  timestep time =   715.505 ms   total time =  147.0362 s


Saving Snapshot: 5
 Writing all data ( Restart File ).
 Converting to Cosmological Physical System
 Total Particles: 134217728
 Saved Snapshot: 5     z:16.000000   next_output: 15.666667
 Converting to Cosmological Comoving System

 Density  Mean: 0.159767   Min: 0.035691   Max: 4.851996      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 4.697619   Min: 0.000000   Max: 210.691568      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 4.909077   Min: 0.000000   Max: 262.083883      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 4.445712   Min: 0.000000   Max: 289.884614      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 308.655214   Min: 0.001793   Max: 21897.658847      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 GasEnergyCalc  Mean: 0.005045   Min: 0.000000   Max: 814.529627      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 TemperatureCalc  Mean: 0.680446   Min: 0.000343   Max: 14054.492306      [ K ]
Current_z: 16.000000
 Delta_a_particles: 0.001525      Delta_a_gas: 0.001485
 Seting max delta_a: 0.000588
 Current_a: 0.058824    delta_a: 0.000588     dt:  0.074090
 t_physical: 250.317287 Myr   dt_physical: 3.707808 Myr
 Particles GPU Memory: N_local_max: 17363338  (12.9 %)  mem_usage: 1250 MB     global_free_min: 21975.1 MB

 BRUNO:
 n_step: 181   sim time: 21.4096088   sim timestep: 3.0977e-02  timestep time =   717.086 ms   total time =  147.8665 s


Saving Snapshot: 5
 Writing all data ( Restart File ).
 Converting to Cosmological Physical System
 Total Particles: 134217728
 Saved Snapshot: 5     z:16.000000   next_output: 9.000000
 Converting to Cosmological Comoving System

 Density  Mean: 0.159767   Min: 0.035771   Max: 4.752865      [ h^2 Msun kpc^-3]
 abs(Momentum X)  Mean: 4.684782   Min: 0.000000   Max: 217.500456      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Y)  Mean: 4.895675   Min: 0.000000   Max: 262.607376      [ h^2 Msun kpc^-3 km s^-1]
 abs(Momentum Z)  Mean: 4.433581   Min: 0.000000   Max: 295.673580      [ h^2 Msun kpc^-3 km s^-1]
 Energy  Mean: 306.997702   Min: 0.001778   Max: 23415.396567      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 GasEnergyCalc  Mean: 0.004487   Min: 0.000000   Max: 896.008389      [ h^2 Msun kpc^-3 km^2 s^-2 ]
 TemperatureCalc  Mean: 0.596468   Min: 0.000343   Max: 15755.632991      [ K ]
Current_z: 16.000000
 Delta_a_particles: 0.001494      Delta_a_gas: 0.001487
 Seting max delta_a: 0.000588
 Current_a: 0.058824    delta_a: 0.000588     dt:  0.073905
 t_physical: 232.709138 Myr   dt_physical: 3.698589 Myr
 Particles GPU Memory: N_local_max: 17363206  (12.9 %)  mem_usage: 1250 MB     global_free_min: 22279.2 MB

// see data.adiabatic.no_DE directories to z~16


 ###############################################

 ## Something is different with the cooling prescription
 ## need to determine the cooling rate
 ## note that the gas heats after the first step
 ## why heating?


 ###############################################
# begin tests subbing in bruno's calculations, see if 
# we can track down the culprit if it is in chemistry_gpu
# could also be in cooling....

# first with chemistry_functions.cpp and rates.cuh subbed in

YAYAYAYAYAYAYAYAYAYY

OK, which is the culprit.  Sub chemistry_functions back out.


Seems to be chemistry_functions.cpp!  Let's figure out why....


Run cholla_381129.log has bad (cholla) chem functions and old rates.  Try bruno chem functions na dnew rates




Submitted batch job 381133 has new rates and Bruno's chemistry_functions.cpp....



New rates and Bruno's chemistry_functions.cpp works!


YYAYAYAYAYAYYAYAYAYAYAYA

OK what in chemistry_functions.cpp is wrong?!?!?!?




Submitted batch job 381163 has temp floor -- check if this works or not

Temp floor doesn't cause the issue



UNITS ISSUE


BRUNOS:
Initializing the GPU Chemistry Solver...
Msun 1.988470e+33
kpc_cgs 3.086000e+21
kpc_km  3.086000e+16
dens_to_CGS 2.674327e-30
Chem.H.a_value 9.900990e-03
Chem.H.density_units 2.755362e-24
Chem.H.length_units 4.515882e+19
Chem.H.time_units 4.561040e+16
Chem.H.velocity_units 9.900990e+02
Chem.H.dens_number_conv 1.598884e-06
dens_base 2.674327e-30
length_base 4.561040e+21
time_base 4.561040e+16
Chem.H.cooling_units 2.293596e-25
Chem.H.reaction_units 1.371258e-11

CHOLLA:
Initializing the GPU Chemistry Solver...
Msun 1.988470e+33
kpc_cgs 3.086000e+21
kpc_km  3.086000e+16
dens_to_CGS 2.674327e-30
Chem.H.a_value 9.900990e-03
Chem.H.density_units 2.755362e-24
Chem.H.length_units 4.515882e+19
Chem.H.time_units 4.561040e+16
Chem.H.velocity_units 9.900990e+02
Chem.H.dens_number_conv 1.551861e-12
dens_base 2.674327e-30
length_base 4.561040e+21
time_base 4.561040e+16
Chem.H.cooling_units 2.293596e-25
Chem.H.reaction_units 1.371258e-11

Revised cholla:
Initializing the GPU Chemistry Solver...
Msun 1.988470e+33
kpc_cgs 3.086000e+21
kpc_km  3.086000e+16
dens_to_CGS 2.674327e-30
Chem.H.a_value 9.900990e-03
Chem.H.density_units 2.755362e-24
Chem.H.length_units 4.515882e+19
Chem.H.time_units 4.561040e+16
Chem.H.velocity_units 9.900990e+02
Chem.H.dens_number_conv 1.598884e-06
dens_base 2.674327e-30
length_base 4.561040e+21
time_base 4.561040e+16
Chem.H.cooling_units 2.293596e-25
Chem.H.reaction_units 1.371258e-11



************************************************
Great!  On to DE

ported changes to non-standard-cosmology after submitting bug fix

Submitted batch job 381182 has updated non-standard-cosmology running with DE

DE doesn't look right:

Energy 0.5528210228034912/3122607.7327247695
Density 3.6682268709522785/295.8837955201574
GasEnergy 4.352137693786062e-05/0.0035104884300380945
KineticEnergy 0.5527286954744066/3122607.731587632
Temperature Calc 0.0011594480231217179/0.0011594527750739048
Temperature 0.0007790433292444843/0.0007790433292444857

Turn off DE, then double check

Submitted batch job 381184 has DE turned off
Something off -- VL vs. SIMPLE?

Submitted batch job 381185 has DE off and SIMPLE on -- let's see.

Energy 0.5531855404769794/3347221.4993978823
Density 3.6622429517151938/290.62394652782274
GasEnergy 5.475341822602786e-05/37481.4993579092
KineticEnergy 0.5530631703034251/3346445.471838315
Temperature Calc 0.0013044527518924949/16372.85084793997
Temperature 0.0013146803933019393/16492.270108624823

Looks like bruno's.  So SIMPLE vs. VL makes a difference in Temperature (not Calc so much)


OK What changes do we need to make DE work?

hydro/hydro_cuda.cu -- remove eta_1 logic
utilities/hydro_utilities.h unchanged but has ETA_1
Change eta_1 in global.h

Submitted batch job 381186 has these changes -- Looks reasonable?

Energy 0.5531855404768812/3347221.4997352376
Density 3.6622429516915966/290.62394652871444
GasEnergy 5.4753420045017265e-05/37481.49935794994
KineticEnergy 0.5530631703033267/3346445.4721714384
Temperature Calc 0.001304451388455818/16372.850847954109
Temperature 0.0013146776450989424/16492.270108637636

NOT SURE IF THE ABOVE IS WITH OR WITHOUT DE -- try again

Submitted batch job 381197 with DE on but with the above changes


Submitted batch job 381187 has bruno w/ DE turned on, with grid printing -- useful reference

Well, it's different!

Energy 1.0062386594137296/3399174.604312294
Density 3.662263851801591/306.31048147177574
GasEnergy 0.19508414478877967/14207.986536919172
KineticEnergy 0.5450897972503433/3399134.9502658495
Temperature Calc 4.835307845840991/8771.885313926303
Temperature 4.872951064722034/8840.37409723357

Very little has separated from the main EOS

So, it's different.....

Propagating changes into TESTING can basically reproduce (Submitted batch job 381197 with DE on but with the above changes), a little different:

Macro Flags     = -DMPI_CHOLLA -DPRECISION=2 -DPPMP -DHLLC -DSIMPLE -DDENSITY_FLOOR -DTEMPERATURE_FLOOR -DDE -DOUTPUT -DHDF5  -DGRAVITY -DPARIS -DGRAVITY_GPU -DGRAVITY_5_POINTS
_GRADIENT -DPARALLEL_OMP -DN_OMP_THREADS=10 -DPARIS_NO_GPU_MPI -DPARTICLES -DPARTICLES_GPU -DPARTICLE_IDS -DSINGLE_PARTICLE_MASS -DPARALLEL_OMP -DN_OMP_THREADS=10 -DCOSMOLOGY -
DCHEMISTRY_GPU -DOUTPUT_TEMPERATURE -DOUTPUT_CHEMISTRY -DAVERAGE_SLOW_CELLS -DPRINT_INITIAL_STATS -DN_OUTPUT_COMPLETE=1 -DPARIS_5PT -DSCALAR -DGIT_HASH=6f84e2e74935040d0c8cafc3
a1f73c1f9e85b9ef

Energy 1.0133213421644538/3348162.212846249
Density 3.6625024023144555/300.00392739557145
GasEnergy 0.19478691263975634/14718.70127359224
KineticEnergy 0.552347992124712/3348124.491893507
Temperature Calc 4.824673333578186/8925.835630469632
Temperature 4.862234278499175/8995.52712780087



*********************

Testing with DE changes at z=9
Energy 309.89109283055416/57471602.59370645
Density 2.169905651792761/3024.3340319862173
GasEnergy 166.79659016581172/253290.4766102475
KineticEnergy 0.7171752918657595/57393027.644068114
Temperature Calc 5860.527855370695/12679.56617208505
Temperature 4901.157844945178/10372.063314645377

Testing with DE changes at z=1
Energy 40.971301709537364/24399880845.750885
Density 0.14166216546203775/573563.9833529233
GasEnergy 9.420003426302628/3949713062.8557835
KineticEnergy 0.28268393924732493/24262455560.59608
Temperature Calc 2802.873963065459/82302694.49613197
Temperature 1362.607899359339/40011032.950760014

TESTING phase diagram is broader, note kinetic energy is lower, energy is lower

Bruno at z=9
Energy 305.82784974974874/66342288.26554036
Density 2.1653352913096566/2742.8737931979526
GasEnergy 166.28929460229574/229745.037410317
KineticEnergy 0.22063081447234797/66251567.89730922
Temperature Calc 6010.463905256566/12318.712660925166
Temperature 5030.532800656265/10173.48631432164

Brunot at z=1
Energy 37.48985530626413/19712719804.775055
Density 0.33695372276902946/177901.57034592584
GasEnergy 9.685928049979339/4933318739.137725
KineticEnergy 0.2101718903228932/18167726393.379124
Temperature Calc 2593.0894983278467/28480587.2993016
Temperature 1260.622657495666/13845691.579834696



*********************


OK, what about DE + VL?  

Job 381211 has DE + VL, just for TESTING comparison

Looks absurd:

Macro Flags     = -DMPI_CHOLLA -DPRECISION=2 -DPPMP -DHLLC -DVL -DDENSITY_FLOOR -DTEMPERATURE_FLOOR -DDE -DOUTPUT -DHDF5  -DGRAVITY -DPARIS -DGRAVITY_GPU -DGRAVITY_5_POINTS_GRA
DIENT -DPARALLEL_OMP -DN_OMP_THREADS=10 -DPARIS_NO_GPU_MPI -DPARTICLES -DPARTICLES_GPU -DPARTICLE_IDS -DSINGLE_PARTICLE_MASS -DPARALLEL_OMP -DN_OMP_THREADS=10 -DCOSMOLOGY -DCHE
MISTRY_GPU -DOUTPUT_TEMPERATURE -DOUTPUT_CHEMISTRY -DAVERAGE_SLOW_CELLS -DPRINT_INITIAL_STATS -DN_OUTPUT_COMPLETE=1 -DPARIS_5PT -DSCALAR -DGIT_HASH=6f84e2e74935040d0c8cafc3a1f7
3c1f9e85b9ef

Energy 0.14460757865723192/48424841.48279893
Density 2.1682887857921256/2804.0136187591347
GasEnergy 2.5957538127840962e-05/7967684.368105745
KineticEnergy 0.144507718076656/48424841.47182133
Temperature Calc 0.0011699063235821522/391517.28164181655
Temperature 0.0007844452141519806/262519.4029305971


*********************
What about DE with VL, but the original implementation?

cholla_381220.log has regular DE settings but with VL

Energy 0.1447461257567935/50483273.30838911
Density 2.168376161481804/2893.741857589518
GasEnergy 2.6050158339785412e-05/7673003.381450945
KineticEnergy 0.1446459275275308/50483273.29690994
Temperature Calc 0.0011740324290424368/371107.5000653265
Temperature 0.0007873730334898983/248885.04634803894

ALSO ABSURD

As things stand -- can't use VL


REVERT TO SIMPLE AND MAKE DE CHANGES -- like the non-standard repo.


***********************

right now -- DE changes and SIMPLE integrator?
Things apparently get very very hot though
seems familiar
worrying about numerical errors and heating
But VL integrator bombs out




data.cooling.draft_DE has nonstd + draft DE changes + cooling
data.cooling.no_ED has nonstd + cooling, no DE



***********************


Dual energy is actually fine with SIMPLE.

After meeting with Bruno, there were changes to PPMP he noticed. Undoing these changes produces results very similar to his original code. We will keep them!

