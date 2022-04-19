### Utility

The script in this folder is used for image and data preprocessing that fit the raw data from the NCLT dataset into the input format of ORB-SLAM 3's monocular-inertial mode. Please notice that these scripts need to be executed in the following order. 

#### Dataset Preparation

First, you need to download the image sequence and the corresponding IMU data from [NCLT's download page](http://robots.engin.umich.edu/nclt/index.html#download). Decompress the files. As our experiment uses the Camera 4 as the input sequence, you need to extract the sequence folder `20XX-XX-XX/lb3/Cam4` and the IMU readings `ms25.csv` into the `Utility` folder.

#### Image Preprocessing

Execute `process_image.py`, and it will load all the raw image, do the image preprocessing and output it in the format that can be recognized by NCLT dataset.

#### Timestamp Generation

Execute `generate_timestamp.sh`, and it will generate the timestamp in the ORB-SLAM 3's format.

#### IMU Data Formatting

Execute `processing_imu.m`, and it will load the raw IMU readings and format it into the ORB-SLAM 3's format. It will also solve the problem of timestamp misalignment.

#### Change to Another Camera

If you would like to use another camera, change the image sequence and undistortion map correspondingly. Use the `translation_matrix.m` to calculate the new translation matrix and replace the one inside configuration file `NCLT.yaml`.

