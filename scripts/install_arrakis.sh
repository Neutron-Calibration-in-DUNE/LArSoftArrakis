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
LARSOFT_VERSION=v09_49_00
DUNE_VERSION=v09_49_00d00
QUALS=e20:prof

#--------------------Setup LArSoft------------------#
source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh
setup larsoft $LARSOFT_VERSION -q $QUALS
setup ninja

#--------------------Create new development---------#
mrb newDev
source localProducts*/setup

#-----------------Specifying packages---------------#
cd $MRB_SOURCE
# here we specify the packages we need
# e.g. 
# "mrb g larsoft@<version>"
# "mrb g larsim@<version>"
mrb g dunecore@$DUNE_VERSION
mrb g duneopdet@$DUNE_VERSION
mrb g dunesim@$DUNE_VERSION
mrb g dunecalib@$DUNE_VERSION
mrb g duneprototypes@$DUNE_VERSION
mrb g dunedataprep@$DUNE_VERSION
mrb g dunereco@$DUNE_VERSION
mrb g duneana@$DUNE_VERSION
mrb g duneexamples@$DUNE_VERSION
mrb g protoduneana@$DUNE_VERSION
mrb g dunesw@$DUNE_VERSION

#------------------Custom code part-----------------#
# here we put any special code that needs to
# be executed for the custom package.

# set up arrakis
cd $MRB_SOURCE/duneana/
git clone https://github.com/UC-Davis-Machine-Learning/Arrakis
sed -i '$ a add_subdirectory(Arrakis)' CMakeLists.txt

#------------------Installation and ninja-----------#
cd $MRB_BUILDDIR
mrbsetenv
mrb install -j 16 --generator ninja

#------------------Custom search and fcl------------#
# here we specify any custom search paths and fcl
# file paths that we want our installation to know about.
CUSTOM_SEARCH_PATH="$LOCAL_LARSOFT_DIR/geometry/"
CUSTOM_FHICL_PATH="$LOCAL_LARSOFT_DIR/fcl/"

export FW_SEARCH_PATH="$FW_SEARCH_PATH:$CUSTOM_SEARCH_PATH"
export FHICL_FILE_PATH="$FHICL_FILE_PATH:$CUSTOM_FHICL_PATH"

#cp $LOCAL_LARSOFT_DIR/geometry/geometry_dune.fcl $MRB_INSTALL/dunecore/$DUNE_VERSION/fcl/

cd $LOCAL_LARSOFT_DIR