clc;
close all;
clear all;

%B-frames
myFolder = 'C:\Users\Adil\Documents\veno fyp\matlab\I-P frame';
cd(myFolder);
for k = 1:25    %this represents the image range.(1 to 200 etc.)
clearvars('-except','k');
       
    baseFileName1 = sprintf('%02d.jpeg', k); %gets image name 
    baseFileName2 = sprintf('%02d.png', k);
       
    im1 = imread(baseFileName1);
    im2 = imread(baseFileName2);
  
    %insert function here
    temporal_predict(im1,im2, 1, k);

end
