% Before you run this code, make sure that you are in the right directory.
%
% First, download the zip files containing code and data for this unit, from 
% the lectures web page (accessible from the course website).
% 
% Second, unzip the zip files.
%
% Third, modify the addpath and cd commands in the beginning of the code,
% to reflect the locations of code and data on your computer
%
% Now you can copy lines from this script file and paste them to Matlab's
% command window.

%%

% The addpath and cd lines are the only lines in the code that you may have
% to change, in order to make the rest of the code work. Adjust
% the paths to reflect the locations where you have stored the code 
% and data in your computer.

restoredefaultpath;
clear all;
close all;

addpath C:\Users\vangelis\Files\Academia\Teaching\TxState\CS4379C-Spr2019\Lectures\Code\00_common\00_detection
addpath C:\Users\vangelis\Files\Academia\Teaching\TxState\CS4379C-Spr2019\Lectures\Code\00_common\00_images
addpath C:\Users\vangelis\Files\Academia\Teaching\TxState\CS4379C-Spr2019\Lectures\Code\00_common\00_utilities
addpath C:\Users\vangelis\Files\Academia\Teaching\TxState\CS4379C-Spr2019\Lectures\Code\03_elementary_image_operations
cd C:\Users\vangelis\Files\Academia\Teaching\TxState\CS4379C-Spr2019\Lectures\Data\03_elementary_image_operations
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read an image, display, convert to double and to gray
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% reads image from file
hand_image = imread('hands/frame2.bmp', 'bmp');
size(hand_image)

%%

figure(1); imshow(hand_image);

%%

disp(hand_image(53, 122, 1)); % shows the red component of pixel 53, 122, 1)
disp(hand_image(53, 122, 2)); % shows the green component of pixel 53, 122, 1)
disp(hand_image(53, 122, 3)); % shows the blue component of pixel 53, 122, 1)
hand_image(53:57, 122:125, 1);

%%

% converts image to double type (each color component is a double), 
% and converts range from [0 255] to [0 1]
double_hand = double(hand_image); 
                            
% to correctly display a double-type image, its values must be between 0 and 1
% (whereas for uchar type, they must be between 0 and 255).
figure(2); 
imshow(double_hand/255); 


%%

% convert color image to grayscale                              
gray_hand = (double_hand(:,:,1) + double_hand(:,:,2) + double_hand(:,:,3)) / 3; 
figure(1); 

% here, note the use of the second argument, that tells Matlab
% the range of values in the gray image.
imshow(gray_hand, [0 255])                              

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read video frames, identify moving objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read frames 61, 62, 63 of walkstraight sequence
% first, read frame 61.
color_frame61 = imread('walkstraight/frame0061.tif');
% convert frame 61 to double, to allow arbitrary mathematical operations
double_frame61 = double(color_frame61);
% convert frame 61 to grayscale.
frame61 = (double_frame61(:,:,1) + double_frame61(:,:,2) + double_frame61(:,:,3)) / 3;
imshow(frame61/255);

%%

% note: first use of a user-defined function, to avoid code duplication.
frame62 = read_gray('walkstraight/frame0062.tif');
frame63 = read_gray('walkstraight/frame0063.tif');

%%

% note that the background is STATIC. The human is the only MOVING OBJECT.
% we can identify areas of motion using FRAME DIFFERENCING
diff1 = frame62 - frame61;
% show the difference. note the second argument, telling matlab to figure
% out the range by itself.
imshow(diff1, []);
figure
imshow(abs(diff1), []);

%%

% to get more pronounced differences, we can take the difference from a
% frame that was further away in time from frame 62, such as frame 47.

% read frame 47
frame47 = read_gray('walkstraight/frame0047.tif');
diff2 = frame62 - frame47;
% again, note second argument to imshow.
imshow(abs(diff2), []);

%%

% diff2 has two problems, that we will fix.
% first fix: use absolute values
diff1 = abs(frame62-frame61);
imshow(diff1, []);

%%

% second fix: use information from a future frame as well
diff2 = abs(frame62-frame63);
motion = min(diff1, diff2);
imshow(motion > 10, []);

%%

% improving accuracy by considering frames further away in time.
frame47 = read_gray('walkstraight/frame0047.tif');
frame77 = read_gray('walkstraight/frame0077.tif');
diff1 = abs(frame62 - frame47);
diff2 = abs(frame62 - frame77);
motion2 = min(diff1, diff2);
imshow(motion2, []);

%%

% saving results to image files:
% note: make sure values are from 0 to 255, otherwise scaling may be
% needed.
% also, make sure you cast to uint8 (8-bit unsigned int), otherwise
% the image you save will not look as you expect.
imwrite(uint8(diff1), 'output/diff1.jpg');
imwrite(uint8(diff2), 'output/diff2.jpg');
imwrite(uint8(motion2), 'output/motion2.jpg');

%%
% question: why save as jpg? What about other formats (gif, bmp, tiff)?

% how do we compute the position?
% what is the position?

%%
% representing the shape as a set of pixels.
% First operation: thresholding:
threshold = 10; thresholded = (motion2 > threshold); imshow(thresholded, []);

%%

% connected component analysis
[labels, number] = bwlabel(thresholded, 4);
figure(1); imshow(labels, []);

%%

colored = label2rgb(labels, @spring, 'c', 'shuffle');
figure(2); imshow(colored);

%%

% find the largest connected component
% create an array of counters, one for each connected component.
counters = zeros(1,number);
for i = 1:number
    % for each i, we count the number of pixels equal to i in the labels
    % matrix
    % first, we create a component image, that is 1 for pixels belonging to
    % the i-th connected component, and 0 everywhere else.
    component_image = (labels == i);
    
    % now, we count the non-zero pixels in the component image.
    counters(i) = sum(component_image(:));
end

% find the id of the largest component
[area, id] = max(counters);    
person = (labels == id);
imshow(person, []);

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read video frames, identify moving objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read frames 47, 62, 77 of walkstraight sequence

frame47 = read_gray('walkstraight/frame0047.tif');
frame62 = read_gray('walkstraight/frame0062.tif');
frame77 = read_gray('walkstraight/frame0077.tif');
diff1 = abs(frame62 - frame47);
diff2 = abs(frame62 - frame77);
motion2 = min(diff1, diff2);
imshow(motion2, []);

%%

% saving results to image files:
% note: make sure values are from 0 to 255, otherwise scaling may be
% needed.
% also, make sure you cast to uint8 (8-bit unsigned int), otherwise
% the image you save will not look as you expect.
imwrite(uint8(diff1), 'output/diff1.jpg');
imwrite(uint8(diff2), 'output/diff2.jpg');
imwrite(uint8(motion2), 'output/motion2.jpg');

%%

% An example of an image whose values are not 
% between 0 and 255,
% and of how we can save a visualization of that image.

my_image = [
    -2 -2 -2 -2 -2 -2 -2 -2 -2
    -2 -2 -2 -2 -2 -2 -2 -2 -2
    -2 -2 -2 -2 -2 -2 -2 -2 -2
    5 5 5 5 5 5 5 5 5
    -2 -2 -2 -2 -2 -2 -2 -2 -2
    -2 -2 -2 -2 -2 -2 -2 -2 -2
    -2 -2 -2 -2 -2 -2 -2 -2 -2
    -2 -2 -2 -2 -2 -2 -2 -2 -2];

my_image = imresize(my_image, 20);

figure(1); imshow(my_image, []);

%%

% this will not work (produces warning, and black image)
imwrite(my_image, 'output/my_image.gif');
my_image2 = imread('output/my_image.gif');
figure(2); imshow(my_image2, []);

%%

% converting to [0 255] range:
low = min(my_image(:));
high = max(my_image(:));
range = high - low;

% this will give warning
converted = (my_image - low) * 255 / range;

% this will also give warning.
imwrite(converted, 'output/my_image2.gif');
my_image2 = imread('output/my_image2.gif');
figure(2); imshow(my_image2, []);

%%

% to avoid warnings and other problems:
% first, cast my_image to double, before conversion
converted = (double(my_image) - low) * 255 / range;
% second, convert to uint8 before writing.
imwrite(uint8(converted), 'output/my_image3.gif');
my_image3 = imread('output/my_image3.gif');
figure(2); imshow(my_image3, []);

%%

% you may find it preferable to use the save_normalized function, which
% automatically normalizes the range.
save_normalized(my_image, 'output/my_image4.gif');
my_image3 = imread('output/my_image3.gif');
figure(2); imshow(my_image3, []);


%%

% representing the shape as a set of pixels.
% First operation: thresholding:
threshold = 10; thresholded = (motion2 > threshold); imshow(thresholded, []);

% connected component analysis
[labels, number] = bwlabel(thresholded, 4);
figure(1); imshow(labels, []);
colored = label2rgb(labels, @spring, 'c', 'shuffle');
figure(2); imshow(colored);

% find the largest connected component
% create an array of counters, one for each connected component.
counters = zeros(1,number);
for i = 1:number
    % for each i, we count the number of pixels equal to i in the labels
    % matrix
    % first, we create a component image, that is 1 for pixels belonging to
    % the i-th connected component, and 0 everywhere else.
    component_image = (labels == i);
    
    % now, we count the non-zero pixels in the component image.
    counters(i) = sum(component_image(:));
end
    
% find the id of the largest component
[area, id] = max(counters);    
person = (labels == id);
imshow(person, []);

%%

% finding the center of the person 
% center: it is the average (i,j) location of all pixels.
[rows, cols] = size(person);
sum_i = 0;
sum_j = 0;
counter = 0;

for i = 1:rows
    for j = 1:cols
        if person(i,j) ~= 0
            sum_i = sum_i + i;
            sum_j = sum_j + j;
            counter = counter + 1;
        end
    end
end

center_i = sum_i / counter;
center_j = sum_j / counter;
disp([center_i center_j]);

%%

% how can we visualize the result?


% Rewriting the previous for loop in a more concise way.
% find coordinates of all non-zero pixels.
[row_coords col_coords] = find(person);
center_i = mean(row_coords);
center_j = mean(col_coords);

original_image = double(imread('walkstraight/frame0062.tif'));
% reminder: for color images, range must be [0 1] for imshow to work.
imshow(original_image / 255);

% make a copy
result_image = original_image;

% round the center
center_row = round(center_i);
center_col = round(center_j);

% draw a yellow cross (rgb color: [255 255 255]
left = max(center_col - 5, 1);
right = min(center_col + 5, cols);
bottom = min(center_row + 5, cols);
top = max(center_row - 5, 1);

% draw horizontal line of cross
result_image(center_row, left:right, 1) = 255;
result_image(center_row, left:right, 2) = 255;
result_image(center_row, left:right, 3) = 255;

% draw vertical line of cross, use shortcut since all values are 255
result_image(top:bottom, center_col, :) = 255;
imshow(result_image / 255);
    
