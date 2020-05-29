clc;clear all;close all;warning off;
% all global parameters
global width;           global height;          % the height and width of the images
global cell_width;      global cell_height;     % the number of blocks in each height and width
global pad_pixel;       global overlap;         % the padding pixel and overlap pixel in method OBMC
global blocksize;       global windowsize;      % the size of the block and windowsize

% set all the global parameters
blocksize = 8; windowsize = floor(blocksize*3/4); average = 5; Ncmp = floor(average/2);
pad_pixel = floor(blocksize*2);   overlap = floor(blocksize/2); Ssws = floor(blocksize/4);
video=VideoReader('noisy_far.avi');
numFrames = video.NumberOfFrames; 
tmp = read(video, 1);
[height, width, ~] = size(tmp);
cell_height=floor(height/blocksize); cell_width=floor(width/blocksize);
height=cell_height*blocksize; width=cell_width*blocksize;
mv_box = zeros(cell_height,cell_width,2,numFrames-2);
rationality_box = zeros(cell_height,cell_width,1,numFrames-2); 
    
for num = 3:numFrames-2
    disp(strcat('Now start to process no. ',num2str(num),' frame!'));
    for numcur = -Ncmp:Ncmp
        if numcur <0
            disp(strcat('tracking the motion of the previous', '  ',num2str(-numcur),'  ',' frame!'));
        end
        if numcur == 0
            disp(strcat('tracking the motion of the current frame£¡'));
        end
        if numcur >0
            disp(strcat('tracking the motion of the next','  ',num2str(numcur),'  ',' frame!'));
        end
        imgpre = read(video, num);            
        imgpre = rgb2gray(imgpre(1:height,1:width,:));
        imgcur = read(video, num+numcur);
        imgcur = rgb2gray(imgcur(1:height,1:width,:));
        imgprepad=padarray(imgpre,[pad_pixel,pad_pixel],'symmetric','both');
        imgcurpad=padarray(imgcur,[pad_pixel,pad_pixel],'symmetric','both');
        Rationality = zeros(cell_height,cell_width);
        tic
        % coarse motion estimation
        mv = MV_coarse(imgprepad,imgcurpad);
        %  motion vectors updating 
        count = 0;
        while sum(Rationality(:)) <= 0.96*cell_height*cell_width
              [mv, Rationality] = MV_Refine(mv, Rationality);
              count = count + 1;
              if count == 15
                 break;
              end
        end
        mv_refine = mv;
        % motion vector refinement
        mv_fine = MV_fine(imgprepad,imgcurpad,round(mv_refine),Ssws);
        [mv_fine, Rationality] = MV_Refine(mv_fine, Rationality);
        toc
        % save the mv and rationality 
        rationality_box(:,:,:,num-2) = Rationality;
        mv_box(:,:,:,num-2) = mv_fine;
        % save the mv data
        if numcur <0 && numFrames-2==num
            mkdir(strcat('./train',num2str(blocksize),'/'));
            saldir = strcat('./train',num2str(blocksize),'/');
            savePath1 = [saldir strcat('mv_left',num2str(-numcur),'.mat')];
            savePath2 = [saldir strcat('rationality_left',num2str(-numcur),'.mat')];
            save(savePath1,'mv_box'); save(savePath2,'rationality_box');
        end
        if numcur == 0 && numFrames-2==num
            saldir = strcat('./train',num2str(blocksize),'/');
            savePath1 = [saldir strcat('mv','.mat')];
            savePath2 = [saldir strcat('rationality','.mat')];
            save(savePath1,'mv_box'); save(savePath2,'rationality_box');
        end
        if numcur >0 && numFrames-2==num
            saldir = strcat('./train',num2str(blocksize),'/');
            savePath1 = [saldir strcat('mv_right',num2str(numcur),'.mat')];
            savePath2 = [saldir strcat('rationality_right',num2str(numcur),'.mat')];
            save(savePath1,'mv_box'); save(savePath2,'rationality_box');        
        end 
    end   
end






















































