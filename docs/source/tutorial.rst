running notes: to be formatted
It can be helpful to make an alias to log in.
It will prompt a passcode: this is your pin + your RSA key.
This puts you in /ccs/home/yourusername
The main project work directory is /lustre/orion/ast206/proj-shared
(it can be helpful to keep this work directories in .sh files that you can then source)
in the ../proj-shared directory:
we have several folders:
ics, which have the intitial conditions for the test runs
runs, where we execute the runs
in ics, we have the testing directory: the most common condititions we will be using will be 2048-50Mpc
the way the initial conditions work, you either have to have exisiting intial conditions, or you have to make them on the computer. 
The ones we have here are really just for testing, not necessarily science cases.
They were made using MUSIC, a cosmological initial conditions generator. They are intitially in a raw format, and then
convereted to CHOLLA format
in the 2048-50Mpc/ics/ics_512_z100 (this is in the slack)
2048: resolution of the box on a side
50Mpc: length of the box
there are 512 separate subvoumes (and 8x8x8 subcomposition)
link ics to the ics_512_z100 directory
the scale output files likes to the scale_output_files directory in cholla repo
to run a simulation, you need a parameter file (.txt)
uvb_rates file has heating and cooling rates (not used in adiabtic)
density and temp floor are set by hand in param file in dev branch, used to be hardcoded
on the slurm submission sript:
8 gpus per node, fso for 512 we need 64 nodes. we have a time limit of 2 hours
give account: ast206
write and ouput file. wtites .o the job number for theoutput file.
set the cholla location
you have to source a build setup file
set how often the all to all synchronication happens
open mp number of threads (certain number availble )
scontol show hostnames: what nodes are actaully used
then the srun command at the bottom
1 gpu per mpi task
the commented out line is to start from scratch
the long line with the read grid is to start from file 230
