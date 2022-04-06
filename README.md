# Alike

A nim implementation of preceptual image hash.
Useful when searching for duplicate or similar pictures.

## How it works

1. Make a small square copy of image to remove high frequency detail
1. make it grayscale
1. compute average pixel brightness
1. compare each pixel against average pixel brightness, and write a bitmask where 1 is bighter 0 - darker.
1. comparing images is just counting differing bits in their hash
