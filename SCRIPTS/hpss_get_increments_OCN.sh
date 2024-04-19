#!/bin/bash
set -u
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh
inc_dir=${IC_DIR}/${dtg}/ocean/increments
mkdir -p ${inc_dir} && cd ${inc_dir}
echo "DOWNLOADING OCN INCREMENT data to ${inc_dir}"
cd ${inc_dir}
if [[ ${NENS} == 10 ]]; then
    file_name=${hpss_ocn_increment_dir}/ocn_perts_C384_${dtg}.tar
    LN=10
else
    file_name=${hpss_ocn_increment_dir}/ocn_perts_4mem_C384_${dtg}.tar
    LN=4
fi
htar -xvf ${file_name}
if (( ${?} > 0 )); then
    echo 'ERROR in htar, file likely does not exist'
    echo '  file_name:', ${file_name}
    exit 1
fi
########################
# copy increment files to directories
for n in $( seq 1 ${LN} ); do
    # copy file to correct directory
    mem=$(printf "%03d" ${n})
    dir=${IC_DIR}/${dtg}/mem${mem}/ocean
    mkdir -p ${dir}
    inc_file=${dir}/${DTG_TEXT}.mom6_increment.nc
    mv ${inc_dir}/${dtg}/mem${mem}_pert.nc ${inc_file}
    if (( ${?} > 0 )); then
        echo 'ERROR in copying increment'
        echo "  mv ${inc_dir}/${dtg}/mem${mem}_pert.nc ${inc_file}"
        exit 1
    fi
done

if [[ ${LN} == 4 ]]; then
    dir=${IC_DIR}/${dtg}/mem005/ocean
    mkdir -p ${dir} && cd ${dir}
    ln -s ../../mem001/ocean/${DTG_TEXT}.mom6_increment.nc .
fi

ls ${IC_DIR}/${dtg}/mem???/ocean/${DTG_TEXT}.mom6_increment.nc
rm -r ${IC_DIR}/${dtg}/ocean
echo 'OCN increment files downloaded and put into mem directories'
exit 0
