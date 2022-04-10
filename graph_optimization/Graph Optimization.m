addpath('D:\matlab\toolbox\gtsam-toolbox-3.2.0-win64\gtsam_toolbox')
import gtsam.*

isam = gtsam.ISAM2();

pose=importdata('0407_CameraTrajectory.txt'); %importing poses
gt = importdata('groundtruth_2012-03-17.csv');
odo_mean=importdata('0407_odometry_mu.csv'); %odometry mean
odo_cov = importdata('0407_odometry_cov.csv'); %odometry covariance

x_edges = odo_mean(:,2);
y_edges = odo_mean(:,3);
z_edges = odo_mean(:,4);
roll_edges = odo_mean(:,5);
pitch_edges = odo_mean(:,6);
yaw_edges = odo_mean(:,7);

% allign frames
gt_rot_matrix = inv(eul2rotm([gt(4752, 5), gt(4752, 6), gt(4752, 7)],'XYZ'));
for i = 1 : 726
    pos_tmp = gt_rot_matrix * [pose(i, 2); pose(i, 3); pose(i, 4)];
    pose(i, 2) = pos_tmp(1, 1) + gt(4752, 2);
    pose(i, 3) = pos_tmp(2, 1) + gt(4752, 3);
    pose(i, 4) = pos_tmp(3, 1) + gt(4752, 4);
end 

for i = 1 : 726
    graph = NonlinearFactorGraph;
    initialEstimate = Values;
    if i == 1
        priorNoise = noiseModel.Diagonal.Sigmas([0.1; 0.1; 0.1; 0.1; 0.1; 0.1]);
        graph.add(PriorFactorPose3(1, Pose3(Rot3(eul2rotm([gt(4752, 5), gt(4752, 6), gt(4752, 7)],'XYZ')), Point3([gt(4752, 2); gt(4752, 3); gt(4752, 4)])), priorNoise));
        initialEstimate.insert(1, Pose3(Rot3(quat2rotm([pose(1, 8), pose(1, 5), pose(1, 6), pose(1, 7)])), Point3([pose(1, 2); pose(1, 3); pose(1, 4)])));
%         initialEstimate.print(sprintf('\nInitial estimate:\n'));
    else
        prevPose = result.at(i - 1);
        initialEstimate.insert(i, prevPose);
        for k = 2 : 726
            if i == k
                q11 = odo_cov(k,2); q12 = odo_cov(k,3);q13= odo_cov(k,4);q14 = odo_cov(k,5);
                q15 = odo_cov(k,6); q16 = odo_cov(k,7); q22 = odo_cov(k,8); q23 = odo_cov(k,9);
                q24 = odo_cov(k,10); q25 = odo_cov(k,11); q26 = odo_cov(k,12); q33 = odo_cov(k,13);
                q34 = odo_cov(k,14); q35 = odo_cov(k,15); q36 = odo_cov(k,16); q44 = odo_cov(k,17);
                q45 = odo_cov(k,18); q46 = odo_cov(k,19); q55 = odo_cov(k,20); q56 = odo_cov(k,21);
                q66 = odo_cov(k,22);
                covariance = [q11, q12, q13, q14, q15, q16;...
                              q12, q22, q23, q24, q25, q26;...
                              q13, q23, q33, q34, q35, q36;...
                              q14, q24, q34, q44, q45, q46;...
                              q15, q25, q35, q45, q55, q56;...
                              q16, q26, q36, q46, q56, q66];
                Model = noiseModel.Gaussian.Covariance(covariance);
                eul_edge = [roll_edges(k), pitch_edges(k), yaw_edges(k)];
                rotm_edge = eul2rotm(eul_edge,'XYZ'); 
                graph.add(BetweenFactorPose3(k-1,k,Pose3(Rot3(rotm_edge),Point3([x_edges(k);y_edges(k);z_edges(k)])),Model));
            end
        end
    end
    isam.update(graph, initialEstimate);
    result = isam.calculateEstimate();
end

%% Plot Ground Truth
% gt = importdata('groundtruth_2012-03-17.csv');
% line 4752: 1331989395227797, 75.600000512748508, 108.813518719820195, -3.316394504599732, 0.013288115560511, -0.235681281754745, -0.979900228739526
gt_eul_angle = [0.013288115560511, -0.235681281754745, -0.979900228739526];
gt_rotm_edge = eul2rotm(gt_eul_angle,'XYZ'); 
timestamp_gt = gt(4752:30:26525,1);
gt = gt(4752:30:26525, :);
x_gt = []; y_gt = []; z_gt = [];
for i = 1:size(timestamp_gt)
    x_gt = [x_gt; gt(i,2)];
    y_gt = [y_gt; gt(i,3)];
    z_gt = [z_gt; gt(i,4)];
end

%% Initialize to noisy points
ini = Values;
for i = 1 : 726
    ini.insert(i, Pose3(Rot3(quat2rotm([pose(i, 8), pose(i, 5), pose(i, 6), pose(i, 7)])), Point3([pose(i,2); pose(i,3); pose(i,4)]))); 
end

%% Plot trajectory
ini_x = [];
ini_y = [];
ini_z = [];
result_x = [];
result_y = [];
result_z = [];

for i = 1 : 726
    result_x = [result_x, result.at(i).x];
    result_y = [result_y, result.at(i).y];
    result_z = [result_z, result.at(i).z];
    ini_x = [ini_x, ini.at(i).x];
    ini_y = [ini_y, ini.at(i).y];
    ini_z = [ini_z, ini.at(i).z];
end

plot(ini_x, ini_y, 'b', 'linewidth', 1.5);
axis equal
hold on
plot(result_x, result_y, 'r', 'linewidth', 1.5);
axis equal
plot(x_gt, y_gt,'g', 'linewidth', 1.5);
xlabel('X (m)')
ylabel('Y (m)')
axis equal
grid on
legend('ORB-SLAM3 Trajectory','Graph Optimized Trajectory', 'Ground Truth Trajectory')