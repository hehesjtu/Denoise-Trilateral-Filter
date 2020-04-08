clc;clear all;close all;warning off;
% global parameters
global width;           global height;          % the height and width of the images
global cell_width;      global cell_height;     % the number of blocks in each height and width
global pad_pixel;       global overlap;         % the padding pixel and overlap pixel in method OBMC
global blocksize;       global windowsize;      % the size of the block and windowsize

% read the video and set global parameters
blocksize = 8; windowsize = floor(blocksize*3/4); overlap = floor(blocksize/2);  
pad_pixel = floor(blocksize*2);     average = 5; Ncmp = floor(average/2);
video = VideoReader('noisy_far.avi');
numFrames = video.NumberOfFrames;
tmp = read(video, 1);
[height, width, ~] = size(tmp);
cell_height=floor(height/blocksize); cell_width=floor(width/blocksize);
height=cell_height*blocksize; width=cell_width*blocksize;

% load the mat files
MVR1 = load(strcat('./train', num2str(blocksize),'/mv_right1.mat'));  MVR2 = load(strcat('./train', num2str(blocksize),'/mv_right2.mat'));
MVL1 = load(strcat('./train', num2str(blocksize),'/mv_left1.mat'));   MVL2 = load(strcat('./train', num2str(blocksize),'/mv_left2.mat'));
VR1 = load(strcat('./train',num2str(blocksize),'/validity_right1.mat'));  VR2 = load(strcat('./train',num2str(blocksize),'/validity_right2.mat'));
VL1 = load(strcat('./train',num2str(blocksize),'/validity_left1.mat'));   VL2 = load(strcat('./train',num2str(blocksize),'/validity_left2.mat'));
vl1 = VL1.validity_box;  vl2 = VL2.validity_box; vr1 = VR1.validity_box;  vr2 = VR2.validity_box; 
mvl1 = MVL1.mv_box;  mvl2 = MVL2.mv_box; mvr1 = MVR1.mv_box;  mvr2 = MVR2.mv_box; 

% ground truth image, globally set, result of the average of all frames
GT = zeros(height,width,3);
for t = 1: numFrames
    imgpre = double(read(video, t));            
    imgpre = imgpre(1:height,1:width,:);
    GT = GT + imgpre;
end
GT = uint8(GT./numFrames);
% write the video
video_denoise = VideoWriter(strcat('denoise_far_',num2str(blocksize),'.avi'),'Motion JPEG AVI');
video_denoise.FrameRate = 5;
open(video_denoise);
for num = 3: numFrames-2
    % key frame:used to correct the wrong zero vectors
    CMP = zeros(height,width,3);
    for t = num-Ncmp: num+Ncmp
        imgpre = double(read(video, t));            
        imgpre = imgpre(1:height,1:width,:);
        CMP = CMP + imgpre;
    end
    CMP = uint8(CMP./average);
    
    disp(strcat('processing the no.',num2str(num),' frame!'));
    imgpre = read(video, num); imgl2 = read(video, num-2); imgl1 = read(video, num-1); 
    imgr1 = read(video, num+1); imgr2 = read(video, num+2);
    imgpre = imgpre(1:height,1:width,:); imgl2 = imgl2(1:height,1:width,:); imgl1 = imgl1(1:height,1:width,:);
    imgr2 = imgr2(1:height,1:width,:); imgr1 = imgr1(1:height,1:width,:);
    mkdir denoise_results
    imwrite(uint8(imgpre),strcat('./denoise_results/frame',num2str(num),'_noisy.png'));
    % padding   
    imgprepad=padarray(imgpre,[pad_pixel,pad_pixel],'symmetric','both');
    imgl2pad=padarray(imgl2,[pad_pixel,pad_pixel],'symmetric','both');
    imgl1pad=padarray(imgl1,[pad_pixel,pad_pixel],'symmetric','both');
    imgr2pad=padarray(imgr2,[pad_pixel,pad_pixel],'symmetric','both');
    imgr1pad=padarray(imgr1,[pad_pixel,pad_pixel],'symmetric','both');
    % get gradient image 
    gimgprepad = grad(imgprepad); gimgl2pad = grad(imgl2pad); gimgl1pad = grad(imgl1pad); 
    gimgr2pad = grad(imgr2pad); gimgr1pad = grad(imgr1pad);
    tic
    for i = pad_pixel+1:blocksize:pad_pixel+height
        for j = pad_pixel+1:blocksize:pad_pixel+width
            mvi = (i-pad_pixel-1)/blocksize+1;
            mvj = (j-pad_pixel-1)/blocksize+1;
            block =  imgprepad(i:i+blocksize-1,j:j+blocksize-1,:);
            blockl2 = imgl2pad(i+mvl2(mvi,mvj,1,num-2):i+mvl2(mvi,mvj,1,num-2)+blocksize-1,j+mvl2(mvi,mvj,2,num-2):j+mvl2(mvi,mvj,2,num-2)+blocksize-1,:);
            blockl1 = imgl1pad(i+mvl1(mvi,mvj,1,num-2):i+mvl1(mvi,mvj,1,num-2)+blocksize-1,j+mvl1(mvi,mvj,2,num-2):j+mvl1(mvi,mvj,2,num-2)+blocksize-1,:);
            blockr2 = imgr2pad(i+mvr2(mvi,mvj,1,num-2):i+mvr2(mvi,mvj,1,num-2)+blocksize-1,j+mvr2(mvi,mvj,2,num-2):j+mvr2(mvi,mvj,2,num-2)+blocksize-1,:);
            blockr1 = imgr1pad(i+mvr1(mvi,mvj,1,num-2):i+mvr1(mvi,mvj,1,num-2)+blocksize-1,j+mvr1(mvi,mvj,2,num-2):j+mvr1(mvi,mvj,2,num-2)+blocksize-1,:);
            
            % block in gradient domain
            gblock =  gimgprepad(i:i+blocksize-1,j:j+blocksize-1,:);
            gblockl2 = gimgl2pad(i+mvl2(mvi,mvj,1,num-2):i+mvl2(mvi,mvj,1,num-2)+blocksize-1,j+mvl2(mvi,mvj,2,num-2):j+mvl2(mvi,mvj,2,num-2)+blocksize-1,:);
            gblockl1 = gimgl1pad(i+mvl1(mvi,mvj,1,num-2):i+mvl1(mvi,mvj,1,num-2)+blocksize-1,j+mvl1(mvi,mvj,2,num-2):j+mvl1(mvi,mvj,2,num-2)+blocksize-1,:);
            gblockr2 = gimgr2pad(i+mvr2(mvi,mvj,1,num-2):i+mvr2(mvi,mvj,1,num-2)+blocksize-1,j+mvr2(mvi,mvj,2,num-2):j+mvr2(mvi,mvj,2,num-2)+blocksize-1,:);
            gblockr1 = gimgr1pad(i+mvr1(mvi,mvj,1,num-2):i+mvr1(mvi,mvj,1,num-2)+blocksize-1,j+mvr1(mvi,mvj,2,num-2):j+mvr1(mvi,mvj,2,num-2)+blocksize-1,:);
            
            % block denoise  spatial/gradient/pixel
            block = Trilateral_Filter(block,blockl1,blockl2,blockr1,blockr2,...
                    gblock,gblockl1,gblockl2,gblockr1,gblockr2,mvl2,mvl1,mvr2,mvr1,mvi,mvj,num);
            
            % block update   
            block_new = block_update(block,GT,CMP,mvi,mvj);
            imgprepad(i:i+blocksize-1,j:j+blocksize-1,:) = block_new;
        end
    end
    imgpre_denoise = uint8(imgprepad(pad_pixel+1:pad_pixel+height,pad_pixel+1:pad_pixel+width,:));
    toc
    imwrite(uint8(imgpre_denoise),strcat('./denoise_results/frame',num2str(num),'_denoise.png'));
    imglast = zeros(height,width+10,3);
    imglast = [imgpre(1:height,1:width/2,:),zeros(height,10,3),imgpre_denoise(1:height,width/2+1:width,:)];
    writeVideo(video_denoise,uint8(imglast));
    clear CMP;
end
close(video_denoise);
  
    

















