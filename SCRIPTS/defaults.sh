set -xu
SCRIPT_DIR=${SCRIPT_DIR:-$PWD}

############
# number of ensembles
dow=$(date -d "${dtg:0:8}" +%A)
if [[ ${dow} == "Thursday" ]] || [[ ${dow} == "Monday" ]]; then
    NENS=10
else
    NENS=5
fi
############
# time stamp for files
DTG_TEXT=${dtg:0:8}.030000 # restarts are +3

############
# top IC directory
IC_DIR=/scratch2/NCEPDEV/stmp3/Neil.Barton/ICs/REPLAY_ICs
mkdir -p ${IC_DIR}

############
# Replay Restarts
# https://noaa-ufs-gefsv13replay-pds.s3.amazonaws.com/index.html
aws_path="https://noaa-ufs-gefsv13replay-pds.s3.amazonaws.com/${dtg:0:4}/${dtg:4:2}/${dtg:0:8}06"

############
# Ocean perturbation files:
hpss_ocn_increment_dir=/ESRL/BMC/gsienkf/2year/Philip.Pegion/ocean_ensemble_perts/C384

############
# Atmosphere perturbation files:
hpss_atm_increment_dir=/ESRL/BMC/gsienkf/2year/whitaker/era5/C384ensperts


