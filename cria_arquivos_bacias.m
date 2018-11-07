%
%   CRIA ARQUIVOS DO TIPO .BACIA QUE´ SÃO AS COORDENADAS GEOGRAFICAS
%  EM REFERENCIA A UMA GRADE DE MODELEO OU DATA SET QUE PERTENCEM A 
%  UM CONJUNTO DE PONTOS QUE ESTAO DENTRO DO SEU CONTORNO DE BACIA
%  QUE É U MARQUIVO TIPO BLN 
%

clear all
%
% LE TODOS OS ARQUIVOS .BLN QUE ESTEJAM NO DIRETORIO .BLN 
%


TEMA='BACIAS_DO_NORTE'; 

mkdir BACIAS
BLNDIR='XINGU';
bacias=dir(strcat('./',BLNDIR,'/*.bln'));
%
% pega arquivo de controle de resolução 
% criado pelo script cria_pontos_de_grade.m

%%
% Essa parte pode ser comentada se o arquivo  ter sido criado. 
%
% CONFIGURACAO DA GRADE DE REFERENCIA (GRADE DO MODELO/GRID DATA)
%

%%CFS
%xdef 55 linear -80.625 0.9375
%ydef 50 levels -35.433 -34.488 -33.543 -32.598 -31.653 -30.709 -29.764 -28.819
%  -27.874 -26.929 -25.984 -25.039 -24.094 -23.15 -22.205 -21.26 -20.315 -19.37
%  -18.425 -17.48 -16.535 -15.59 -14.646 -13.701 -12.756 -11.811 -10.866 -9.921
%  -8.976 -8.031 -7.087 -6.142 -5.197 -4.252 -3.307 -2.362 -1.417 -0.472
%  0.472 1.417 2.362 3.307 4.252 5.197 6.142 7.087 8.031 8.976
% % %  9.921 10.866
% MOD='CFS';
% LONW=-80.625;
% LONE=-30.000;
% LATS=-35.433;
% LATN=8.976;
% RESX=0.9375;
% RESY=0.9375;



%%ETA40
%LON set to -83 -25.8
% % %LAT set to -50.2 12.2%
MOD='ETA40'
LONW=-83;
LONE=-25.8;
LATS=-50.2;
LATN=12.2;
RESX=0.40;
RESY=0.40;

%GEFS 1 grau
%ydef 46 linear -35.000000 1
%xdef 51 linear 280.000000 1.000000
% %tdef 65 linear 00Z29jan2018 6hr
% MOD='GEFS';
% LONW=-80;
% LONE=-30;
% LATS=-35;
% LATN=10;
% RESX=1;
% RESY=1;

%  8 km 
% LONW=-80.069;
% LONE=-29.939;
% RESX=0.072756669;
% LATS=-35.003;
% LATN=10.0425;
% RESY=0.072771377;
%
%  25KM  
% %
MOD='MERGE'
LONW=-80.069;
LONE=-29.939;
RESX=0.25;
LATS=-35.003;
LATN=10.0425;
RESY=0.25;

FILE180='GRADE180.PRN';
FILE360='GRADE360.PRN';
[y,x]=ndgrid(LATS:RESY:LATN,LONW:RESX:LONE);
%
% arquivoS de saida
%
pid=fopen(FILE180,'w');
fid=fopen(FILE360,'w');
%  
%
[tamy,tamx]=size(x);
 for i=1:tamy
     for j=1:tamx
         if (x(i,j) < 0 ) 
             xx=x(i,j)+360; 
         else
             xx=x(i,j);
         end
         fprintf(pid,'%f %f \n',x(i,j),y(i,j));
         fprintf(fid,'%f %f \n',xx,y(i,j));
          
          
     end
 end
 fclose(pid);
 fclose(fid);
 %%
 %
 %
n1=dlmread(FILE180,' ');
n2=dlmread(FILE360,' ');

%
% numero de bacias a serem processadas
%
[num_bacias,~]=size(bacias);
%
% processa as bacias
%
baciadat=sprintf('%s_%s_%s.dat','bacias',TEMA,MOD);
 lid=fopen(baciadat,'w+');
  fprintf(lid,'%s\n','</START/>');
 fclose(lid);
 
for i=1:num_bacias
    disp(['Processando ' bacias(i).name]);
    argx=strcat('./',BLNDIR,'/%s');
    arquivo=sprintf(argx,bacias(i).name);
    imagem=sprintf('%s_%s_%s.png',bacias(i).name,TEMA,MOD);
    
    
    m1=dlmread(arquivo,',');
    
    x0=max(m1(:,1));
    x1=min(m1(:,1));
    y0=max(m1(:,2));
    y1=min(m1(:,2));
    
    numpontos=size(m1);

    if (x1 <= 0) 
        disp('Coordenadas do tipo -180 a 180 encontrado');
        
        zx=n1(:,1);
        zy=n1(:,2);
        px=m1(:,1);
        py=m1(:,2);
        clear in1
        in1=inpolygon(zx,zy,px,py); 
        

        
        

        [ii ,jj]=size(in1);
        kk=1;
        clear pontos
        kid=fopen(strcat('./BACIAS/',strtok(bacias(i).name,'.'),'.bacia'),'w');
        for  j=1:ii
             if (in1(j) == 1)
                fprintf(kid,'%10.4f %10.4f %d\n',n1(j,1),n1(j,2),in1(j));
                          pontos(kk,1)=n1(j,1);
                pontos(kk,2)=n1(j,2);
                kk=kk+1;
             end 
        end

    else
        disp('Coordenadas do tipo 0 360 encontrado');
        
        zx=n1(:,1);
        zy=n1(:,2);
        px=m1(:,1);
        py=m1(:,2);
        in1=inpolygon(zx,zy,px,py); 
        clear pontos
        [ii ,jj]=size(in1);
        kid=fopen(strcat('./BACIAS/',strtok(bacias(i).name,'.'),'.bacia'),'w');
        kk=1;
        for  j=1:ii
             if (in1(j) == 1)
                fprintf(kid,'%10.4f %10.4f %d\n',n1(j,1),n1(j,2),in1(j));
                pontos(kk,1)=n1(j,1);
                pontos(kk,2)=n1(j,2);
                kk=kk+1;
             end 
        end
        
        
    end
    lid=fopen(baciadat,'a');
 
      fprintf(lid,'%s\n','</BACIA/>');
    fprintf(lid,'%s %s %s %d %s\n','</OPTIONS:',strtok(bacias(i).name,'.'),'NUMLIN=',kk-1,'/>');
    %for u=1:kk-1
        fprintf(lid,'%d %d\n',pontos(:,1),pontos(:,2)); 
    %end
 
    fclose(lid);
 
    figure(i)
    clf
    plot(m1(2:numpontos,1),m1(2:numpontos,2),'*');hold on;
    plot(pontos(:,1),pontos(:,2),'r+')
    eixos=axis;
    plot(pontos(:,1),pontos(:,2),'mX');plot(n1(:,1),n1(:,2),'rO');
    axis(eixos);
    grid;
    saveas(gcf,imagem,'png'); 
   
   
  
    

    
    
end
 lid=fopen(baciadat,'a');
fprintf(lid,'%s','</END/>');

fclose(lid);

% 
% L=importdata('./XINGU/belomonte_br080.bln',',',2)
% plot(L.data(:,1),L.data(:,2),'*');hold on;plot(K(:,1),K(:,2),'r+')


