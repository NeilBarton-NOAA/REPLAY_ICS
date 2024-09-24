#!/bin/sh
set -xu
dtg=${1}
SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/defaults.sh
dir=${dir_ocean}
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

if [[ ! -f ${WORKDIR}/ocean.nc ]]; then
    echo 'Creating ${WORKDIR}/ocean.nc file'
    ncks -v Temp,Salt,h,u ${dir}/${DTG_TEXT}.MOM.res.nc ${WORKDIR}/ocean.nc
    ncks -v v,sfc -A ${dir}/${DTG_TEXT}.MOM.res_1.nc ${WORKDIR}/ocean.nc
fi
ln -sf ${OCNICEPREP}/ocean.csv ${WORKDIR}

cat << EOF > ocniceprep.nml
&ocniceprep_nml
ftype='ocean'
wgtsdir="${FIXDIR}"
griddir="${FIXDIR}"
srcdims=1440,1080
dstdims=360,320
debug=.true.
/
EOF

########################
# modules
module purge
module use ${HOMEufs}/modulefiles
module load build.hera.${compiler}

echo "Running $( basename ${EXEC} ) at ${PWD}"
cp ${EXEC} .
${APRUN} -n 1 ./$( basename ${EXEC} )
if (( ${?} > 0 )); then
    echo 'chgres_OCN failed'
    exit 1
fi
if [[ ! -f ${WORKDIR}/ocean.mx100.nc ]]; then
    echo "FATAL: ${WORKDIR}/ocean.mx100.nc not created"
    exit 1
fi

mv ${WORKDIR}/ocean.mx100.nc ${dir}/${DTG_TEXT}.MOM.res.nc
rm -rf ${WORKDIR}
rm ${dir}/${DTG_TEXT}.MOM.res_*.nc
