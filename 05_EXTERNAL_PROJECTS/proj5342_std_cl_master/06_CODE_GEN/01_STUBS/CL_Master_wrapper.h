#ifndef __CL_Master_WRAPPER_H__
#define __Cl_Master_WRAPPER_H__

#include "rtwtypes.h"

/* Inputs */ 

extern boolean_T get_V_ClEnable();
extern int16_T get_V_CurveRadius();
extern int16_T get_V_FiltStWhAngleScaled();
extern uint16_T get_V_FiltVehSpeed();
extern boolean_T get_V_TiLeft();
extern boolean_T get_V_TiRight();



/* Outputs */ 


extern void set_V_ClLeft(boolean_T value);
extern void set_V_ClRight(boolean_T value);

#endif

