subroutine  VEGFLX (EVAPV)
  use simsphere_mod
  implicit none

  real :: EVAPV, rprime


!      INCLUDE 'modvars.h'

  QSTG = 10**( 6.1989 - 2353 / TG)
  XLEG = F * CHG * DENS * LE * (QSTG - QAF)
!      XLEG = (xleg + xlegn) / 2 ! Smooth
  if ( XLEG .LT. 0 ) XLEG = 0

  TG = TAF + (HG / CHG) / (DENS * CP) 
  EVAPV = XLEG + XLEF
  TAF = (CHA * TA + CHF * TF + TG * CHG) / (CHF + CHG + CHA)
  rprime = 1/(1/chf + RST)
  QAF = ( CHA * QA + rprime * QSTF + F * ChG * QSTG ) / ( CHA + rprime + F * CHG )


  return
end

! XLEG smoothed .. prevents instabilities at Low XLAI in full vegetation
! mode. 5th May 1992
