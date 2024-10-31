#!/bin/bash
set -u
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh
inc_dir=${dir_ocean_perturbations}/perturbation
mkdir -p ${inc_dir} && cd ${inc_dir}
echo "DOWNLOADING OCN INCREMENT data to ${inc_dir}"

############
# Ocean perturbation files on hpss
LN=${NENS}
#aws_ocn_increment_dir="https://noaa-oar-sfsdev-pds.s3.amazonaws.com/input/ocn_ice/mx100/ens_perts"
hpss_ocn_increment_dir=/ESRL/BMC/gsienkf/Permanent/UFS_replay_input/oras5_ocn/ensemble_perts/${OCNRES}
file_name=${hpss_ocn_increment_dir}/ocn_perts_for_SFS_${OCNRES}_${dtg:0:6}0100.tar
echo "DOWNLOADING: ${file_name}"
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
    dir_mem=${dir_ocean_perturbations/mem001/mem${mem}}
    mkdir -p ${dir_mem}
    pert_file=${inc_dir}/??????????/mem${mem}_pert.nc
    inc_file=${dir_mem}/${DTG_TEXT}.mom6_perturbation.nc
    mv ${pert_file} ${inc_file}
    if (( ${?} > 0 )); then
        echo 'ERROR in copying perturbation'
        echo "  mv ${pert_file} ${inc_file}"
        exit 1
    fi
done

if [[ ${LN} == 4 ]]; then
    dir_mem=${dir_ocean_perturbations/mem001/mem005}
    dir_mem001=${dir_ocean_perturbations}
    mkdir -p ${dir_mem} && cd ${dir_mem}
    cp ${dir_mem001}/${DTG_TEXT}.mom6_perturbation.nc .
fi
rm -r ${inc_dir}
echo 'OCN perturbation files downloaded and put into mem directories'
