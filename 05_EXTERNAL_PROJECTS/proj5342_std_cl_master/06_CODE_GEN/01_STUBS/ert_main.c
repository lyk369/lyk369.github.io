/*
 * File: ert_main.c
 *
 * Code generated for Simulink model 'CL_Master'.
 *
 * Model version                  : 7.158
 * Simulink Coder version         : 9.4 (R2020b) 29-Jul-2020
 * C/C++ source code generated on : Wed Apr  5 23:42:27 2023
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: NXP->Cortex-M0/M0+
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include <stdio.h>              /* This ert_main.c example uses printf/fflush */
#include "CL_Master.h"                 /* Model's header file */
#include "rtwtypes.h"
#include "stddef.h"

/* Includes for objects with custom storage classes. */
#include "CL_Master.h"
#include "CL_Master_wrapper.h"
#include "CL_Master_calib.h"

/*
 * Example use case for call to exported function:
 * CLMExecution_vidRunnable
 */
extern void sample_usage_CLMExecution_vidRunnable(void);
void sample_usage_CLMExecution_vidRunnable(void)
{
  /*
   * Set task inputs here:
   */

  /*
   * Call to exported function
   */
  CLMExecution_vidRunnable();

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
  CL_Master_initialize();

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
