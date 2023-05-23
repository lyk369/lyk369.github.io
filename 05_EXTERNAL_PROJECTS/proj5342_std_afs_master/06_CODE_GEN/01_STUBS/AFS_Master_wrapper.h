#ifndef __AFS_Master_wrapper_H__
#define __AFS_Master_wrapper_H__

#include "rtwtypes.h"

/* Inputs */ 


extern uint16_T get_V_FiltVehSpeed();
extern boolean_T get_V_CAN_Fail();
extern boolean_T get_V_Veh_speed_Fail();
extern boolean_T get_V_Mod_LeftFail();
extern boolean_T get_V_Mod_RightFail();
extern boolean_T get_V_AFS_ActStatus();
extern boolean_T get_V_ForceExternalAfsMode();
extern uint8_T get_V_ExternalAfsMode();
extern boolean_T get_V_LbStatus();
extern boolean_T get_V_ActivateADBFeatures();
extern boolean_T get_V_WetDetection();
extern boolean_T get_V_TouristModeActivated();
extern boolean_T get_V_Foggy();
extern boolean_T get_V_RevGearEng();
extern boolean_T get_V_DayNightStatus();
extern boolean_T get_V_HBNoADBRequest();

/* Outputs */ 

extern uint8_T set_V_AfsMode();
extern boolean_T set_V_AFS_Fail();

#endif

