! ESTE PROGRAMA ES PARA FILTRAR PARTICULAS EN BASE A REGIONES DEL DIAGRAMA DE
! FASES; BUSCARLAS EN OTRO SNAPSHOT Y VER SUS PROPIEDADES. LAS REGIONES EN LAS
! QUE SE QUIERE FILTRAR ESTAN INTRODUCIDAS EN LA SUBRUTINA 'CONTADOR' Y EN OTRAS
! PARTES DEL PROGRAMA, ASI QUE REVISAR BIEN.

!USA OPENMP Y SE COMPILA JUNTO CON EL PROGRAMA IDENTIKIT.F90 QUE TIENE TODAS LAS
!SUBRUTINAS Y MODULOS NECESARIOS.
program recorrido
        use modulos
        use OMP_lib  
        implicit none
        real,parameter:: rmax=6.57, rmin=0.08, pi=acos(-1.)
        integer,parameter ::   snap=30, nthread=10 
        integer,parameter :: dmn0 = 29791000    !para el void S 
        !integer,parameter :: dmn0 = 35937000    !para el void R 
        character(len=200)::snumber
        real:: xbox,ybox,zbox,xc,yc,zc,xh,yhe,mp,mu,kcgs,vv,te,d,dmean
        integer::p,dmn,snapshot
        integer,allocatable:: idp(:)
        real,allocatable:: hist(:,:)
        real,dimension(snap) :: z 
        write(snumber,'(I3)') 50
        call reader(snumber)
        print*, redshift
        xbox=403.8960 
        ybox=459.8882
        zbox=440.9021
        xc=408.205481-xbox+250
        yc=457.777839-ybox+250
        zc=441.538681-zbox+250 
        xH=0.76
        yHe=(1.0-xH)/(4.0*xH)
        mp=1.6726E-24
        kcgs=1.3807E-16
        vv=1e10
        dmean=(3*(100**2)*(0.045))/(8*pi*(4.3e-9))*1e-10
        p=0
       ! call contador(nall,pos,ne,u,id,dens,p,rmin,rmax,xc,yc,zc,mu,yhe,te,vv,mp,kcgs)
        do i=1,nall(0)
                d=sqrt((pos(1,i)-xc)**2+(pos(2,i)-yc)**2+(pos(3,i)-zc)**2)       
                if (d<rmax .and. d>rmin) then 
                 mu=(1.0-yHe)/(1+yHe+ne(i))
                 te=(5./3.-1.)*u(i)*vv*mu*mp/kcgs
                 if (te<10**(3) .and. (dens(i)/dmean)<10**(0)) p=p+1         
                endif 
        enddo
        dmn=p
   ! LA SUBRUTINA CONTADOR ME DICE CUANTAS PARTICULAS HAY EN EL RANGO QUE ME
   ! INTERESA, DE ESTA MANERA OBTENGO LAS DIMENSION DE LOS VECTORES CON LOS QUE
   ! VOY A TRABAJAR--------     
        write(*,*) 'PARTICULAS IDENTIFICADAS',dmn
        allocate(idp(dmn))
        allocate(hist(snap,dmn))
        idp= 0 
        p=0
        do i=1,nall(0)
                d=sqrt((pos(1,i)-xc)**2+(pos(2,i)-yc)**2+(pos(3,i)-zc)**2)       
                if (d<rmax .and. d>rmin) then 
                 mu=(1.0-yHe)/(1+yHe+ne(i))
                 te=(5./3.-1.)*u(i)*vv*mu*mp/kcgs
                 if (te<10**(3) .and. (dens(i)/dmean)<10**(0)) then
                        p = p +1
                        idp(p) = id(i)
                 endif         
                endif 
        enddo
   ! EL VECTOR IDP TIENE LOS ID DE LAS PARTICULAS QUE ME INTERESA RASTREAR,
   ! AHORA LO QUE TENGO QUE HACER ES ORDENARLO EN FORMA CRECIENTE   
        call orden(dmn,idp) 
        write(*,*) 'VECTOR ID ORDENADO: READY'
   !     snapshot=49

      !  print*, u(123)m, u(321313)
       deallocate(pos,vel,id,idch,idgn,u,dens,mass,ne)
   !call OMP_set_num_threads(nthread)   !si no llamo esta subrutina la compu
hist=0        
   !$OMP PARALLEL DEFAULT(NONE) &
   !$OMP PRIVATE (i,snapshot) &  !!,pos,vel,id,idch,idgn,u,dens,mass,ne) &
   !$OMP SHARED (dmn,idp,hist,z)   
   !$OMP DO SCHEDULE (DYNAMIC)
        
        do i=21,50
                snapshot=i
                call Id_Finder(snap,dmn0,dmn,idp,snapshot,hist,z)         
        enddo

   !$OMP END DO
   !$OMP BARRIER
   !$OMP END PARALLEL
        open(20,file='evolucion.dat',status='unknown')
        open(21,file='redshifts.dat',status='unknown')
        do i=1,dmn
              !  write(*,*) idp(i)
                write(20,*) hist(:,i)
                write(21,*) z(i)
        enddo
        close(20)
        close(21)
        deallocate(hist,idp)

endprogram
