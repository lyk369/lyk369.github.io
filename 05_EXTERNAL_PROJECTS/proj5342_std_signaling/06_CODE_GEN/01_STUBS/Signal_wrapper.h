#ifndef __Signal_WRAPPER_H__
#define __Signal_WRAPPER_H__

#include "rtwtypes.h"


#define   N_NumberOfTiLeds	  5
#define	  C_Config 		1

//Inputs 

extern uint8_T get_V_TiCycle();
extern boolean_T get_V_DRL_Rqst();
extern boolean_T get_V_PL_Rqst();
extern boolean_T get_V_TI_Rqst();
extern uint8_T get_V_ActivePowerSupply();
extern uint16_T get_V_DrlPlFunctionTpsPwm();
extern uint16_T get_V_TiFunctionTpsPwm(uint8_T index);
extern boolean_T get_V_PL_OUT();
extern boolean_T get_V_DRL_OUT();
//extern boolean_T get_V_TI_OUT();
extern boolean_T get_V_TiBlink();
extern uint8_T get_V_SideMarker();

//Outputs 
extern void set_V_TiCycle(uint8_T value);
extern void set_V_DRL_Rqst(boolean_T value);
extern void set_V_PL_Rqst(boolean_T value);
extern void set_V_TI_Rqst(boolean_T value);
extern void set_V_ActivePowerSupply(uint8_T value);
extern void set_V_DrlPlFunctionTpsPwm(uint16_T value);
extern void set_V_TiFunctionTpsPwm(uint16_T value, uint8_T index);
extern void set_V_PL_OUT(boolean_T value);
extern void set_V_DRL_OUT(boolean_T value);
//extern void set_V_TI_OUT(boolean_T value);
extern void set_V_TiBlink(boolean_T value);
extern void set_V_SideMarker(uint8_T value);

#endif

