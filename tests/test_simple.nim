import unittest

import pixie

import alike

test "Test simple hash same image equality":
    let
        img1 = readImage("tests/assets/testimg1.png")
        img2 = readImage("tests/assets/testimg1.png")
    
    check img1.getSimpleImgHash.diff(img2.getSimpleImgHash) == 0.0

test "Test simple hash HUE rotated 45 diff < 0.2":
    let
        img1 = readImage("tests/assets/testimg1.png")
        img2 = readImage("tests/assets/testimg1_hue_rotated_45.png")
    
    check img1.getSimpleImgHash.diff(img2.getSimpleImgHash) < 0.2

test "Test simple hash desatureated image diff < 0.1":
    let
        img1 = readImage("tests/assets/testimg1.png")
        img2 = readImage("tests/assets/testimg1_desaturated.png")
    
    check img1.getSimpleImgHash.diff(img2.getSimpleImgHash) < 0.1
