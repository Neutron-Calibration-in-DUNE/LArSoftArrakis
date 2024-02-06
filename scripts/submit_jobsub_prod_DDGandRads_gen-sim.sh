#!/bin/bash

####################################################################################################
## jobsub command shell script for use with the standard jobsub_ scripts
## because it's annoying to remember the whole command
## author: David Rivera <drivera@fnal.gov>
## usage: bash submit_jobsub_
## notes: 
##    * run from the directory where the jobsub_ script is located
####################################################################################################
LARSOFT_VERSION="v09_75_00"
JOBSUB_FILE=jobsub_prod_DDGandRads_gen-sim.sh

jobsub_submit -G dune -N 50 --expected-lifetime=8h --memory=10000MB --disk=20GB -l '+SingularityImage=\"/cvmfs/singularity.opensciencegrid.org/fermilab/fnal-wn-sl7:latest\"' -l '+FERMIHTC_AutoRelease=True' -l '+FERMIHTC_GraceMemory=600' --append_condor_requirements='(TARGET.HAS_Singularity==true&&TARGET.HAS_CVMFS_dune_opensciencegrid_org==true&&TARGET.HAS_CVMFS_larsoft_opensciencegrid_org==true&&TARGET.HAS_CVMFS_fifeuser1_opensciencegrid_org==true&&TARGET.HAS_CVMFS_fifeuser2_opensciencegrid_org==true&&TARGET.HAS_CVMFS_fifeuser3_opensciencegrid_org==true&&TARGET.HAS_CVMFS_fifeuser4_opensciencegrid_org==true)' --resource-provides=usage_model=DEDICATED,OPPORTUNISTIC,OFFSITE --tar_file_name=dropbox:///dune/app/users/drivera/LArSoftArrakis_${LARSOFT_VERSION}.tar.gz file://`pwd`/${JOBSUB_FILE}
