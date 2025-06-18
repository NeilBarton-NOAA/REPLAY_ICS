#!/usr/bin/env python3 
####################################################################################
# from Dave Bailey: What is likely happening is that you are initializing with the 
#                   same thickness in two categories where thickness is vicen / aicen.
#ncks -A kmtu_cice_NEMS_mx025.nc cice_model.res.nc
#ncap2 -s where(kmt==0) aicen=0.0 cice_model.res.nc
#ncap2 -s where(kmt==0) vicen=0.0 cice_model.res.nc
#ncap2 -s where(kmt==0) vsnon=0.0 cice_model.res.nc
#ncap2 -s where(kmt==0) Tsfcn=0.0 cice_model.res.nc
#ncap2 -s 'where(aicen.total($ncat) == 0) vicen=0' cice_model.res.fix.nc cice_model.res.fix2.nc
#ncap2 -s 'where(aicen.total($ncat) == 0) vsnon=0' cice_model.res.fix2.nc cice_model.res.fix3.nc
####################################################################################
import argparse
import os
import xarray as xr
#from matplotlib import pyplot as plt

################################################
# parser for file
parser = argparse.ArgumentParser( description = "Looks for Errors in CICE restart file")
parser.add_argument('-f', '--file', action = 'store', nargs = 1, \
        help="cice file to edit")
args = parser.parse_args()
infile = args.file[0]
print(infile)
dat = xr.open_dataset(infile)

############
# remove ice and snow where there is no ice
d = dat['aicen'].sum(axis = 0)
vs = ['vicen', 'vsnon']
for v  in vs:
    dat[v] = dat[v].where(d != 0, 0)

############
# remove ice variables over land
d = dat['iceumask']
vs = ['aicen', 'vicen', 'vsnon', 'Tsfcn']
for v in vs:
    dat[v] = dat[v].where(d == 1, 0)

#########################
# save file
new_file = infile.split('.nc')[0] + '_new.nc'
if os.path.exists(new_file):
    os.remove(new_file)
dat.to_netcdf(new_file)
print('SAVED: ' + new_file)

