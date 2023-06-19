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
LOCAL_LARSOFT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )/../"

#---------------------Installation Directory--------#
INSTALL_DIRECTORY=$LOCAL_LARSOFT_DIR/larsoft
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
setup ninja
cd $INSTALL_DIRECTORY
source localProducts*/setup

cd $MRB_SOURCE/duneana/Arrakis
git pull

mrbslp

#--------------------Custom updating code-----------#
# here we specify how we want to update our custom
# larsoft, e.g. by pulling some information into
# a custom module:
#   $ cd $MRB_SOURCE/larsoft/MyCustomModule"
#   $ git pull

#--------------------Rebuild------------------------#
ninja -C $MRB_BUILDDIR -j 16 install

#------------------Custom search and fcl------------#
# here we specify any custom search paths and fcl
# file paths that we want our installation to know about.
CUSTOM_SEARCH_PATH="$LOCAL_LARSOFT_DIR/geometry/"
CUSTOM_FHICL_PATH="$LOCAL_LARSOFT_DIR/fcl/"

export FW_SEARCH_PATH="$FW_SEARCH_PATH:$CUSTOM_SEARCH_PATH"
export FHICL_FILE_PATH="$FHICL_FILE_PATH:$CUSTOM_FHICL_PATH"

cp $LOCAL_LARSOFT_DIR/geometry/geometry_dune.fcl $MRB_INSTALL/dunecore/$DUNE_VERSION/fcl/

cd $LOCAL_LARSOFT_DIR
