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
DTG_TEXT=${dtg:0:8}.030000 # restarts valid at 

############
# top IC directory
IC_DIR=/scratch2/NCEPDEV/stmp3/Neil.Barton/ICs/REPLAY_ICs/${ATMRES}${OCNRES}
mkdir -p ${IC_DIR}

############
# Replay Restarts
# https://noaa-ufs-gefsv13replay-pds.s3.amazonaws.com/index.html
aws_path="https://noaa-ufs-gefsv13replay-pds.s3.amazonaws.com/${dtg:0:4}/${dtg:4:2}/${dtg:0:8}06"

############
# Ocean perturbation files:
hpss_ocn_increment_dir=/ESRL/BMC/gsienkf/2year/Philip.Pegion/ocean_ensemble_perts/C384

#1 degree 
#/ESRL/BMC/gsienkf/Permanent/UFS_replay_input/oras5_ocn/ensemble_perts/mx100/
#There is a tar file for the 1st of each month from Jan 1993 through Dec 2023.  
#I also have the May 1 and Nov 1 perturbations on AWS at 
aws_ocn_increment_dir="https://noaa-oar-sfsdev-pds.s3.amazonaws.com/input/ocn_ice/mx100/ens_perts"

########################
# Atmosphere perturbation files:
hpss_atm_increment_dir=/ESRL/BMC/gsienkf/2year/whitaker/era5/C384ensperts

########################
# CODE Directory
CODE_DIR=/scratch2/NCEPDEV/stmp3/Neil.Barton/CODE/REPLAY

########################
# compiler used for chgres
export chgres_compiler=gnu
export APRUN="srun -n 6"

