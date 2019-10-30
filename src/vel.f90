subroutine VEL (MONCE,IONCE,StabCriteria,YCOUNT,Obst_Hgt,dual_regime, &
  zo_patch,VEGVELinit_vel,PSLCALINIT)
  use simsphere_mod
  implicit none

!  Subroutine VEL computes the Monin Obukhov Length, the Friction
!  Velocity and the Integral of Heat Diffusivity.

! Code Altered 5th May 1992 ... Code transferred to Bri.for
! Alterations 16th July to account for different Roughness Lenghts 
! associated with partial vegetation calculations.

  real :: KMM,KW,KS,KX
  real(kind=4) :: Obst_Hgt,zo_patch
  integer(kind=1) :: StabCriteria
  logical :: dual_regime
  integer :: MONCE, IONCE
  real :: REFLEV, ZTEN, CMH, CMW, YCOUNT
  real :: USCRN, RZAZO, U_Patch, Ustar_Patch, RZA_Obst, RObst_Patch
  real :: PTMP20, BOWEN, RTRANS, RTRANO3
  real :: SA, SRFCZO, SO10M, STEN, FM, FTEN, USTAR1
  real :: CHIO, CHIA, CHI20, T_ft, FT20, SObst_Hgt, FObst_Hgt
  real :: CH_Obst_Hgt, FT_Obst_Hgt, RZA_Obst_Hgt
  real :: PSIHNEW, REKUST
  real :: Rtrans_patch, RtransW_patch

  integer(kind=1) :: VEGVELinit_vel
  integer :: PSLCALINIT
      
!      INCLUDE 'modvars.h'

!  ZO Roughness height, ZA Top of surface layer (50m)

!  ZTEN - height at 10 m, REFLEV - "Screen or Anemometer Height".

  DATA REFLEV, ZTEN, KS, KW / 2., 10., 2.49951e-2, 2.97681e-2 /
  DATA CMH,CMW / 2*1. /

!  The model assumes neutral conditions at the start of the run where
!  HEAT = 0.  Therefore calc surface wind profile and resistances for
!  the surface layer on the basis log wind profile law.

  IF (StabCriteria .eq. 0 .or. (StabCriteria .eq. 1 .and.               &
     Heat <= 0.0 )) THEN ! Neutral Profile (Rare)
           
!         ^ Allow for negative heat flux 
       
    USTAR = You_Star (AWIND,ZA,ZO,0.0,KARMAN)      ! Friction Velocity

    USCRN = WindF (USTAR,Reflev,ZO,0.0,KARMAN)      ! Wind Speeds
    UTEN =  WindF (USTAR,ZTEN,ZO,0.0,KARMAN)

    RZAZO = R_ohms (USTAR,ZA,ZO,0.0,KARMAN)        ! Resistances
    RZASCR = R_ohms (USTAR,ZA,REFLEV,0.0,KARMAN) 
       
  if (dual_regime) then

     U_Patch = WindF (USTAR,Obst_Hgt,ZO,0.0,KARMAN)
     Ustar_Patch = You_Star (U_Patch,Obst_Hgt,zo_patch,0.0,KARMAN)
     RZA_Obst = R_ohms (USTAR,ZA,Obst_Hgt,0.0,KARMAN)
     RObst_Patch = R_ohms (Ustar_Patch,Obst_Hgt,zo_patch,0.0,KARMAN)

  end if
        
!  Potential, actual temp, specific humidity at 2 m. Pass
!  to vegetation component.

  PTMP20 = APTEMP + ( HEAT * RZASCR / ( DENS * CP ) )
  TA = PTMP20 - Tdif_s
  QA = AHUM + ( EVAP * RZASCR / ( DENS * LE ) )
   
!  Unstable case ... use the nondimensional functions of Z/L in
!  wind profiles for momentum and heat (FM,FT) to determine the
!  resistance term over the surface layer.

  else if ( StabCriteria .eq. 1 .and. heat > 0) then ! Unstable
    IF (EVAP < 0.000001) EVAP = 0.000001
    BOWEN = HEAT / EVAP
    IF ( ABS( BOWEN ) > 10 ) BOWEN = 10 * BOWEN / ABS ( BOWEN )
    MOL =  - ( ( USTAR**3 ) * aptemp * CP * DENS ) /                    &     
           ( KARMAN * GRAV * HEAT * ( 1 + 0.07 / ( ABS ( BOWEN ) ) ) )

!  Dimensionless wind shear

    SA = Stab (ZA,MOL) 
    SRFCZO = Stab (ZO,MOL)  
    SO10M = Stab (REFLEV,MOL)
    STEN = Stab (ZTEN,MOL)
       
!  Stability Correction for momentum. Benoit solution.

    FM = FstabM (SRFCZO, SA)
    FTEN = FstabM (SRFCZO, STEN)

    USTAR1 = You_Star (AWIND,ZA,ZO,FM,KARMAN) ! Friction Velocity
    USTAR = ( USTAR + USTAR1 ) / 2 ! Smooth

! Dimensionless temperature gradient again using the integrated form.

    CHIO = StabH (ZO,MOL)
    CHIA = StabH (ZA,MOL)
    CHI20 = StabH (REFLEV,MOL)
       
!  Stability Correction for heat. Benoit solution.

    T_ft = FstabH (CHIO,CHIA)
    FT20 = FstabH (CHI20,CHIA)
       
    UTEN = WindF (USTAR,ZTEN,ZO,FTEN,KARMAN)       ! Surface Winds at 
    USCRN = WindF (USTAR,REFLEV,ZO,0.0,KARMAN)     ! Screen Level & 10 metres

    RZASCR = R_ohms (USTAR,ZA,REFLEV,FT20,KARMAN) ! Resistances in 
    RZAZO = R_ohms (USTAR,ZA,ZO,T_ft,KARMAN)  ! Surface Layer
       
    if (dual_regime) then                   ! As above

      Sobst_Hgt = Stab (Obst_Hgt,MOL)
      Fobst_Hgt = FstabM (SRFCZO, Sobst_Hgt)
      U_Patch = WindF (USTAR,Obst_Hgt,ZO,0.0,KARMAN)
      Ustar_Patch = You_Star(U_Patch,Obst_Hgt,zo_patch,Fobst_Hgt,KARMAN)

      CH_Obst_Hgt = StabH (Obst_Hgt,MOL) 
      FT_Obst_Hgt = FstabH (CH_Obst_Hgt,CHIA)  
      RZA_Obst_Hgt = R_ohms (USTAR,ZA,Obst_Hgt,FT_Obst_Hgt,KARMAN) 
      RObst_Patch = R_ohms (Ustar_Patch,Obst_Hgt,zo_patch,0.0,KARMAN)  
        
    end if

!   As in neutral case calculate TA and QA.

    PTMP20 = APTEMP + ( HEAT * RZASCR / ( DENS * CP ) )
    TA = PTMP20 - Tdif_s
    QA = AHUM + ( EVAP * RZASCR / ( DENS * LE ) )

  else

!  Call the nightime routine.  Stable case

    CALL BRI (MONCE,PSIHNEW,YCOUNT,ZTEN) ! Stable

    REKUST = 1 / (KARMAN * USTAR)
    RZAZO =  REKUST * ( ALOG( ZA / ZO ) + psihnew )

!       RZASCR = REKUST * ( ALOG( ZA / REFLEV ) + psihref )

!  note that stability correction function corresponds to
!  old method described in Panofsky and Dutton.  New function
!  employed in Bri.for.  Differences between two are
!  slight during the short period following radiation sunset
!  when the above functions are employed.

    TA = T1
    QA = AHUM

  END IF

!  Set USTAR equal to some non-zero value if small.

  IF ( USTAR < 0.01 ) USTAR = 0.01
! TJC Work around a problem with this being unitialized.
! TJC Related to dual_regime and zo_patch
  ustar_patch = ustar

!  Calc the diffusivities and resistances to heat and water for
!  the transition layer.  KS & KW are the molecular conductivities
!  for heat and water.  CMH and CMW are the scaling factors .. see
!  manual.

  IF (IONCE == 0) THEN
    KMM = CMH * KS / ( DENS * CP )
    KX =  CMW * KW / ( DENS * CP )
  END IF
       
  RTRANS = ResTrn (USTAR,ZO,KMM,KARMAN) ! Resistance Transition Layer
  RTRANW = ResTrn (USTAR,ZO,KX,KARMAN)
  RTRANO3 = ResTrn (USTAR,ZO,KX/1.32,KARMAN)

!  Finally compute the total series resistance over both layers.

  GBL_sum = RZAZO + RTRANS
  SUMW = RZAZO + RTRANW
  sumo3 = rzazo + rtrano3

  If( dual_regime) then 
    Rtrans_Patch = ResTrn (ustar_patch,ZO,KMM,KARMAN)
    RtransW_Patch = ResTrn (ustar_patch,ZO,KX,KARMAN)

    GBL_sum = RZA_Obst_Hgt + RObst_Patch + Rtrans_Patch
    SUMW = RZA_Obst_Hgt + RObst_Patch + RtransW_Patch
  End if

!  If vegetation included, call vegetation component.

  IF (SWAVE > 0 .AND. RNET > 0 .AND. FRVEG > 0) THEN
    CALL VEGVEL(VEGVELinit_vel, PSLCALINIT)
  END IF

  return

end subroutine

