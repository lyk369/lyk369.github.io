#ifndef AFSDBLS_WRAPPER_H
#define AFSDBLS_WRAPPER_H

#include "rtwtypes.h"

#define C_DblSlavePeriod            (uint8_T)4
#define C_NumOfLightingModes        (uint8_T)2
#define C_NumOfLightingLeds         (uint8_T)18
#define C_NumOfLightingModules      (uint8_T)2


extern uint8_T get_V_ActiveLightingModes(uint8_T Module);
extern int16_T get_V_DblAngle();
extern void set_V_DblAngle(int16_T data);
extern void set_V_ActiveLightingModes(uint8_T Module,uint8_T data);
extern uint16_T get_V_LedPwm(uint8_T led);
extern void set_V_LedPwm(uint8_T led,uint16_T data);


#endif                                 /* AFSDBLS_WRAPPER_H */
