#!/bin/bash
set -u
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh
inc_dir=${IC_DIR}/${dtg}/atmos/increments
mkdir -p ${inc_dir} && cd ${inc_dir}
echo "DOWNLOADING ATM INCREMENT data to ${inc_dir}"
cd ${inc_dir}
file_name=${hpss_atm_increment_dir}/C384_era5anl_5mem_${dtg:0:8}03_inc.tar
htar -xvf ${file_name}
if (( ${?} > 0 )); then
    echo 'ERROR in htar, file likely does not exist'
    echo '  file_name:', ${file_name}
    exit 1
fi

########################
# copy increment files to directories
for n in {1..5}; do
    # copy file to correct directory
    mem=$(printf "%03d" ${n})
    dir=${IC_DIR}/${dtg}/mem${mem}/atmos
    mkdir -p ${dir}
    i=$(( n + 4 ))
    inc_file=${dir}/${DTG_TEXT}.fv3_increment.nc
    cp ${inc_dir}/C384_era5anl_inc${i}_${dtg:0:8}03.nc ${inc_file}
    if (( ${?} > 0 )); then
        echo 'ERROR in coping increment'
        echo "  cp ${inc_dir}/C384_era5anl_inc${i}_${dtg:0:8}03.nc ${inc_file}"
        exit 1
    fi
    # link to another member
    i=$(( i + 1 ))
    mem=$(printf "%03d" ${i})
    dir=${IC_DIR}/${dtg}/mem${mem}/atmos
    mkdir -p ${dir}
    ln -sf ${inc_file} ${dir}
done

ls ${IC_DIR}/${dtg}/mem???/atmos/${DTG_TEXT}.fv3_increment.nc
rm -r ${inc_dir}/../
echo 'ATM increment files downloaded and put into mem directories'
exit 0
