subroutine  DAYKM(thick)
  use simsphere_mod
  implicit none

! **  This routine computes eddy diffusivities as a function of height,
! **  friction velocity and Monin Obukhov length for all the relevant
! **  levels in the mixing layer at each time step during the day; using
! **  the method of O'Brien.  Used in MOMDAY.

  real :: KTOP , KMA , KMAPRI , KMW(50)
  real, intent(inout) :: THICK
  real :: RATIO, SIGN

  integer :: I, J, L, M

!      INCLUDE 'modvars.h'

!  COMMON /MXDLYR/ THICK

  THICK = HGT - ZA

! **  If there is no mixing layer skip this routine.

  if ( .not. eq(thick,0.0) ) then

! **  Define or calc eddy diff's (K's) at the top of the surface layer
! **  using the standard flux profile law.  Calculate the derivative
! **  of KMA and define K at the top of the mixing layer to be zero.

    !KMA = KARMAN * USTAR * ZA * ( 1.0 - ( 15.0 * ZA / MOL )**0.25)
    ! This matches the original f77 code:
    KMA = KARMAN * USTAR * ZA * ( 1.0 - ( 15.0 * ZA / MOL ) )**0.25
    KM(1) = KMA
    KMW(1) = KMA
    KMAPRI = KMA * (1.0 / ZA - ( 15.0 / MOL ) / (1.0 - 15.0 * ZA / MOL))
    KTOP = 0.0

! **  Calc heights between the 250 metre intervals (ZI system) as passed
! **  from SPLINE, and call ZK system (Interval 50,175,425 etc).

    M = NTRP + 1
    do I = 2 , M
      ZK(I) = ZI(I) - 0.5 * DELTAZ
    end do
    ZK(1) = ZI(1)

! **  Calc the Eddy Diffusivities for momentum & water up to the top of
! **  the mixing layer using the O'Brien function.  If NRTP goes above
! **  HGT fill with zeros.

    do L = 2 , NTRP
      IF ( ZK(L) < HGT ) THEN
        KM(L) = KTOP + ( ( ZK(L) - HGT)**2 / THICK**2 ) * ( KMA - KTOP +  &
                ( ZK(L) - ZA ) * ( KMAPRI + 2 * ( KMA - KTOP ) / THICK ) )
        KMW(L) = KTOP + ( ( ZI(L) - HGT )**2 / THICK**2 ) * ( KMA - KTOP  &
                 + ( ZI(L) - ZA ) * ( KMAPRI + 2 * ( KMA - KTOP ) / THICK ) )
      ELSE
        KM(L)  = 0
        KMW(L) = 0
      END IF
    end do

! **  Smooth K's as a weighted average.

    do J = 2 , NTRP
      KM(J) = ( KMW(J) + KM(J) + KMW(J-1 ) ) / 3
    end do

! **  No mixing layer exists.

  end if

! **  Format statements

  return
end
