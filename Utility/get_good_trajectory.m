clear;
close all;
cam_time = readmatrix('time_stamp.txt');
tr = readtable('CameraTrajectory.txt');
gt = readtable('groundtruth_2012-03-17.csv');
start_frame = 1;
end_frame = 534; % first lost at 839, complete lost at 1631
%start_time = cam_time(start_frame);
%end_time = cam_time(end_frame);
start_time = tr{1, 1};
end_time = tr{end, 1};
tr = tr(tr{:,1}>=start_time & tr{:,1}<=end_time, :);
gt = gt(gt{:,1}>=start_time/1000 & gt{:,1}<=end_time/1000, :);
subplot(1,2,1);
plot3(tr{:,2},tr{:,3},tr{:,4})
sample = tr{ceil(linspace(1, height(tr),20)),:};
C = [linspace(1,0,height(sample))',zeros(1,height(sample))',linspace(0,1,height(sample))'];
hold on
scatter3(sample(:,2),sample(:,3),sample(:,4), 36, C);
title('Estimation')
view(0,-90)
subplot(1,2,2);
plot3(gt{:,2},gt{:,3},gt{:,4})
sample = gt{ceil(linspace(1, height(gt),20)),:};
C = [linspace(1,0,height(sample))',zeros(1,height(sample))',linspace(0,1,height(sample))'];
hold on
scatter3(sample(:,2),sample(:,3),sample(:,4), 36, C);
title('Ground truth')
view(0,-90)

