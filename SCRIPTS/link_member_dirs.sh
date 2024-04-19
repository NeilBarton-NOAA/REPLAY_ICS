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
for i in $(seq 1 ${NENS}); do
    mem=$(printf "%03d" ${i})
    out_dir=${IC_DIR}/${dtg}/mem${mem}
    # atmos files
    model=atmos && dir=${out_dir}/${model} 
    mkdir -p ${dir} && cd ${dir}
    for f in ${atm_files}; do
        ln -sf ../../mem000/${model}/${DTG_TEXT}.${f}*nc .
    done
    # ocean files
    model=ocean && dir=${out_dir}/${model} 
    mkdir -p ${dir} && cd ${dir}
    ln -sf ../../mem000/${model}/${DTG_TEXT}.${ocn_file}*nc .
    # ice file
    model=ice && dir=${out_dir}/${model} 
    mkdir -p ${dir} && cd ${dir}
    ln -sf ../../mem000/${model}/${DTG_TEXT}.${ice_file} .
    # wav file
    model=wave && dir=${out_dir}/${model} 
    mkdir -p ${dir} && cd ${dir}
    ln -sf ../../mem000/${model}/${DTG_TEXT}.${wav_file}* .
    # med file
    model=med && dir=${out_dir}/${model} 
    mkdir -p ${dir} && cd ${dir}
    ln -sf ../../mem000/${model}/${DTG_TEXT}.${med_file} .
done
