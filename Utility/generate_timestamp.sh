#!/bin/bash
ls -1 mav0/cam0/data | grep '.png' | sed -e 's/\.png$/000/' | sort > time_stamp.txt