IMU = readtable('ms25.csv', 'Format','%s%f%f%f%f%f%f%f%f%f');
IMU = IMU(:,[1 8:10 5:7]);
IMU(:,1)=strcat(IMU{:,1}, '000');
IMU.Properties.VariableNames={'#timestamp [ns]','w_RS_S_x [rad s^-1]','w_RS_S_y [rad s^-1]','w_RS_S_z [rad s^-1]','a_RS_S_x [m s^-2]','a_RS_S_y [m s^-2]','a_RS_S_z [m s^-2]'};
writetable(IMU,'data.csv')