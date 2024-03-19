set -xu
############
# top IC directory
export IC_DIR=/scratch2/NCEPDEV/stmp3/Neil.Barton/ICs/REPLAY_ICs
export DTG_TEXT=${DTG:0:8}.${DTG:8:2}0000
mkdir -p ${IC_DIR}

############
# Replay Restarts
#https://noaa-ufs-gefsv13replay-pds.s3.amazonaws.com/index.html
export aws_path="https://noaa-ufs-gefsv13replay-pds.s3.amazonaws.com/${DTG:0:4}/${DTG:4:2}/${DTG:0:8}06"

############
# Ocean perturbation files:
export hpss_ocn_increment_dir=/ESRL/BMC/gsienkf/2year/Philip.Pegion/ocean_ensemble_perts/C384

############
# Atmosphere perturbation files:
export hpss_atm_increment_dir=/ESRL/BMC/gsienkf/2year/whitaker/era5/C384ensperts


