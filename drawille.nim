import unicode

## Drawille is a way to draw monocolor pixel graphics in the terminal with higher
## resolution than the size of a single character. It works by using the 2x4
## unicode braille characters. This means that each character can be used to draw
## a 2x4 section of an image as long as your font supports it. The name and idea
## comes from https://github.com/asciimoo/drawille however not all functions from
## there are implemented while some new functionality is added.

type
  Canvas* = object
    ## A standard canvas object
    grid*: seq[seq[uint8]]
  LayeredCanvas* = object
    ## A canvas with multiple layers
    canvases*: seq[Canvas]
  Dot = object
    cx, cy: int
    dot: uint8

const dots = [1'u8, 2, 4, 64, 8, 16, 32, 128]

# Helper function to get the character and the subdot that we need
proc getDot(x, y: int): Dot =
  result.cx = x div 2
  result.cy = y div 4

  result.dot = dots[y-(result.cy*4) + ((x-(result.cx*2)) shl 2)]

proc newCanvas*(w, h: int): Canvas =
  ## Creates a new canvas with a width and height given in _characters_
  ## Since the braille symbols are 2x4 dots this means that the actual
  ## resolution will be w*2 and h*4
  result.grid = newSeq[seq[uint8]](w)
  for i in 0..<w:
    result.grid[i] = newSeq[uint8](h)

proc get*(c: Canvas, x, y: int): bool =
  ## Checks if a dot is set on the canvas at position x, y
  let d = getDot(x, y)
  return (c.grid[d.cx][d.cy] and d.dot) != 0

proc set*(c: var Canvas, x, y: int) =
  ## Set a dot on the canvas at position x, y
  let d = getDot(x, y)
  c.grid[d.cx][d.cy] = c.grid[d.cx][d.cy] or d.dot

proc unset*(c: var Canvas, x, y: int) =
  ## Unset a dot on the canvas at position x, y
  let d = getDot(x, y)
  c.grid[d.cx][d.cy] = c.grid[d.cx][d.cy] and not d.dot

proc toggle*(c: var Canvas, x, y: int) =
  ## Toggles a dot on the canvas at position x, y
  let d = getDot(x, y)
  c.grid[d.cx][d.cy] = c.grid[d.cx][d.cy] xor d.dot

proc fill*(c: var Canvas, x1, y1, x2, y2: int) =
  ## Sets the entire region from x1, y1 to x2, y2
  for x in min(x1,x2)..max(x1,x2):
    for y in min(y1,y2)..max(y1,y2):
      c.set(x, y)

proc toggle*(c: var Canvas, x1, y1, x2, y2: int) =
  ## Toggles the entire region from x1, y1, to x2, y2
  for x in min(x1,x2)..max(x1,x2):
    for y in min(y1,y2)..max(y1,y2):
      c.toggle(x, y)

proc clear*(c: var Canvas, x1, y1, x2, y2: int) =
  ## Unsets the entire region from x1, y1, to x2, y2
  for x in min(x1,x2)..max(x1,x2):
    for y in min(y1,y2)..max(y1,y2):
      c.unset(x, y)

proc clear*(c: var Canvas) =
  ## Unsets the entire canvas
  for j in 0..c.grid[0].high:
    for i in 0..c.grid.high:
      c.grid[i][j] = 0

proc drawLine*(c: var Canvas, x1, y1, x2, y2: int) =
  ## Draws a line from x1, y1 to x2, y2
  let
    dx = x1 - x2
    dy = y1 - y2
  for x in min(x1,x2)..max(x1,x2):
    let y = y1 + dy * (x - x1) div dx
    c.set(x, y)

proc toggleLine*(c: var Canvas, x1, y1, x2, y2: int) =
  ## Toggles all dots on a line from x1, y1 to x2, y2
  let
    dx = x1 - x2
    dy = y1 - y2
  for x in min(x1,x2)..max(x1,x2):
    let y = y1 + dy * (x - x1) div dx
    c.toggle(x, y)

proc `$`*(c: Canvas): string =
  ## Outputs the entire buffer as the actual braille characters
  ## If you want to do anything else than printing you can get
  ## the raw buffer from the object
  result = ""
  for j in 0..c.grid[0].high:
    if j != 0: result.add "\n"
    for i in 0..c.grid.high:
      result.add Rune(0x2800 or c.grid[i][j].int).toUTF8


proc newLayeredCanvas*(w, h, layers: int): LayeredCanvas =
  ## Creates a new layered canvas. This is useful to avoid clearing
  ## and drawing the entire canvas. All layers will be xor-ed with
  ## the other layers on draw.
  result.canvases = newSeq[Canvas](layers)
  for i in 0..<layers:
    result.canvases[i] = newCanvas(w, h)

proc get*(c: LayeredCanvas, x, y, layer: int): bool =
  ## Same as for a regular canvas, but for a single layer
  c.canvases[layer].get(x, y)

proc getSum*(c: LayeredCanvas, x, y: int): bool =
  ## True if all xor-ing returns a set dot at the position
  result = false
  let d = getDot(x, y)
  for i in 0..c.canvases.high:
    if (c.canvases[i].grid[d.cx][d.cy] and d.dot) != 0:
      result = not result

proc get*(c: LayeredCanvas, x, y: int): bool =
  ## True if any dot on any layer is set at the position
  let d = getDot(x, y)
  for i in 0..c.canvases.high:
    if (c.canvases[i].grid[d.cx][d.cy] and d.dot) != 0:
      return true

proc set*(c: var LayeredCanvas, x, y, layer: int) =
  ## Same as for a regular canvas, but for a single layer
  c.canvases[layer].set(x, y)

proc unset*(c: var LayeredCanvas, x, y, layer: int) =
  ## Same as for a regular canvas, but for a single layer
  c.canvases[layer].unset(x, y)

proc toggle*(c: var LayeredCanvas, x, y, layer: int) =
  ## Same as for a regular canvas, but for a single layer
  c.canvases[layer].toggle(x, y)

proc fill*(c: var LayeredCanvas, x1, y1, x2, y2, layer: int) =
  ## Same as for a regular canvas, but for a single layer
  c.canvases[layer].fill(x1, y1, x2, y2)

proc toggle*(c: var LayeredCanvas, x1, y1, x2, y2, layer: int) =
  ## Same as for a regular canvas, but for a single layer
  c.canvases[layer].toggle(x1, y1, x2, y2)

proc clear*(c: var LayeredCanvas, layer: int) =
  ## Same as for a regular canvas, but for a single layer
  c.canvases[layer].clear()

proc clear*(c: var LayeredCanvas, x1, y1, x2, y2, layer: int) =
  ## Same as for a regular canvas, but for a single layer
  c.canvases[layer].clear(x1, y1, x2, y2)

proc clear*(c: var LayeredCanvas, x1, y1, x2, y2: int) =
  ## Same as for a regular canvas, but for all layers 
  for layer in 0..c.canvases.high:
    c.canvases[layer].clear(x1, y1, x2, y2)

proc clear*(c: var LayeredCanvas) =
  ## Clears all layers
  for layer in 0..c.canvases.high:
    c.canvases[layer].clear()

proc drawLine*(c: var LayeredCanvas, x1, y1, x2, y2, layer: int) =
  ## Same as for a regular canvas, but for a single layer
  c.canvases[layer].drawLine(x1, y1, x2, y2)

proc toggleLine*(c: var LayeredCanvas, x1, y1, x2, y2, layer: int) =
  ## Same as for a regular canvas, but for a single layer
  c.canvases[layer].toggleLine(x1, y1, x2, y2)

proc `$`*(c: LayeredCanvas): string =
  ## Same as for a regular canvas, but each layer is xor-ed together
  result = ""
  for j in 0..c.canvases[0].grid[0].high:
    if j != 0: result.add "\n"
    for i in 0..c.canvases[0].grid.high:
      var character: uint8
      for layer in 0..c.canvases.high:
        character = character xor c.canvases[layer].grid[i][j]
      result.add Rune(0x2800 or character.int).toUTF8