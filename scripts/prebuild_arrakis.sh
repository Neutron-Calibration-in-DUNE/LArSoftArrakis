#! /bin/bash

#---------------------Directory---------------------#
# this handy piece of code determines the relative
# directory that this script is in.
SOURCE="${BASH_SOURCE[0]}"

# resolve $SOURCE until the file is no longer a symlink
while [ -h "$SOURCE" ]; do 
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  # if $SOURCE was a relative symlink, we need to resolve it relative 
  # to the path where the symlink file was located
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" 
done
export ARRAKIS_SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )/"

LOCAL_LARSOFT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )/../"
export ARRAKIS_LARSOFT_DIR=$LOCAL_LARSOFT_DIR

#---------------------Installation Directory--------#
INSTALL_DIRECTORY=$LOCAL_LARSOFT_DIR/larsoft
export ARRAKIS_INSTALL_DIR=$INSTALL_DIRECTORY

mkdir -p $INSTALL_DIRECTORY
cd $INSTALL_DIRECTORY

#--------------------Versioning---------------------#
# specify the version of the larsoft packages.
LARSOFT_VERSION=v09_75_00
DUNE_VERSION=v09_75_00d00
QUALS=e20:prof

#--------------------Setup LArSoft------------------#
source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh
setup larsoft $LARSOFT_VERSION -q $QUALS
setup dunesw $DUNE_VERSION -q $QUALS
cd $INSTALL_DIRECTORY
source localProducts*/setup


cd $MRB_SOURCE/duneana/Arrakis
git remote update origin --prune

echo -e "\nNewly set environment vars for Arrakis:"
echo -e "ARRAKIS_SCRIPT_DIR =$ARRAKIS_SCRIPT_DIR"
echo -e "ARRAKIS_LARSOFT_DIR=$ARRAKIS_LARSOFT_DIR"
echo -e "ARRAKIS_INSTALL_DIR=$ARRAKIS_INSTALL_DIR"
echo -e "\n====================SETUP SUCCESSFUL===================="
echo -e "Now you can proceed to checkout or make desired changes to Arrakis itself and then run the <rebuild-arrakis> bash function.\n"

# -- rebuild function that can be called once all changes have been made
function rebuild-arrakis()
{

  if [[ -v ARRAKIS_SCRIPT_DIR ]]; then
    cd $ARRAKIS_SCRIPT_DIR
  else
    echo -e "ARRAKIS_SCRIPT_DIR is NOT set. run <source prebuild_arrakis.sh> before continuing"
    return 1
  fi

  if [[ -z "$ARRAKIS_LARSOFT_DIR" ]]; then
    echo -e "ARRAKIS_LARSOFT_DIR is NOT set. run <source prebuild_arrakis.sh> before continuing"
    return 1
  fi


  #--------------------Set up---------------------#
  if [[ -v ARRAKIS_INSTALL_DIR ]]; then
    cd $ARRAKIS_INSTALL_DIR
    source localProducts*/setup
  else
    echo -e "ARRAKIS_INSTALL_DIR is NOT set. run <source prebuild_arrakis.sh> before continuing"
    return 1
  fi

  #--------------------Rebuild------------------------#
  cd $MRB_BUILDDIR
  mrbsetenv

  ninja -C $MRB_BUILDDIR -j 16 install

  #------------------Custom search and fcl------------#
  # here we specify any custom search paths and fcl
  # file paths that we want our installation to know about.
  CUSTOM_SEARCH_PATH="$ARRAKIS_LARSOFT_DIR/geometry/"
  CUSTOM_FHICL_PATH="$ARRAKIS_LARSOFT_DIR/fcl/"
  
  export FW_SEARCH_PATH="$FW_SEARCH_PATH:$CUSTOM_SEARCH_PATH"
  export FHICL_FILE_PATH="$FHICL_FILE_PATH:$CUSTOM_FHICL_PATH"
  
  cd $ARRAKIS_LARSOFT_DIR

  return 0
}
