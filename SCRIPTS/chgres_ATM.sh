#!/bin/sh
set -xu
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh
compiler=${chgres_compiler}
dir=${IC_DIR}/${dtg}/mem000/atmos
export DATA=${dir}
SRC_ATMRES="C384"
SRC_OCNRES="mx025"

cd ${DATA}
########################
# chgres_cube.sh options
export HOMEufs=${CODE_DIR}/UFS_UTILS
export INPUT_TYPE="restart"
export COMIN=${dir} 
export CDATE=${dtg:0:8}03
export ocn=${OCNRES:2:3}
export VCOORD_FILE="${HOMEufs}/fix/am/global_hyblev.l128.txt"
export MOSAIC_FILE_INPUT_GRID="${HOMEufs}/fix/orog/${SRC_ATMRES}/${SRC_ATMRES}_mosaic.nc"
export MOSAIC_FILE_TARGET_GRID="${HOMEufs}/fix/orog/${ATMRES}/${ATMRES}_mosaic.nc"
export OROG_DIR_INPUT_GRID="${HOMEufs}/fix/orog/${SRC_ATMRES}"
export OROG_DIR_TARGET_GRID="${HOMEufs}/fix/orog/${ATMRES}"

F=""
F=${F}${SRC_ATMRES}.${SRC_OCNRES}'_oro_data.tile1.nc","'
F=${F}${SRC_ATMRES}.${SRC_OCNRES}'_oro_data.tile2.nc","'
F=${F}${SRC_ATMRES}.${SRC_OCNRES}'_oro_data.tile3.nc","'
F=${F}${SRC_ATMRES}.${SRC_OCNRES}'_oro_data.tile4.nc","'
F=${F}${SRC_ATMRES}.${SRC_OCNRES}'_oro_data.tile5.nc","'
F=${F}${SRC_ATMRES}.${SRC_OCNRES}'_oro_data.tile6.nc'
export OROG_FILES_INPUT_GRID=${F}

F=""''
F=${F}${DTG_TEXT}'.fv_core.res.tile1.nc","'
F=${F}${DTG_TEXT}'.fv_core.res.tile2.nc","'
F=${F}${DTG_TEXT}'.fv_core.res.tile3.nc","'
F=${F}${DTG_TEXT}'.fv_core.res.tile4.nc","'
F=${F}${DTG_TEXT}'.fv_core.res.tile5.nc","'
F=${F}${DTG_TEXT}'.fv_core.res.tile6.nc","'
F=${F}${DTG_TEXT}'.fv_core.res.nc'
export ATM_CORE_FILES_INPUT=${F}

F=""
F=${F}${DTG_TEXT}'.fv_tracer.res.tile1.nc","'
F=${F}${DTG_TEXT}'.fv_tracer.res.tile2.nc","'
F=${F}${DTG_TEXT}'.fv_tracer.res.tile3.nc","'
F=${F}${DTG_TEXT}'.fv_tracer.res.tile4.nc","'
F=${F}${DTG_TEXT}'.fv_tracer.res.tile5.nc","'
F=${F}${DTG_TEXT}'.fv_tracer.res.tile6.nc'
export ATM_TRACER_FILES_INPUT=${F}

F=""
F=${F}${DTG_TEXT}'.sfc_data.tile1.nc","'
F=${F}${DTG_TEXT}'.sfc_data.tile2.nc","'
F=${F}${DTG_TEXT}'.sfc_data.tile3.nc","'
F=${F}${DTG_TEXT}'.sfc_data.tile4.nc","'
F=${F}${DTG_TEXT}'.sfc_data.tile5.nc","'
F=${F}${DTG_TEXT}'.sfc_data.tile6.nc'
export SFC_FILES_INPUT=${F}

F=""
F=${F}''${ATMRES}.${OCNRES}'_oro_data.tile1.nc","'
F=${F}''${ATMRES}.${OCNRES}'_oro_data.tile2.nc","'
F=${F}''${ATMRES}.${OCNRES}'_oro_data.tile3.nc","'
F=${F}''${ATMRES}.${OCNRES}'_oro_data.tile4.nc","'
F=${F}''${ATMRES}.${OCNRES}'_oro_data.tile5.nc","'
F=${F}''${ATMRES}.${OCNRES}'_oro_data.tile6.nc'
export OROG_FILES_TARGET_GRID=${F}

########################
# modules
module purge
module use ${HOMEufs}/modulefiles
module load build.hera.${compiler}

mkdir -p ${COMIN}/CHGRES
cd ${COMIN}/CHGRES
############
cat << EOF > fort.41

&config
 fix_dir_target_grid="${OROG_DIR_TARGET_GRID}/sfc"
 mosaic_file_target_grid="${MOSAIC_FILE_TARGET_GRID}"
 orog_dir_target_grid="${OROG_DIR_TARGET_GRID}"
 orog_files_target_grid="${OROG_FILES_TARGET_GRID}"
 mosaic_file_input_grid="${MOSAIC_FILE_INPUT_GRID}"
 orog_dir_input_grid="${OROG_DIR_INPUT_GRID}"
 orog_files_input_grid="${OROG_FILES_INPUT_GRID}"
 data_dir_input_grid="${COMIN}"
 atm_core_files_input_grid="${ATM_CORE_FILES_INPUT}"
 atm_tracer_files_input_grid="${ATM_TRACER_FILES_INPUT}"
 vcoord_file_target_grid="${VCOORD_FILE}"
 sfc_files_input_grid="${SFC_FILES_INPUT}"
 cycle_mon=${dtg:4:2}
 cycle_day=${dtg:6:2}
 cycle_hour=${dtg:8:2}
 convert_atm=.true.
 convert_sfc=.true.
 convert_nst=.true.
 tracers="sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"
 tracers_input="sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"
/
EOF

#SCRIPT=${HOMEufs}/ush/chgres_cube.sh
#bash ${SCRIPT}
${APRUN} ${HOMEufs}/exec/chgres_cube
if (( ${?} > 0 )); then
    echo 'chgres_ATM failed'
    exit 1
fi

# move files
for n in $(seq 1 6); do
    mv out.atm.tile${n}.nc ${dir}/gfs_data.tile${n}.nc
    mv out.sfc.tile${n}.nc ${dir}/sfc_data.tile${n}.nc
done
mv gfs_ctrl.nc ${dir}/gfs_ctrl.nc

echo 'NPB check files and move data'
exit 1
cd ${dir}
rm -r CHGRES
rm ${DTG_TEXT}*nc
