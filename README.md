# REPLAY_ICS
Scripts to Process Replay ICs for SFS

FOR GFS ICS: run in the following order
    (1) GET_ICS.sh ${DTG} GFS
    (2) RUN_CHGRES.sh ${DTG} GFS
    (2) RUN_REGRID.sh ${DTG} 

FOR CPC ICS update with LAND SPIN-UP: run in the following order
    (1) GET_ICS.sh ${DTG} CPC_land
    (1) GET_PERTIRBATIONS.sh ${DTG} CPC_land
    (2) RUN_CHNGRES.sh ${DTG} CPC_land
    (3) LAND_REPLACE.sh ${DTG} CPC_land
    (4) LINK.sh ${DTG} CPC_land

FOR GFS ICS WITH UPDATED MARINE ICs (DA_UPDATE): run in the following order
    (1) GET_ICS.sh ${DTG} GFS
    (2) RUN_CHGRES.sh ${DTG} GFS
    (2) RUN_REGRID.sh ${DTG} 
    (3) CREATE_DA_UPDATE_DIR.sh ${DTG} 
    (4) GET_ICS.sh ${DTG} DA_UPDATE

FOR REPLAY ICS: run in the following order
    (1) GET_ICS.sh ${DTG} REPLAY
    (1) GET_PERTIRBATIONS.sh ${DTG} 
    (2) RUN_CHNGRES.sh ${DTG} REPLAY
    (3) LINK.sh ${DTG} REPLAY
