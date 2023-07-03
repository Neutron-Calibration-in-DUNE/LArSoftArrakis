#!/bin/bash
####################################################################################################
## -- D.R. 6/20/2023
## job submission script for the grid
## Can also be used to do a local (standlone) test run on the gpvms
####################################################################################################

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
NUMBER_OF_RUNS=1
NEUTRONS_PER_EVENT=1450
BASE_NAME="prod_pns_neutrons_Arrakis_v3"
DESTINATION=scratch
GEN_SCRIPT=generate_neutrons_protodune.py #creates the .dat files
SIM_FHICL=protodune_full_sim_arrakis.fcl
#destination is to choose between scratch and persistent

JOB_NAME=${BASE_NAME}
BASE_DIR=/pnfs/dune/${DESTINATION}/users/${GRID_USER}/Arrakis/${LARSOFT_VERSION}/${BASE_NAME}
####################################################################################################

# -- setup base env
source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh
setup dunesw $DUNE_VERSION -q $QUALS

if [ x$IFDHC_DIR = x ]; then
  setup ifdhc
fi

# -- IFDH settings for timeout and max retries
export IFDH_GRIDFTP_EXTRA="-st 20" 
export IFDH_CP_MAXRETRIES=2
#export IFDH_DEBUG=1 #turn on debuggin information from ifdhc

# -- log files
LOG_FILE="job_output_${CLUSTER}.${PROCESS}.log"
ERR_FILE="job_output_${CLUSTER}.${PROCESS}.err"

####################################################################################################
#print the initial environment
echo "Here is the your initial environment in this job: " > ${LOG_FILE} 2> ${ERR_FILE} #Creates file for logging information, note that this is stdout only
env >> ${LOG_FILE} 2>> ${ERR_FILE} #since file already exists use ">>" instead of ">"
echo "################################################################################" >> ${LOG_FILE}
####################################################################################################
# -- TARBALL SETUP

#tar file should be unpacked if passed to the jobsub_submit command with argument: --tar_file_name
# TAR_FILE should be copied and unpacked according to the jobsub_submit command description
# "TAR_FILE will be accessible to the user job on the worker node via the environment variable $INPUT_TAR_FILE.
# The unpacked contents will be in the same directory as $INPUT_TAR_FILE."
# The tarball contents will be placed in $INPUT_TAR_DIR_LOCAL.
# Note that the unpacked contents will be READ-ONLY. Don't run or create files/dirs within it

# -- Define the work dir
TEMPDIR=`pwd`
if [ $STANDALONE -ne 1 ]; then

  export WORKDIR=${_CONDOR_JOB_IWD} 
  if [ ! -d "$WORKDIR" ]; then
    export WORKDIR=`echo .`
  fi

  if [ x$INPUT_TAR_FILE != x ]; then
    # Setup the environment.
    echo "Input .tar file : ${INPUT_TAR_FILE}" >> ${LOG_FILE} 2>> ${ERR_FILE}
    pwd
    ls
    echo

    # -- setup-grid must be defined and placed alongside the normal setup script in the local prods
		if [ x$IFDHC_DIR = x ]; then
		  echo "Setting up ifdhc before fetching tarball." >> ${LOG_FILE} 2>> ${ERR_FILE}
		  setup ifdhc
		fi
    echo "IFDHC_DIR=$IFDHC_DIR" >> ${LOG_FILE} 2>> ${ERR_FILE}

    # -- setting up ARRAKIS and our local grid setup

    #---------------------Installation Directory--------#
    INSTALL_DIRECTORY=${INPUT_TAR_DIR_LOCAL}/${DIRECTORY}

    #------------------Setup our LArSoft----------------#
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
  else 
    echo "No tar file provided.. setting up dunesw + duneana and hope that your code is already there" >> ${LOG_FILE} 2>> ${ERR_FILE}
    setup dunesw $DUNE_VERSION -q $QUALS
    setup duneana $DUNE_VERSION -q $QUALS
  fi
fi

cd $TEMPDIR
# -- debugging... 11/2021
echo "pwd is " `pwd`
echo `pwd` >> ${LOG_FILE} 2>> ${ERR_FILE}



###############create output directories###############

ifdh ls ${BASE_DIR} 
# -- A non-zero exit value probably means it doesn't, so create it
if [ $? -ne 0 ]; then
  echo "Creating and adding permissions to ${BASE_DIR}" >> ${LOG_FILE}
	ifdh mkdir ${BASE_DIR} >> ${LOG_FILE} 2>> ${ERR_FILE}
	ifdh chmod 775 ${BASE_DIR}
else
	echo "Directory ${BASE_DIR} exists.. continuing.." 
	ifdh chmod 775 ${BASE_DIR}
fi

#create new directory for cluster
ifdh mkdir ${BASE_DIR}/${CLUSTER} >> ${LOG_FILE} 2>> ${ERR_FILE}
#change permissions
ifdh chmod 775 ${BASE_DIR}/${CLUSTER}

#create new directory for gen
ifdh mkdir ${BASE_DIR}/${CLUSTER}/gen >> ${LOG_FILE} 2>> ${ERR_FILE}
#change permissions
ifdh chmod 775 ${BASE_DIR}/${CLUSTER}/gen

#create new directory for sim
ifdh mkdir ${BASE_DIR}/${CLUSTER}/sim >> ${LOG_FILE} 2>> ${ERR_FILE}
#change permissions
ifdh chmod 775 ${BASE_DIR}/${CLUSTER}/sim



###################event generation####################
STAGE=gen
echo "Entering ${STAGE} stage" >> ${TEMPDIR}/${LOG_FILE} 2>> ${TEMPDIR}/${ERR_FILE}


PYTHON_SCRIPT_DIR="${INPUT_TAR_DIR_LOCAL}/generator/protodune/"
cd $PYTHON_SCRIPT_DIR

echo "Python Script Dir contents:" >> ${TEMPDIR}/${LOG_FILE} 2>> ${TEMPDIR}/${ERR_FILE}
ifdh ls $PYTHON_SCRIPT_DIR >> ${TEMPDIR}/${LOG_FILE} 2>> ${TEMPDIR}/${ERR_FILE}

# -- set up the python environment w/ the needed dependencies
cmd="python ${GEN_SCRIPT} --num_events ${EVENTS_PER_RUN} --num_neutrons ${NEUTRONS_PER_EVENT} --output_file pns_input_${CLUSTER}.${PROCESS} --output_dir ${TEMPDIR}/"
source ${INPUT_TAR_DIR_LOCAL}/generator/protodune/bin/activate >> ${TEMPDIR}/${LOG_FILE} 2>> ${TEMPDIR}/${ERR_FILE}

ifdh ls `pwd` >> ${TEMPDIR}/${LOG_FILE} 2>> ${TEMPDIR}/${ERR_FILE}
#produce output files for this stage
echo $cmd >> ${TEMPDIR}/${LOG_FILE} 2>> ${TEMPDIR}/${ERR_FILE}
eval $cmd

echo "Exiting ${STAGE} stage" >> ${TEMPDIR}/${LOG_FILE} 2>> ${TEMPDIR}/${ERR_FILE}


#####################geant stage#######################
STAGE=sim
echo "Entering ${STAGE} stage" >> ${LOG_FILE} 2>> ${ERR_FILE}

ifdh ls `pwd` >> ${TEMPDIR}/${LOG_FILE} 2>> ${TEMPDIR}/${ERR_FILE}

cd ${TEMPDIR}
cp ${INPUT_TAR_DIR_LOCAL}/fcl/protodune/${SIM_FHICL} ./

# -- override the input PNS file w/ the locally produced one
# -- NOTE: Assuming there will only be one input file per job at the moment
INPUT_NAME="pns_input_${CLUSTER}.${PROCESS}_${EVENTS_PER_RUN}_${NEUTRONS_PER_EVENT}_0.dat"
sed -i "\$aphysics.producers.PNS.InputFileName:   \"${INPUT_NAME}\"" ${SIM_FHICL}

ifdh ls `pwd` >> ${LOG_FILE} 2>> ${ERR_FILE}

cmd="lar -c ${SIM_FHICL} -n ${EVENTS_PER_RUN} -T ${PARTICLE_TYPE}_output_${STAGE}_file_${CLUSTER}.${PROCESS}.root >> ${LOG_FILE} 2>> ${ERR_FILE}"
echo "Working Dir contents: " >> ${LOG_FILE} 2>> ${ERR_FILE}
ifdh ls ./ >> ${LOG_FILE} 2>> ${ERR_FILE}

echo $cmd >> ${LOG_FILE} 2>> ${ERR_FILE}
eval $cmd

echo "Exiting ${STAGE} stage" >> ${LOG_FILE} 2>> ${ERR_FILE}


##################Copying files back####################

cd $TEMPDIR

echo "group = $GROUP"

if [ -z ${GRID_USER} ]; then
  GRID_USER=`basename $X509_USER_PROXY | cut -d "_" -f 2`
fi

echo "GRID_USER = `echo $GRID_USER`"

#loop over stages of interest
for stage in sim gen ; do
  #copy output files to corresponding destinations
  if [ -z "${BASE_DIR}/${CLUSTER}/${stage}" ]; then
  	echo "Invalid dCache scratch directory, not copying back"
  	echo "I am going to dump the log file to the main job stdout in this case."
  	cat ${LOG_FILE}
  	cat ${ERR_FILE}
  else
  
  	# first do lfdh ls to check if directory exists
  	ifdh ls ${BASE_DIR}/${CLUSTER}/${stage}
  	# A non-zero exit value probably means it doesn't, so create it
  	if [ $? -ne 0 ]; then
  	
  		echo "Unable to read ${BASE_DIR}/${CLUSTER}/${stage}. Make sure that you have created this directory and given it group write permission (chmod g+w ${BASE_DIR}/${CLUSTER}/${stage}."
  		exit 74
  	else
      if [ ${stage} = sim ]; then
  		  ifdh cp -D ${PARTICLE_TYPE}_output_${stage}_file_${CLUSTER}.${PROCESS}.root ${BASE_DIR}/${CLUSTER}/${stage}
        ifdh cp -D ${LOG_FILE} ${ERR_FILE} ${BASE_DIR}/${CLUSTER}/${stage}/
      elif [ ${stage} = gen ]; then 
        ifdh cp -D ${INPUT_NAME} ${BASE_DIR}/${CLUSTER}/${stage}/
      fi

  		if [ $? -ne 0 ]; then
  	    		echo "Error $? when copying to dCache scratch area!"
  	    		echo "If you created ${BASE_DIR}/${CLUSTER}/${stage} yourself,"
  	    		echo " make sure that it has group write permission."
  	    		exit 73
  		fi
  	fi 
  fi #end of check for non-existing output dir
done

echo "End `date`"

exit 0
