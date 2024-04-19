#!/bin/bash
set -u
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh
inc_dir=${IC_DIR}/${dtg}/ocean/increments
mkdir -p ${inc_dir} && cd ${inc_dir}
echo "DOWNLOADING OCN INCREMENT data to ${inc_dir}"
cd ${inc_dir}
file_name=${hpss_ocn_increment_dir}/ocn_perts_4mem_C384_${dtg}.tar
htar -xvf ${file_name}
if (( ${?} > 0 )); then
    echo 'ERROR in htar, file likely does not exist'
    echo '  file_name:', ${file_name}
    exit 1
fi

########################
# copy increment files to directories
for n in {1..4}; do
    # copy file to correct directory
    mem=$(printf "%03d" ${n})
    dir=${IC_DIR}/${dtg}/mem${mem}/ocean
    mkdir -p ${dir}
    inc_file=${dir}/${DTG_TEXT}.mom6_increment.nc
    cp ${inc_dir}/${dtg}/mem00${n}_pert.nc ${inc_file}
    if (( ${?} > 0 )); then
        echo 'ERROR in copying increment'
        echo "  cp ${inc_dir}/${dtg}/mem00${n}_pert.nc ${inc_file}"
        exit 1
    fi
    # link to another member
    i=$(( n + 4 ))
    mem=$(printf "%03d" ${i})
    dir=${IC_DIR}/${dtg}/mem${mem}/ocean
    mkdir -p ${dir}
    ln -sf ${inc_file} ${dir}
done

############
# members 9 and 10 also need files
for n in {1..2}; do
    mem=$(printf "%03d" ${n})
    in_file=${IC_DIR}/${dtg}/mem${mem}/ocean/${DTG_TEXT}.mom6_increment.nc
    i=$(( n + 8 ))
    mem=$(printf "%03d" ${i})
    out_file=${IC_DIR}/${dtg}/mem${mem}/ocean/${DTG_TEXT}.mom6_increment.nc
    mkdir -p $(dirname ${out_file})
    ln -sf ${in_file} ${out_file}
done

ls ${IC_DIR}/${dtg}/mem???/ocean/${DTG_TEXT}.mom6_increment.nc
rm -r ${inc_dir}/../
echo 'OCN increment files downloaded and put into mem directories'
exit 0
