! COMPILACION:  gfortran -fopenmp module.f90 recorrido_df.f90 -o df 
program SF
       use modulos
       use OMP_lib 
       implicit none
       integer,parameter :: VOID = 1198
       integer :: SNAPSHOT,c1,c2,k,particula 
       real :: d,xbox,ybox,zbox,x,y,z,rv
       character(len=200) :: snumber
        xbox=411.217
        ybox=162.1655
        zbox=453.0553 
        open(13,file='voids_new.dat')
        do i=1,VOID-1
        read(13,*)
        enddo
        read(13,*) rv,x,y,z
        x=x-xbox+250
        y=y-ybox+250
        z=z-zbox+250
       open(10,file='df_raster_parallel.dat',status='unknown')
       open(20,file='RECORRIDO.dat',status='unknown',action='write')
       do i=1,17
       !write(*,*) 'PARTICULA',i
       read(10,*) particula
        do j=0,50
        SNAPSHOT=j
        !write(*,*) snapshot
        write(snumber,'(I3)') SNAPSHOT
        call reader(snumber)
      !$OMP PARALLEL DEFAULT(NONE) &
      !$OMP PRIVATE(k  ) &
      !$OMP SHARED(nall,id,particula,u,dens,ne,redshift)
      !$OMP DO SCHEDULE(DYNAMIC)
                do k=1,nall(0)
                if (id(k) == particula) then
                        write(*,*) id(k),u(k),dens(k),ne(k), redshift
                        cycle
                endif
                enddo        
        !$OMP ENDDO
        !$OMP ENDPARALLEL   
        deallocate(pos,vel,id,idch,idgn,mass,u,dens,ne)
        enddo
       enddo
   close(10) 
   close(20) 
endprogram 
