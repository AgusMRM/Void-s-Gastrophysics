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
        real,parameter:: rmax=76.83, rmin=0.00, pi=acos(-1.)
        integer,parameter ::   snap1=00, snap2=50,nthread=40 
        integer,parameter :: dmn0 = 29791000    !para el void S 
        !integer,parameter :: dmn0 = 35937000    !para el void R 
        character(len=200)::snumber
        real:: xbox,ybox,zbox,xc,yc,zc,xh,yhe,mp,mu,kcgs,vv,te,d,dmean
        integer::p,n1,snapshot,n2,dmn,part
        integer,allocatable:: idp(:)
        real,allocatable:: pos1(:,:),pos2(:,:)
        write(snumber,'(I3)') snap1
        call reader(snumber)
        print*, redshift
        xbox=403.8960 
        ybox=459.8882
        zbox=440.9021
        xc=408.205481-xbox+250
        yc=457.777839-ybox+250
        zc=441.538681-zbox+250 
    !    xH=0.76
    !    yHe=(1.0-xH)/(4.0*xH)
    !    mp=1.6726E-24
    !    kcgs=1.3807E-16
    !    vv=1e10
    !    dmean=(3*(100**2)*(0.045))/(8*pi*(4.3e-9))*1e-10
        p=0
       ! call contador(nall,pos,ne,u,id,dens,p,rmin,rmax,xc,yc,zc,mu,yhe,te,vv,mp,kcgs)
        do i=1+nall(0),nall(0)+nall(1)
                d=sqrt((pos(1,i)-xc)**2+(pos(2,i)-yc)**2+(pos(3,i)-zc)**2)       
                if (d<rmax .and. d>rmin) p=p+1 
                         
        enddo
        n1=p
        write(*,*) 'PARTICULAS IDENTIFICADAS',n1
        allocate(idp(n1),pos2(3,n1))
        !allocate(hist(snap,dmn))
        idp= 0 
        p=0
        do i=1+nall(0),nall(0)+nall(1)
                d=sqrt((pos(1,i)-xc)**2+(pos(2,i)-yc)**2+(pos(3,i)-zc)**2)       
                if (d<rmax .and. d>rmin) then 
                p = p +1
                idp(p) = id(i)
                endif         
        enddo
   ! EL VECTOR IDP TIENE LOS ID DE LAS PARTICULAS QUE ME INTERESA RASTREAR,
   ! AHORA LO QUE TENGO QUE HACER ES ORDENARLO EN FORMA CRECIENTE   
   !     call orden(n1,idp) 
   !     write(*,*) 'VECTOR ID ORDENADO: READY'
        deallocate(pos,vel,id)!,idch,idgn,u,dens,mass,ne)
   ! A ESTA ALTURA DEL PROGRAM TENGO UN VECTOR IDP CON TODOS LOS ID QUE EN EL
   ! PRIMER SNAPSHOT ESTAN EN LA ZONA DE INTERES. AHORA VOY BUSCAR ESTAS
   ! PARTICULAS EN OTROS SNAPSHOT
!-----------------------------------------------------------------------------------
!-----------------------------------------------------------------------------------
!-----------------------------------------------------------------------------------
!-----------------------------------------------------------------------------------

        call OMP_set_num_threads(nthread)   !si no llamo esta subrutina la compu
        write(snumber,'(I3)') snap2
        call reader(snumber)
   !selecciono las particulas de dm a z 0     
        allocate(pos1(3,nall(1)),id2(nall(1)))
        j=0
        do i=nall(0)+1,nall(0)+nall(1)
                j=j+1
                pos1(1,j)=pos(1,i)
                pos1(2,j)=pos(2,i)
                pos1(3,j)=pos(3,i)
                id2(j)=id(i)
        enddo 
        n2=nall(1)
        
       call Id_Finder(n1,idp,n2,id,pos1,pos2)         
       part=0
       do i=1,n1
        if (pos2(1,i)>0) part=part+1
       enddo
       write(*,*) 'CM:',sum(pos2(1,:))/part, sum(pos2(2,:))/part, sum(pos2(3,:))/part
        deallocate(idp,pos2)

endprogram
