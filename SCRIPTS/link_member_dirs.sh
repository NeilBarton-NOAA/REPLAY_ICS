#!/bin/bash
set -xu
dtg=${1}

SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh

dir=${IC_DIR}/${dtg}/

atm_files='ca_data fv_core.res fv_srf_wnd.res fv_tracer.res phy_data sfc_data'
ocn_file="MOM.res"
ice_file="cice_model.res.nc"
wav_file="restart_"
med_file="ufs.cpld.cpl.r.nc"
    
in_dir=${IC_DIR}/${dtg}/mem000
for i in $(seq 1 ${NENS}); do
    mem=$(printf "%03d" ${i})
    out_dir=${IC_DIR}/${dtg}/mem${mem}
    # atmos files
    mkdir -p ${out_dir}/atmos
    for f in ${atm_files}; do
        ln -s ${in_dir}/atmos/${DTG_TEXT}.${f}*nc ${out_dir}/atmos/
    done
    # ocean files
    mkdir -p ${out_dir}/ocean
    ln -s ${in_dir}/ocean/${DTG_TEXT}.${ocn_file}*nc ${out_dir}/ocean
    echo 'NPB check'
    exit 1
    # ice file
    mkdir -p ${out_dir}/ice
    ln -s ${in_dir}/ice/${DTG_TEXT}.${ice_file} ${out_dir}/ice
    # wav file
    mkdir -p ${out_dir}/wave
    ln -s ${in_dir}/wave/${DTG_TEXT}.${wav_file}* ${out_dir}/wave
    # med file
    mkdir -p ${out_dir}/med
    ln -s ${in_dir}/med/${DTG_TEXT}.${med_file} ${out_dir}/med
done
