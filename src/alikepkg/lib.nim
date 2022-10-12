import std/math
import std/enumerate
import std/strutils
import std/stats
import std/sequtils

import pixie

# Change this to your preference
# Greater values cause to match smaller image details
const HASH_SIZE {.intdefine.}: int = 64

type
  PixelArray = array[HASH_SIZE * 8, uint8]
  HashArray* = array[HASH_SIZE, uint8]
    ## Simple hash bit array

  RGBAArray = array[HASH_SIZE * 8, ColorRGBA]
  RGBAHash* = tuple[r, g, b, a: HashArray]
    ## RGBA hash consists of 4 simple hash bit arrays for each channel


const SMALL_IMG_SIDE = sqrt((HASH_SIZE * 8).float64).int
when SMALL_IMG_SIDE <= 1:
  static: raise Defect.newException:
    "HASH_SIZE too small. "


proc getSmallImg(img: Image): Image =
  ## Return an image resized to sqrt(HASH_SIZE * 8)
  result = img.resize(SMALL_IMG_SIDE, SMALL_IMG_SIDE)

iterator iterPixelValues(img: Image): uint8 =
  ## Iterate over average of rgb channels pixel values
  ## Gray-scale pixels basically
  for col in img.data:
    let channelSum = col.r.uint16 + col.g.uint16 + col.g.uint16
    yield channelSum.floorDiv(3).uint8

iterator iterPixelColors(img: Image): ColorRGBA =
  ## Iterate over RGBA colors of pixels in the image
  for col in img.data:
    yield col

proc getSimpleImgHash*(img: Image): HashArray =
  ## Compute simple perceptual hash for image

  let smallImg = img.getSmallImg

  var pixelValues: PixelArray
  for i, pv in enumerate(smallImg.iterPixelValues):
    pixelValues[i] = pv

  let avg = block:
    var rs: RunningStat
    for i in 0..pixelValues.high:
      rs.push(pixelValues[i].int)
    rs.mean.uint8

  for i, pv in enumerate(pixelValues):
    let idx = floorDiv(i, 8)
    let shift = i mod 8
    if pv > avg:
      result[idx] = result[idx] or (1'u8 shl shift)

proc getRGBAImgHash*(img: Image): RGBAHash =
  ## Compute RGBAHash of an image

  let smallImg = img.getSmallImg

  var pixelRGBAs: RGBAArray
  for i, pix in enumerate(smallImg.iterPixelColors):
    pixelRGBAs[i] = pix

  let (rAvg, gAvg, bAvg, aAvg) = block:
    var rRs: RunningStat
    var gRs: RunningStat
    var bRs: RunningStat
    var aRs: RunningStat
    for i in 0..pixelRGBAs.high:
      rRs.push(pixelRGBAs[i].r.int)
      gRs.push(pixelRGBAs[i].g.int)
      bRs.push(pixelRGBAs[i].b.int)
      aRs.push(pixelRGBAs[i].a.int)
    (rRs.mean.uint8,
     gRs.mean.uint8,
     bRs.mean.uint8,
     aRs.mean.uint8)

  template cmpBitMask(val, threshold, arr, idx, shift: untyped): untyped =
    if val > threshold:
      arr[idx] = arr[idx] or (1'u8 shl shift)

  for i, pix in enumerate(pixelRGBAs):
    let idx = floorDiv(i, 8)
    let shift = i mod 8

    cmpBitMask(pix.r, rAvg, result.r, idx, shift)
    cmpBitMask(pix.g, gAvg, result.g, idx, shift)
    cmpBitMask(pix.b, bAvg, result.b, idx, shift)
    cmpBitMask(pix.a, aAvg, result.a, idx, shift)

proc hexDigest*(hash: HashArray): string =
  ## Return hex digest of an image hash
  result = block:
    var hexReprs = newSeq[string](HASH_SIZE)
    for i, v in enumerate(hash):
      hexReprs[i] = v.toHex
    hexReprs.join("")

proc diff*(hash1, hash2: HashArray): float64 =
  ## Compute diff for an image
  ##
  ## Result is a float value in range 0-1, larger values mean more difference
  let totalBits = HASH_SIZE * 8
  var diffBits = 0
  for (v1, v2) in zip(hash1, hash2):
    var d = v1 xor v2
    if d == 0: continue

    while d > 0:
      diff_bits = diff_bits + (d and 1).int
      d = d shr 1
  result = diff_bits / totalBits

proc diff*(hash1, hash2: RGBAHash): float64 =
  ## Compute diff for an image using RGBAHash
  ## 
  ## Result is a float value in range 0-1, larger values mean more difference

  return (
    hash1.r.diff(hash2.r) +
    hash1.g.diff(hash2.g) +
    hash1.b.diff(hash2.b) +
    hash1.a.diff(hash2.a)
  ) / 4

proc `$`*(v: RGBAHash): string =
  result = "r: " & v.r.hexDigest &
    "\ng: " & v.g.hexDigest &
    "\nb: " & v.b.hexDigest &
    "\na: " & v.a.hexDigest

proc toImage*(ha: HashArray): Image =
  ## Return an image representation of Simple hash
  result = newImage(SMALL_IMG_SIDE, SMALL_IMG_SIDE)

  for i, val in ha:
    for shift in countdown(7, 0, 1):
      let pixidx = min((i * 8) + (7 - shift), result.data.high)
      if (val and (1'u8 shl (7 - shift))) > 0:
        result.data[pixidx] = ColorRGBX(r: 255'u8, g: 255'u8, b: 255'u8, a: 255'u8)
      else:
        result.data[pixidx] = ColorRGBX(r: 0'u8, g: 0'u8, b: 0'u8, a: 255'u8)

proc toImage*(imgHash: RGBAHash): Image =
  ## Return an image representation of RGBA hash
  result = newImage(SMALL_IMG_SIDE, SMALL_IMG_SIDE)

  let
    red = imgHash.r.toImage
    green = imgHash.g.toImage
    blue = imgHash.b.toImage
    alpha = imgHash.a.toImage
  
  for i in 0..result.data.high:
    let idx = min(i, result.data.high)
    result.data[idx].r = red.data[idx].r
    result.data[idx].g = green.data[idx].r
    result.data[idx].b = blue.data[idx].r
    result.data[idx].a = alpha.data[idx].r
