/*
 * File: ert_main.c
 *
 * Code generated for Simulink model 'LdAfsDblSlave'.
 *
 * Model version                  : 1.29
 * Simulink Coder version         : 9.4 (R2020b) 29-Jul-2020
 * C/C++ source code generated on : Fri Aug  5 20:53:26 2022
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: NXP->Cortex-M0/M0+
 * Code generation objectives:
 *    1. Execution efficiency
 *    2. RAM efficiency
 *    3. ROM efficiency
 *    4. MISRA C:2012 guidelines
 *    5. Safety precaution
 *    6. Traceability
 *    7. Debugging
 *    8. Polyspace
 * Validation result: Not run
 */

extern int printf(const char *, ...);
extern int fflush(void *);

#include "LdAfsDblSlave.h"             /* Model's header file */
#include "rtwtypes.h"
#include "stddef.h"

/* Includes for objects with custom storage classes. */
#include "AFSDBLS_wrapper.h"

/*
 * Example use case for call to exported function:
 * AFSS_vidSlaveDist
 */
extern void sample_usage_AFSS_vidSlaveDist(void);
void sample_usage_AFSS_vidSlaveDist(void)
{
  /*
   * Set task inputs here:
   */

  /*
   * Call to exported function
   */
  AFSS_vidSlaveDist();

  /*
   * Read function outputs here
   */
}

/*
 * Example use case for call to exported function:
 * DBLS_vidPwmOutout
 */
extern void sample_usage_DBLS_vidPwmOutout(void);
void sample_usage_DBLS_vidPwmOutout(void)
{
  /*
   * Set task inputs here:
   */

  /*
   * Call to exported function
   */
  DBLS_vidPwmOutout();

  /*
   * Read function outputs here
   */
}

/*
 * The example "main" function illustrates what is required by your
 * application code to initialize, execute, and terminate the generated code.
 * Attaching exported functions to a real-time clock is target specific.
 * This example illustrates how you do this relative to initializing the model.
 */
int_T main(int_T argc, const char *argv[])
{
  /* Unused arguments */
  (void)(argc);
  (void)(argv);

  /* Initialize model */
  LdAfsDblSlave_initialize();

  /* First time initialization of system output variables.
   * Constant and invariant outputs will not be updated
   * after this step.
   */

  /* The option 'Remove error status field in real-time model data structure'
   * is selected, therefore the following code does not need to execute.
   */
#if 0

  /* Disable rt_OneStep() here */
#endif

  return 0;
}

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
