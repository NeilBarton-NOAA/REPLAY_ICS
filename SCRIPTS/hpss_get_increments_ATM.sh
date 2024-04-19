#!/bin/bash
set -u
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh
inc_dir=${IC_DIR}/${dtg}/atmos/increments
mkdir -p ${inc_dir} && cd ${inc_dir}
echo "DOWNLOADING ATM INCREMENT data to ${inc_dir}"
cd ${inc_dir}
if [[ ${NENS} == 10 ]]; then
    file_name=${hpss_atm_increment_dir}/C384_era5anl_${dtg:0:8}03_inc.tar
else
    file_name=${hpss_atm_increment_dir}/C384_era5anl_5mem_${dtg:0:8}03_inc.tar
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
    inc_file=${dir}/${DTG_TEXT}.fv3_increment.nc
    mv ${inc_dir}/C384_era5anl_inc${i}_${dtg:0:8}03.nc ${inc_file}
    if (( ${?} > 0 )); then
        echo 'ERROR in coping increment'
        echo "  mv ${inc_dir}/C384_era5anl_inc${i}_${dtg:0:8}03.nc ${inc_file}"
        exit 1
    fi
done

ls ${IC_DIR}/${dtg}/mem???/atmos/${DTG_TEXT}.fv3_increment.nc
rm -r ${IC_DIR}/${dtg}/atmos
echo 'ATM increment files downloaded and put into mem directories'
exit 0
