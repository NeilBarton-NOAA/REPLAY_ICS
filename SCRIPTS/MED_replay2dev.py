#!/usr/bin/env python3 
########################
#  Neil P. Barton (NOAA-EMC), 2022-10-27
#   edit replay mediator restart for more recent version of model
########################
# Denise's email 
#   The actual process will depend on the field though. 
#    For fields which are now present, but were not present previously, I think you can safely set any added field to zero. 
#   evap Field   
#       Previously the ATM exported latent which was converted in the mediator to evap (sent to the ocean). 
#       Now the ATM exports evap directly. So the new evap field will need to be created from the latent field.
#   There are also a set of fields which will need to have their signs changed (taux,tauy,sensible). 
#   atmImp---ie, imported from the atm
#   atmExp---ie, exported to the atm from another model
########################
import argparse
import numpy as np
import os
import sys
import xarray as xr

################################################
# parse arguments
parser = argparse.ArgumentParser( description = "mediator file")
parser.add_argument('-r', '--replay', action = 'store', nargs = 1, \
        default=['/scratch2/NCEPDEV/stmp3/Neil.Barton/ICs/2017100503/ufs.cpld.cpl.r.2017-10-05-10800.nc'], \
        help="replay mediator restart file (ufs.cpld.cpl.r)")
parser.add_argument('-d', '--dev', action = 'store', nargs = 1, \
        #default=['/scratch2/NCEPDEV/stmp3/Neil.Barton/ufs.cpld.cpl.r.2017-10-05-32400.nc'], \
        default=['/scratch2/NCEPDEV/stmp3/Neil.Barton/ufs.cpld.cpl.r.2013-04-01-21600.nc'], \
        help="dev mediator restart file (ufs.cpld.cpl.r)")
args = parser.parse_args()
r = args.replay[0]
d = args.dev[0]
print('Replay Med File:', r)
print('Develop Med File:', d)
rdat = xr.open_dataset(r)
ddat = xr.open_dataset(d)

################################################
# get variables in data
#   variable naming convention
#    modelDirection_variable 
#    model -> atm, ocn, ice, wav
#    Direction -> Imp: into the mediator (from model)
#                 Exp: out of mediator (to the model)
#    variable -> variable 
r_vars = set(rdat.variables.keys())
d_vars = set(ddat.variables.keys())

################################################
# update in code has fluxed defined as positive down, and some variables need to be multipled by -1 
c_vars = ['tauy', 'taux', 'sen']
for v in r_vars:
    v_name = v.split('_')[-1]
    if (v[0:6] == 'atmImp') and (v_name in c_vars):
        print('Switching sign of', v)
        rdat[v] = rdat[v] * -1.0

################################################
# add evaporation: (replay latent heat) to (dev evaporation)
#   atmImp_Faxa_lat to atmImp_Faxa_evap 
#   https://github.com/NOAA-EMC/CMEPS/compare/cec8db8d09fa0a0b016d197a68edc67cbd100d97...9923d6d17700daf502d9a016138bf8eb8aad7f09
#   latent heat / const_lhvap = > evap
print('Calculating atmIMP_Faxa_evap from atmIMP_Faxa_lat')
const_lhvap = 2.501e6  # latent heat of evaporation  used in replay (J/kg)
rdat['atmImp_Faxa_evap'] = (rdat['atmImp_Faxa_lat'].dims, -1.0 * rdat['atmImp_Faxa_lat'].values / const_lhvap)

################################################
# copy wavExp_ to  wavExpAccum_
#   replay was done with waves in faster coupling loop, which the accumaltion variables did not write correctly
#multi = rdat['ocnExpAccum_cnt'].values
for v in r_vars:
    if v[0:7] == 'wavExp_':
        variable = v.split('wavExp_')[-1]
        print('Copying wavExp_' + variable + ' to wavExpAccum_' + variable)
        #if variable in ['lat', 'lon', 'Sa_u10m', 'Sa_v10m', 'So_u', 'So_v']:
        #    rdat['wavExpAccum_' + variable] = (rdat[v].dims, rdat[v].values)
        #else:
        #    rdat['wavExpAccum_' + variable] = (rdat[v].dims, rdat[v].values * multi)
        rdat['wavExpAccum_' + variable] = (rdat[v].dims, rdat[v].values)
#v_check = 'wavExpAccum_Sa_u10m'
#print(v_check)
#print(multi)
#print(rdat[v_check].min().values, rdat[v_check].max().values)
################################################
# add new variables as zeros
diff_vars = list(d_vars - r_vars)
for v in diff_vars:
    if v[-3:] in ['lat', 'lon']:
        #print('adding lat/lon values', v)
        rdat[v] = (ddat[v].dims, ddat[v].values)
    elif (v.split('_')[1] == 'Foxx'):
        old_name = v.split('_')[0] + '_Faxa_' + v.split('_')[-1]
        rdat[v] = rdat[old_name]
    elif (v.split('_')[0] == 'MedOcnAlb'):
        print('adding albedo 0.06 value', v)
        rdat[v] = (ddat[v].dims, np.zeros(ddat[v].shape) + 0.06)
    else:
        print('adding zeros', v)
        rdat[v] = (ddat[v].dims, np.zeros(ddat[v].shape))

################################################
# add global attribute
rdat.assign_attrs({'File Edited' : 'Replay to Dev/GEFS'})

################################################
# save new file
name_f = os.path.basename(r)
dir_f = os.path.dirname(r)
file_save = dir_f + '/DEV_MEDFILE.nc'
rdat.to_netcdf(file_save)
print('SAVED: ', file_save)

