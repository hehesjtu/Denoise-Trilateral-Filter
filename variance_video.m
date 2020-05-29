clc;clear all;warning off;
video = VideoReader('noisy_far.avi');
numFrames = video.NumberOfFrames; blocksize = 8;
frame = read(video, 1); [height, width, ~] = size(frame);
height=floor(height/blocksize)*blocksize; width=floor(width/blocksize)*blocksize;
GroupVar =[];string = 'GT';
for k = 1:14
    tic
    disp(strcat('Begin to process no.',num2str(k),' video sequence!'));
    Files = dir(strcat('C:\Users\hehesjtu\Desktop\test\',num2str(k),'\*.bmp'));
    LengthFiles = length(Files);
    for i = 1:LengthFiles
        if strcmp(Files(i).name(end-5:end-4),string)==1
           c = find(Files(i).name=='_');
           num1 = str2num(Files(i).name(c(3)+1:c(4)-1));
           num2 = str2num(Files(i).name(c(4)+1:c(5)-1));
        end
    end
    
    % Get the ground truth image
    GT = zeros(256,256,3);
    for i=1:numFrames
        imgpre = double(read(video, i));
        imgpre = imgpre(1:height,1:width,:);
        tmp = imgpre(num2:num2+255,num1:num1+255,:);
        GT = GT + tmp;
    end
    GT = GT./numFrames;

    % Get the mean-variance in the temporal domain
    VARR = []; VARG = []; VARB = []; meanVar = [];
    for t = 1: 40
        imgpre = double(read(video, t));
        imgpre = imgpre(1:height,1:width,:);
        NOISY = imgpre(num2:num2+255,num1:num1+255,:)-GT;
        for i=1:3
            NOISY1 = double(NOISY(:,:,i));
            [m,n] =size(NOISY1);
            NOISY1 = reshape(NOISY1,m*n,1);
            if i==1
                VARR = [VARR,var(NOISY1)];
            end
            if i==2
                VARG = [VARG,var(NOISY1)];
            end
            if i==3
                VARB = [VARB,var(NOISY1)];
            end
        end
    end
    meanVARR = mean(VARR); meanVARG = mean(VARG); meanVARB = mean(VARB); 
    meanVar = [meanVARR,meanVARG,meanVARB];
    GroupVar =[GroupVar;meanVar];
    toc
end

%% Show the figures
% subplot(1,2,1);
fig = bar(GroupVar);
set(fig,'edgecolor','none');
xlabel('Video sequence number');
ylabel('Mean-variances of noise in each channel');
legend('Mean-variances of R channel','Mean-variances of G channel','Mean-variances of B channel');
% subplot(1,2,2);
X = [1:40];
plot(X,VARR,'.r-','markersize',12);
hold on;
plot(X,VARG,'.g-','markersize',12);
hold on;
plot(X,VARB,'.b-','markersize',12);
xlabel('Frame number');
ylabel('Mean-variances of noise in each frame');
legend('Mean-variances of R channel','Mean-variances of G channel','Mean-variances of B channel');
% title('Noise mean-variance in each frame');
