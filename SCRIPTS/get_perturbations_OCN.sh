#!/bin/bash
set -u
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh
inc_dir=${IC_DIR}/${dtg}/ocean/perturbation
mkdir -p ${inc_dir} && cd ${inc_dir}
echo "DOWNLOADING OCN INCREMENT data to ${inc_dir}"

############
# Ocean perturbation files on hpss
if [[ ${OCNRES} == "mx100" ]]; then
    hpss_ocn_increment_dir=/ESRL/BMC/gsienkf/Permanent/UFS_replay_input/oras5_ocn/ensemble_perts/mx100/
    file_name=${hpss_ocn_increment_dir}/ocn_perts_for_SFS_mx100_${dtg}.tar
    LN=10
    #aws_ocn_increment_dir="https://noaa-oar-sfsdev-pds.s3.amazonaws.com/input/ocn_ice/mx100/ens_perts"
elif [[ ${OCNRES} == "mx025" ]]; then
    hpss_ocn_increment_dir=/ESRL/BMC/gsienkf/2year/Philip.Pegion/ocean_ensemble_perts/C384
    f_dtg=${dtg}
    if [[ ${dtg:0:4} == 2021 ]]; then
        f_dtg=2010${dtg:4:6}
    fi
    if [[ ${NENS} == 10 ]]; then
        file_name=${hpss_ocn_increment_dir}/ocn_perts_C384_${f_dtg}.tar
        LN=10
    else
        file_name=${hpss_ocn_increment_dir}/ocn_perts_4mem_C384_${f_dtg}.tar
        LN=4
    fi
else
    echo 'No perturbation files for this ocean resolution', ${OCNRES}
    exit 1
fi

htar -xvf ${file_name}
if (( ${?} > 0 )); then
    echo 'ERROR in htar, file likely does not exist'
    echo '  file_name:', ${file_name}
    exit 1
fi
if [[ ${dtg:0:4} == 2021 ]]; then
    mv ${f_dtg} ${dtg}
fi

########################
# copy increment files to directories
for n in $( seq 1 ${LN} ); do
    # copy file to correct directory
    mem=$(printf "%03d" ${n})
    dir=${IC_DIR}/${dtg}/mem${mem}/ocean
    mkdir -p ${dir}
    inc_file=${dir}/${DTG_TEXT}.mom6_perturbation.nc
    mv ${inc_dir}/${dtg}/mem${mem}_pert.nc ${inc_file}
    if (( ${?} > 0 )); then
        echo 'ERROR in copying perturbation'
        echo "  mv ${inc_dir}/${dtg}/mem${mem}_pert.nc ${inc_file}"
        exit 1
    fi
done

if [[ ${LN} == 4 ]]; then
    dir=${IC_DIR}/${dtg}/mem005/ocean
    mkdir -p ${dir} && cd ${dir}
    ln -s ../../mem001/ocean/${DTG_TEXT}.mom6_perturbation.nc .
fi

ls ${IC_DIR}/${dtg}/mem???/ocean/${DTG_TEXT}.mom6_perturbation.nc
rm -r ${IC_DIR}/${dtg}/ocean
echo 'OCN perturbation files downloaded and put into mem directories'
