#include "Signal_wrapper.h"



//Inputs 


uint8_T get_V_TiCycle()
{
	return 0;
}

boolean_T get_V_DRL_Rqst()
{
	return 0;
}
boolean_T get_V_PL_Rqst()
{
	return 0;
}
boolean_T get_V_TI_Rqst()
{
	return 0;
}
uint8_T get_V_ActivePowerSupply()
{
	return 0;
}
uint16_T get_V_DrlPlFunctionTpsPwm()
{
	return 0;
}
uint16_T get_V_TiFunctionTpsPwm(uint8_T index)
{
	return 0;
}
boolean_T get_V_PL_OUT()
{
	return 0;
}
boolean_T get_V_DRL_OUT()
{
	return 0;
}
/*boolean_T get_V_TI_OUT()
{
	return 0;
}*/
boolean_T get_V_TiBlink()
{
	return 0;
}
uint8_T get_V_SideMarker()
{
	return 0;
}

//Outputs 

void set_V_TiCycle(uint8_T value)
{
	return 0;
}
void set_V_DRL_Rqst(boolean_T value)
{
	return 0;
}
void set_V_PL_Rqst(boolean_T value)
{
	return 0;
}
void set_V_TI_Rqst(boolean_T value)
{
	return 0;
}
void set_V_ActivePowerSupply(uint8_T value)
{
	return 0;
}
void set_V_DrlPlFunctionTpsPwm(uint16_T value)
{
	return 0;
}
void set_V_TiFunctionTpsPwm(uint16_T value, uint8_T index)
{
	return 0;
}
void set_V_DRL_OUT(boolean_T value)
{
	return 0;
}
void set_V_PL_OUT(boolean_T value)
{
	return 0;
}
/*void set_V_TI_OUT(boolean_T value)
{
	return 0;
}*/
void set_V_TiBlink(boolean_T value)
{
	return 0;
}
void set_V_SideMarker(uint8_T value)
{
	return 0;
}

//Constants


uint8_T *C_TickTIBlk;
uint8_T *C_Config;
uint16_T *C_DrlRampTime;
uint16_T *C_PlNominalPwm;
uint16_T *C_TeAdbSlave;
uint16_T *C_CieCurvePwmToGammaY;
uint16_T *C_CieCurveGammaToPwmY;
boolean_T *C_IsDrlAutorizedInPower2;
boolean_T *C_IsPlAutorizedInPower2;
boolean_T *C_IsTiAutorizedInPower2;
uint8_T *C_PlOverDRL;
uint8_T *C_B_SlidingTiStepOfTheLeds;
uint8_T *C_F_RampTimeSlidingTI;
uint8_T *C_F_FadingDisableSlidingTI;
uint8_T *C_TiSampleTime;
uint8_T *C_DefaultTiLEDsPwm;
uint16_T *C_TiLEDsOff;
uint8_T *C_TickTIBlk;




