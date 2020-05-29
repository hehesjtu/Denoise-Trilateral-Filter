clear all;clc;warning off; close all;
foldnumber = 2;linenumber = 150;
string = strcat('C:\Users\hehesjtu\Desktop\test\',num2str(foldnumber),'\');
Files = dir(strcat(string,'*.bmp')); 
LengthFiles = length(Files);
t = [1:256];

for i = 1:LengthFiles
    string_GT = Files(i).name(end-5:end-4); 
    if (strcmp(string_GT,'GT'))
       ygt = getline(imread(strcat(string,Files(i).name)),linenumber);
       name = strcat(Files(i).name(1:end-6));
       break;
    end
end

picture = imread(strcat(string,name,'noisy.bmp'));
block = ones(5,256,3);block(:,:,1)= block(:,:,1)*255;block(:,:,2) = 0; block(:,:,3) = 0;
picture(linenumber-2:linenumber+2,:,:) = block;
ynoisy = getline(imread(strcat(string,name,'noisy.bmp')),linenumber);
yNLM = getline(imread(strcat(string,name,'NLM.bmp')),linenumber);
yBM3D = getline(imread(strcat(string,name,'BM3D.bmp')),linenumber);
yDDID = getline(imread(strcat(string,name,'DDID.bmp')),linenumber);
yEPLL = getline(imread(strcat(string,name,'EPLL.bmp')),linenumber);
yPGPD = getline(imread(strcat(string,name,'PGPD.bmp')),linenumber);
yWNNM = getline(imread(strcat(string,name,'WNNM.bmp')),linenumber);
yMCWNNM = getline(imread(strcat(string,name,'MCWNNM.bmp')),linenumber);
yDnCNN = getline(imread(strcat(string,name,'DnCNN.bmp')),linenumber);
yFFDNet = getline(imread(strcat(string,name,'FFDNet.bmp')),linenumber);
yOur = getline(imread(strcat(string,name,'Our.bmp')),linenumber);

subplot(3,4,1)
imshow(picture);

subplot(3,4,2)
plot(t,ygt,'k','linewidth',2);
hold on;
plot(t,ynoisy,'r','linewidth',1.5);
axis([1 256 50 150]);
legend('y_{gt}','y');

subplot(3,4,3)
plot(t,ygt,'k','linewidth',2);
hold on;
plot(t,yNLM,'g','linewidth',1.5);
axis([1 256 50 150]);
legend('y_{gt}','NLM');

subplot(3,4,4)
plot(t,ygt,'k','linewidth',2);
hold on;
plot(t,yBM3D,'g','linewidth',1.5);
axis([1 256 80 150]);
legend('y_{gt}','BM3D');

subplot(3,4,5)
plot(t,ygt,'k','linewidth',2);
hold on;
plot(t,yDDID,'g','linewidth',1.5);
axis([1 256 80 150]);
legend('y_{gt}','DDID');

subplot(3,4,6)
plot(t,ygt,'k','linewidth',2);
hold on;
plot(t,yEPLL,'g','linewidth',1.5);
axis([1 256 80 150]);
legend('y_{gt}','EPLL');

subplot(3,4,7)
plot(t,ygt,'k','linewidth',2);
hold on;
plot(t,yPGPD,'g','linewidth',1.5);
axis([1 256 80 150]);
legend('y_{gt}','PGPD');

subplot(3,4,8)
plot(t,ygt,'k','linewidth',2);
hold on;
plot(t,yWNNM,'g','linewidth',1.5);
axis([1 256 80 150]);
legend('y_{gt}','WNNM');

subplot(3,4,9)
plot(t,ygt,'k','linewidth',2);
hold on;
plot(t,yMCWNNM,'g','linewidth',1.5);
axis([1 256 80 150]);
legend('y_{gt}','MCWNNM');

subplot(3,4,10)
plot(t,ygt,'k','linewidth',2);
hold on;
plot(t,yDnCNN,'g','linewidth',1.5);
axis([1 256 80 150]);
legend('y_{gt}','DnCNN');

subplot(3,4,11)
plot(t,ygt,'k','linewidth',2);
hold on;
plot(t,yFFDNet,'g','linewidth',1.5);
axis([1 256 80 150]);
legend('y_{gt}','FFDNet');

subplot(3,4,12)
plot(t,ygt,'k','linewidth',2);
hold on;
plot(t,yOur,'g','linewidth',1.5);
axis([1 256 80 150]);
legend('y_{gt}','Ours');









