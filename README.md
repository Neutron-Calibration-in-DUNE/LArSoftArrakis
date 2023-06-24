# LArSoftArrakis

LArSoftArrakis is a development environment for Arrakis which contains scripts for installing and running the Arrakis module in a custom LArSoft install.

### Table of Contents

1. [ Getting the Repository ](#get)
2. [ Installing LArSoft and Arrakis ](#install)
     *  [ Updating Arrakis ](#update)
3. [ Basic Usage ](#usage)

<a name="get"></a>
## Getting the Repository

In the terminal, one can clone this repository by typing the command:

`git clone https://personal_username@github.com/Neutron-Calibration-in-DUNE/LArSoftArrakis.git`

This uses the HTTPS protocol. For environments (e.g. computing clusters) where one has to use the SSH protocol:

`git clone git@github.com:Neutron-Calibration-in-DUNE/LArSoftArrakis.git`

Anyone in the "Neutron-Calibration-in-DUNE" organization should be able to develop (push changes to the remote repository).

Please contact Nicholas Carrara or David Rivera about becoming involved in development before merging with the master branch. 

<a name="install"></a>
## Installing LArSoft and Arrakis
A set of scripts for installing and configuring LArSoftArrakis can be found in the [scripts folder](https://github.com/Neutron-Calibration-in-DUNE/LArSoftArrakis/tree/main/scripts).  The first script you will want to run for a fresh install is *prebuild_arrakis.sh*, 
```bash
[<user>@dunebuildXX:<LArSoftArrakis_DIR>]$ source scripts/prebuild_arrakis.sh 
```
Depending on which tagged version of LArSoftArrakis you are using, the associated LArSoft version should be defined in the *prebuild_arrakis.sh* file, e.g.
```bash
#--------------------Versioning---------------------#
# specify the version of the larsoft packages.
LARSOFT_VERSION=v09_75_00
DUNE_VERSION=v09_75_00d00
QUALS=e20:prof
```
If this step is successful you should see,
```bash
====================SETUP SUCCESSFUL====================
Now you can proceed to checkout or make desired changes to Arrakis itself and then run the <rebuild-arrakis> bash function.
```
You should then be able to run the *install_arrakis.sh* script,
```bash
[<user>@dunebuildXX:<LArSoftArrakis_DIR>]$ source scripts/install_arrakis.sh 
```
Which will compile Arrakis with the *duneana* and *dunecore* source.  

<a name="update"></a>
### Updating Arrakis
Once changes have been made to Arrakis, the LArsoftArrakis development directory can download and compile those changes using the *update_arrakis.sh* script,
```bash
[<user>@dunebuildXX:<LArSoftArrakis_DIR>]$ source scripts/update_arrakis.sh 
```

<a name="usage"></a>
## Basic Usage
