program test_intpol
  use simsphere_mod
  use mod_testing, only: assert, initialize_tests, report_tests
  use, intrinsic :: ieee_arithmetic
  implicit none

  ! Expected test results
  real, dimension(50), parameter :: ug_exp =  & 
             (/9.18181801,8.36363602,7.54545498,6.72727299,5.90909100, &
               5.09090948,4.27272749,3.45454597,2.63636398,1.81818199, &
               1.00000000,0.181818962,-0.636363029,-1.45454502,-2.27272701, &
               -3.09090805,-3.90909004,-4.72727203,-5.54545403,-6.36363602, &
               0.00000000,0.00000000,0.00000000,0.00000000,0.00000000, &
               0.00000000,0.00000000,0.00000000,0.00000000,0.00000000, &
               0.00000000,0.00000000,0.00000000,0.00000000,0.00000000, &
               0.00000000,0.00000000,0.00000000,0.00000000,0.00000000, &
               0.00000000,0.00000000,0.00000000,0.00000000,0.00000000, &
               0.00000000,0.00000000,0.00000000,0.00000000,0.00000000/)
  real, dimension(50), parameter :: vg_exp =  & 
             (/9.18181801,8.36363602,7.54545498,6.72727299,5.90909100, &
               5.09090948,4.27272749,3.45454597,2.63636398,1.81818199, &
               1.00000000,0.181818962,-0.636363029,-1.45454502,-2.27272701, &
               -3.09090805,-3.90909004,-4.72727203,-5.54545403,-6.36363602, &
               0.00000000,0.00000000,0.00000000,0.00000000,0.00000000, &
               0.00000000,0.00000000,0.00000000,0.00000000,0.00000000, &
               0.00000000,0.00000000,0.00000000,0.00000000,0.00000000, &
               0.00000000,0.00000000,0.00000000,0.00000000,0.00000000, &
               0.00000000,0.00000000,0.00000000,0.00000000,0.00000000, &
               0.00000000,0.00000000,0.00000000,0.00000000,0.00000000/)
  real, dimension(50), parameter :: ugd_exp =  &
              (/9.57142830,7.42857170,5.28571463,3.14285755,1.00000000, &
                1.00000000,1.00000000,1.00000000,1.00000000,1.00000000, &
                1.00000000,1.00000000,1.00000000,1.00000000,1.00000000, &
                1.00000000,1.00000000,1.00000000,1.00000000,1.00000000, &
                0.00000000,0.00000000,0.00000000,0.00000000,0.00000000, &
                0.00000000,0.00000000,0.00000000,0.00000000,0.00000000, &
                0.00000000,0.00000000,0.00000000,0.00000000,0.00000000, &
                0.00000000,0.00000000,0.00000000,0.00000000,0.00000000, &
                0.00000000,0.00000000,0.00000000,0.00000000,0.00000000, &
                0.00000000,0.00000000,0.00000000,0.00000000,0.00000000/)
  real, dimension(50), parameter :: vgd_exp =  &
              (/9.57142830,7.42857170,5.28571463,3.14285755,1.00000000, &
                1.00000000,1.00000000,1.00000000,1.00000000,1.00000000, &
                1.00000000,1.00000000,1.00000000,1.00000000,1.00000000, &
                1.00000000,1.00000000,1.00000000,1.00000000,1.00000000, &
                0.00000000,0.00000000,0.00000000,0.00000000,0.00000000, &
                0.00000000,0.00000000,0.00000000,0.00000000,0.00000000, &
                0.00000000,0.00000000,0.00000000,0.00000000,0.00000000, &
                0.00000000,0.00000000,0.00000000,0.00000000,0.00000000, &
                0.00000000,0.00000000,0.00000000,0.00000000,0.00000000, &
                0.00000000,0.00000000,0.00000000,0.00000000,0.00000000/)

  logical, dimension(:), allocatable ::  tests
  logical :: test_failed
  integer :: n, ntests

  if (ieee_support_rounding(IEEE_NEAREST)) then
    call ieee_set_rounding_mode(IEEE_NEAREST)
  end if

  n = 1
  ntests = 4
  call initialize_tests(tests,ntests)

  NTRP = 10.0
  VGS = 10.0
  UGS = 10.0

  VD = 1.0
  UD = 1.0

  VGD(NTRP) = 1.0
  UGD(NTRP) = 1.0

  call intpol

  tests(n) = assert(all(ug_exp == ug), 'array ug')
  n = n + 1
  tests(n) = assert(all(vg_exp == vg), 'array vg')
  n = n + 1
  tests(n) = assert(all(ugd_exp == ugd), 'array ugd')
  n = n + 1
  tests(n) = assert(all(vgd_exp == vgd), 'array vgd')
  n = n + 1

  test_failed = .false.
  call report_tests(tests,test_failed)
  if (test_failed) stop 1
    

end program test_intpol