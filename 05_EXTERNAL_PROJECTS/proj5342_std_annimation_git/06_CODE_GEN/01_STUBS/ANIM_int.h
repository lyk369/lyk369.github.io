#ifndef __ANIM_int_h__
#define __ANIM_int_h__

#include "rtwtypes.h"

#define C_NumOfLeds		      3
#define C_NumOfScenarios	  4
#define C_NumOfSteps		  32

/*INPUTS*/

extern uint8_T get_V_RequestedScenarioNum(void);
extern boolean_T get_V_AnimationFinished(void);

/*OUTPUTS*/

extern void set_V_AnimationFinished(boolean_T value);
extern void set_V_FinishedAnimationNumber(uint8_T value);
extern void set_V_RunningAnimationNumber(uint8_T value);
extern void set_V_AnimationPwm(uint8_T index,uint16_T value);

#endif                            