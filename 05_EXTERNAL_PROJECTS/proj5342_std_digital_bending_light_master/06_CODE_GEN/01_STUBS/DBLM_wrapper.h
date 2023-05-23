#ifndef DBLM_wrapper_h
#define DBLM_wrapper_h

#include "rtwtypes.h"

#define C_DblDeadZone             (uint16_T)50            
#define C_DblRateLimit            (uint16_T)50            

#define C_DblSpeed0               (uint16_T)150
#define C_CSpeed0                 (uint16_T)350
#define C_LeftDblMinAngle         (int16_T)-150
#define C_LeftDblMaxAngle         (int16_T)25
#define C_RightDblMinAngle        (int16_T)-25
#define C_RightDblMaxAngle        (int16_T)150



extern int16_T get_V_FiltStWhAngleScaled();
extern uint16_T get_V_FiltVehSpeed();
extern int16_T get_V_LeftDblAimingAngle();
extern int16_T get_V_RightDblAimingAngle();
extern void set_V_LeftDblAimingAngle(int16_T);
extern void set_V_RightDblAimingAngle(int16_T);

#endif                                 /* DBLM_wrapper_h_ */
