proc toHsv(rgb: tuple[red, green, blue: uint8]): tuple[hue, saturation, value: uint8] =
  var
    rgbMin = if rgb.red < rgb.green: (if rgb.red < rgb.blue: rgb.red else: rgb.blue) else: (if rgb.green < rgb.blue: rgb.green else: rgb.blue)
    rgbMax = if rgb.red > rgb.green: (if rgb.red > rgb.blue: rgb.red else: rgb.blue) else: (if rgb.green > rgb.blue: rgb.green else: rgb.blue)
  echo rgbMin
  echo rgbMax

  result.value = rgbMax.uint8
  if result.value == 0:
    result.hue = 0
    result.saturation = 0
    return result

  result.saturation = (255 * (rgbMax.int - rgbMin.int) div rgbMax.int).uint8
  if result.saturation == 0:
    result.hue = 0
    return result

  if rgbMax == rgb.red:
    result.hue = ((43 * (rgb.green - rgb.blue).int) div (rgbMax - rgbMin).int).uint8
  elif rgbMax == rgb.green:
    result.hue = (85 + (43 * (rgb.blue - rgb.red).int) div (rgbMax - rgbMin).int).uint8
  else:
    result.hue = (171 + (43 * (rgb.red - rgb.green).int) div (rgbMax - rgbMin).int).uint8

proc toRgb(hsv: tuple[hue, saturation, value: uint8]): tuple[red, green, blue: uint8] =
  if hsv.saturation == 0:
    result.red = hsv.value
    result.green = hsv.value
    result.blue = hsv.value
    return result

  var
    region = hsv.value div 43
    remainder = (hsv.value - (region * 43)) * 6
    p = (hsv.value * (255'u8 - hsv.saturation)) shr 8
    q = (hsv.value * (255'u8 - ((hsv.saturation * remainder) shr 8))) shr 8
    t = (hsv.value * (255'u8 - ((hsv.saturation * (255'u8 - remainder)) shr 8))) shr 8

  case region:
  of 0:
    result.red = hsv.value
    result.green = t
    result.blue = p
  of 1:
    result.red = q
    result.green = hsv.value
    result.blue = p
  of 2:
      result.red = p
      result.green = hsv.value
      result.blue = t
  of 3:
      result.red = p
      result.green = q
      result.blue = hsv.value
  of 4:
      result.red = t
      result.green = p
      result.blue = hsv.value
  else:
      result.red = hsv.value
      result.green = p
      result.blue = q

when isMainModule:
  var
    rgbColour = (red: 75'u8, green: 20'u8, blue: 200'u8)
    hsvColour = rgbColour.toHsv()
    rgbColour2 = hsvColour.toRgb()
  echo "h: " & $hsvColour.hue & ", s: " & $hsvColour.saturation & ", v: " & $hsvColour.value
  echo "r: " & $rgbColour.red & ", g: " & $rgbColour.green & ", b: " & $rgbColour.blue
  echo "r: " & $rgbColour2.red & ", g: " & $rgbColour2.green & ", b: " & $rgbColour2.blue
