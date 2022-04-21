"""
Demonstrating how to undistort images.

Reads in the given calibration file, parses it, and uses it to undistort the given
image. Then display both the original and undistorted images.

To use:

    python process_image.py path_to_image calibration_file path_to_export
"""

import numpy as np
import cv2
import matplotlib.pyplot as plt
import argparse
import re
import os
from glob2 import glob
from pathlib import Path
import shutil

class Undistort(object):

    def __init__(self, fin, scale=1.0, fmask=None):
        self.fin = fin
        # read in distort
        with open(fin, 'r') as f:
            #chunks = f.readline().rstrip().split(' ')
            header = f.readline().rstrip()
            chunks = re.sub(r'[^0-9,]', '', header).split(',')
            self.mapu = np.zeros((int(chunks[1]),int(chunks[0])),
                    dtype=np.float32)
            self.mapv = np.zeros((int(chunks[1]),int(chunks[0])),
                    dtype=np.float32)
            for line in f.readlines():
                chunks = line.rstrip().split(' ')
                self.mapu[int(chunks[0]),int(chunks[1])] = float(chunks[3])
                self.mapv[int(chunks[0]),int(chunks[1])] = float(chunks[2])
            mid_y = int(self.mapu.shape[0]/2)
            mid_x = int(self.mapu.shape[1]/2)
            for i in range(self.mapu.shape[1]):
                if self.mapu[mid_y, i] >= 0 and self.mapv[mid_y, i] >= 0:
                    self.left_edge = i
                    break
            for i in range(self.mapu.shape[1]-1, -1, -1):
                if self.mapu[mid_y, i] <= self.mapu.shape[1]-1 and self.mapv[mid_y, i] <= self.mapu.shape[0]-1:
                    self.right_edge = i
                    break
            for i in range(self.mapu.shape[0]):
                if self.mapu[i, mid_x] >= 0 and self.mapv[i, mid_x] >= 0:
                    self.upper_edge = i + 1
                    break
            for i in range(self.mapu.shape[0]-1, -1, -1):
                if self.mapu[i, mid_x] <= self.mapu.shape[1]-1 and self.mapv[i, mid_x] <= self.mapu.shape[0]-1:
                    self.bottom_edge = i + 1
                    break

    """
    Use OpenCV to undistorted the given image
    """
    def undistort(self, img):
        return cv2.remap(img, self.mapu, self.mapv, cv2.INTER_LINEAR)
    
    def crop(self, img):
        return img[self.upper_edge:self.bottom_edge, self.left_edge:self.right_edge]

    def report_edge(self):
        print('left_edge is ' + str(self.left_edge))
        print('right_edge is ' + str(self.right_edge))
        print('upper_edge is ' + str(self.upper_edge))
        print('bottom_edge is ' + str(self.bottom_edge))
        return None

def main():
    parser = argparse.ArgumentParser(description="Undistort images")
    parser.add_argument('path', metavar='path', type=str, nargs='?', default='Cam4', help='path to image')
    parser.add_argument('map', metavar='map', type=str, nargs='?', default='U2D_Cam4_1616X1232.txt', help='undistortion map')
    parser.add_argument('export', metavar='export', type=str, nargs='?',default='./NCLT/mav0/cam0/data', help='path to export')

    args = parser.parse_args()
    
    if os.path.exists(args.export):
        shutil.rmtree(args.export)    
    os.makedirs(args.export)
        
    undistort = Undistort(args.map)
    
    filelist = glob(os.path.join(args.path, '*.tiff'))
    filelist = sorted(filelist)
    
    for filename in filelist:
        print("Process " + filename)
        img = cv2.imread(filename)
        
        img = undistort.undistort(img)
        img = undistort.crop(img)
        img = cv2.rotate(img, cv2.ROTATE_90_CLOCKWISE)
        img = cv2.resize(img, None, fx = 0.5, fy=0.5, interpolation=cv2.INTER_AREA)
        cv2.imwrite(os.path.join(args.export, Path(filename).stem + '000.png'), img)
    
    undistort.report_edge()
        
if __name__ == "__main__":
    main()
