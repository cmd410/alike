import std/math
import std/enumerate
import std/strutils
import std/stats
import std/sequtils

import pixie

# Change this to your preference
# Greater values cause to match smaller image details
const HASH_SIZE: int = 32

type
    PixelArray = array[HASH_SIZE * 8, uint8]
    HashArray = array[HASH_SIZE, uint8]


const SMALL_IMG_SIDE = sqrt((HASH_SIZE * 8).float64).int
when SMALL_IMG_SIDE <= 1:
    static: raise Defect.newException:
        "HASH_SIZE too small. "


proc getSmallImg(img: Image): Image =
    ## Return an image resized to sqrt(HASH_SIZE)
    result = img.resize(SMALL_IMG_SIDE, SMALL_IMG_SIDE)


iterator iterPixelValues(img: Image): uint8 =
    ## Iterate over average of rgb channels pixel values
    ## Gray-scale pixels basically
    for col in img.data:
        let channel_sum = col.r.uint16 + col.g.uint16 + col.g.uint16
        yield channel_sum.floorDiv(3).uint8


proc getSimpleImgHash*(img: Image): HashArray =
    ## Compute simple perceptive hash for image

    let small_img = img.getSmallImg

    var pixel_values: PixelArray
    for i, pv in enumerate(small_img.iterPixelValues):
        pixel_values[i] = pv

    let avg = block:
        var fv = newSeq[float](pixel_values.len)
        for i in 0..pixel_values.high:
            fv[i] = pixel_values[i].float
        var rs: RunningStat
        rs.push(fv)
        rs.mean.uint8

    for i, pv in enumerate(pixel_values):
        let idx = floorDiv(i, 8)
        let shift = i mod 8
        if pv > avg.uint8:
            result[idx] = result[idx] or (1'u8 shl shift)

proc hexDigest*(hash: HashArray): string =
    ## Return hex digest of an image hash
    result = block:
        var hex_reprs = newSeq[string](HASH_SIZE)
        for i, v in enumerate(hash):
            hex_reprs[i] = v.toHex
        hex_reprs.join("")

proc diff*(hash1, hash2: HashArray): float64 =
    ## Compute diff for an image
    let total_bits = HASH_SIZE * 8
    var diff_bits = 0
    for (v1, v2) in zip(hash1, hash2):
        var d = v1 xor v2
        if d == 0: continue

        while d > 0:
            diff_bits = diff_bits + (d and 1).int
            d = d shr 1
    result = diff_bits / total_bits