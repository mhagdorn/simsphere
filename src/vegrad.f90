subroutine  VEGRAD (TIME,RNETV,SWAVEV,TZERO)
  use simsphere_mod
  implicit none

  real :: TIME, RNETV, SWAVEV, TZERO
  real :: TZERO5, TZERO4
  !real :: T1

!      INCLUDE 'modvars.h'

  if (eq(time,0.0)) then ! Initialize
    TAF = otemp
    TF =  otemp
    TG =  otemp
    !AAP: Is this supposed to be the same T1 used in VEL and BRI ???
    !     Not the same in original code, so comment-out.
!    T1 = atemp
    TA = ATEMP
!	QA = QD(1)
    QAF = QD(1)
  end if


! **  Calculate incident solar flux at top of the canopy (SOL)

  SOL = SWAVE / ( 1 - ALBDOE )

! **

  RSG = SOL * ( 1 - SIGF ) * ( 1 - ALBG ) / ( 1 - SIGF * ALBG * ALBF )

  RSF = SOL * ( 1 - ALBF ) * SIGF * ( 1 + ALBG * ( 1 - SIGF ) / ( 1 - SIGF * ALBF * ALBG ) )

! **

  RLG = ( 1 - SIGF ) * EPSI * ( LWDN - SIGMA * TG**4 ) /         &
           ( 1 - SIGF * ( 1 - EPSF ) * ( 1 - EPSI ) ) -          &
           EPSI * EPSF * SIGF * SIGMA * ( TG**4 - TF**4 ) /      &
           ( 1 - SIGF * ( 1 - EPSF ) * ( 1 - EPSI ) )

  RLF = SIGF * ( EPSF * ( LWDN - SIGMA * TF**4 ) +               &
           EPSF * EPSI * SIGMA * ( TG**4 - TF**4) /              &
           ( 1 - SIGF * ( 1 - EPSF ) * ( 1 - EPSI ) ) ) +        &
           SIGF * ( 1 - SIGF ) * ( 1- EPSI ) * ( EPSF ) *        &
           ( LWDN - SIGMA * TF**4 ) / ( 1 - SIGF *               &
           ( 1 - EPSI ) * ( 1 - EPSF ) )

! **  Note that the radiometric temperature at the surfce is denoted
! **  by TZERO and is the equivalent to OTEMP in the bare soil mode.

  TZERO5 = (1 - SIGF ) * EPSI * TG**4 + EPSF * SIGF * TF**4
  TZERO5 = TZERO5**0.25

  TZERO4 = LWDN - RLG - RLF
  TZERO4 = TZERO4 / ( 1 * SIGMA )
  TZERO = TZERO4**0.25

  RNETG = RLG + RSG
  RNETF = RLF + RSF
  RNETV = RNETG + RNETF

! **  Set temperature and humidity variables.

  if (rnetf <= 0.0) then ! Set value since TA set to T1 (Vel)
    TAF = ta ! Set in Vel
    TF =  otemp
    TG =  otemp
!	TA = ATEMP
!	QA = QD(1)
    QAF = QD(1)
  end if


!
  SWAVEV = (RSG + RSF)


 return
end
