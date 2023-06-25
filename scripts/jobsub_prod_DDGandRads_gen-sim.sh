#!/bin/bash

## -- D.R. 6/20/2023

printenv
set -x #start bash debugging at this point
echo Start  `date`
echo Site:${GLIDEIN_ResourceName}
echo "the worker node is " `hostname` "OS: "  `uname -a`
echo "the user id is " `whoami`
echo "the output of id is " `id`
set +x #stop bash debugging at this point

umask 002 #set the read/write permission of files created to be 775

#--------------------Versioning---------------------#
# specify the version of the larsoft packages.
LARSOFT_VERSION=v09_75_00
DUNE_VERSION=v09_75_00d00
QUALS=e20:prof


# -- Commenting the following line and uncommenting the lines for standalone make this file standalone
STANDALONE=0
GRID_USER=drivera
GROUP=dune
JOBSUB_GROUP=dune
DIRECTORY=larsoft
##<----->cd $_CONDOR_SCRATCH_DIR

#######STANDALONE LINES##########
#STANDALONE=1
#GRID_USER=drivera
#CLUSTER=$1 #pass as first argument
#PROCESS=$1
#GROUP=dune
#---

echo "pwd is " `pwd`

####################################################################################################
PARTICLE_TYPE="pnsNeutrons"
EVENTS_PER_RUN=1
BASE_NAME="prod_pns_neutrons_Arrakis"
DESTINATION=scratch
GEN_SCRIPT=generate_neutrons_protodune.py #creates the .dat files
SIM_FHICL=labeling_sim.fcl
#destination is to choose between scratch and persistent

JOB_NAME=${BASE_NAME}
BASE_DIR=/pnfs/dune/${DESTINATION}/users/${GRID_USER}/Arrakis/${LARSOFT_VERSION}/${BASE_NAME}
####################################################################################################

# -- setup env
source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh

setup dunesw $DUNE_VERSION -q $QUALS
# -- will set up my own version from the tar
#setup duneana $DUNE_VERSION -q $QUALS

if [ x$IFDHC_DIR = x ]; then
  setup ifdhc
fi

####################################################################################################
#print the initial environment
echo "Here is the your initial environment in this job: " > job_output_${CLUSTER}.${PROCESS}.log 2> job_output_${CLUSTER}.${PROCESS}.err #Creates file for logging information, note that this is stdout only
env >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err #since file already exists use ">>" instead of ">"
echo "################################################################################" >> job_output_${CLUSTER}.${PROCESS}.log
####################################################################################################

#tar file should be unpacked if passed to the jobsub_submit command with argument: --tar_file_name
# TAR_FILE should be copied and unpacked according to the jobsub_submit command description
# "TAR_FILE will   be accessible to the user job on the worker node via the   environment variable $INPUT_TAR_FILE.
# The unpacked   contents will be in the same directory as   $INPUT_TAR_FILE."
TEMPDIR=`pwd`
if [ $STANDALONE -ne 1 ]; then

  # -- Define the work dir
  export WORKDIR=${_CONDOR_JOB_IWD} # if we use the RCDS then our tarball will be placed in $INPUT_TAR_DIR_LOCAL.
  if [ ! -d "$WORKDIR" ]; then
    export WORKDIR=`echo .`
  fi

  if [ x$INPUT_TAR_FILE != x ]; then
    # Setup the environment.
    echo "Input .tar file : ${INPUT_TAR_FILE}" >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err
    pwd
    ls
    echo

    # -- setup-grid must be defined and placed alongside the normal setup script in the local prods
		if [ x$IFDHC_DIR = x ]; then
		  echo "Setting up ifdhc before fetching tarball." >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err
		  setup ifdhc
		fi
    echo "IFDHC_DIR=$IFDHC_DIR" >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err

    # -- setting up ARRAKIS and our local grid setup
    #---------------------Directory---------------------#
    # this handy piece of code determines the relative
    # directory that this script is in.
    #SOURCE="${BASH_SOURCE[0]}"
    SOURCE="${INPUT_TAR_DIR_LOCAL}/${DIRECTORY}"
    # resolve $SOURCE until the file is no longer a symlink
    while [ -h "$SOURCE" ]; do 
      DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
      SOURCE="$(readlink "$SOURCE")"
      # if $SOURCE was a relative symlink, we need to resolve it relative 
      # to the path where the symlink file was located
      [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
    done
    LOCAL_LARSOFT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )/../"

    #---------------------Installation Directory--------#
    #INSTALL_DIRECTORY=$LOCAL_LARSOFT_DIR/larsoft
    INSTALL_DIRECTORY=${INPUT_TAR_DIR_LOCAL}/larsoft
    ###ifdh mkdir -p $INSTALL_DIRECTORY
    ###cd $INSTALL_DIRECTORY

    #--------------------Setup LArSoft------------------#
    #source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh
    #setup larsoft $LARSOFT_VERSION -q $QUALS
    #setup dunesw $DUNE_VERSION -q $QUALS
    cd $INSTALL_DIRECTORY
    source localProducts*/setup-grid

    mrbslp

    #------------------Custom search and fcl------------#
    # here we specify any custom search paths and fcl
    # file paths that we want our installation to know about.
    CUSTOM_SEARCH_PATH="${INPUT_TAR_DIR_LOCAL}/geometry/"
    CUSTOM_FHICL_PATH="${INPUT_TAR_DIR_LOCAL}/fcl/"

    export FHICL_FILE_PATH="$FHICL_FILE_PATH:$CUSTOM_FHICL_PATH"
    export FW_SEARCH_PATH="$FW_SEARCH_PATH:$CUSTOM_SEARCH_PATH" # -- don't think we really need this

    cd $LOCAL_LARSOFT_DIR
    ##<--ifdh mkdir inputs
    ##<--ifdh chmod 775 inputs/
    #mkdir inputs/

    #<--ifdh mkdir inputs/protodune
    #<--ifdh chmod 775 inputs/protodune
    #mkdir inputs/protodune
 
    ##<--echo "Initializing localProducts from tarball ${INPUT_TAR_FILE}." >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err
    ##<--ARRAKIS_SCRIPT_DIR="${INPUT_TAR_DIR_LOCAL}/${DIRECTORY}"
    ##<--cd $ARRAKIS_SCRIPT_DIR
    ##<--source setup-grid-arrakis.sh
    ##<--source ${INPUT_TAR_DIR_LOCAL}/${DIRECTORY}/localProducts*/setup-grid
    ##<--mrbslp
  else 
    echo "No tar file provided.. setting up dunesw + duneana and hope that your code is already there"
    #>> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err
    setup dunesw $DUNE_VERSION -q $QUALS
    setup duneana $DUNE_VERSION -q $QUALS
  fi
fi

cd $TEMPDIR
# -- debugging... 11/2021
echo "pwd is " `pwd`
echo `pwd` >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err


##-->cd ${WORKDIR}
##-->####################################################################################################
##-->#print the environment
##-->echo "Here is the your environment after setup: " >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err #Creates file for logging information, note that this is stdout only
##-->env >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err #since file already exists use ">>" instead of ">"
##-->####################################################################################################
##-->
##-->return 0
##-->
##-->#debugging...
##-->####################################################################################################
##-->#CONDOR stuff, only applicable when not running standalone
##-->if [ $STANDALONE -ne 1 ]; then 
##-->  ls -larth ${_CONDOR_JOB_IWD} >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err
##-->
##-->  echo "contents of the WORKDIR, i.e. _CONDOR_JOB_IWD = ${_CONDOR_JOB_IWD} :" >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err
##-->fi
##-->
##-->echo "ups active : " >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err
##-->ups active >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err
##-->####################################################################################################


# -- IFDH settings for timeout and max retries
export IFDH_GRIDFTP_EXTRA="-st 20" 
export IFDH_CP_MAXRETRIES=2
#export IFDH_DEBUG=1 #turn on debuggin information from ifdhc

# -- create output directories
ifdh ls ${BASE_DIR} 
# -- A non-zero exit value probably means it doesn't, so create it
if [ $? -ne 0 ]; then
  echo "Creating and adding permissions to ${BASE_DIR}" >> job_output_${CLUSTER}.${PROCESS}.log
	ifdh mkdir ${BASE_DIR} >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err
	ifdh chmod 775 ${BASE_DIR}
else
	echo "Directory ${BASE_DIR} exists.. continuing.." 
	ifdh chmod 775 ${BASE_DIR}
fi

#create new directory for cluster
ifdh mkdir ${BASE_DIR}/${CLUSTER} >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err
#change permissions
ifdh chmod 775 ${BASE_DIR}/${CLUSTER}

#create new directory for reco
#ifdh mkdir ${BASE_DIR}/${CLUSTER}/g4 >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err
#change permissions
#ifdh chmod 775 ${BASE_DIR}/${CLUSTER}/g4

#create new directory for ana
ifdh mkdir ${BASE_DIR}/${CLUSTER}/gen >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err
#change permissions
ifdh chmod 775 ${BASE_DIR}/${CLUSTER}/gen

#create new directory for ana
ifdh mkdir ${BASE_DIR}/${CLUSTER}/sim >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err
#change permissions
ifdh chmod 775 ${BASE_DIR}/${CLUSTER}/sim

##create new directory for skim
#ifdh mkdir ${BASE_DIR}/${CLUSTER}/skim >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err
##change permissions
#ifdh chmod 775 ${BASE_DIR}/${CLUSTER}/skim
#
##copy any other files/executables
##RadSkim executable
#ifdh cp -D "/pnfs/dune/resilient/users/${GRID_USER}/exec/${SKIM_VER}" `pwd`
#if [ $? -ne 0 ]; then
#        echo "ifdh cp failed!" >> job_output_${CLUSTER}.${PROCESS}.err
#else
#        echo "ifdh cp worked!" >> job_output_${CLUSTER}.${PROCESS}.log
#fi
#
##give executable permission to executables
#ifdh chmod a+rwx `pwd`/${SKIM_VER}

#unique event and run info to be able to locate specific events in the reco files
#For beam events it seems like the event number is used to extract an entry number from the root files
#will instead vary the run number to retain uniqueness between the different output files
#FIRST_EVT=$(( (${PROCESS}*${EVENTS_PER_RUN}) + 1))
FIRST_EVT=1
SUBRUN=1
RUN=$(( ${PROCESS} + 1 )) #make sure this is an integer
#RUN=$(( ${CLUSTER} )) #make sure this is an integer



###################event generation####################
STAGE=gen
echo "Entering ${STAGE} stage" >> ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.log 2>> ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.err

    #cd $LOCAL_LARSOFT_DIR
    #ifdh mkdir inputs
    #ifdh chmod 775 inputs/

    #ifdh mkdir inputs/protodune
    #ifdh chmod 775 inputs/protodune

#GEN_OUTPUT_DIR="${INPUT_TAR_DIR_LOCAL}/inputs/protodune"
PYTHON_SCRIPT_DIR="${INPUT_TAR_DIR_LOCAL}/generator/protodune/"

cd $PYTHON_SCRIPT_DIR

#GEN_OUTPUT_DIR="`pwd`/../../inputs/protodune"

echo "Python Script Dir contents:" >> ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.log 2>> ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.err
ifdh ls $PYTHON_SCRIPT_DIR >> ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.log 2>> ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.err

# -- set up the python environment w/ the needed dependencies
#cmd="python ${GEN_SCRIPT} pns_input_${CLUSTER}.${PROCESS}.dat ${GEN_OUTPUT_DIR}"
cmd="python ${GEN_SCRIPT} pns_input_${CLUSTER}.${PROCESS}.dat ${TEMPDIR}"
#pns_input_${CLUSTER}.${PROCESS}.dat"
source ${INPUT_TAR_DIR_LOCAL}/generator/protodune/bin/activate >> ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.log 2>> ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.err

ifdh ls `pwd` >> ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.log 2>> ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.err
#produce output files for this stage
echo $cmd >> ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.log 2>> ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.err
eval $cmd

echo "Exiting ${STAGE} stage" >> ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.log 2>> ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.err


#####################geant stage#######################
STAGE=sim
echo "Entering ${STAGE} stage" >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err

ifdh ls `pwd` >> ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.log 2>> ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.err

cd ${TEMPDIR}
cp ${INPUT_TAR_DIR_LOCAL}/fcl/protodune/${SIM_FHICL} ./

# -- override the input PNS file w/ the locally produced one
sed -i "\$aphysics.producers.PNS.InputFileName:   \"pns_input_$CLUSTER.$PROCESS.dat\"" ${SIM_FHICL}

ifdh ls `pwd` >> ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.log 2>> ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.err

cmd="lar -c ${SIM_FHICL} -n ${EVENTS_PER_RUN} -T ${PARTICLE_TYPE}_output_${STAGE}_file_${CLUSTER}.${PROCESS}.root >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err"
ifdh ls `pwd` >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err
#produce output files for current stage
echo $cmd >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err
eval $cmd

echo "Exiting ${STAGE} stage" >> job_output_${CLUSTER}.${PROCESS}.log 2>> job_output_${CLUSTER}.${PROCESS}.err


#######################################################

cd $TEMPDIR

echo "group = $GROUP"

if [ -z ${GRID_USER} ]; then
GRID_USER=`basename $X509_USER_PROXY | cut -d "_" -f 2`
fi

echo "GRID_USER = `echo $GRID_USER`"

#loop over stages of interest
for step in sim gen ; do
  #copy output files to corresponding destinations
  if [ -z "${BASE_DIR}/${CLUSTER}/${step}" ]; then
  	echo "Invalid dCache scratch directory, not copying back"
  	echo "I am going to dump the log file to the main job stdout in this case."
  	cat ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.log
  	cat ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.err
  else
  
  	# first do lfdh ls to check if directory exists
  	ifdh ls ${BASE_DIR}/${CLUSTER}/${step}
  	# A non-zero exit value probably means it doesn't, so create it
  	if [ $? -ne 0 ]; then
  	
  		echo "Unable to read ${BASE_DIR}/${CLUSTER}/${step}. Make sure that you have created this directory and given it group write permission (chmod g+w ${BASE_DIR}/${CLUSTER}/${step}."
  		exit 74
  	else
      if [ ${step} = sim ]; then
  		  #ifdh cp -D ${PARTICLE_TYPE}_output_${step}_file_${CLUSTER}.${PROCESS}.root ${BASE_DIR}/${CLUSTER}/${step}
        ifdh cp -D ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.log ${TEMPDIR}/job_output_${CLUSTER}.${PROCESS}.err ${BASE_DIR}/${CLUSTER}/${step}/
      elif [ ${step} = gen ]; then 
        ifdh cp -D ${TEMPDIR}/pns_input_${CLUSTER}.${PROCESS}.dat ${BASE_DIR}/${CLUSTER}/${step}/
  		#<--  ifdh cp -D ${PARTICLE_TYPE}_output_${step}_file_${CLUSTER}.${PROCESS}.root ${BASE_DIR}/${CLUSTER}/${step}
      #<--  ##ifdh cp outgoing_particles.tuple ${BASE_DIR}/${CLUSTER}/${step}/outgoing_particles_${CLUSTER}.${PROCESS}.tuple
      #<--  ##ifdh cp cascade_particles.tuple ${BASE_DIR}/${CLUSTER}/${step}/cascade_particles_${CLUSTER}.${PROCESS}.tuple
      fi

  		if [ $? -ne 0 ]; then
  	    		echo "Error $? when copying to dCache scratch area!"
  	    		echo "If you created ${BASE_DIR}/${CLUSTER}/${step} yourself,"
  	    		echo " make sure that it has group write permission."
  	    		exit 73
  		fi
  	fi 
  fi #end of check for non-existing output dir
done

echo "End `date`"

exit 0
