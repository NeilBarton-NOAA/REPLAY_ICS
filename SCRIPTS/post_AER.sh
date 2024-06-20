#!/bin/bash
set -xu
dtg=${1}

SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh
dir=${IC_DIR}/${dtg}/mem000/atmos

echo "Adding Aerosols to FV3 Files in ${dir}"

dir_aer_code=${CODE_DIR}/MERRA2_UFS_ICS
if [[ ! -d ${dir_aer_code} ]]; then
    echo "Checking out Code"
    mkdir -p ${CODE_DIR} && cd ${CODE_DIR}
    git clone https://github.com/noaa-oar-arl/MERRA2_UFS_ICS
fi

############
# download data
cd ${dir}
https=https://goldsmr5.gesdisc.eosdis.nasa.gov/data/MERRA2/M2I3NVAER.5.12.4/${dtg:0:4}/${dtg:4:2}/
MN=400
if (( ${dtg} < 2001010100 )); then
 MN=200
fi
if (( ${dtg} > 2000123100 )) && (( ${dtg} < 2011010100 )); then
 MN=300
fi
if (( ${dtg} > 2021060200 )) && (( ${dtg} < 2021100700 )); then
 MN=401
fi
merra_file=MERRA2_${MN}.inst3_3d_aer_Nv.${dtg:0:8}.nc4

HSI_DIR=/NCEPDEV/emc-marine/1year/Neil.Barton/MERRA2_INST_3D_AERO
hsi -q get ${merra_file} : ${HSI_DIR}/${merra_file} 2>/dev/null

if [ ! -f ${merra_file} ]; then #2nd try, download from Barry's directory
    # first try to download from HPSS
    htar -xvf /NCEPDEV/emc-naqfc/5year/Barry.Baker/MERRA2_INST_3D_AERO/MERRA2_400.inst_3d_aero_Nv.${dtg:0:4}.nc4 ${merra_file}
fi

if [ ! -f ${merra_file} ]; then #3rd try, download from MERRA Server
    # if doesn't exist wget from server
    #   needs to be set up to download
    #       (1) EARTHDATA LOGIN https://urs.earthdata.nasa.gov/
    #       (2) NASA GESDISC DATA ARCHIVE added to Approved Applications
    #       (3) username and password in ~/.netrc
    wget --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --keep-session-cookies -r -c -nH -nd -np -A nc4 --content-disposition "${https}${merra_file}"
    # save file as it takes a while to download from NASA
    hsi -q put ${merra_file} : ${HSI_DIR}/${merra_file} 2>/dev/null
fi
if [ ! -f ${merra_file} ]; then
    echo "FAILURE in downloading MERRA file: ${merra_file}"
    echo "  https://goldsmr5.gesdisc.eosdis.nasa.gov/data/MERRA2/M2I3NVAER.5.12.4/${dtg:0:4}/${dtg:4:2}/${merra_file}"
    echo "  or "
    echo "  htar -xvf /NCEPDEV/emc-naqfc/5year/Barry.Baker/MERRA2_INST_3D_AERO/MERRA2_400.inst_3d_aero_Nv.${dtg:0:4}.nc4"
    exit 1
fi

###########
# add data to fv_core files
if [[ ${C96_REPLAY} == 'True' ]]; then
    ATMRES_POSTAER=C96
else
    ATMRES_POSTAER=C384
fi
for i in {1..6}; do 
    ${dir_aer_code}/merra2_to_ufs_cubesphere_restarts.py -m ${merra_file} -c ${DTG_TEXT}.fv_core.res.nc -t ${DTG_TEXT}.fv_tracer.res.tile${i}.nc -r ${ATMRES_POSTAER} -cyc 1
    if (( ${?} > 0 )); then
        echo "merra2_to_ufs_cubsphere_restarts.py failed"
        exit 1
    fi
done

############
# remove checksum in files or code will fail
files=$( ls *fv_tracer*.nc )
for f in ${files}; do 
    ncatted -a checksum,,d,, ${f}
    if (( ${?} > 0 )); then
        echo 'ncatted command failed'
        exit 1
    fi
done

############
# clean up files
rm ${merra_file}
rm ${DTG_TEXT}.fv_tracer.res.tile?.nc.old
echo "AEROSOLS added to fv_tracer files"
