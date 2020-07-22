program first0
        implicit none
        integer,parameter :: bines=100, VOID=1277,halos= 850350  !106409 
        real,parameter :: rmax=120.0,rmin=5.0, pi=acos(-1.),corte=21,box=500
        real :: abin,d,vol,rm, rand,minmass,maxmass,minsfr,maxsfr,abin2,rad,r0
        integer :: bin,bin2  
        integer :: dmp,gsp,i,subhalos 
        real :: x,y,z,rv,ri,vol2,masa,a,dx,dy,dz
        real,dimension(bines):: sf,hsml0
        real,dimension(bines):: wgth,mass_dm
        integer,dimension(bines):: num_gs,num_dm,num_st
        real,dimension(3,halos) :: pos
        integer,dimension(halos) :: pnum, PID
  !-----------------------------------------------------------------------------    
 open(24,file='/mnt/is2/fstasys/ITV/base09/rockstar/host.dat',status='unknown',action='read')
 do i=1,16
 read(24,*)
 enddo
 do i=1,halos
        read(24,*) a,a,a,a,a,a,a,pnum(i), pos(1,i), pos(2,i), pos(3,i),a, &
                a,a,a,a,a,a,a,a,  a,a,a,a,a,a,a,a,a,a,  a,a,a,a,a,a, & 
                PID(i)
 enddo
 close(24)
 !------------------------------------------------------------------------------
print*, 'leo voids'
        open(13,file='voids_new.dat')
        do i=1,VOID-1
        read(13,*)
        enddo

        read(13,*) rv,x,y,z
        close(13)
print*, rv,x,y,z
  !-----------------------------------------------------------------------------
        abin = (log10(rmax)-log10(rmin))/real(bines)        
        num_dm  = 0
        subhalos = 0
  !---------------------------------------------- DM ------------------------
        do i=1,halos
                dx=abs(pos(1,i)-x)
                dy=abs(pos(2,i)-y)
                dz=abs(pos(3,i)-z)
                if (dx>box/2.) dx=box-dx
                if (dy>box/2.) dy=box-dy
                if (dz>box/2.) dz=box-dz
                
                d=sqrt(dx**2+dy**2+dz**2)
                if (pnum(i)>=corte .and. PID(i)==-1) subhalos=subhalos+1
                if (d <= rmax .and. d>=rmin .and. pnum(i)>= corte .and. & 
                PID(i)==-1) then 
                bin = int((log10(d)-log10(rmin))/abin) + 1
                num_dm(bin)  = num_dm(bin) + 1
                endif
        enddo
        write(*,*) 'hay:',subhalos,'subhalos'
   !---------------------------------------------------------------------     
        open(17,file='halosprofiles22.dat',status='unknown')
        dmp = 0
        r0=rmin
        ri=0
        do i=1,bines
                dmp = dmp + num_dm(i)
                rad = 10**(i*abin+log10(rmin))
              !  vol2 = (4./3.)*pi*((10**(rad))**3-((10**(r0))**3))  ! ESTE ES
         !       PARA EL DIFERENCIAL
                vol  = (4./3.)*pi*(rad**3) !-(rmin)**3)
                write(17,*) 10**((i-.5)*abin+log10(rmin)), dmp, vol,num_dm(i),vol2
                !write(17,*) ((i)*abin), dmp, vol,num_dm(i),vol2
                r0 = rad
        enddo
        close(17)
endprogram
