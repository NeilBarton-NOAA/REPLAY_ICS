#!/bin/bash
set -xu
dtg=${1}

SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh
dir=${IC_DIR}/${dtg}/mem000/atmos

echo "Adding Aerosols to FV3 Files in ${dir}"

dir_aer_code=${SCRIPT_DIR}/MERRA2_UFS_ICS
if [[ ! -d ${dir_aer_code} ]]; then
    echo "Checking out Code"
    cd ${SCRIPT_DIR}
    git clone https://github.com/noaa-oar-arl/MERRA2_UFS_ICS
fi

############
# download data
cd ${dir}
https=https://goldsmr5.gesdisc.eosdis.nasa.gov/data/MERRA2/M2I3NVAER.5.12.4/${dtg:0:4}/${dtg:4:2}/
MN=400
if [[ ${dtg:0:4} == "2008" ]]; then
 MN=300
fi
merra_file=MERRA2_${MN}.inst3_3d_aer_Nv.${dtg:0:8}.nc4
# first try to download from HPSS
htar -xvf /NCEPDEV/emc-naqfc/5year/Barry.Baker/MERRA2_INST_3D_AERO/MERRA2_400.inst_3d_aero_Nv.${dtg:0:4}.nc4 ${merra_file}
# if doesn't exist wget from server
#   needs to be set up to download
#       (1) EARTHDATA LOGIN https://urs.earthdata.nasa.gov/
#       (2) NASA GESDISC DATA ARCHIVE added to Approved Applications
#       (3) username and password in ~/.netrc
if [ ! -f ${merra_file} ]; then
    wget --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --keep-session-cookies -r -c -nH -nd -np -A nc4 --content-disposition "${https}${merra_file}"
fi
if [ ! -f ${merra_file} ]; then
    echo "FAILURE in downloading MERRA file: ${merra_file}"
    echo "  check comments in post_AER.sh script"
    exit 1
fi
###########
# add data to fv_core files
for i in {1..6}; do 
    ${dir_aer_code}/merra2_to_ufs_cubesphere_restarts.py -m ${merra_file} -c ${DTG_TEXT}.fv_core.res.nc -t ${DTG_TEXT}.fv_tracer.res.tile${i}.nc -r C384 -cyc 1
done
############
# clean up files
rm ${merra_file}
rm ${DTG_TEXT}.fv_tracer.res.tile?.nc.old
echo "AEROSOLS added to fv_tracer files"
