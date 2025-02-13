program grid_mesh
        use modulos
        use OMP_lib
        implicit none
        integer, parameter :: cell=300, vec=10, nd=2000
        real, parameter :: box=89
        integer, dimension(cell,cell) :: tot, head
        !real*8,dimension(12232826) :: distance
        real, allocatable :: distance(:)
        real, allocatable :: dist(:)
        integer,allocatable,dimension(:,:,:) :: tot_gs, head_gs
        integer,allocatable,dimension(:,:,:) :: tot_dm, head_dm
        integer,allocatable,dimension(:,:,:) :: tot_st, head_st
        integer,allocatable :: link_gs(:)
        integer,allocatable :: link_dm(:)
        integer,allocatable :: link_st(:)
        real :: abin
        integer :: ndm, ngs, nst

        abin = box/real(cell)
        allocate(tot_gs(cell,cell,cell), head_gs(cell,cell,cell))
        allocate(tot_dm(cell,cell,cell), head_dm(cell,cell,cell))
        allocate(tot_st(cell,cell,cell), head_st(cell,cell,cell))
        call reader()
        allocate(link_gs(nall(0)),link_dm(nall(1)),link_st(nall(4)))

        ngs=nall(0)
        ndm=nall(1)
        nst=nall(4)

        tot_gs  = 0
        head_gs = 0
        link_gs = 0
        tot_dm  = 0       
        head_dm = 0
        link_dm = 0
        tot_st  = 0
        head_st = 0
        link_st = 0
        write(*,*) 'LiNKEANDO DM'
        call linkedlist(ndm,abin,cell,pos_dm,head_dm,tot_dm,link_dm)
        write(*,*) 'LiNKEANDO GAS'
        call linkedlist(ngs,abin,cell,pos_gs,head_gs,tot_gs,link_gs)
        write(*,*) 'LiNKEANDO ESTRELLAs'
        call linkedlist(nst,abin,cell,pos_st,head_st,tot_st,link_st)
     !************************************************************   
     !*********** VECTOR DE DISTANCIAS ***************************
    ! allocate(distance(nst))
     open(12,file='vecinas.dat',status='unknown')
    !do i=1,nst
       call vecina(nd,ngs,pos_gs,vec,nst,pos_st,abin,cell,box,tot_gs,head_gs,link_gs)!,distance)
       call vecina(nd,ndm,pos_dm,vec,nst,pos_st,abin,cell,box,tot_dm,head_dm,link_dm)!,distance)
       
    !enddo
    close(12)
    ! deallocate(distance)
endprogram grid_mesh
subroutine vecina(nd,ngs,pos2,vec,n,pos1,abin,cell,box,tot,head,link)!,d)
        implicit none
        integer :: i,j,k,m,cand,bxx,byy,bzz,u,p,l
        integer :: bx,by,bz,n,cell,vec,nd,ngs
        real :: x0,y0,z0,x,y,z,r,abin,box,dx,dy,dz
        real,dimension(3,n):: pos1
        real,dimension(3,ngs):: pos2
        integer,dimension(n) :: link
      !  real,dimension(n) :: d
        integer,dimension(cell,cell,cell):: head, tot
        real,allocatable :: dist(:)
        integer :: r1
        real    :: random
        cand = 0
        !d    = 0
        l = 0 
  !$OMP PARALLEL DEFAULT (NONE) &
  !$OMP PRIVATE (i,bx,by,bz,x,y,z,j,k,m,u,p,bxx,byy,bzz, &
  !$OMP cand,dist,l,x0,y0,z0,dx,dy,dz,r,r1,random) &
  !$OMP SHARED (pos1,abin,tot,head,link,n,cell,vec,box,nd,pos2 )
  !$OMP DO SCHEDULE (DYNAMIC)
        do i=1,nd
                l=0
                cand=0
                call random_number(random)
                r1=int(random*n)+1
                x = pos1(1,r1)
                y = pos1(2,r1)
                z = pos1(3,r1)
                bx = int(x/abin) + 1 
                by = int(y/abin) + 1 
                bz = int(z/abin) + 1
                if (bx == 0)      bx=cell
                if (bx == cell+1) bx=1 
                if (by == 0)      by=cell
                if (by == cell+1) by=1
                if (bz == 0)      bz=cell
                if (bz == cell+1) bz=1
                do j= bx-1,bx+1
                 if (j == 0) then 
                        bxx=cell
                 elseif (j == cell+1) then
                        bxx=1
                 else
                        bxx=j
                 endif      
                 do k= by-1,by+1
                    if (k == 0) then
                        byy=cell
                    elseif (k == cell+1) then
                        byy=1
                    else
                        byy=k
                    endif  
                 do m= bz-1,bz+1
                    if (m == 0) then
                        bzz=cell
                    elseif (m == cell+1) then
                        bzz=1
                    else
                        bzz=m
                    endif
                       cand = cand + tot(bxx,byy,bzz)
                enddo
                enddo 
                enddo 
                if (cand < vec) then
                        print*, 'HAY:',cand,'vecinas' 
                        go to 2
                endif
                allocate(dist(cand))
           !---------------------------------------     
                do j= bx-1,bx+1
                 if (j == 0) then 
                        bxx=cell
                 elseif (j == cell+1) then
                        bxx=1
                 else
                        bxx=j
                 endif      
                 do k= by-1,by+1
                    if (k == 0) then
                        byy=cell
                    elseif (k == cell+1) then
                        byy=1
                    else
                        byy=k
                    endif  
                 do m= bz-1,bz+1
                    if (m == 0) then
                        bzz=cell
                    elseif (m == cell+1) then
                        bzz=1
                    else
                        bzz=m
                    endif
           
           
                     p  = head(bxx,byy,bzz)
                    do u=1,tot(bxx,byy,bzz)
                        l  = l + 1
                        x0 = pos2(1,p)
                        y0 = pos2(2,p)
                        z0 = pos2(3,p)
                        dx=abs(x-x0)
                        dy=abs(y-y0)
                        dz=abs(z-z0)
                        if (dx > box/2.) dx = box - dx
                        if (dy > box/2.) dy = box - dy
                        if (dz > box/2.) dz = box - dz

                        r  = sqrt(dx**2+dy**2+dz**2)
                        dist(l) = r
                        p = link(p)
                    enddo
                 enddo    
                  enddo    
                enddo
                  l = 0
                  call orden(cand,dist)
                 ! d(i) = dist(vec) 
                  write(12,*) x, y,z, dist(vec) 
                  deallocate(dist)  
        2          cand = 0
        enddo
   !$OMP END DO
   !$OMP BARRIER
   !$OMP END PARALLEL
endsubroutine        
SUBROUTINE ORDEN(NELEM,ARREG)
! -----------------------------------------------------
!ORDENACION POR BURBUJA ("buble sort") de un arreglo
! unidimensional, de menor a mayor.
!
! NELEM = Número de elementos del arreglo
! ARREG = Arreglo unidimensional a ordenar
! -----------------------------------------------------
IMPLICIT NONE
INTEGER :: NELEM
REAL :: ARREG(*)
!-----------------------------------------------------
INTEGER:: I,J
REAL:: AUX
!-----------------------------------------------------
IF (NELEM.LT.2) RETURN
DO I=1,NELEM-1
DO J=1,NELEM-I
IF (ARREG(J).GT.ARREG(J+1)) THEN
AUX = ARREG(J)
ARREG(J) = ARREG(J+1)
ARREG(J+1) = AUX
ENDIF
ENDDO
ENDDO
RETURN
END
SUBROUTINE sort(n,arr)
      INTEGER n,M,NSTACK
      REAL*8 arr(n)
      PARAMETER (M=7,NSTACK=50)
      INTEGER i,ir,j,jstack,k,l,istack(NSTACK)
      REAL a,temp
      jstack=0
      l=1
      ir=n
1     if(ir-l.lt.M)then
        do 12 j=l+1,ir
          a=arr(j)
          do 11 i=j-1,1,-1
            if(arr(i).le.a)goto 2
            arr(i+1)=arr(i)
11        continue
          i=0
2         arr(i+1)=a
12      continue
        if(jstack.eq.0)return
        ir=istack(jstack)
        l=istack(jstack-1)
        jstack=jstack-2
      else
        k=(l+ir)/2
        temp=arr(k)
        arr(k)=arr(l+1)
        arr(l+1)=temp
        if(arr(l+1).gt.arr(ir))then
          temp=arr(l+1)
          arr(l+1)=arr(ir)
          arr(ir)=temp
        endif
        if(arr(l).gt.arr(ir))then
          temp=arr(l)
          arr(l)=arr(ir)
          arr(ir)=temp
        endif
        if(arr(l+1).gt.arr(l))then
          temp=arr(l+1)
          arr(l+1)=arr(l)
          arr(l)=temp
        endif
        i=l+1
        j=ir
        a=arr(l)
3       continue
          i=i+1
        if(arr(i).lt.a)goto 3
4       continue
          j=j-1
        if(arr(j).gt.a)goto 4
        if(j.lt.i)goto 5
        temp=arr(i)
        arr(i)=arr(j)
        arr(j)=temp
        goto 3
5       arr(l)=arr(j)
        arr(j)=a
        jstack=jstack+2
        if(jstack.gt.NSTACK)pause 'NSTACK too small in sort'
        if(ir-i+1.ge.j-l)then
          istack(jstack)=ir
          istack(jstack-1)=i
          ir=j-1
        else
          istack(jstack)=j-1
          istack(jstack-1)=l
          l=i
        endif
      endif
      goto 1
      END
