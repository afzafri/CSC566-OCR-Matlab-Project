%% Read Image
Inputimage=imread('example.jpg');

%% Show image
figure(1)
imshow(Inputimage);
title('ORIGINAL IMAGE')

%% Convert to gray scale
if size(Inputimage,3)==3 % RGB image
 Inputimage=rgb2gray(Inputimage);
end

%% Convert to binary image
threshold = graythresh(Inputimage);
Inputimage =~im2bw(Inputimage,threshold);

%% Remove all object containing fewer than 30 pixels
Inputimage = bwareaopen(Inputimage,30);
pause(1);