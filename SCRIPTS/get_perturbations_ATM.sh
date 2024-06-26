#!/bin/bash
set -u
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh
inc_dir=${IC_DIR}/${dtg}/atmos/perturbation
mkdir -p ${inc_dir} && cd ${inc_dir}

echo "DOWNLOADING ATM INCREMENT data to ${inc_dir}"

########################
# Atmosphere perturbation files on hpss
if [[ ${ATMRES} == "C96" ]]; then
    hpss_atm_increment_dir=/ESRL/BMC/gsienkf/Permanent/UFS_replay_input/era5/C96_perts
    if [[ ${dtg:3:1} == 0 ]]; then
        EY=1
    else
        EY=0
    fi
    file_name=${hpss_atm_increment_dir}/atm_perts_for_SFS_${ATMRES}_${EY}${dtg:3:3}01.tar
else
    hpss_atm_increment_dir=/ESRL/BMC/gsienkf/2year/whitaker/era5/C384ensperts
    if [[ ${NENS} == 10 ]]; then
        file_name=${hpss_atm_increment_dir}/${ATMRES}_era5anl_${dtg:0:8}03_inc.tar
    else
        file_name=${hpss_atm_increment_dir}/${ATMRES}_era5anl_5mem_${dtg:0:8}03_inc.tar
    fi
fi

htar -xvf ${file_name}
if (( ${?} > 0 )); then
    echo 'ERROR in htar, file likely does not exist'
    echo '  file_name:', ${file_name}
    exit 1
fi
########################
# copy increment files to directories
for n in $( seq 1 ${NENS}); do
    # copy file to correct directory
    mem=$(printf "%03d" ${n})
    dir=${IC_DIR}/${dtg}/mem${mem}/atmos
    mkdir -p ${dir}
    if [[ ${NENS} == 10 ]]; then
        i=$(( n - 1 ))
    else
        i=$(( n + 4 ))
    fi
    inc_file=${dir}/${DTG_TEXT}.fv3_perturbation.nc
    if [[ ${ATMRES} == "C96" ]]; then
        hpss_file=${inc_dir}/${EY}${dtg:3:3}01/${ATMRES}_era5anl_mem${mem}_${EY}${dtg:3:3}01.nc 
    else
        hpss_file=${inc_dir}/${ATMRES}_era5anl_inc${i}_${dtg:0:8}03.nc 
    fi
    mv ${hpss_file} ${inc_file}
    if (( ${?} > 0 )); then
        echo 'ERROR in copying perturbation'
        echo "  mv ${hpss_file} ${inc_file}"
        exit 1
    fi
done

ls ${IC_DIR}/${dtg}/mem???/atmos/${DTG_TEXT}.fv3_perturbation.nc
rm -r ${IC_DIR}/${dtg}/atmos
echo 'ATM perturbation files downloaded and put into mem directories'
exit 0
