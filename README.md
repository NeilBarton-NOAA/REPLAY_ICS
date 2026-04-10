# REPLAY_ICS
Scripts to Process Replay ICs for SFS

FOR GFS ICS: run in the following order
    (1) GET_ICS.sh ${DTG} GFS
    (2) RUN_CHGRES.sh ${DTG} GFS
    (2) RUN_REGRID.sh ${DTG} 


FOR REPLAY ICS: run in the following order
    (1) GET_ICS.sh ${DTG} REPLAY
    (1) GET_PERTIRBATIONS.sh ${DTG} 
    (2) RUN_CHNGRES ${DTG} REPLAY
    (3) LINK.sh ${DTG}
