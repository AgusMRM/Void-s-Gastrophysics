program asdsa
    integer,parameter :: vec=3,n=20 
    integer ::i,o,q,vec0,activador
    real,dimension(vec) ::dist
    real :: r,dist_vieja, dist_vieja2
    vec0=vec
    open(10,file='numeros',status='unknown')
    dist=99999
    do i=1,n
    activador=1
    read(10,*) r
    if (r<dist(vec)) then
            print*, r, 'es una vecina'
            do o=1,vec0-1      
print*, vec-o        
print*, '¿es',r,'mayor q', dist(vec-o), 'y menor que', dist(vec+1-o),'?' 
                if (r>dist(vec-o) .and. r<= dist(vec+1-o)) then   
                   activador=0     
                print*, 'si'
                    dist_vieja=dist(vec-o)
                    dist(vec-o)=r
                    !do q=o+1,vec0
                    do q=vec-o,vec0
                    dist_vieja2=dist(q)
                    dist(q)=dist_vieja
                    dist_vieja=dist_vieja2
                    enddo
                    goto 4
                endif
            enddo
      4      if (activador==1) then
                    dist_vieja=dist(1)
                print*, 'entonces es el mas chico de todos' 
                dist(1)=r    
                    do q=2,vec0
                    dist_vieja2=dist(q)
                    dist(q)=dist_vieja
                    dist_vieja=dist_vieja2
                    enddo
            endif    
    endif   
   print*, dist 
    enddo   
    close(10)
endprogram
