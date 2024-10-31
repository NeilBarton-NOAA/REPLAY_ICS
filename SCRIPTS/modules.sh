#!/bin/sh
set -u
PYTHON_PATH=/scratch2/NCEPDEV/stmp3/Neil.Barton/TOOLS/miniconda3/bin
PATH=${PYTHON_PATH}:${PATH}
export PYTHON=${PYTHON_PATH}/python3

set +x
module purge
module load hpss
module load globus-cli
module use -a /scratch2/NCEPDEV/nwprod/hpc-stack/libs/hpc-stack/modulefiles/stack
module load hpc/1.1.0
module load hpc-intel/2022.1.2 
module load nco/4.9.1
set -x
