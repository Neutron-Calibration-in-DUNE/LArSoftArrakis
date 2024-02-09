#!/bin/bash
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

#----------------Setup everything else we need-----------------#
# These packages will setup all of their dependencies as well
# eg. setting up dune-sw will set up duneana and dunedataprep as well
setup dunesw $DUNE_VERSION -q $QUALS

#--------------------Create new development---------#
mrb newDev
source localProducts*/setup

#-----------------Specifying packages---------------#
# cd $MRB_SOURCE
# # here we check out the packages we intend to modify
# # e.g. duneana, where Arrakis lives
# mrb g dunecore@$DUNE_VERSION
# mrb g duneana@$DUNE_VERSION

# # cleanly add local copy of duneana to the CMakeLists.txt file for building
# mrb uc

# # Edit the geometry_dune.fcl file before building
# DUNE_GEOMETRY_FHICL=$MRB_SOURCE/dunecore/dunecore/Geometry/geometry_dune.fcl
# # Search for and delete the line containing END_PROLOG. This should be
# # at or near the end of the file.
# sed -i '/END_PROLOG/d'                                            $DUNE_GEOMETRY_FHICL
# # Add the ddg geometry info
# sed -i '$ a\# DDG geometry for Protodune-SP'                      $DUNE_GEOMETRY_FHICL
# sed -i '$ a\protodunev7_ddg_geo:         @local::protodunev7_geo' $DUNE_GEOMETRY_FHICL
# sed -i '$ a\protodunev7_ddg_geo.Name:    "protodunev7ddg"'        $DUNE_GEOMETRY_FHICL
# sed -i '$ a\protodunev7_ddg_geo.GDML:    "protodune_v7_ddg.gdml"' $DUNE_GEOMETRY_FHICL
# sed -i '$ a\protodunev7_ddg_geo.ROOT:    "protodune_v7_ddg.gdml"' $DUNE_GEOMETRY_FHICL
# # Add the END_PROLOG back in
# sed -i -e '$ a\\'                                                 $DUNE_GEOMETRY_FHICL
# sed -i '$ a\END_PROLOG'                                           $DUNE_GEOMETRY_FHICL


# #------------------Custom code part-----------------#
# # here we put any special code that needs to
# # be executed for the custom package.

# # set up arrakis
# cd $MRB_SOURCE/duneana/
# git clone https://github.com/Neutron-Calibration-in-DUNE/Arrakis
# cd Arrakis
# # checkout the tagged version for this version of LArsoft
# # TODO: should add a check for the tag
# git checkout $LARSOFT_VERSION -b $LARSOFT_VERSION

# cd $MRB_SOURCE/duneana/
# sed -i '$ a add_subdirectory(Arrakis)' CMakeLists.txt

# #------------------Installation and ninja-----------#
# cd $MRB_BUILDDIR
# mrbsetenv
# mrb install -j 16 --generator ninja

# #------------------Custom search and fcl------------#
# # here we specify any custom search paths and fcl
# # file paths that we want our installation to know about.
# CUSTOM_SEARCH_PATH="$LOCAL_LARSOFT_DIR/geometry/"
# CUSTOM_FHICL_PATH="$LOCAL_LARSOFT_DIR/fcl/"

# export FW_SEARCH_PATH="$FW_SEARCH_PATH:$CUSTOM_SEARCH_PATH"
# export FHICL_FILE_PATH="$FHICL_FILE_PATH:$CUSTOM_FHICL_PATH"


# cd $LOCAL_LARSOFT_DIR
