import pixie
when isMainModule:
  import argparse

import alikepkg/lib

export lib

when isMainModule:
  var p = newParser:
    command("compare2"):
      arg("file1")
      arg("file2")
      run:
        let
          filepath1 = opts.file1
          filepath2 = opts.file2

          hash1 = readImage(filepath1).getSimpleImgHash
          hash2 = readImage(filepath2).getSimpleImgHash
          difference = hash1.diff(hash2) 
        
        echo "file1: ", hash1.hexDigest
        echo "file2: ", hash2.hexDigest
        echo "----"
        echo "Image difference = ", difference
        if difference == 0.0:
          echo "same picture"
        elif difference < 0.1:
          echo "most likely the same image"
        elif difference < 0.35:
          echo "kinda looks alike"
        else:
          echo "entirely different image"

  try:
    p.run(commandLineParams())
  except UsageError:
    stderr.writeLine getCurrentExceptionMsg()
    quit(1)