      SUBROUTINE VEC_ABSB( BAD, N, ARGV, RESV, IERR, NERR, STATUS )
*+
*  Name:
*     VEC_ABSB

*  Purpose:
*     Vectorised BYTE Fortran ABS function.

*  Language:
*     Starlink Fortran

*  Invocation:
*     CALL VEC_ABSB( BAD, N, ARGV, RESV, IERR, NERR, STATUS )

*  Description:
*     The routine evaluates the Fortran ABS function for a vectorised
*     array ARGV of BYTE values.  If numerical errors occur, the
*     value VAL__BADB is returned in appropriate elements of the
*     result array RESV and a STATUS value is set.

*  Arguments:
*     BAD = LOGICAL (Given)
*        Whether the argument values (ARGV) may be "bad".
*     N = INTEGER (Given)
*        The number of argument values to be processed.  If N is not
*        positive the routine returns with IERR and NERR set to zero,
*        but without processing any values.
*     ARGV( N ) = BYTE (Given)
*        A vectorised (1-dimensional) array containing the N BYTE
*        argument values for the Fortran ABS function.
*     RESV( N ) = BYTE (Returned)
*        A vectorised (1-dimensional) array with at least N elements to
*        receive the function results.  Each element I of RESV receives
*        the BYTE value:
*
*           RESV( I ) = ABS( ARGV( I ) )
*
*        for I = 1 to N.  The value VAL__BADB will be set in
*        appropriate elements of RESV under error conditions.
*     IERR = INTEGER (Returned)
*        The index of the first input array element to generate a
*        numerical error.  Zero is returned if no errors occur.
*     NERR = INTEGER (Returned)
*        A count of the number of numerical errors which occur.
*     STATUS = INTEGER (Given & Returned)
*        This should be set to SAI__OK on entry, otherwise the routine
*        returns without action.  A STATUS value will be set by this
*        routine if any numerical errors occur.

*  Copyright:
*     Copyright (C) 1988, 1991 Science & Engineering Research Council.
*     Copyright (C) 1995 Central Laboratory of the Research Councils.
*     All Rights Reserved.

*  Licence:
*     This program is free software; you can redistribute it and/or
*     modify it under the terms of the GNU General Public License as
*     published by the Free Software Foundation; either version 2 of
*     the License, or (at your option) any later version.
*
*     This program is distributed in the hope that it will be
*     useful,but WITHOUT ANY WARRANTY; without even the implied
*     warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
*     PURPOSE. See the GNU General Public License for more details.
*
*     You should have received a copy of the GNU General Public License
*     along with this program; if not, write to the Free Software
*     Foundation, Inc., 51 Franklin Street,Fifth Floor, Boston, MA
*     02110-1301, USA

*  Authors:
*     R.F. Warren-Smith (STARLINK)
*     {enter_new_authors_here}

*  History:
*     15-AUG-1988 (RFWS):
*        Original version.
*     28-OCT-1991 (RFWS):
*        Added LIB$REVERT call.
*     7-NOV-1991 (RFWS):
*        Changed to use NUM_TRAP.
*     27-SEP-1995 (BKM):
*        Changed LIB$ESTABLISH and LIB$REVERT calls to NUM_HANDL and NUM_REVRT
*     27-SEP-1995 (BKM):
*        Changed LIB$ESTABLISH and LIB$REVERT calls to NUM_HANDL and NUM_REVRT
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-

*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants

      INCLUDE 'PRM_PAR'          ! PRM_ public constants

      INCLUDE 'PRM_CONST'        ! PRM_ private constants

      INCLUDE 'PRM_ERR'          ! PRM_ error codes


*  Arguments Given:
      LOGICAL BAD                ! Bad data flag
      INTEGER N                  ! Number of argument values to process
      BYTE ARGV( * )           ! Function argument array

*  Arguments Returned:
      BYTE RESV( * )           ! Function result array
      INTEGER IERR               ! Numerical error pointer
      INTEGER NERR               ! Numerical error count

*  Status:
      INTEGER STATUS             ! Error status

*  External References:
      EXTERNAL NUM_TRAP          ! Error handling routine

*  Global Variables:
      INCLUDE 'NUM_CMN'          ! Define NUM_ERROR flag


*  Local Variables:
      INTEGER I                  ! Loop counter
      BYTE ARG                 ! Temporary argument variable

*  Internal References:
      INCLUDE 'NUM_DEC_CVT'      ! Declare NUM_ conversion functions

      INCLUDE 'NUM_DEC_B'      ! Declare NUM_ arithmetic functions

      INCLUDE 'NUM_DEF_CVT'      ! Define NUM_ conversion functions

      INCLUDE 'NUM_DEF_B'      ! Define NUM_ arithmetic functions


*.

*  Check status.
      IF( STATUS .NE. SAI__OK ) RETURN

*  If required, establish the error handler and initialise the common
*  block error flag.
      IF( .FALSE. ) THEN
         CALL NUM_HANDL( NUM_TRAP )
         NUM_ERROR = SAI__OK
      ENDIF

*  Initialise the numerical error pointer and the error count.
      IERR = 0
      NERR = 0

*  If the bad data flag is set:
*  ---------------------------
*  Loop to process each element of the input argument array in turn.
      IF( BAD ) THEN
         DO 1 I = 1, N
            ARG = ARGV( I )

*  Check if the argument value is bad.  If it is, then put a value of
*  VAL__BADB in the corresponding element of the result array.
            IF( ARG .EQ. VAL__BADB ) THEN
               RESV( I ) = VAL__BADB

*  Check if the argument value is acceptable.  If not, then put a value
*  of VAL__BADB in the corresponding element of the result array and
*  increment the numerical error count.
            ELSE IF( .NOT. ( BAD .OR. NUM_NEB( ARG, NUM__MINB ) ) ) THEN
               RESV( I ) = VAL__BADB
               NERR = NERR + 1

*  Set a STATUS value (if not already set) and update the error
*  pointer.
               IF( STATUS .EQ. SAI__OK ) THEN
                  STATUS = PRM__INTOF
                  IERR = I
               ENDIF

*  If the argument value is acceptable, then evaluate the Fortran ABS
*  function.
            ELSE
               RESV( I ) = NUM_ABSB( ARG )

*  If an error handler is established, check if the numerical error
*  flag is set.  If so, put a value of VAL__BADB in the corresponding
*  element of the result array and increment the error count.
               IF( .FALSE. ) THEN
                  IF( NUM_ERROR .NE. SAI__OK ) THEN
                     RESV( I ) = VAL__BADB
                     NERR = NERR + 1

*  Set a STATUS value (if not already set) and update the error
*  pointer.
                     IF( STATUS .EQ. SAI__OK ) THEN
                        STATUS = NUM_ERROR
                        IERR = I
                     ENDIF

*  Clear the error flag.
                     NUM_ERROR = SAI__OK
                  ENDIF
               ENDIF
            ENDIF
 1       CONTINUE

*  If the bad data flag is not set:
*  -------------------------------
*  Loop to process each element of the input argument array in turn.
      ELSE
         DO 2 I = 1, N
            ARG = ARGV( I )

*  Check if the argument value is acceptable.  If not, then put a value
*  of VAL__BADB in the corresponding element of the result array and
*  increment the error count.
            IF( .NOT. ( BAD .OR. NUM_NEB( ARG, NUM__MINB ) ) ) THEN
               RESV( I ) = VAL__BADB
               NERR = NERR + 1

*  Set a STATUS value (if not already set) and update the error
*  pointer.
               IF( STATUS .EQ. SAI__OK ) THEN
                  STATUS = PRM__INTOF
                  IERR = I
               ENDIF

*  If the argument value is acceptable, then evaluate the Fortran ABS
*  function.
            ELSE
               RESV( I ) = NUM_ABSB( ARG )

*  If an error handler is established, check if the numerical error
*  flag is set.  If so, put a value of VAL__BADB in the corresponding
*  element of the result array and increment the error count.
               IF( .FALSE. ) THEN
                  IF( NUM_ERROR .NE. SAI__OK ) THEN
                     RESV( I ) = VAL__BADB
                     NERR = NERR + 1

*  Set a STATUS value (if not already set) and update the error
*  pointer.
                     IF( STATUS .EQ. SAI__OK ) THEN
                        STATUS = NUM_ERROR
                        IERR = I
                     ENDIF

*  Clear the error flag.
                     NUM_ERROR = SAI__OK
                  ENDIF
               ENDIF
            ENDIF
 2       CONTINUE
      ENDIF

*  If required, remove the error handler.
      IF( .FALSE. ) THEN
         CALL NUM_REVRT
      ENDIF

*  Exit routine.
      END
