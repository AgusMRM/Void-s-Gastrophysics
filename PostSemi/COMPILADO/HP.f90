! el programa arma una tabla con las propiedades de los halos

! E S T A      P A R A L E L I Z A D O 


!---------------------------------------------------------------------
! hay que compilar el modulo y subroutina de el archivo modulos.f90
! uso:  gfortran -fopenmp -o pp modulosVOIDS.f90 HP.f90 

program first
        use modulos
        use OMP_lib
        implicit none
        integer,parameter::halos=71417 -19, box=500, cell=50, radvr=2,VOID=1373
        real,parameter ::  xbox=403.8960 ,ybox=459.8882 ,zbox=440.9021
        character(len=200), parameter :: hpath='/mnt/is2/dpaz/ITV/S1373/halos/halos_50.ascii'
        !integer,parameter::halos=87780-19, box=500, cell=50, radvr=1,VOID=1198
        !real,parameter ::  xbox=411.2170 ,ybox=162.1655 ,zbox=453.0553
        !character(len=200), parameter :: hpath='/mnt/is2/dpaz/ITV/R1198/halos/halos_50.ascii'
        character(len=200) :: hfilename
        integer :: ngas,ndm,ntid,nst
        integer :: k,m,l,p,particles,part_gs,part_dm,part_st,part_td
        real,allocatable :: pos_gs(:,:), vel_gs(:,:)
        real,allocatable :: u_gs(:), mass_gs(:)
        integer,allocatable :: id_gs(:)
        real,allocatable :: pos_dm(:,:), vel_dm(:,:)
        real,allocatable :: mass_dm(:)
        integer,allocatable :: id_dm(:)
        real,allocatable :: pos_td(:,:), vel_td(:,:)
        real,allocatable :: mass_td(:)
        integer,allocatable :: id_td(:)
        real,allocatable :: pos_st(:,:), vel_st(:,:)
        real,allocatable :: mass_st(:)
        integer,allocatable :: id_st(:)
        real,dimension(3,halos) :: pos_hl, vel_hl
        !real,dimension(halos) :: rvir,spin,lx_hl,ly_hl,lz_hl
        real,allocatable :: rvir(:),spin(:),lx_hl(:),ly_hl(:),lz_hl(:)
        integer,dimension(halos) :: id_hl,np_hl
        real :: nn, rmax, rmx,abin,masa_dm,masa_gs,masa_st,masa_t,masa_td,rho
        integer,dimension(cell,cell,cell) :: tot_gs, head_gs
        integer,dimension(cell,cell,cell) :: tot_dm, head_dm
        integer,dimension(cell,cell,cell) :: tot_td, head_td
        integer,dimension(cell,cell,cell) :: tot_st, head_st
        integer,allocatable :: link_gs(:)
        integer,allocatable :: link_dm(:)
        integer,allocatable :: link_td(:)
        integer,allocatable :: link_st(:)
        integer:: bxg,byg,bzg,cand,bx,by,bz,bxdm,bydm,bzdm,partcls
        real :: rx,ry,rz,x,y,z,velx,vely,velz,G,L_dm,L_gs,L_st,L_td,espin_dm,ssfr,e,h
        real :: hsml_gs,mas,maxhsml
        real :: xe,ye,ze,dc,rv,te 
        hfilename= trim(hpath)
        open(13,file='/mnt/is2/fstasys/ITV/base09/voids/voids_new.dat')
        do i=1,VOID-1
        read(13,*)
        enddo
        read(13,*) rv,xe,ye,ze
        xe=(xe-xbox+250)
        ye=(ye-ybox+250)
        ze=(ze-zbox+250) 

  !-----------------------------------------------------------------------------     
        call reader()
  !-----------------------------------------------------------------------------
        ngas=nall(0)
        ndm=nall(1)
        ntid=nall(2)
        nst=nall(4)
        allocate(pos_gs(3,ngas),vel_gs(3,ngas))
        allocate(u_gs(ngas),mass_gs(ngas),id_gs(ngas),link_gs(ngas)) 
        allocate(pos_dm(3,ndm),vel_dm(3,ndm))
        allocate(mass_dm(ndm),id_dm(ndm),link_dm(ndm)) 
        allocate(pos_td(3,ntid),vel_td(3,ntid))
        allocate(mass_td(ntid),id_td(ntid),link_td(ntid)) 
        allocate(pos_st(3,nst),vel_st(3,nst))
        allocate(mass_st(nst),id_st(nst),link_st(nst)) 
        write(*,*) 'PROGRAMA PRINCIPAL'
        do i=1,nall(0)
                pos_gs(1,i) = pos(1,i)
                pos_gs(2,i) = pos(2,i)
                pos_gs(3,i) = pos(3,i)
                vel_gs(1,i) = vel(1,i)
                vel_gs(2,i) = vel(2,i)
                vel_gs(3,i) = vel(3,i)
                mass_gs(i)  = mass(i)
                u_gs(i)     = u(i)

        enddo
        j=0
        do i=1+nall(0),nall(0)+nall(1)
                j=j+1
                pos_dm(1,j) = pos(1,i)
                pos_dm(2,j) = pos(2,i)
                pos_dm(3,j) = pos(3,i)
                vel_dm(1,j) = vel(1,i)
                vel_dm(2,j) = vel(2,i)
                vel_dm(3,j) = vel(3,i)
                mass_dm(j)  = mass(i)
        enddo
        j=0
        do i=1+nall(0)+nall(1),nall(0)+nall(1)+nall(2)
                j=j+1
                pos_td(1,j) = pos(1,i)
                pos_td(2,j) = pos(2,i)
                pos_td(3,j) = pos(3,i)
                vel_td(1,j) = vel(1,i)
                vel_td(2,j) = vel(2,i)
                vel_td(3,j) = vel(3,i)
                mass_td(j)  = mass(i)
        enddo
        j=0
        do i=1+nall(0)+nall(1)+nall(2)+nall(3),nall(0)+nall(1)+nall(2)+nall(3)+nall(4)
                j=j+1
                pos_st(1,j) = pos(1,i)
                pos_st(2,j) = pos(2,i)
                pos_st(3,j) = pos(3,i)
                vel_st(1,j) = vel(1,i)
                vel_st(2,j) = vel(2,i)
                vel_st(3,j) = vel(3,i)
                mass_st(j)  = mass(i)
        enddo
!---------------------------------------------------------------------------------------------------        
        allocate(rvir(halos),spin(halos),lx_hl(halos),ly_hl(halos),lz_hl(halos))
        rmax = 0

        open(7,file=hfilename,status='unknown')  !saltear 19 filas
        do i=1,19
                read(7,*)
        enddo
        print*, 'empiezo a leer halos'
        do i = 1, halos
                read(7,*) id_hl(i), np_hl(i), nn, nn, rvir(i), nn, nn, nn,pos_hl(1,i), pos_hl(2,i), pos_hl(3,i), &
                                vel_hl(1,i), vel_hl(2,i), vel_hl(3,i),lx_hl(i),ly_hl(i),lz_hl(i),nn,spin(i)
                if (rvir(i) >= rmax) rmax = rvir(i)
        enddo 
        close(7)
write(*,*) 'MAXIMO RADIO VIRIAL:',rmax*1e-3,'Mpc'
       
        abin    = real(box)/real(cell)
        
        tot_gs  = 0
        head_gs = 0
        link_gs = 0
        tot_dm  = 0       
        head_dm = 0
        link_dm = 0
        tot_td  = 0
        head_td = 0
        link_td = 0
        tot_st  = 0
        head_st = 0
        link_st = 0
        write(*,*) 'LiNKEANDO DM'
        call linkedlist(ndm,abin,cell,pos_dm,head_dm,tot_dm,link_dm)
        write(*,*) 'LiNKEANDO GAS'
        call linkedlist(ngas,abin,cell,pos_gs,head_gs,tot_gs,link_gs)
        write(*,*) 'LiNKEANDO TIDALES'
        call linkedlist(ntid,abin,cell,pos_td,head_td,tot_td,link_td)
        write(*,*) 'LiNKEANDO ESTRELLAs'
        call linkedlist(nst,abin,cell,pos_st,head_st,tot_st,link_st)

!-------------------------------------------------------------------------------------------
!-------------------------------------------------------------------------------------------
write(*,*) 'COMENZANDO CALCULOS'
!open(10,file='propiedades_halos.dat',status='unknown')
open(10,file='halosprop1.dat',status='unknown')
!$OMP PARALLEL DEFAULT (NONE) &
!$OMP PRIVATE(x,y,z,velx,vely,velz,bx,by,bz,part_td,rho,ssfr,maxhsml,part_gs, &
!$OMP part_dm,part_st, masa_gs,masa_dm,masa_st,dc,l_dm,te ) &
!$OMP SHARED(pos_hl,vel_hl,id_hl,abin,tot_td,tot_gs,tot_dm,tot_st,head_td,head_gs, &
!$OMP head_st,head_dm,pos_td,pos_dm,pos_gs,pos_st,vel_td,vel_gs,vel_st,vel_dm,link_td, &
!$OMP link_gs,link_st,link_dm,rvir,mass_gs,mass_dm,mass_st,dens,sfr,hsml,ntid,ngas, &
!$OMP nst,ndm,np_hl,spin,xe,ye,ze,lx_hl,ly_hl,lz_hl,ne,u)

!$OMP DO SCHEDULE(DYNAMIC)
        do i=1,halos                            
                x = pos_hl(1,i)
                y = pos_hl(2,i)
                z = pos_hl(3,i)
                velx = vel_hl(1,i)
                vely = vel_hl(2,i)
                velz = vel_hl(3,i)

                bx = int(x/abin) + 1
                by = int(y/abin) + 1
                bz = int(z/abin) + 1
             !------------------------------------   
                part_td = 0 
                call chequeo(x,y,z,bx,by,bz,part_td,ntid,cell,tot_td, &
                               head_td,pos_td,vel_td,link_td,rvir(i))
                if (part_td>0) cycle
             !-----------------------------------
                part_gs = 0 
                call cuentasgas(radvr,x,y,z,velx,vely,velz,bx,by,bz,part_gs,ngas,cell,tot_gs, &
                                head_gs,pos_gs,vel_gs,link_gs,rvir(i),dens,mass_gs,sfr,masa_gs,rho,ssfr,hsml,maxhsml, &
                                te,ne,u) 
                part_dm = 0 
                call cuentas(radvr,x,y,z,velx,vely,velz,bx,by,bz,part_dm,ndm,cell,tot_dm, &
                               head_dm,pos_dm,vel_dm,link_dm,rvir(i),mass_dm,masa_dm) 
                part_st = 0 
                call cuentas(radvr,x,y,z,velx,vely,velz,bx,by,bz,part_st,nst,cell,tot_st, &
                               head_st,pos_st,vel_st,link_st,rvir(i),mass_st,masa_st)
!                if (part_dm>25) then
                        !espin_dm = L_dm/(masa_dm*rvir(i)**2)*sqrt(G*masa_dm/(rvir(i)**3))
                dc = sqrt((x-xe)**2+(y-ye)**2+(z-ze)**2)       
                L_dm = sqrt(lx_hl(i)**2+ly_hl(i)**2+lz_hl(i)**2) 
                        write(10,*) dc,x,y,z,rvir(i),np_hl(i),part_gs,part_dm,part_st,masa_st,id_hl(i),spin(i),l_dm,te
!                endif
              !  endif
        enddo
       !$OMP END DO
       !$OMP BARRIER
       !$OMP END PARALLEL 
       close(10) 
endprogram first
subroutine cuentas(radvr,x,y,z,velx,vely,velz,bx,by,bz,o,n,cell,tot,head,pos,vel,link,rvir,mass,masa)
        !use modulos
        implicit none
        integer:: cell,n
        integer,dimension(cell,cell,cell) :: tot, head
        real,dimension(3,n):: pos,vel 
        real,dimension(n) :: mass
        integer,dimension(n) :: link       
        integer ::j, o,k,m,l,bx,by,bz,p,radvr
        real ::x,y,z,rx,ry,rz,rvir,masa,Lx,Ly,Lz,Ltot,vx,vy,vz,velx,vely,velz
                masa = 0
                o    = 0
                Lx   = 0
                Ly   = 0
                Lz   = 0
                do k = bx-1,bx+1
                 do m = by-1,by+1
                  do l = bz-1,bz+1
                        if (tot(k,m,l) == 0) cycle
                        p = head(k,m,l)
                        do j = 1,tot(k,m,l)
                                rx = pos(1,p) - x 
                                ry = pos(2,p) - y 
                                rz = pos(3,p) - z
                                vx = vel(1,p) - velx
                                vy = vel(2,p) - vely
                                vz = vel(3,p) - velz
                                if (sqrt(rx**2+ry**2+rz**2)<radvr*rvir*1e-3) then
                                        Lx = Lx + ry*vz - rz*vy
                                        Ly = Ly - rx*vz + rz*vx
                                        Lz = Lz + rx*vy - ry*vx                 
                                        masa = masa + mass(p)    
                                        o = o + 1
                                endif
                               p = link(p)       
                        enddo
                  enddo      
                 enddo
                enddo
endsubroutine
subroutine cuentasgas(radvr,x,y,z,velx,vely,velz,bx,by,bz,o,n,cell,tot,head,pos,vel,link,rvir,dens,mass,sfr,masa, &
                                     rho,ssfr,hsml,maxhsml,te,ne,u)
        !use modulos
        implicit none
        integer:: cell,n
        integer,dimension(cell,cell,cell) :: tot, head
        real,dimension(3,n):: pos,vel 
        real,dimension(n) :: mass,sfr,ne,nh,hsml,dens,u
        integer,dimension(n) :: link       
        integer ::j, o,k,m,l,bx,by,bz,p,radvr
        real::x,y,z,rx,ry,rz,rvir,masa,Lx,Ly,Lz,Ltot,vx,vy,vz,velx,vely,velz
        real::ssfr,rho,maxhsml,te
        real::xh,yhe,mp,kcgs,vv,mu
                masa = 0
                o    = 0
                ssfr = 0
                rho = 0
                maxhsml = -999
                xH=0.76
                yHe=(1.0-xH)/(4.0*xH)
              !  mu0=(1.0-yHe)/(1+yHe+ne0)
                mp=1.6726E-24
                kcgs=1.3807E-16
                vv=1e10
                te=0
              !  te0=(5./3.-1.)*u0*vv*mu0*mp/kcgs
                do k = bx-1,bx+1
                 do m = by-1,by+1
                  do l = bz-1,bz+1
                        if (tot(k,m,l) == 0) cycle
                        p = head(k,m,l)
                        do j = 1,tot(k,m,l)
                                rx = pos(1,p) - x 
                                ry = pos(2,p) - y 
                                rz = pos(3,p) - z
                                vx = vel(1,p) - velx
                                vy = vel(2,p) - vely
                                vz = vel(3,p) - velz
                                if (sqrt(rx**2+ry**2+rz**2)<radvr*rvir*1e-3) then
                                        Lx = Lx + ry*vz - rz*vy
                                        Ly = Ly - rx*vz + rz*vx
                                        Lz = Lz + rx*vy - ry*vx                 
                                        masa = masa + mass(p)
                                        rho = rho + dens(p) 
                                        o = o + 1
                                        mu=(1.0-yhe)/(1+yhe+ne(p))
                                        te= te + (5./3.-1)*u(p)*vv*mu*mp/kcgs
                                       ! if (hsml(p) > maxhsml) maxhsml = hsml(p)
                                endif
                               p = link(p)       
                        enddo
                  enddo      
                 enddo
                enddo
                rho=rho/real(o)
                if (o>0) te=te/real(o)
endsubroutine
subroutine chequeo(x,y,z,bx,by,bz,o,n,cell,tot,head,pos,vel,link,rvir)
        !use modulos
        implicit none
        integer:: cell,n
        integer,dimension(cell,cell,cell) :: tot, head
        real,dimension(3,n):: pos,vel 
        real,dimension(n) :: mass
        integer,dimension(n) :: link       
        integer ::j, o,k,m,l,bx,by,bz,p
        real ::x,y,z,rx,ry,rz,rvir,masa,Lx,Ly,Lz,Ltot,vx,vy,vz,velx,vely,velz
                masa = 0
                o    = 0
                Lx   = 0
                Ly   = 0
                Lz   = 0
                do k = bx-1,bx+1
                 do m = by-1,by+1
                  do l = bz-1,bz+1
                        if (tot(k,m,l) == 0) cycle
                        p = head(k,m,l)
                        do j = 1,tot(k,m,l)
                                rx = pos(1,p) - x 
                                ry = pos(2,p) - y 
                                rz = pos(3,p) - z
                                vx = vel(1,p) - velx
                                vy = vel(2,p) - vely
                                vz = vel(3,p) - velz
                                if (sqrt(rx**2+ry**2+rz**2)<3*rvir*1e-3) then
                                        o = o + 1
                                endif
                               p = link(p)       
                        enddo
                  enddo      
                 enddo
                enddo
endsubroutine
