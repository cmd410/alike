# Alike

A nim implementation of preceptual image hash.
Useful when searching for duplicate or similar pictures.

## How it works

1. Make a small square copy of image to remove high frequency detail
1. make it grayscale
1. compute average pixel brightness
1. compare each pixel against average pixel brightness, and write a bitmask where 1 is bighter 0 - darker.
1. comparing images is just counting differing bits in their hash

## Installation

1. Get source code by cloning this repository or downloading as zip
1. Open directory where the source code is in terminal and run `nimble build` (yeah, you'll need to have nimble installed first)
1. After successful build the binaries will be in `./bin` folder, you can run them

## Usage

For now cli only features 1 command - `compare2` which takes 2 arguments, which are paths to images you want to compare
