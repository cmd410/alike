when isMainModule:
  import strutils

  import pixie
  import argparse

import alikepkg/lib

export lib

when isMainModule:
  const algHelp = """
      Algorithm to use for hash computation, options are:
          simple - use only brightness of pixel
          rgba - compute hash for RGBA channels separatelyshould be more precise, but slightly less performant than simple)
      """.dedent()

  var p = newParser:
    option("-a", "--algorithm",
             help = algHelp,
             default = some("rgba"),
             choices = @["simple", "rgba"],
    )

    command("compare2"):
      arg("file1")
      arg("file2")
      
      run:
        let
          algo = opts.parentOpts.algorithm
          filepath1 = opts.file1
          filepath2 = opts.file2
        
        var difference = 1.0
        case algo
        of "simple":
          let
            hash1 = readImage(filepath1).getSimpleImgHash
            hash2 = readImage(filepath2).getSimpleImgHash
          
          difference = hash1.diff(hash2)
          
          echo "file1: ", hash1.hexDigest
          echo "file2: ", hash2.hexDigest
        of "rgba":
          let
            hash1 = readImage(filepath1).getRGBAImgHash
            hash2 = readImage(filepath2).getRGBAImgHash
          
          difference = hash1.diff(hash2)
        else: discard
        
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

    command("hash"):
      arg("file")
      run:
        let algo = opts.parentOpts.algorithm
        case algo
        of "simple":
          echo readImage(opts.file).getSimpleImgHash.hexDigest
        of "rgba":
          echo readImage(opts.file).getRGBAImgHash
        else: discard

  try:
    p.run(commandLineParams())
  except UsageError:
    stderr.writeLine getCurrentExceptionMsg()
    quit(1)