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
#JOBSUB_FILE=jobsub_prod_DDGSingleGammas_gen-sim.sh
JOBSUB_FILE=test_gen.sh

gammaNames=("4.745MeV" "1.866MeV" "0.1673MeV" "0.8378MeV" "0.5161MeV" "3.365MeV" "2.566MeV")
## -- Gamma energies are mapped as below:
function printInfo() {
  echo "Gamma energy by index:"
  echo "  0) 0.004745  GeV"
  echo "  1) 0.001866  GeV"
  echo "  2) 0.0001673 GeV"
  echo "  3) 0.0008378 GeV"
  echo "  4) 0.0005161 GeV"
  echo "  5) 0.003365  GeV"
  echo "  6) 0.002566  GeV"

  return 0
}

USAGE="bash <this_script.sh> <index on gamma array>"

if [ $# -eq 0 ]; then
  printInfo
  echo "Running w/ whatever is in: ${JOBSUB_FILE}"

	setting=$(grep "^GAMMA_E_INDEX=" "${JOBSUB_FILE}")

	# Print the line if it is found
	if [[ -n "$setting" ]]; then
	    echo "$setting"
	else
	    echo "Line not found"
	fi

elif [ $# -eq 1 ]; then

  gammaIndex=$(( $1 ))
	# -- make sure that the index is valid
	if [ $gammaIndex -gt 6 ]; then
		printInfo
		echo "The list of gammas only includes indices 0-6!"
		exit 1
	fi

	# -- Set the gamma energy index in the jobsub file to be transferred over.
	sed -i "s/^GAMMA_E_INDEX=.$/GAMMA_E_INDEX=${gammaIndex}/" "$JOBSUB_FILE"
	echo "Running the job for gammas: ${gammaNames[$gammaIndex]}"

else
  echo "Single input argument"
  echo "Usage: $USAGE"
  printInfo
  exit 1
fi

bash ${JOBSUB_FILE} 1 1

# -- The jobsub command
#jobsub_submit -G dune -N 5 --expected-lifetime=8h --memory=10000MB --disk=20GB -l '+SingularityImage=\"/cvmfs/singularity.opensciencegrid.org/fermilab/fnal-wn-sl7:latest\"' -l '+FERMIHTC_AutoRelease=True' -l '+FERMIHTC_GraceMemory=600' --append_condor_requirements='(TARGET.HAS_Singularity==true&&TARGET.HAS_CVMFS_dune_opensciencegrid_org==true&&TARGET.HAS_CVMFS_larsoft_opensciencegrid_org==true&&TARGET.HAS_CVMFS_fifeuser1_opensciencegrid_org==true&&TARGET.HAS_CVMFS_fifeuser2_opensciencegrid_org==true&&TARGET.HAS_CVMFS_fifeuser3_opensciencegrid_org==true&&TARGET.HAS_CVMFS_fifeuser4_opensciencegrid_org==true)' --resource-provides=usage_model=DEDICATED,OPPORTUNISTIC,OFFSITE --tar_file_name=dropbox:///dune/app/users/drivera/LArSoftArrakis_${LARSOFT_VERSION}.tar.gz file://`pwd`/${JOBSUB_FILE}
