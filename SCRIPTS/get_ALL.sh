#!/bin/sh
set -u
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/defaults.sh

dir=${IC_DIR}/${dtg}/mem000
mkdir -p ${dir} && cd ${dir}

echo "DOWNLOADING C96 Replay Restarts to ${dir}"
dir_hpss="/NCEPDEV/cpcnudge/5year/Yan.1.Wang/ERA5_ORAS5_replay_C96mx100/RESTART_FILES"
htar -xvf ${dir_hpss}/${dtg:0:8}06.tar

# location of restart files in tar file
RESTART_DIR=${dir}/${dtg:0:8}06/control/INPUT
cd ${RESTART_DIR}

# atmos file
IC_DIR=${dir}/atmos && mkdir -p ${IC_DIR}
atmos_files='ca_data* fv_core* fv_srf_wnd* fv_tracer* phy_data* sfc_data*'
files=$( ls ${atmos_files} )
for f in ${files}; do
    cp ${f} ${IC_DIR}/${DTG_TEXT}.${f}
done
touch ${IC_DIR}/${DTG_TEXT}.coupler.res

# ocean file
IC_DIR=${dir}/ocean && mkdir -p ${IC_DIR}
ocean_file='MOM.res.nc'
f=$( ls ${ocean_file} )
cp ${f} ${IC_DIR}/${DTG_TEXT}.${f}

# ice file
IC_DIR=${dir}/ice && mkdir -p ${IC_DIR}
ice_file='iced*.nc'
f=$( ls ${ice_file} )
cp ${f} ${IC_DIR}/${DTG_TEXT}.cice_model.res.nc

# med file
IC_DIR=${dir}/med && mkdir -p ${IC_DIR}
med_file='ufs.cpld.cpl.r*.nc'
f=$( ls ${med_file} )
cp ${f} ${IC_DIR}/${DTG_TEXT}.ufs.cpld.cpl.r.nc


# wave file from outside of tar
#   wave_file='restart.ww3'

# remove
rm -r ${dir}/${dtg:0:8}06
