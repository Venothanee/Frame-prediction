function [E_temporal,x_motion,y_motion,pf]=temporal_predict(im_old,im_new,plot_flag,k)

% im_new ='thumb0452.png';
% im_old='thumb0047.png';
 
 %im_old=imread('1.png');
 %im_new=imread('2.png');
 %plot_flag=1;
 
N = 8;      % block size is N x N pixels
W = 16;     % search window size is W x W pixels

% Make image size divisible by 8
[X,Y,nframes] = size(im_new);
if mod(X,N)~=0
    Height = floor(X/N)*N;  % cut off the extra rows if not divisible by N
else
    Height = X;             % else keep as it is
end
if mod(Y,N)~=0
    Width = floor(Y/N)*N;   % cut off the extra cols if not divisible by N
else
    Width = Y;              % else Keep as it is
end
clear X Y Z


% pad input images on left, right, top, and bottom
% padding by replicating works better than padding w/ zeros, which is 
% better than symmetric which is better than circular
im_old1 = double(padarray(im_old,[W/2 W/2],'replicate'));
im_new1 = double(padarray(im_new,[W/2 W/2],'replicate'));

%initialisation of motion vector components
x = int16(zeros(Height/N,Width/N));% x-component
y = int16(zeros(Height/N,Width/N));% y-component

if (plot_flag==1)
%     figure,imshow(im_new), title('Superimposed motion vectors')
%     hold on % display image & superimpose motion vectors
    smv = figure('visible', 'off'), imshow(im_new), title('s..m...v')
    hold on
    set(smv,'visible','off')
    
    % Determine Motion Vector for the image by calculating CAD
for rows = N:N:Height
    rblk = floor(rows/N);       % pointer for motion vectore x
    for cols = N:N:Width
        cblk = floor(cols/N);   % pointer for motion vectore y
        CAD = 1.0e+10;% initial Cumulative Absolute Difference(CAD)
        for u = -N:N
            for v = -N:N
                cad = im_new1(rows+1:rows+N,cols+1:cols+N)-im_old1(rows+u+1:rows+u+N,cols+v+1:cols+v+N);
                cad = sum(abs(cad(:)));% CAD between pixels
                if cad < CAD            %min CAD
                    CAD=cad;
                    %Motion Vectors are positions in block, in which CAD is
                    %minimum
                    x(rblk,cblk) = v; y(rblk,cblk) = u; %Motion Vectors
                end
            end
        end
        if (plot_flag==1)
            %plot Motion Vectors using Quiver matlab function
            quiver(cols+y(rblk,cblk),rows+x(rblk,cblk),x(rblk,cblk),y(rblk,cblk),'k','LineWidth',1)
            
        end
    end
end

% Image reconstruction and Error calculation from motion vector
x_motion=x;y_motion=y;    
N2 = 2*N;
pf = double(zeros(Height,Width)); % prediction frame Initialisation
Br = double(zeros(Height,Width)); % reconstructed frame Initialisation
for rows = 1:N:Height
    rblk = floor(rows/N) + 1;
    for cols = 1:N:Width
        cblk = floor(cols/N) + 1;
        x1 = x(rblk,cblk); y1 = y(rblk,cblk); % take correspionding motion vector
    
        %Predicted frame error (current image - old image moved by motion vectors)
        pf(rows:rows+N-1,cols:cols+N-1) = im_new1(rows+N:rows+N2-1,cols+N:cols+N2-1)-im_old1(rows+N+y1:rows+y1+N2-1,cols+N+x1:cols+x1+N2-1);
        %Reconstructed Image (old imagemoved by motion vector+ error calculted)
        Br(rows:rows+N-1,cols:cols+N-1) = im_old1(rows+N+y1:rows+y1+N2-1,cols+N+x1:cols+x1+N2-1)+ pf(rows:rows+N-1,cols:cols+N-1);
    end
end

    hold off
    for n = 1:4
            saveas(smv, ['C:\Users\Adil\Desktop\veno fyp\analysed\smv' num2str(n)], 'png');
    end
   

if (plot_flag==1)
%     hold off;
%     figure,quiver(x,y,'k'),title('Motion Vector')
%     sprintf('MSE with MC = %3.3f',std2(pf))
%     figure,imshow(pf,[]),title('MC prediction')
            mv=figure('visible','off'), quiver(x,y,'k'), title('Motion Vector');
            for n = 1:4
            saveas(mv, ['C:\Users\Adil\Desktop\veno fyp\analysed\mv' num2str(n)], 'png');
            end
            %to set plot visible again
            set(mv,'visible','on')
                        
            fprintf('MSE with MC = %3.3f',std2(pf))
            mc=figure('visible','off'),imshow(pf,[]),title('MC prediction');
            for n = 1:4
            saveas(mc, ['C:\Users\Adil\Desktop\veno fyp\analysed\mc' num2str(n)], 'png');
            %saveas(pf,'txt');
            end
%             saveas(mc, fullfile(myFolder, pf), 'png');
 end
    
E_temporal=std2(pf);

end
                





