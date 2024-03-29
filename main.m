global filePath;

%% Read Image
Inputimage=imread(filePath);

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

%% Label connected components
[L Ne]=bwlabel(Inputimage);

propied=regionprops(L,'BoundingBox');
imshow(~Inputimage);
hold on
for n=1:size(propied,1)
  rectangle('Position',propied(n).BoundingBox,'EdgeColor','g','LineWidth',2)
end
hold off
pause (1);

%% Objects extraction
figure('Name', 'Extracted Texts'); 
for n=1:Ne
  [r,c] = find(L==n);
  n1=Inputimage(min(r):max(r),min(c):max(c));
  subplot(2,Ne/2,n);
  imshow(~n1);
  pause(0.5)
end

%% Extract object from image into plain text using Matlab OCR function
result = ocr(~Inputimage, 'TextLayout', 'Block');

%% Show alert result
success = msgbox({'Image selected successfully processed.'; strcat('Result: ',result.Text)},'Success');
