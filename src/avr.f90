subroutine average(T_Unsmoothed, T_smoothed)

  real :: av_array(4), sum, T_Unsmoothed, T_smoothed
  integer :: init

  data init /1/

  if (init .eq. 1) then ! fill all 4 elements with initial value of otemp

    do i = 1,4
      av_array(i) = T_Unsmoothed
    end do
  
    init = 2

  else

    do j = 2,4
      av_array(j-1) = av_array(j)
    end do

    av_array(4) = T_Unsmoothed

  endif

  sum = 0
  do k = 1,4
    sum = av_array(k) + sum
  end do

  T_smoothed = sum / 4

  return
end