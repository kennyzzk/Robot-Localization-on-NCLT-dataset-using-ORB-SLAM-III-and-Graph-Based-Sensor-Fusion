cam_time = readmatrix('time_stamp.txt', 'OutputType','uint64');
imu = readmatrix('data.csv','OutputType','uint64' );
imu = imu(:,1);
index = [1; zeros(height(cam_time)-1, 1)];
for i = 1:height(cam_time)
    for j = index(nnz(index)):height(imu)
        if imu(j)>cam_time(i)
%             if mean(double(imu(j-1:j))) > cam_time(i)
                index(i)=j-1;
                imu(j-1)=cam_time(i);
%             else
%                 index(i)=j;
%                 imu(j)=cam_time(i);                
%             end
            break;
        end
    end
end
imu_table = readtable('data.csv', 'Format','%s%f%f%f%f%f%f');
imu_table(:,1) = cellstr(num2str(imu));
imu_table.Properties.VariableNames={'#timestamp [ns]','w_RS_S_x [rad s^-1]','w_RS_S_y [rad s^-1]','w_RS_S_z [rad s^-1]','a_RS_S_x [m s^-2]','a_RS_S_y [m s^-2]','a_RS_S_z [m s^-2]'};
writetable(imu_table,'data_aligned.csv')

