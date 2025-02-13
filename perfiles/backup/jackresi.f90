! hay que compilar el modulo y subroutina de el archivo modulos.f90
! ej:  gfortran -o pp modulos.f90 program.f90 
program first
        use modulos
        implicit none
        real,parameter    :: masadm=0.0932880491
        integer,parameter :: bines=10, VOID=1198, n=48
        real,parameter :: rmax=25, pi=acos(-1.),rmin=.3
        real :: abin,d,vol,vol2,rm,minmass,maxmass,minsfr,maxsfr,abin2,ri,rad,r0
        integer :: bin,bin2,ijac,ijack,nparticulas
        real :: dgs,ddm,ddm2,dst,dtt,x,y,z,xbox,ybox,zbox,rv,rand 
        real,dimension(bines):: sf,hsml0
        real,dimension(bines)::mass_dm,mass_dm2,mass_st,den_dm
        integer,allocatable :: jack(:)
        integer :: num_dm(bines,n)
        real,allocatable :: part(:,:)
        real,dimension(bines) :: jmed,jsig,sig
        logical,dimension(n):: ilogic
  !-----------------------------------------------------------------------------    
  !El vector jack tiene un numero del 1 al n, entonces voy hacer n
  !realizaciones jacknife y en cada realizacion NO CONSIDERO las particulas
  !jack(n), osea, hago un perfil con todas las particulas menos las jack(1), el
  !segundo perfil lo hago sin usar las jack(2), etc. Despues tengo que
  !normalizar la cantidad de particulas  
  !--------------------------------------------------------------------     
        xbox=411.217
        ybox=162.1655
        zbox=453.0553 
      !  xbox=403.896
      !  ybox=459.8882
      !  zbox=440.9021 

        open(13,file='voids_new.dat')
        do i=1,VOID-1
        read(13,*)
        enddo

        read(13,*) rv,x,y,z
        x=x-xbox+250
        y=y-ybox+250
        z=z-zbox+250
        close(13)
  !-----------------------------------------------------------------------------
        rm=log10(rmax)
        ri=log10(rmin)
        abin = (rm-ri)/real(bines)        
        sf = 0
        num_dm  = 0
        mass_dm=0
        call reader()
  !--------------------------------------------------------------------------
  !------ahora me fijo de todas las particulas cuales son las que me interesan y
  !me las guardo en un vector (osea las que estan dentro de mi radio de
  !interes).  
        nparticulas=0
       do i=nall(0)+1,nall(0)+nall(1)
        d=log10(sqrt((pos(1,i)-x)**2+(pos(2,i)-y)**2+(pos(3,i)-z)**2))
        if (d < rm .and. d>ri) nparticulas=nparticulas+1
       enddo
       allocate(part(3,nparticulas))
       j=0
       do i=nall(0)+1,nall(0)+nall(1)
        d=log10(sqrt((pos(1,i)-x)**2+(pos(2,i)-y)**2+(pos(3,i)-z)**2))
        if (d < rm .and. d>ri) then
        j=j+1        
        part(1,j)= pos(1,i)
        part(2,j)= pos(2,i)
        part(3,j)= pos(3,i)
        endif
       enddo
       print*, 'dentro del radio de interes hay',nparticulas,'particulas'
   !-----------------------------------------------------------------    
       allocate(jack(nparticulas))
       j=0
       do i=1,nparticulas
        j=j+1
        call random_number(rand)
        jack(j) = int((rand)*n)+1
        if (jack(j) == 0)  print*, jack(j),j
        if (jack(j) > n)   print*, jack(j),j
       enddo
  ! aca leo mis datos y los asigno el bin que pertenezcan y a la realizacion
  ! jacknife pertinente
  !---------------------------------------------- DM ------------------------
        j=0
        do i=1,nparticulas
                j=j+1
                d=log10(sqrt((part(1,i)-x)**2+(part(2,i)-y)**2+(part(3,i)-z)**2))
                if ((d) < rm .and. d>ri) then
                bin = int((d-ri)/abin) + 1
                ijack = jack(j)
                num_dm(bin,ijack) = num_dm(bin,ijack) + 1
                endif
        enddo
   ! ------------------------- JACKNIFE REALIZATION -------------------------
   ! aca calculo la media jacknife para cada bin con su respectiva desviacion
   ! estandar estimada con jacknife. 
   jmed=0.0
   jsig=0.0
   sig =0.0
    r0 = ri
   do j=1,bines
    rad = (j*abin+ri)
    vol = (4./3.)*pi*((10**rad)**3-(10**r0)**3)

    do ijack=1,n
        ilogic=.TRUE.
        ilogic(ijack)=.FALSE.
        jmed(j) = jmed(j) + sum(num_dm(j,:),mask=ilogic)*masadm/vol
    enddo
    jmed(j) = jmed(j)/real(n)
    do ijack=1,n
        ilogic=.TRUE.
        ilogic(ijack)=.FALSE.
        jsig(j)=jsig(j)+(sum(num_dm(j,:),mask=ilogic)*masadm/vol-jmed(j))**2
    enddo
    sig(j)=sqrt(real(n-1)/real(n)*jsig(j))
    r0=rad       

   enddo   
   !---------------------------------------------------------------------     
        open(10,file='particlesprofile.dat',status='unknown')
        ddm = 0
        ddm2 = 0
                r0 = ri
        do i=1,bines
                ddm = ddm + mass_dm(i)
                rad = (i*abin+ri)
                vol = (4./3.)*pi*((10**rad)**3-(10**r0)**3)
              write(10,*) 10**((i-.5)*abin+ri), sum(num_dm(i,:))*masadm/vol,jmed(i), sig(i)
                  r0=rad       
        enddo
        close(10)
        !print*
endprogram
