#!/bin/sh
set -xu
dtg=2017100500
ATMRES=C96
OCNRES=mx100
#SCRIPT_DIR=$(dirname "$0")
SCRIPT_DIR=${PWD}
source ${SCRIPT_DIR}/defaults.sh
export DATA=${NPB_WORKDIR}/TEST/CHGRES_ATMOS
dir="/scratch2/NCEPDEV/stmp3/Neil.Barton/ICs/REPLAY_ICs/TEST_CHGRES/2017100500/mem000/atmos"
#dir=${IC_DIR}/${dtg}/mem000/atmos
SRC_ATMRES="384"
SRC_OCNRES="025"
cd ${DATA}
########################
# chgres_cube.sh options
#export HOMEufs=${SCRIPT_DIR}/UFS_UTILS
export HOMEufs=/scratch2/NCEPDEV/stmp3/Neil.Barton/CODE/UFS_UTILS_NOAA-EMC
export INPUT_TYPE="restart"
export COMIN=${dir} 
export CDATE=${dtg:0:8}03
export ocn=${OCNRES:2:3}
export VCOORD_FILE="${HOMEufs}/fix/am/global_hyblev.l128.txt"
export MOSAIC_FILE_INPUT_GRID="${HOMEufs}/fix/orog/C${SRC_ATMRES}/C${SRC_ATMRES}_mosaic.nc"
export OROG_DIR_INPUT_GRID="${HOMEufs}/fix/orog/C${SRC_ATMRES}"
F=""
F=${F}'C'${SRC_ATMRES}.mx${SRC_OCNRES}'_oro_data.tile1.nc","'
F=${F}'C'${SRC_ATMRES}.mx${SRC_OCNRES}'_oro_data.tile2.nc","'
F=${F}'C'${SRC_ATMRES}.mx${SRC_OCNRES}'_oro_data.tile3.nc","'
F=${F}'C'${SRC_ATMRES}.mx${SRC_OCNRES}'_oro_data.tile4.nc","'
F=${F}'C'${SRC_ATMRES}.mx${SRC_OCNRES}'_oro_data.tile5.nc","'
F=${F}'C'${SRC_ATMRES}.mx${SRC_OCNRES}'_oro_data.tile6.nc'
#F=""
#F=${F}'C'${SRC_ATMRES}'_oro_data.tile1.nc","'
#F=${F}'C'${SRC_ATMRES}'_oro_data.tile2.nc","'
#F=${F}'C'${SRC_ATMRES}'_oro_data.tile3.nc","'
#F=${F}'C'${SRC_ATMRES}'_oro_data.tile4.nc","'
#F=${F}'C'${SRC_ATMRES}'_oro_data.tile5.nc","'
#F=${F}'C'${SRC_ATMRES}'_oro_data.tile6.nc'
export OROG_FILES_INPUT_GRID=${F}
F=""
F=${F}${DTG_TEXT}'.fv_core.res.nc","'
F=${F}${DTG_TEXT}'.fv_core.res.tile1.nc","'
F=${F}${DTG_TEXT}'.fv_core.res.tile2.nc","'
F=${F}${DTG_TEXT}'.fv_core.res.tile3.nc","'
F=${F}${DTG_TEXT}'.fv_core.res.tile4.nc","'
F=${F}${DTG_TEXT}'.fv_core.res.tile5.nc","'
F=${F}${DTG_TEXT}'.fv_core.res.tile6.nc'
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
export APRUN="srun -n 6"
########################
# modules
module purge
module use ${HOMEufs}/modulefiles
module load build.hera.intel

SCRIPT=${HOMEufs}/ush/chgres_cube.sh
bash ${SCRIPT}
exit 1
#export EXECufs=${HOMEufs}/exec
#export FUXufs=${HOMEufs}/fix
############
# file options
#LEVS=127
#mm=${dtg:4:2}
#dd=${dtg:6:2}
#hh=${dtg:8:2}
#
############
#CODE_DIR=${SCRIPT_DIR}/UFS_UTILS
#GDAS_INIT_DIR=${CODE_DIR}/util/gdas_init
#ORO_DIR="${ATMRES}"
#FIX_ORO=${CODE_DIR}/fix/orog
#FIX_AM=${CODE_DIR}/fix/am
#FIX_ORO_INPUT=/scratch1/NCEPDEV/global/glopara/fix/orog/20230615

#cd ${dir}

#module purge
#module use ${CODE_DIR}/modulefiles
# atm_files_input_grid="${ATMFILE}"
#module load build.hera.intel
ORO_NAME="${ATMRES}.mx${OCNRES}_oro_data"
cat << EOF > fort.41

&config
 data_dir_input_grid="${dir}"
 cycle_mon=${dtg:4:2}
 cycle_day=${dtg:6:2}
 cycle_hour=${dtg:8:2}
 convert_atm=.true.
 convert_sfc=.true.
 convert_nst=.true.
 tracers="sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"
 tracers_input="spfh","clwmr","o3mr","icmr","rwmr","snmr","grle"
 
 fix_dir_target_grid="${HOMEufs}/fix/orog/${ATMRES}/sfc"
 orog_dir_target_grid="${HOMEufs}/fix/orog/${ATMRES}"
 
 orog_files_target_grid="${OROG_FILES_INPUT}"
 sfc_files_input_grid="${SFC_FILES_INPUT}"
 mosaic_file_target_grid="${HOMEufs}/fix/orog/${ATMRES}/${ATMRES}_mosaic.nc"
 vcoord_file_target_grid="${VCOORD_FILE}"
 
/
EOF

${APRUN} ${HOMEufs}/exec/chgres_cube
#EXEC_DIR=${CODE_DIR}/exec
#${EXEC_DIR}/chgres_cube
#rc=$?

#if [ $rc != 0 ]; then
#  exit $rc
#fi

