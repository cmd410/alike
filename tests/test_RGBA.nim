import unittest

import pixie

import alike

test "Test RGBAHash same image equality":
    let
        img1 = readImage("tests/assets/testimg1.png")
        img2 = readImage("tests/assets/testimg1.png")
    
    check img1.getRGBAImgHash.diff(img2.getRGBAImgHash) == 0.0

test "Test HUE rotated 45 diff < 0.1":
    let
        img1 = readImage("tests/assets/testimg1.png")
        img2 = readImage("tests/assets/testimg1_hue_rotated_45.png")
    
    check img1.getRGBAImgHash.diff(img2.getRGBAImgHash) < 0.1

test "Test desatureated image diff < 0.1":
    let
        img1 = readImage("tests/assets/testimg1.png")
        img2 = readImage("tests/assets/testimg1_desaturated.png")
    
    check img1.getRGBAImgHash.diff(img2.getRGBAImgHash) < 0.1
