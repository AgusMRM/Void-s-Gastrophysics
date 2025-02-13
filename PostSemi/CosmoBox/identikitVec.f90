module modulos
   implicit none
   integer, parameter :: SNAPSHOT = 50     ! number of dump
   integer, parameter :: FILES = 8         ! number of files per snapshot
   character(len=200), parameter :: path='/mnt/is0/fstasys/512_b/out/snapdir_'!030'
   !character(len=200), parameter :: path='/mnt/is0/fstasys/512_b/out/snapdir_030'
   !character(len=200), parameter :: path='/mnt/is2/fstasys/ITV/S1050/out'
   character(len=200) :: filename, snumber, fnumber
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

   real*4,allocatable    :: pos_gs(:,:),vel_gs(:,:)
   real*4,allocatable    :: pos_st(:,:),vel_st(:,:)
   real*4,allocatable    :: pos_dm(:,:),vel_dm(:,:)
   integer*4,allocatable :: id(:),idch(:),idgn(:)
   real*4, allocatable,dimension(:):: mass, u, dens, ne,age, &
                                        nh,hsml,sfr,abvc 
   real*4,allocatable    :: pos0(:,:),vel0(:,:)
   integer*4,allocatable :: id0(:),idch0(:),idgn0(:)
   real*4, allocatable,dimension(:):: mass0, u0, dens0, ne0,age0, &
                                        nh0,hsml0,sfr0,abvc0
   
   real*8 n0,mol,R,vx,vy,vz
   real :: prom1,prom2,prom3
   character(len=4) :: blckname 
   integer(kind=4) :: hwm
   real(kind=4)  :: hwm2 
   real :: xmin,ymin,zmin
   real :: xmax,ymax,zmax
   integer(4) :: i1,i2,jgs,jst,jdm

   logical :: ilogic
endmodule
subroutine reader()
        use modulos
   write(snumber,'(I3)') SNAPSHOT
   write(fnumber,'(I1)') 0
   do i=1,3 
      if (snumber(i:i) .eq. ' ') then 
          snumber(i:i)='0'
      end if
   end do
   filename= trim(path)//trim(snumber)//'/snapshot_'//trim(snumber)//'.'//trim(fnumber)
   print *,'opening...  '//filename
   ! now, read in the header
   open (1, file=filename, form='unformatted')
   !open (1, file=filename, access='stream')
   read (1)blckname,hwm
   write(*,*)'leyendo ',blckname,hwm
   read (1) npart, massarr, a, redshift, flag_sfr,flag_feedback, nall,flag_cool, num_files, boxsize,omega_m,omega_l,unused
  write(*,*) 'npart:',npart
  write(*,*) 'redshift:',redshift
  write(*,*) 'unused:',nall
  ! do i=0,5
  !    print *,'Type=',i,'    Particles=', nall(i)
  ! end do
   allocate(pos_gs(3,nall(0)),vel_gs(3,nall(0)))
   allocate(pos_st(3,nall(4)))!,vel_st(3,nall(4)))
   allocate(pos_dm(3,nall(1)))!,vel_dm(3,nall(1)))
   allocate(id(sum(nall)))!,idch(sum(nall)),idgn(sum(nall)),mass(sum(nall)))
  ! allocate(u(nall(0)),dens(nall(0)),ne(nall(0)),nh(nall(0)),hsml(nall(0)))
  ! allocate(sfr(nall(0)),abvc(nall(0)))
  ! allocate(age(nall(4)))
   close(1)
!--------------------------------------------------------------------------------------
!--------------------------------------------------------------------------------------
!--------------------------------------------------------------------------------------
!--------------------------------------------------------------------------------------
   jgs=0; jdm=0; jst=0
   do fn=0, FILES-1     
   
   write(snumber,'(I3)') SNAPSHOT
   write(fnumber,'(I1)') fn
   do i=1,3 
      if (snumber(i:i) .eq. ' ') then 
          snumber(i:i)='0'
      end if
   end do
   !filename= trim(path)//'/snapshot_'//trim(snumber)//'.'//trim(fnumber)
   filename= trim(path)//trim(snumber)//'/snapshot_'//trim(snumber)//'.'//trim(fnumber)
  
   print *,'opening...  '//filename
   ! now, read in the header
   open (1, file=filename, form='unformatted')
   !open (1, file=filename, access='stream')
   read (1)blckname,hwm
   !write(*,*)'leyendo ',blckname,hwm
   read (1) npart, massarr, a, redshift, flag_sfr,flag_feedback, nall,flag_cool, num_files, boxsize,omega_m,omega_l,unused
  ! do i=0,5
  !    print *,'Type=',i,'    Particles=', nall(i)
  ! end do
   
   ! Now we just read in the coordinates, and only keep those of type=1
   ! The array PartPos(1:3,1:Ntot) will contain all these particles

   allocate(pos0(3,sum(npart)),vel0(3,sum(npart)))
   allocate(id0(sum(npart)))!,idch0(sum(npart)),idgn0(sum(npart)),mass0(sum(npart)))
   !allocate(u0(npart(0)),dens0(npart(0)),ne0(npart(0)),nh0(npart(0)),hsml0(npart(0)))
   !allocate(sfr0(npart(0)),abvc0(npart(0)))
   !allocate(age0(npart(4)))
 !  print*, (3*sum(npart)*4), '<--------- 3*sum(nall)*4 '
   read (1)blckname,hwm
   read (1)pos0
 !  write(*,*)'leyendo ',blckname,hwm-8
   read (1)blckname,hwm
   read (1)vel0
 !  write(*,*)'leyendo ',blckname,hwm-8
   read (1)blckname,hwm
   read (1)id0
 !  write(*,*)'leyendo ',blckname,hwm-8
   k=0
   do j=1,npart(0)
        k = k + 1
        jgs = jgs + 1
        pos_gs(1,jgs) = pos0(1,k)
        pos_gs(2,jgs) = pos0(2,k)
        pos_gs(3,jgs) = pos0(3,k)
   !     vel_gs(1,jgs) = vel0(1,k)
   !     vel_gs(2,jgs) = vel0(2,k)
   !     vel_gs(3,jgs) = vel0(3,k)
   !     dens(jgs)     = dens0(k)
   !     u(jgs)        = u0(k)
   !     sfr(jgs)      = sfr0(k)
             
   enddo
   k=0
   do j=1+npart(0),npart(0)+npart(1)
        k = k + 1
        jdm = jdm + 1
        pos_dm(:,jdm) = pos0(:,j)
 !       vel_dm(:,jdm) = vel0(:,j)
   enddo
   k=0
   do j=1+npart(0)+npart(1),npart(0)+npart(1)+npart(4)
        k = k + 1
        jst = jst + 1
        pos_st(:,jst) = pos0(:,j)
  !      age(jst) = age0(k)
   enddo

   nstart=nstart+npart(0)
deallocate(pos0,vel0,id0)!,idgn0,idch0,mass0,u0,dens0,age0,hsml0,abvc0,ne0,nh0,sfr0)
close(1)
   enddo

endsubroutine
subroutine linkedlist(n,abin,cell,pos,head,tot,link)
        implicit none
        integer :: i,n,bx,by,bz,cell
        integer,dimension(cell,cell,cell) :: tot, head
        real,dimension(3,n) :: pos
        integer,dimension(n) :: link
        real :: abin
        print*, 1
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


