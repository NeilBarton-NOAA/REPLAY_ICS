#!/bin/sh
set -xu
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh
dir=${dir_ice}
compiler=${chgres_compiler}

########################
HOMEufs=${CODE_DIR}/UFS_UTILS
OCNICEPREP=${HOMEufs}/reg_tests/ocnice_prep/parm
EXEC=${HOMEufs}/exec/oiprep
#FIXDIR=/scratch2/NCEPDEV/stmp3/Neil.Barton/CODE/FIX/rt_1191124
#FIXDIR='/scratch1/NCEPDEV/stmp4/Denise.Worthen/CPLD_GRIDGEN/rt_1191124/'
FIXDIR='/scratch1/NCEPDEV/nems/role.ufsutils/ufs_utils/reg_tests/cpld_gridgen/baseline_data'

########################
WORKDIR=${dir}/CHGRES
mkdir -p ${WORKDIR} && cd ${WORKDIR}
ln -sf ${dir}/${DTG_TEXT}.cice_model.res.nc ${WORKDIR}/ice.nc
ln -sf ${OCNICEPREP}/ice.csv ${WORKDIR}

cat << EOF > ocniceprep.nml
&ocniceprep_nml
ftype='ice'
wgtsdir="${FIXDIR}"
griddir="${FIXDIR}"
srcdims=1440,1080
dstdims=360,320
debug=.true.
/
EOF

########################
# modules
#module purge
module use ${HOMEufs}/modulefiles
module load build.hera.${compiler}

########################
# run
echo "Running $( basename ${EXEC} ) at ${PWD}"
cp ${EXEC} .
${APRUN} -n 1 ./$( basename ${EXEC} )

if (( ${?} > 0 )); then
    echo 'chgres_ICE failed'
    exit 1
fi
if [[ ! -f ${WORKDIR}/ice.mx100.nc ]]; then
    echo "FATAL: ${WORKDIR}/ice.mx100.nc not created"
fi
#mv ${dir}/${DTG_TEXT}.cice_model.res.nc ${dir}/${DTG_TEXT}.cice_model.res_mx025.nc
rm ${dir}/${DTG_TEXT}.cice_model.res.nc
mv ${WORKDIR}/ice.mx100.nc ${dir}/${DTG_TEXT}.cice_model.res.nc
rm -rf ${WORKDIR}

