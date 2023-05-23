/*
 * File: ert_main.c
 *
 * Code generated for Simulink model 'AFS_Master'.
 *
 * Model version                  : 1.129
 * Simulink Coder version         : 9.4 (R2020b) 29-Jul-2020
 * C/C++ source code generated on : Thu Apr  6 09:42:58 2023
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

#include "AFS_Master.h"                /* Model's header file */
#include "rtwtypes.h"
#include "stddef.h"

/* Includes for objects with custom storage classes. */
#include "AFS_Master.h"
#include "AFS_Master_calib.h"
#include "AFS_Master_wrapper.h"

/*
 * Example use case for call to exported function:
 * AFS_failureRunnable
 */
extern void sample_usage_AFS_failureRunnable(void);
void sample_usage_AFS_failureRunnable(void)
{
  /*
   * Set task inputs here:
   */

  /*
   * Call to exported function
   */
  AFS_failureRunnable();

  /*
   * Read function outputs here
   */
}

/*
 * Example use case for call to exported function:
 * AFS_vidRunnable
 */
extern void sample_usage_AFS_vidRunnable(void);
void sample_usage_AFS_vidRunnable(void)
{
  /*
   * Set task inputs here:
   */

  /*
   * Call to exported function
   */
  AFS_vidRunnable();

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
  AFS_Master_initialize();

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
