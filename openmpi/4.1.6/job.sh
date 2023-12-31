#!/bin/bash -eu
#PBS -l select=1:ncpus=4
#PBS -l walltime=24:00:00

# Parameters
software_kind=util
name=openmpi
version=4.1.6
PBS_EXEC=/opt/openpbs

PREFIX=$PREFIX_APP_DIR/packages/$software_kind/$name/$version

WORK_DIR=/lwork/users/$USER/$PBS_JOBID
cd $WORK_DIR

# Download source
wget "https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-${version}.tar.bz2"

# Build
tar -xvf openmpi-${version}.tar.bz2
cd openmpi-${version}

./configure \
    --prefix=$PREFIX
make -j `nproc`
make install

# Create modulefile
module_file_path=$PREFIX_APP_DIR/modules/$software_kind/$name/$version
mkdir -p `dirname $module_file_path`
# Set template variables
# Commands below assume that TEMPLATE_PREFIX is used in template_modulefile
export TEMPLATE_PREFIX=$PREFIX
envsubst '$TEMPLATE_PREFIX' \
    < $APPLICATION_REPOSITORY_PATH/$name/template_modulefile \
    > $module_file_path

## Ensure all users have executable permission for all directories
## and read permission for all files
find $PREFIX_APP_DIR/modules/$software_kind/$name -type d -exec chmod 755 {} \;
chmod 644 $PREFIX_APP_DIR/modules/$software_kind/$name/$version
