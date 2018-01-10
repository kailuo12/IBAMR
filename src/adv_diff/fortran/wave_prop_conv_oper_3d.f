cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Computes r = u.grad(q)
c
c     where u is vector valued face centered velocity
c     q is cell centered with depth d
c     returns r_data at cell centeres
c     computes grad(q) using weno + wave propagation
c     interpolation coefficients and weights must be provided
c     currently only works for interp orders 3 (k=2) and 5 (k=3)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      subroutine wave_prop_convective_oper_3d(
     &            q_data, q_gcw,
     &            u_data_0, u_data_1, u_data_2, u_gcw,
     &            r_data, r_gcw, depth,
     &            ilower0, ilower1, ilower2,
     &            iupper0, iupper1, iupper2,
     &            dx,
     &            interp_coefs, smooth_weights, k)
      implicit none
      INTEGER ilower0, iupper0
      INTEGER ilower1, iupper1
      INTEGER ilower2, iupper2

      INTEGER depth

      INTEGER q_gcw
      real*8 q_data((ilower0-q_gcw):(iupper0+q_gcw),
     &              (ilower1-q_gcw):(iupper1+q_gcw),
     &              (ilower2-q_gcw):(iupper2+q_gcw),
     &               0:(depth-1))

      real*8 s_data_0((ilower0):(iupper0+1),
     &              (ilower1):(iupper1),
     &              (ilower2):(iupper2),
     &               0:1)
      real*8 s_data_1((ilower1):(iupper1+1),
     &              (ilower2):(iupper2),
     &              (ilower0):(iupper0),
     &               0:1)
      real*8 s_data_2((ilower2):(iupper2+1),
     &              (ilower0):(iupper0),
     &              (ilower1):(iupper1),
     &               0:1)

      INTEGER u_gcw
      real*8 u_data_0((ilower0-u_gcw):(iupper0+u_gcw+1),
     &                (ilower1-u_gcw):(iupper1+u_gcw),
     &                (ilower2-u_gcw):(iupper2+u_gcw))

      real*8 u_data_1((ilower1-u_gcw):(iupper1+u_gcw+1),
     &                (ilower2-u_gcw):(iupper2+u_gcw),
     &                (ilower0-u_gcw):(iupper0+u_gcw))

      real*8 u_data_2((ilower2-u_gcw):(iupper2+u_gcw+1),
     &                (ilower0-u_gcw):(iupper0+u_gcw),
     &                (ilower1-u_gcw):(iupper1+u_gcw))

      INTEGER r_gcw
      real*8 r_data((ilower0-r_gcw):(iupper0+r_gcw),
     &              (ilower1-r_gcw):(iupper1+r_gcw),
     &              (ilower2-r_gcw):(iupper2+r_gcw),
     &               0:(depth-1))

      real*8 dx(0:2)

      INTEGER k, j
      real*8 interp_coefs(0:k,0:(k-1))
      real*8 smooth_weights(0:(k-1))

      INTEGER i0, i1, i2
      real*8 inv_dx, inv_dy, inv_dz

      do j=0,(depth-1)
      call reconstruct_data_on_patch_3d(q_data(:,:,:,j), q_gcw,
     &             s_data_0, s_data_1, s_data_2, 0,
     &             ilower0, ilower1, ilower2,
     &             iupper0, iupper1, iupper2,
     &             interp_coefs, smooth_weights, k)
      inv_dx = 1.d0/dx(0)
      inv_dy = 1.d0/dx(1)
      inv_dz = 1.d0/dx(2)
      do i2 = ilower2, iupper2
      do i1 = ilower1, iupper1
        do i0 = ilower0, iupper0
         r_data(i0,i1,i2,j) =
     &     inv_dx*(max(u_data_0(i0,i1,i2),0.d0)*
     &     (s_data_0(i0,i1,i2,1)-s_data_0(i0,i1,i2,0))
     &     + min(u_data_0(i0+1,i1,i2),0.d0)*
     &     (s_data_0(i0+1,i1,i2,1)-s_data_0(i0+1,i1,i2,0))
     &     + 0.5d0*(u_data_0(i0+1,i1,i2)+u_data_0(i0,i1,i2))*
     &     (s_data_0(i0+1,i1,i2,0)-s_data_0(i0,i1,i2,1)))

         r_data(i0,i1,i2,j) = r_data(i0,i1,i2,j) +
     &     inv_dy*(max(u_data_1(i1,i2,i0),0.d0)*
     &     (s_data_1(i1,i2,i0,1)-s_data_1(i1,i2,i0,0))
     &     + min(u_data_1(i1+1,i2,i0),0.d0)*
     &     (s_data_1(i1+1,i2,i0,1)-s_data_1(i1+1,i2,i0,0))
     &     + 0.5d0*(u_data_1(i1+1,i2,i0)+u_data_1(i1,i2,i0))*
     &     (s_data_1(i1+1,i2,i0,0)-s_data_1(i1,i2,i0,1)))

         r_data(i0,i1,i2,j) = r_data(i0,i1,i2,j) +
     &     inv_dz*(max(u_data_2(i2,i0,i1),0.d0)*
     &     (s_data_2(i2,i0,i1,1)-s_data_2(i2,i0,i1,0))
     &     + min(u_data_2(i2+1,i0,i1),0.d0)*
     &     (s_data_2(i2+1,i0,i1,1)-s_data_2(i2+1,i0,i1,0))
     &     + 0.5d0*(u_data_2(i2+1,i0,i1)+u_data_2(i2,i0,i1))*
     &     (s_data_2(i2+1,i0,i1,0)-s_data_2(i2,i0,i1,1)))
      enddo; enddo; enddo; enddo
      end subroutine

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c       Reconstructs data on patches using a weno scheme
c       the convex and interpolation weights must be supplied
c
c       q_data is cell centered with depth 1
c       r_data_* are face centered with depth 2
c         and return the values reconstructed from each side
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      subroutine reconstruct_data_on_patch_3d(q_data, q_gcw,
     &            r_data_0, r_data_1, r_data_2, r_gcw,
     &            ilower0, ilower1, ilower2,
     &            iupper0, iupper1, iupper2,
     &            weights_cell_sides, smooth_weights_sides, k)

      implicit none
      INTEGER k
      INTEGER ilower0, iupper0
      INTEGER ilower1, iupper1
      INTEGER ilower2, iupper2

      INTEGER q_gcw
      real*8 q_data((ilower0-q_gcw):(iupper0+q_gcw),
     &            (ilower1-q_gcw):(iupper1+q_gcw),
     &            (ilower2-q_gcw):(iupper2+q_gcw))

      INTEGER r_gcw
      real*8 r_data_0((ilower0-r_gcw):(iupper0+r_gcw+1),
     &              (ilower1-r_gcw):(iupper1+r_gcw),
     &              (ilower2-r_gcw):(iupper2+r_gcw),
     &               0:1)
      real*8 r_data_1((ilower1-r_gcw):(iupper1+r_gcw+1),
     &              (ilower2-r_gcw):(iupper2+r_gcw),
     &              (ilower0-r_gcw):(iupper0+r_gcw),
     &               0:1)
      real*8 r_data_2((ilower2-r_gcw):(iupper2+r_gcw+1),
     &              (ilower0-r_gcw):(iupper0+r_gcw),
     &              (ilower1-r_gcw):(iupper1+r_gcw),
     &               0:1)

       real*8 weights_cell_sides(0:k,0:(k-1))
       real*8 smooth_weights_sides(0:(k-1))

       real*8 interp_values_p(0:(k-1))
       real*8 interp_values_n(0:(k-1))
       real*8 smooth_id_p(0:(k-1))
       real*8 smooth_id_n(0:(k-1))
       real*8 weights_p(0:(k-1))
       real*8 weights_n(0:(k-1))
       real*8 interp_values(0:(k-1))
       real*8 smooth_id(0:(k-1))
       real*8 weights(0:(k-1))

       INTEGER i0, i1, i2
       INTEGER j, r

       real*8 eps, total, alpha
       eps = 1.0d-7

c     X-Direction
      do i2 = ilower2, iupper2; do i1 = ilower1, iupper1
        do i0=ilower0,iupper0+1
          do r=0,k-1
            interp_values_p(r) = 0.d0
            interp_values_n(r) = 0.d0
            do j=0,k-1
              interp_values_p(r) = interp_values_p(r)
     &          + weights_cell_sides(r,j)*q_data(i0-r+j,i1,i2)
              interp_values_n(r) = interp_values_n(r)
     &          + weights_cell_sides(r+1,j)*q_data(i0-1-r+j,i1,i2)
            enddo
          enddo
          smooth_id_p(0) = 13.d0/12.d0*(q_data(i0,i1,i2)
     &         -2.d0*q_data(i0+1,i1,i2)+q_data(i0+2,i1,i2))**2
     &      + 0.25d0*(3.d0*q_data(i0,i1,i2)-4.d0*q_data(i0+1,i1,i2)
     &         +q_data(i0+2,i1,i2))**2
          smooth_id_p(1) = 13.d0/12.d0*(q_data(i0-1,i1,i2)
     &        -2.d0*q_data(i0,i1,i2)+q_data(i0+1,i1,i2))**2
     &      + 0.25d0*(q_data(i0-1,i1,i2)-q_data(i0+1,i1,i2))**2
          smooth_id_p(2) = 13.d0/12.d0*(q_data(i0-2,i1,i2)
     &        -2.d0*q_data(i0-1,i1,i2)+q_data(i0,i1,i2))**2
     &      + 0.25d0*(3.d0*q_data(i0,i1,i2)-4.d0*q_data(i0-1,i1,i2)
     &        +q_data(i0-2,i1,i2))**2

          smooth_id_n(0) = 13.d0/12.d0*(q_data(i0-1,i1,i2)
     &        -2.d0*q_data(i0,i1,i2)+q_data(i0+1,i1,i2))**2
     &      + 0.25d0*(3.d0*q_data(i0-1,i1,i2)-4.d0*q_data(i0,i1,i2)
     &        +q_data(i0+1,i1,i2))**2
          smooth_id_n(1) = 13.d0/12.d0*(q_data(i0-2,i1,i2)
     &        -2.d0*q_data(i0-1,i1,i2)+q_data(i0,i1,i2))**2
     &      + 0.25d0*(q_data(i0-2,i1,i2)-q_data(i0,i1,i2))**2
          smooth_id_n(2) = 13.d0/12.d0*(q_data(i0-3,i1,i2)
     &        -2.d0*q_data(i0-2,i1,i2)+q_data(i0-1,i1,i2))**2
     &      + 0.25d0*(3.d0*q_data(i0-1,i1,i2)
     &        -4.d0*q_data(i0-2,i1,i2)+q_data(i0-3,i1,i2))**2

          total = 0.d0
           do j=0,k-1
             alpha = smooth_weights_sides(k-1-j)/(eps+smooth_id_p(j))**2
             total = total + alpha
             weights_p(j) = alpha
           enddo
           do j=0,k-1
             weights_p(j) = weights_p(j)/total
           enddo
           total = 0.d0
           do j=0,k-1
             alpha = smooth_weights_sides(j)/(eps+smooth_id_n(j))**2
             total = total + alpha
             weights_n(j) = alpha
           enddo
           do j=0,k-1
             weights_n(j) = weights_n(j)/total
           enddo
           r_data_0(i0,i1,i2,0) = 0.d0
           r_data_0(i0,i1,i2,1) = 0.d0
           do r=0,k-1
             r_data_0(i0,i1,i2,0) = r_data_0(i0,i1,i2,0)
     &               + weights_n(r)*interp_values_n(r)
             r_data_0(i0,i1,i2,1) = r_data_0(i0,i1,i2,1)
     &               + weights_p(r)*interp_values_p(r)
           enddo
         enddo
       enddo; enddo

c       SECOND INTERPOLANT
c       Y DIRECTION
c     Interpolate in other direction
      do i2 = ilower2, iupper2; do i1 = ilower1, iupper1+1
        do i0=ilower0,iupper0
          do r=0,k-1
            interp_values_p(r) = 0.d0
            interp_values_n(r) = 0.d0
            do j=0,k-1
              interp_values_p(r) = interp_values_p(r)
     &          + weights_cell_sides(r,j)*q_data(i0,i1-r+j,i2)
              interp_values_n(r) = interp_values_n(r)
     &          + weights_cell_sides(r+1,j)*q_data(i0,i1-1-r+j,i2)
            enddo
          enddo
          smooth_id_p(0) = 13.d0/12.d0*(q_data(i0,i1,i2)
     &          -2.d0*q_data(i0,i1+1,i2)+q_data(i0,i1+2,i2))**2
     &       + 0.25d0*(3.d0*q_data(i0,i1,i2)-4.d0*q_data(i0,i1+1,i2)
     &          +q_data(i0,i1+2,i2))**2
          smooth_id_p(1) = 13.d0/12.d0*(q_data(i0,i1-1,i2)
     &          -2.d0*q_data(i0,i1,i2)+q_data(i0,i1+1,i2))**2
     &       + 0.25d0*(q_data(i0,i1-1,i2)-q_data(i0,i1+1,i2))**2
          smooth_id_p(2) = 13.d0/12.d0*(q_data(i0,i1-2,i2)
     &          -2.d0*q_data(i0,i1-1,i2)+q_data(i0,i1,i2))**2
     &       + 0.25d0*(3.d0*q_data(i0,i1,i2)-4.d0*q_data(i0,i1-1,i2)
     &          +q_data(i0,i1-2,i2))**2

          smooth_id_n(0) = 13.d0/12.d0*(q_data(i0,i1-1,i2)
     &          -2.d0*q_data(i0,i1,i2)+q_data(i0,i1+1,i2))**2
     &       + 0.25d0*(3.d0*q_data(i0,i1-1,i2)-4.d0*q_data(i0,i1,i2)
     &          +q_data(i0,i1+1,i2))**2
          smooth_id_n(1) = 13.d0/12.d0*(q_data(i0,i1-2,i2)
     &          -2.d0*q_data(i0,i1-1,i2)+q_data(i0,i1,i2))**2
     &       + 0.25d0*(q_data(i0,i1-2,i2)-q_data(i0,i1,i2))**2
          smooth_id_n(2) = 13.d0/12.d0*(q_data(i0,i1-3,i2)
     &          -2.d0*q_data(i0,i1-2,i2)+q_data(i0,i1-1,i2))**2
     &       + 0.25d0*(3.d0*q_data(i0,i1-1,i2)-4.d0*q_data(i0,i1-2,i2)
     &          +q_data(i0,i1-3,i2))**2

          total = 0.d0
           do j=0,k-1
             alpha = smooth_weights_sides(k-1-j)/(eps+smooth_id_p(j))**2
             total = total + alpha
             weights_p(j) = alpha
           enddo
           do j=0,k-1
             weights_p(j) = weights_p(j)/total
           enddo
           total = 0.d0
           do j=0,k-1
             alpha = smooth_weights_sides(j)/(eps+smooth_id_n(j))**2
             total = total + alpha
             weights_n(j) = alpha
           enddo
           do j=0,k-1
             weights_n(j) = weights_n(j)/total
           enddo
           r_data_1(i1,i2,i0,0) = 0.d0
           r_data_1(i1,i2,i0,1) = 0.d0
           do r=0,k-1
             r_data_1(i1,i2,i0,0) = r_data_1(i1,i2,i0,0)
     &               + weights_n(r)*interp_values_n(r)
             r_data_1(i1,i2,i0,1) = r_data_1(i1,i2,i0,1)
     &               + weights_p(r)*interp_values_p(r)
           enddo
         enddo
       enddo; enddo

c       THIRD INTERPOLANT
c       Z DIRECTION
c     Interpolate in other direction
      do i2 = ilower2, iupper2+1; do i1 = ilower1, iupper1
        do i0=ilower0,iupper0
          do r=0,k-1
            interp_values_p(r) = 0.d0
            interp_values_n(r) = 0.d0
            do j=0,k-1
              interp_values_p(r) = interp_values_p(r)
     &          + weights_cell_sides(r,j)*q_data(i0,i1,i2-r+j)
              interp_values_n(r) = interp_values_n(r)
     &          + weights_cell_sides(r+1,j)*q_data(i0,i1,i2-1-r+j)
            enddo
          enddo
          smooth_id_p(0) = 13.d0/12.d0*(q_data(i0,i1,i2)
     &          -2.d0*q_data(i0,i1,i2+1)+q_data(i0,i1,i2+2))**2
     &       + 0.25d0*(3.d0*q_data(i0,i1,i2)-4.d0*q_data(i0,i1,i2+1)
     &          +q_data(i0,i1,i2+2))**2
          smooth_id_p(1) = 13.d0/12.d0*(q_data(i0,i1,i2-1)
     &          -2.d0*q_data(i0,i1,i2)+q_data(i0,i1,i2+1))**2
     &       + 0.25d0*(q_data(i0,i1,i2-1)-q_data(i0,i1,i2+1))**2
          smooth_id_p(2) = 13.d0/12.d0*(q_data(i0,i1,i2-2)
     &          -2.d0*q_data(i0,i1,i2-1)+q_data(i0,i1,i2))**2
     &       + 0.25d0*(3.d0*q_data(i0,i1,i2)-4.d0*q_data(i0,i1,i2-1)
     &          +q_data(i0,i1,i2-2))**2

          smooth_id_n(0) = 13.d0/12.d0*(q_data(i0,i1,i2-1)
     &          -2.d0*q_data(i0,i1,i2)+q_data(i0,i1,i2+1))**2
     &       + 0.25d0*(3.d0*q_data(i0,i1,i2-1)-4.d0*q_data(i0,i1,i2)
     &          +q_data(i0,i1,i2+1))**2
          smooth_id_n(1) = 13.d0/12.d0*(q_data(i0,i1,i2-2)
     &          -2.d0*q_data(i0,i1,i2-1)+q_data(i0,i1,i2))**2
     &       + 0.25d0*(q_data(i0,i1,i2-2)-q_data(i0,i1,i2))**2
          smooth_id_n(2) = 13.d0/12.d0*(q_data(i0,i1,i2-3)
     &          -2.d0*q_data(i0,i1,i2-2)+q_data(i0,i1,i2-1))**2
     &       + 0.25d0*(3.d0*q_data(i0,i1,i2-1)-4.d0*q_data(i0,i1,i2-2)
     &          +q_data(i0,i1,i2-3))**2

          total = 0.d0
           do j=0,k-1
             alpha = smooth_weights_sides(k-1-j)/(eps+smooth_id_p(j))**2
             total = total + alpha
             weights_p(j) = alpha
           enddo
           do j=0,k-1
             weights_p(j) = weights_p(j)/total
           enddo
           total = 0.d0
           do j=0,k-1
             alpha = smooth_weights_sides(j)/(eps+smooth_id_n(j))**2
             total = total + alpha
             weights_n(j) = alpha
           enddo
           do j=0,k-1
             weights_n(j) = weights_n(j)/total
           enddo
           r_data_2(i2,i0,i1,0) = 0.d0
           r_data_2(i2,i0,i1,1) = 0.d0
           do r=0,k-1
             r_data_2(i2,i0,i1,0) = r_data_2(i2,i0,i1,0)
     &               + weights_n(r)*interp_values_n(r)
             r_data_2(i2,i0,i1,1) = r_data_2(i2,i0,i1,1)
     &               + weights_p(r)*interp_values_p(r)
           enddo
         enddo
       enddo; enddo
      endsubroutine

