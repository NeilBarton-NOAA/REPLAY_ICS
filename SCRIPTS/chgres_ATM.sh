#!/bin/sh
# https://noaa-emcufs-utils.readthedocs.io/en/latest/
set -xu
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh
compiler=${chgres_compiler}
dir=${dir_input_atmos}
export DATA=${dir}
SRC_ATMRES="C192"
SRC_OCNRES="mx025"
cd ${DATA}
echo ${DATA}
########################
# chgres_cube.sh options
export HOMEufs=${CODE_DIR}/UFS_UTILS
if [[ ${IC_SRC} == "SCOUT" ]]; then
    export INPUT_TYPE="gaussian_netcdf"
else
    export INPUT_TYPE="restart"
fi
# make this better
# needed for IC_SRC == SCOUT
export ATM_FILES_INPUT_GRID="gdas.t${dtg:8:10}z.atmanl.nc"
export SFC_FILES_INPUT_GRID="gdas.t${dtg:8:10}z.sfcanl.nc"
# needed for IC_SRC == "restart"
ORO_SRC=() && CORE_SRC=() && TRACER_SRC=() && SFC_SRC=() && ORO_DES=()
for i in {1..6}; do
    ORO_SRC+=("${SRC_ATMRES}.${SRC_OCNRES}_oro_data.tile${i}.nc")
    CORE_SRC+=("${DTG_TEXT}.fv_core.res.tile${i}.nc")
    TRACER_SRC+=("${DTG_TEXT}.fv_tracer.res.tile${i}.nc")
    SFC_SRC+=("${DTG_TEXT}.sfc_data.tile${i}.nc")
    ORO_DES+=("${ATMRES}.${OCNRES}_oro_data.tile${i}.nc")
done
ORO_SRC=$(printf ',"%s"' "${ORO_SRC[@]}")          && ORO_SRC="${ORO_SRC:1}"
CORE_SRC=$(printf ',"%s"' "${CORE_SRC[@]}")        && CORE_SRC="${CORE_SRC:1}"
TRACER_SRC=$(printf ',"%s"' "${TRACER_SRC[@]}")    && TRACER_SRC="${TRACER_SRC:1}"
SFC_SRC=$(printf ',"%s"' "${SFC_SRC[@]}")          && SFC_SRC="${SFC_SRC:1}"
ORO_DES=$(printf ',"%s"' "${ORO_DES[@]}")          && ORO_DES="${ORO_DES:1}"
export OROG_FILES_INPUT_GRID=${ORO_SRC}
export ATM_CORE_FILES_INPUT=${CORE_SRC}
export ATM_TRACER_FILES_INPUT=${TRACER_SRC}
export SFC_FILES_INPUT=${SFC_SRC}
export OROG_FILES_TARGET_GRID=${ORO_DES}
export COMIN=${dir}
export CDATE=${dtg}
export ocn=${OCNRES:2:3}
export VCOORD_FILE="${HOMEufs}/fix/am/global_hyblev.l128C.txt"
export MOSAIC_FILE_INPUT_GRID="${HOMEufs}/fix/orog/${SRC_ATMRES}/${SRC_ATMRES}_mosaic.nc"
export MOSAIC_FILE_TARGET_GRID="${HOMEufs}/fix/orog/${ATMRES}/${ATMRES}_mosaic.nc"
export OROG_DIR_INPUT_GRID="${HOMEufs}/fix/orog/${SRC_ATMRES}"
export OROG_DIR_TARGET_GRID="${HOMEufs}/fix/orog/${ATMRES}"
export TRACERS_INPUT='"spfh","clwmr","o3mr","icmr","rwmr","snmr","grle"'
export TRACERS_TARGET='"sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"'
#export TRACERS_TARGET='"spfh","clwmr","o3mr","icmr","rwmr","snmr","grle"'
#export TRACERS_INPUT=${TRACERS_TARGET}

########################
# modules
module purge
module use ${HOMEufs}/modulefiles
module load build.${m_target}.${compiler}

mkdir -p ${COMIN}/CHGRES
cd ${COMIN}/CHGRES
############
cat << EOF > fort.41

&config
 fix_dir_target_grid="${OROG_DIR_TARGET_GRID}/sfc"
 mosaic_file_target_grid="${MOSAIC_FILE_TARGET_GRID}"
 orog_dir_target_grid="${OROG_DIR_TARGET_GRID}"
 orog_files_target_grid=${OROG_FILES_TARGET_GRID}
 vcoord_file_target_grid="${VCOORD_FILE}"
 data_dir_input_grid="${COMIN}"
 atm_files_input_grid="${ATM_FILES_INPUT_GRID}"
 sfc_files_input_grid="${SFC_FILES_INPUT_GRID}"
 input_type="${INPUT_TYPE}"
 cycle_mon=${dtg:4:2}
 cycle_day=${dtg:6:2}
 cycle_hour=${dtg:8:2}
 convert_atm=.true.
 convert_sfc=.true.
 convert_nst=.true.
 tracers_input=${TRACERS_INPUT}
 tracers=${TRACERS_TARGET}
/
EOF
# orog_dir_input_grid="${OROG_DIR_INPUT_GRID}"
# mosaic_file_input_grid="${MOSAIC_FILE_INPUT_GRID}"
# orog_files_input_grid=${OROG_FILES_INPUT_GRID}
# atm_core_files_input_grid=${ATM_CORE_FILES_INPUT}
# sfc_files_input_grid=${SFC_FILES_INPUT}
# atm_tracer_files_input_grid=${ATM_TRACER_FILES_INPUT}

#SCRIPT=${HOMEufs}/ush/chgres_cube.sh
#bash ${SCRIPT}
${APRUN} -n 6 ${HOMEufs}/exec/chgres_cube
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

cd ${dir}
rm ${ATM_FILES_INPUT_GRID}
rm ${SFC_FILES_INPUT_GRID}
rm -r CHGRES
