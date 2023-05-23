/*
 * File: ert_main.c
 *
 * Code generated for Simulink model 'Signaling_Model'.
 *
 * Model version                  : 1.148
 * Simulink Coder version         : 9.4 (R2020b) 29-Jul-2020
 * C/C++ source code generated on : Wed May  3 14:38:27 2023
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: Renesas->RH850
 * Code generation objectives:
 *    1. Execution efficiency
 *    2. RAM efficiency
 *    3. ROM efficiency
 *    4. Safety precaution
 *    5. MISRA C:2012 guidelines
 *    6. Polyspace
 *    7. Traceability
 *    8. Debugging
 * Validation result: Not run
 */

extern int printf(const char *, ...);
extern int fflush(void *);

#include "Signaling_Model.h"           /* Model's header file */
#include "rtwtypes.h"
#include "stddef.h"

/* Includes for objects with custom storage classes. */
#include "Signaling_Model.h"
#include "Signal_wrapper.h"

/*
 * Example use case for call to exported function:
 * ALPC_Signalling
 */
extern void sample_usage_ALPC_Signalling(void);
void sample_usage_ALPC_Signalling(void)
{
  /*
   * Set task inputs here:
   */

  /*
   * Call to exported function
   */
  ALPC_Signalling();

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
  Signaling_Model_initialize();

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
