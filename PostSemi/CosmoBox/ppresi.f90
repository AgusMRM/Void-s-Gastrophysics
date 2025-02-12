! hay que compilar el modulo y subroutina de el archivo modulos.f90
! ej:  gfortran -o pp modV.f90 ppresi.f90 
program first
        use modulos
        implicit none
        integer,parameter :: bines=25, VOID=1373
        real,parameter :: rmax=26, pi=acos(-1.),rmin=0.001
        real :: abin,d,vol,vol2,rm,rand,minmass,maxmass,minsfr,maxsfr,abin2,ri,rad,r0
        integer :: bin,bin2
        real :: dgs,ddm,ddm2,dst,dtt,x,y,z,xbox,ybox,zbox,rv 
        real,dimension(bines):: sf,hsml0
        real*8,dimension(bines):: wgth,mass_dm,mass_tot,mass_gs,mass_dm2,mass_st
        integer,dimension(bines):: num_gs,num_dm,num_st
  !-----------------------------------------------------------------------------     
        call reader()

        !xbox=411.217
        !ybox=162.1655
        !zbox=453.0553 
        xbox=403.896
        ybox=459.8882
        zbox=440.9021 

        open(13,file='/mnt/is2/fstasys/ITV/base09/voids/voids_new.dat')
        do i=1,VOID-1
        read(13,*)
        enddo

        read(13,*) rv,x,y,z
        x=x-xbox+250
        y=y-ybox+250
        z=z-zbox+250
        close(13)
        write(*,*) x,y,z
  !-----------------------------------------------------------------------------
        rm=(rmax)
        ri=(rmin)
        abin = (rm-ri)/real(bines)        
        sf = 0
        num_gs  = 0
        num_dm  = 0
        num_st = 0
        wgth = 0
        minsfr=400
        maxsfr=0
        mass_tot=0
        mass_gs=0
        mass_dm=0
        mass_dm2=0
        mass_st=0
 !----------------------------------------------- GAS --------------------------       
        do i=1,nall(0)
                d=(sqrt((pos(1,i)-x)**2+(pos(2,i)-y)**2+(pos(3,i)-z)**2))
                if ((d) < rm .and. d>ri) then
                        bin = int((d-ri)/abin) + 1
                        sf(bin) = sf(bin) + sfr(i)
                        if (bin==1 .and. sfr(i)>0) print*, sfr(i)
                        num_gs(bin)  = num_gs(bin) + 1
                        wgth(bin) = wgth(bin) + 1e10*mass(i)
                        mass_tot(bin) = mass_tot(bin) + mass(i)
                        mass_gs(bin) = mass_gs(bin) + mass(i)
                endif

        enddo
  !---------------------------------------------- DM ------------------------
        do i=nall(0)+1,nall(0)+nall(1)
                d=(sqrt((pos(1,i)-x)**2+(pos(2,i)-y)**2+(pos(3,i)-z)**2))
                if ((d) < rm .and. d>ri) then
                bin = int((d-ri)/abin) + 1
                num_dm(bin)  = num_dm(bin) + 1
                mass_dm(bin) = mass_dm(bin) + mass(i)
                mass_dm2(bin) = mass_dm2(bin) + mass(i)
                mass_tot(bin) = mass_tot(bin) + mass(i)
                endif
        enddo
  !---------------------------------------------- TIDALES ------------------   
        do i=nall(0)+nall(1)+1,nall(0)+nall(1)+nall(2)
                d=(sqrt((pos(1,i)-x)**2+(pos(2,i)-y)**2+(pos(3,i)-z)**2))
                if ((d) < rm) then
                bin = int((d-ri)/abin) + 1
                num_dm(bin)  = num_dm(bin) + 1
                mass_dm2(bin) = mass_dm2(bin) + mass(i)
                mass_tot(bin) = mass_tot(bin) + mass(i)
                endif
        enddo   
   !--------------------------------------------- ESTRELLAS -------------
        do i=nall(0)+nall(1)+nall(2)+1,nall(0)+nall(1)+nall(2)+nall(4)
                d=(sqrt((pos(1,i)-x)**2+(pos(2,i)-y)**2+(pos(3,i)-z)**2))
                if ((d) < rm .and. d>ri) then
                bin = int((d-ri)/abin) + 1
                num_st(bin)  = num_st(bin) + 1
                mass_tot(bin) = mass_tot(bin) + mass(i)
                mass_st(bin) = mass_st(bin) + mass(i)
                endif
        enddo
   !---------------------------------------------------------------------     
        open(10,file='particlesprofile.dat',status='unknown')
        ddm = 0
        ddm2 = 0
        dgs = 0
        dst = 0
        dtt = 0
        r0 = rmax
        do i=1,bines
                ddm = ddm + mass_dm(bines+1-i)
                rad = ((bines-i)*abin+ri)
                vol2 = (4./3.)*pi*((r0)**3-(rad)**3)
       !        write(10,*) 10**(i*abin), num_gs(i)/vol, num_dm(i)/vol,num_st(i)/vol, wgth(i)/vol, sf(i)/vol, mass_dm(i)
             !   write(10,'(11(e25.10,1x))') 10**((i-.5)*abin+ri), dgs,ddm,ddm2,dst,dtt,vol, & 
             !                  mass_dm(i), mass_gs(i), mass_st(i),vol2,sf(i)
              !write(10,*) 10**((i-.5)*abin+ri), mass_gs(i), mass_dm(i),mass_st(i), sf(i), vol2,vol
              write(10,*) (((bines+1-i)-.5)*abin+ri), ddm , vol2
                  !r0=rad       
        enddo
        close(10)
        !print*, sf
endprogram
