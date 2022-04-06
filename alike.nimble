# Package

version       = "0.1.0"
author        = "Crystal Melting Dot"
description   = "A nim implementation of pHash algorithm for computing perceptual hash of an image"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["alike"]
binDir        = "bin"


# Dependencies

requires "nim >= 1.6.2"
requires "pixie == 4.1.0"
requires "argparse == 3.0.0"
