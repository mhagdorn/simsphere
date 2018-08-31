      SUBROUTINE  BRI (T1,MONCE,PSIHNEW,YCOUNT,ZTEN)

*/  Subroutine BRI computes the M-O-L when BRI is (+) and less than
*/  .2 using the Blackadar model.



*/ Code altered 5th May 1992 ... transfer from Vel.for.

      REAL MOL1

      INCLUDE 'modvars.h'

*/  The following are constants.  See manual for explanation.

      DATA A,DT,Z1,B /8.3E-4,90,1.0,0.2/
      DATA ANEW,BNEW,CNEW,DNEW /1.0,0.667,5.0,0.35/
*/	DATA PHIM /  0 /

*/  ZAN is the night-time surface depth and is input in START.
*/  ZAN is simply ZA @ night.

      PHIH = 0
      X1 = 0

      IF ( YCOUNT .LE. 0 .AND. IFIRST .EQ. 0 ) THEN

*/       MOL = 10E5
       TSTAR = 0
       T(1) = APTEMP
       T1 = TSCREN
       IFIRST = 1
      
      elseif (ycount .ge. 1 .and. ifirst .eq. 1) then
       
      ! Start the surface temp at some nominal value.
       
       otemp = atemp
       T1 = ATEMP - 1
       TSTAR = 0
       DO 5 I=1,46
         T(I) = t_fine(i)
         U(I) = u_fine(i)
         V(I) = v_fine(i)
         QN(I) = q_fine(i)
  5    CONTINUE
       IFIRST = 2

      END IF

*/     Surface Potential Temperature

       Pot_S = t1 + Tdif_s

C **  Calc the windspeed at the first level and the Critical Richardson
C **  Number.

      WG1 = SQRT( UG(1)**2 + VG(1)**2 )
      CR1 = ( EXP( -0.2129 * WG1 ) * 0.5542 ) + 0.2

   11 TDIF = ABS( T(1) - Pot_S )

C **  Calc the Bulk Richardson number using the Blackadar scheme along
C **  with the paramteristation for dO/dt.

      Atemp = T(1) - Tdif_50
      RADCOR = A * ( OTEMP - T1 ) - RAD
*/      TDIF = ABS( T(1) - T1 )
      TSURF = T1 - TSTAR * ALOG( Z1 / ZO )
      BULK = ( (T(1) - Pot_S) * GRAV * ZA ) / ( OTEMP * AWIND**2 )

C **  Now use this to determine the stability criteria and execute the
C **  the appropriate physics.

      IF ( TDIF .LT. 0.05 ) THEN

C     .... Soln Sequence Neutral ....

         TSTAR = (T(1)-Pot_S)/ALOG(ZA/Z1)
         USTAR1 = KARMAN * AWIND /  ALOG ( ZA / ZO )
         USTAR = (USTAR1 + USTAR) / 2
	 HEAT = - KARMAN * DENS * CP * USTAR * TSTAR
	 UTEN	=  USTAR / KARMAN * ( ALOG( ZTEN / ZO))

      ELSE IF (BULK .LT. 0) THEN

C      .... Soln Sequence Unstable ....

C **   On entering this routine the MOL will be positive which will
C **   result in a domain error.  Hence restrain MOL first time through.

*/       IF ( MOL .GE. 0 ) MOL = -1.E5
*/       X = ( 1 - 16 * ( ZA / MOL ) )**( -0.25 )
*/       PHIH = 2 * ALOG( ( 1 + X**2 ) / 2 )
*/       PHIM = ( PHIH + 3.1416 ) / 2 + 2 * ALOG( ( 1 + X ) / 2 ) - 2
*/     #        * ATAN( X )
*/       MOL1 = BULK / ZA * ( ( ALOG( ZA / Z1 ) - PHIM )**2 ) /
*/     #        ( ALOG( ZA / Z1 ) - PHIH )
*/       MOL = 1 / MOL1
*/       MOL = 1e5

       USTAR = KARMAN * AWIND / ( ALOG( ZA / ZO ) )
       TSTAR = (T(1) - Pot_S) / ( ALOG( ZA / Z1 ) )
       HEAT = -KARMAN * DENS * CP * USTAR * TSTAR
       UTEN   =	USTAR / KARMAN * ( ALOG( ZTEN / ZO))

      ELSE IF ( BULK .GT. 0 .AND. BULK .LT. CR1 ) THEN

C      .... Soln Sequence Stable Turbulent ....

       MOL1 = ( 1 / ZA ) * ALOG( ZA / ZO ) *
     /        ( BULK / ( 5 * ( CR1 - BULK ) ) )
       MOL =  1 / MOL1

	ZtenOVERL = zten / MOL
	PSImzten = ANEW * ZtenOVERL + BNEW * (ZtenOVERL - CNEW / DNEW) *
     &	EXP ( - DNEW * ZtenOVERL) + BNEW * CNEW / DNEW

*/	PSIHzten  =  (1.0 + 0.6667 * ANEW * ZtenOVERL)**1.5 + BNEW *
*/     &	   ( ZtenOVERL - CNEW / DNEW) * EXP ( - DNEW * ZtenOVERL) +
*/     &	   BNEW * CNEW / DNEW - 1.0

*/       ZrefOVERL = reflev / mol

*/	PSIMref = ANEW * ZrefOVERL + BNEW * (ZrefOVERL - CNEW / DNEW) *
*/	&	EXP ( - DNEW * ZrefOVERL) + BNEW * CNEW / DNEW

*/	   PSIHref = (1.0 + 0.6667 * ANEW * ZrefOVERL)**1.5 + BNEW *
*/	&	( ZrefOVERL - CNEW / DNEW) * EXP ( - DNEW * ZrefOVERL) +
*/	&	   BNEW * CNEW / DNEW - 1.0

*/	USCRN  =  USTAR / KARMAN * ( ALOG ( REFLEV / ZO ) + psimref )


C Compute the Static Stability Correction

       ZOVERL  = ZA / MOL
       PSIMNEW = ANEW * ZOVERL + BNEW * (ZOVERL - CNEW / DNEW)*
     /           EXP(-DNEW * ZOVERL) + BNEW * CNEW / DNEW
       PSIHNEW = (1 + 0.6667 * ANEW * ZOVERL)**1.5 + BNEW *
     /           (ZOVERL - CNEW / DNEW) * EXP(-DNEW * ZOVERL) +
     /           BNEW * CNEW / DNEW - 1


       TSTAR = (T(1) - Pot_S) / ( ALOG( ZA / Z1 ) + PSIHNEW)
       USTAR1 = KARMAN * AWIND / ( ALOG( ZA / ZO ) + PSIMNEW)
       USTAR = ( USTAR1 + USTAR) / 2
       HEAT = -KARMAN * DENS * CP * USTAR * TSTAR
       UTEN   =  USTAR / KARMAN * ( ALOG( ZTEN / ZO ) + psimzten )

      ELSE

*/	.... Soln Sequence Stable Non - Turbulent ....

      HEAT = - 0.001
      USTAR = USTAR / 2
      UTEN = UTEN / 2

      END IF

      IF ( USTAR .LT. 0.01 ) USTAR = 0.01

      T2 = T1 + DT * ( RADCOR + ADVGT - B * HEAT / (CP * DENS * Z1))
      T1 = ( T1 + T2 )/ 2.0
      T1 = T1 - 0.017


C **  Mitre the night-time loop; cycle through twice (120s).

      X1 = X1 + 1
      XMOD = AMOD ( X1 , 2.0 )
      IF( XMOD .NE. 0 ) GO TO 11

C **  Call MOM to calculate the night-time vertical profiles of
C **  temperature and winds.

      IF ( YCOUNT .GE. 1 ) THEN

       CALL MOM (Pot_S, DT, MONCE)

      END IF

      RETURN
      END
