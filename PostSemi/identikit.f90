module modulos
   implicit none
   integer, parameter :: FILES = 1         ! number of files per snapshot
   character(len=200), parameter :: path='/mnt/is2/dpaz/ITV/S1373/out'
   !character(len=200), parameter :: path='/mnt/is2/fstasys/ITV/S1050/out'

   character(len=200) :: filename, fnumber

   integer(4),dimension(0:5) :: npart, nall
   real(8),dimension(0:5)    :: massarr
   real*8    a
   real*8    redshift
   integer*4 fn,i,j,nstart,flag_sfr,flag_feedback
   integer*4 N,Ntot
   integer(4),dimension(0:5) :: Newnpart

   integer*4 flag_cool, num_files
   real*8    boxsize
   real*8 newbox
   real*8    omega_m,omega_l
   integer*4 unused(26)

   real*4,allocatable    :: pos(:,:),vel(:,:)
   integer*4,allocatable :: id(:),idch(:),idgn(:)
   real*4, allocatable,dimension(:)    :: mass, u, dens, ne, &
                                        nh,hsml,sfr,abvc,temp 
   real*8 n0,mol,R,vx,vy,vz
   real :: prom1,prom2,prom3
       
   character(len=4) :: blckname 
   integer(kind=4) :: hwm
   real(kind=4)  :: hwm2 
   real :: xmin,ymin,zmin
   real :: xmax,ymax,zmax
   integer(4) :: i1,i2,npgs

   logical :: ilogic
endmodule
subroutine reader(snumber)
        use modulos
        implicit none
        integer :: unidad
       character(len=200) :: snumber

   write(fnumber,'(I3)') 1
   do i=1,3 
      if (snumber(i:i) .eq. ' ') then 
          snumber(i:i)='0'
      end if
   end do

   filename= trim(path)//'/snapshot_'//trim(snumber) !!// '.' // fnumber(verify(fnumber,' '):3)

   ! now, read in the header
   unidad=1
   open (unidad, file=filename, form='unformatted')
   !open (1, file=filename, access='stream')

   read (1)blckname,hwm

   read (1) npart, massarr, a, redshift, flag_sfr,flag_feedback, nall,flag_cool, num_files, boxsize,omega_m,omega_l,unused

   Ntot= sum(nall)

   allocate(pos(3,Ntot))
   allocate(vel(3,Ntot))
   N=sum(npart)

   
   !hwm contiene el numero de bytes del bloque de datos mas 8 bytes
   read (1)blckname,hwm
   read (1)pos
 !  write(*,*) blckname,hwm
 !  write(*,*)'leyendo ',blckname,hwm-8
   read (1)blckname,hwm
   read (1) vel
   read (1)blckname,hwm
 !  write(*,*) blckname,hwm
 !  write(*,*)'leyendo ',blckname,hwm-8
   allocate(id(int((hwm-8)/4)))
   read (1)id
        
 
   read (1)blckname,hwm
 !  write(*,*)'leyendo ',blckname,hwm-8
   allocate(idch(int((hwm-8)/4)))
   read (1)idch
   read (1)blckname,hwm
 !  write(*,*)'leyendo ',blckname,hwm-8
   allocate(idgn(int((hwm-8)/4)))
   read (1)idgn

   read (1)blckname,hwm
 !  write(*,*)'leyendo ',blckname,hwm-8
 !       print*, 'allocateo con ',int(real((hwm-8)/4.)-1)
   allocate(mass(int((hwm-8)/4)))
   read (1)mass
   read (1)blckname,hwm
 !  write(*,*)'leyendo ',blckname,hwm-8
   allocate(u(int((hwm-8)/4)))
   !write(*,*) 'allocate con', int(real(hwm-8)/4.)
   read (1)u
   read (1)blckname,hwm
 !  write(*,*)'leyendo ',blckname,hwm-8
   allocate(dens(int(hwm-8)/4))
   read (1)dens
 
   read (1)blckname,hwm
   allocate(ne(int(hwm-8)/4))
   read(1)ne
   close(1)
   npgs = nall(0)
endsubroutine
subroutine linkedlist(n,abin,cell,pos,head,tot,link)
        implicit none
        integer :: i,n,bx,by,bz,cell
        integer,dimension(cell,cell,cell) :: tot, head
        real,dimension(3,n) :: pos
        integer,dimension(n) :: link
        real :: abin
        
        do i = 1,n
               bx = int(pos(1,i)/abin) + 1
               by = int(pos(2,i)/abin) + 1
               bz = int(pos(3,i)/abin) + 1
               if (bx==0)     bx=cell
               if (bx==cell+1)bx=1
               if (by==0)     by=cell
               if (by==cell+1)by=1
               if (bz==0)     bz=cell
               if (bz==cell+1)bz=1

               tot(bx,by,bz) = tot(bx,by,bz) + 1
               head(bx,by,bz)   = i
       enddo

       do i = 1,n
               bx = int(pos(1,i)/abin) + 1
               by = int(pos(2,i)/abin) + 1
               bz = int(pos(3,i)/abin) + 1

                if (bx==0)     bx=cell
                if (bx==cell+1)bx=1
                if (by==0)     by=cell
                if (by==cell+1)by=1
                if (bz==0)     bz=cell
                if (bz==cell+1)bz=1
               
                link(head(bx,by,bz)) = i
                head(bx,by,bz)       = i
        enddo 
endsubroutine 
!subroutine contador(nall,pos,ne,u,id,dens,p,rmin,rmax,xc,yc,zc,mu,yhe,te,vv,mp,kcgs)
!        use modulos
!        implicit none
!        integer :: p
 !       real :: d,xc,yc,zc,mu,yhe,te,vv,mp,kcgs,rmin,rmax,dmean,pi
 !       pi=acos(-1.)
 !       dmean=(3*(100**2)*(0.045))/(8*pi*(4.3e-9))*1e-10
 !       p=0
  !      do i=1,nall(0)
  !              d=sqrt((pos(1,i)-xc)**2+(pos(2,i)-yc)**2+(pos(3,i)-zc)**2)       
  !              if (d<rmax .and. d>rmin) then 
  !               mu=(1.0-yHe)/(1+yHe+ne(i))
   !              te=(5./3.-1.)*u(i)*vv*mu*mp/kcgs
   !              if (te<10**(3) .and. (dens(i)/dmean)<10**(-1.3)) p=p+1         
   !              if (te<10**(3) .and. (dens(i)/dmean)<10**(-1.3)) print*, id(i)        
   !             endif 
   !     enddo
   !     print*, p
!endsubroutine
subroutine Id_Finder(snap,dmn0,dmn,idp,snapshot,hist,z)
!        use modulos
        implicit none
        character(len=200) :: snumber
        integer:: s,p,particula,snapshot,dmn,i,j
        integer,dimension(dmn) :: idp
        real,dimension(snap,dmn) :: hist
        integer(4),dimension(0:5) ::nall
        real    :: pos(3,dmn0),vel(3,dmn0)
        integer*4,dimension(dmn0) :: id,idch,idgn
        real*4,dimension(dmn0)    :: mass, u, dens, ne, nh,hsml,sfr,abvc,temp
        integer :: dmn1,dmn0,snap
        real :: redshift
        real,dimension(snap) :: z
        s = 51-snapshot
        write(snumber,'(I3)') snapshot
        id=0; pos=0; u=0; dens=0; ne=0
        call reader_parallel(snumber,snapshot,dmn0,pos,id,u,dens,ne,dmn1)
        p = 1
        z(s)=redshift
        particula = idp(p)
        do while (p<=dmn)
                do j=1,dmn1
                if (id(j)==particula) then
                        hist(s,p) = dens(j)
                        p = p + 1
                        particula = idp(p)
                if (mod(p,500)==0)  print*, p,snapshot
!                print*, p,snapshot
                endif      
                       
                        
                enddo  
!                deallocate(pos,vel,id,idch,idgn,u,dens,mass,ne)
        enddo 

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
ENDSUBROUTINE
subroutine reader_parallel(snumber,snapshot,dmn0,pos0,id0,u0,dens0,ne0,dmn1)
   implicit none
   integer, parameter :: FILES = 1         ! number of files per snapshot
   character(len=200), parameter :: path='/mnt/is2/dpaz/ITV/S1373/out'
   character(len=200) :: filename, fnumber
   integer(4),dimension(0:5) :: npart, nall
   real(8),dimension(0:5)    :: massarr
   real*8    a
   real*8    redshift
   integer*4 fn,i,j,nstart,flag_sfr,flag_feedback
   integer*4 N,Ntot
   integer(4),dimension(0:5) :: Newnpart
   integer*4 flag_cool, num_files
   real*8    boxsize
   real*8 newbox
   real*8    omega_m,omega_l
   integer*4 unused(26)
   real*4,allocatable  :: pos(:,:),vel(:,:)
   integer*4,allocatable,dimension(:) :: id,idch,idgn
   real*4, allocatable,dimension(:)    :: mass, u, dens, ne, nh,hsml,sfr,abvc
   real,dimension(dmn0) :: u0,dens0,ne0
   integer,dimension(dmn0) :: id0
   real :: pos0(3,dmn0)
   real*8 n0,mol,R,vx,vy,vz
   real :: prom1,prom2,prom3
   character(len=4) :: blckname 
   integer(kind=4) :: hwm
   real(kind=4)  :: hwm2 
   real :: xmin,ymin,zmin
   real :: xmax,ymax,zmax
   integer(4) :: i1,i2,npgs
   logical :: ilogic
   character(len=200) :: snumber
   integer:: snapshot,dmn1,dmn0

   print*, snapshot
   write(fnumber,'(I3)') 1
   do i=1,3 
      if (snumber(i:i) .eq. ' ') then 
          snumber(i:i)='0'
      end if
   end do

   !filename= path(1:len_trim(path)) // '/snapshot_' // snumber(1:len_trim(snumber)) !!// '.' // fnumber(verify(fnumber,' '):3)
   filename= trim(path)//'/snapshot_'//trim(snumber) !!// '.' // fnumber(verify(fnumber,' '):3)

   ! now, read in the header

   open (snapshot, file=filename, form='unformatted')
   !open (1, file=filename, access='stream')

   read (snapshot)blckname,hwm

   read (snapshot) npart, massarr, a, redshift, flag_sfr,flag_feedback, nall,flag_cool, num_files, boxsize,omega_m,omega_l,unused

 !  do i=0,5
 !     print *,'Type=',i,'    Particles=', nall(i)
 !  end do
   ! Now we just read in the coordinates, and only keep those of type=1
   ! The array PartPos(1:3,1:Ntot) will contain all these particles
   Ntot= sum(nall)

   allocate(pos(3,Ntot))
   allocate(vel(3,Ntot))
   N=sum(npart)

   
   !hwm contiene el numero de bytes del bloque de datos mas 8 bytes
   read (snapshot)blckname,hwm
   read (snapshot)pos
 !  write(*,*) blckname,hwm
 !  write(*,*)'leyendo ',blckname,hwm-8
   read (snapshot)blckname,hwm
   
   read (snapshot) vel
   read (snapshot)blckname,hwm
 !  write(*,*) blckname,hwm
 !  write(*,*)'leyendo ',blckname,hwm-8
   allocate(id(int((hwm-8)/4)))
   read (snapshot)id
        
 
   read (snapshot)blckname,hwm
 !  write(*,*)'leyendo ',blckname,hwm-8
   allocate(idch(int((hwm-8)/4)))
   read (snapshot)idch
   read (snapshot)blckname,hwm
 !  write(*,*)'leyendo ',blckname,hwm-8
   allocate(idgn(int((hwm-8)/4)))
   read (snapshot)idgn

   read (snapshot)blckname,hwm
 !  write(*,*)'leyendo ',blckname,hwm-8
 !       print*, 'allocateo con ',int(real((hwm-8)/4.)-1)
   allocate(mass(int((hwm-8)/4)))
   read (snapshot)mass
   read (snapshot)blckname,hwm
 !  write(*,*)'leyendo ',blckname,hwm-8
   allocate(u(int((hwm-8)/4)))
   !write(*,*) 'allocate con', int(real(hwm-8)/4.)
   read (snapshot)u
   read (snapshot)blckname,hwm
 !  write(*,*)'leyendo ',blckname,hwm-8
   allocate(dens(int(hwm-8)/4))
   read (snapshot)dens
 
   read (snapshot)blckname,hwm
   allocate(ne(int(hwm-8)/4))
   read(snapshot)ne
   close(snapshot)
   npgs = nall(0)

   do i=1,nall(0)
                pos0(1,i) = pos(1,i)
                pos0(2,i) = pos(2,i)
                pos0(3,i) = pos(3,i)
                u0(i)     = u(i)
                id0(i)    = id(i)
                ne0(i)    = ne(i)
                dens0(i)  = dens(i)
   enddo
        dmn1=nall(0)

endsubroutine

