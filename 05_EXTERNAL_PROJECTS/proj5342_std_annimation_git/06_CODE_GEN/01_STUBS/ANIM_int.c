#include "ANIM_int.h"
													
uint16_T *C_MaintainAnimationTime;
uint16_T *C_TRamp;             
uint16_T *C_TStart;           
boolean_T *C_AnimationOnLoop;  
boolean_T *C_MaintainAnimationPwm;
uint8_T *C_DefaultValue;       
uint8_T *C_EndValues;          
uint8_T *C_StartValues;         
uint16_T *C_IndexOfStartStepForEachScenario;                        
uint8_T *C_NumOfStepsForEachScenario;
uint16_T *C_AnimationPeriod;
uint16_T *C_CieCurvePwmToGammaY;
uint16_T *C_CieCurveGammaToPwmY;
											 
/*INPUTS*/
					
uint8_T get_V_RequestedScenarioNum(void){return 0;}
boolean_T get_V_AnimationFinished(void){return 0;}

/*OUTPUTS*/

void set_V_AnimationFinished(boolean_T value){return;}
void set_V_FinishedAnimationNumber(uint8_T value){return;}
void set_V_RunningAnimationNumber(uint8_T value){return;}
void set_V_AnimationPwm(uint8_T index,uint16_T value){return;}
