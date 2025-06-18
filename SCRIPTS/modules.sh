#!/bin/sh
set -u
set +x
module purge
module load Core/24.11
module load DefApps/default
module load nco/5.1.9
module use -a /usw/hpss/modulefiles
module load hsi
module use -a /ncrc/home2/Neil.Barton/TOOLS/modulefiles
module load conda
set -x
