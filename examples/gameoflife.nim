import "../drawille"
import "./extra_colour_code"
import math
import strutils
import os
import osproc
import random
import nimPNG

type WinSize = object
  row, col, xpixel, ypixel: cushort

const TIOCGWINSZ = 0x5413
const I_NREAD = 0x5301
const FIONREAD = 0x541b

proc ioctl(fd: cint, request: culong, argp: pointer): cint
  {.importc, header: "<sys/ioctl.h>".}

var size: WinSize
discard ioctl(0, TIOCGWINSZ, addr size)
echo size
echo size.col

# Set an arbitrary width and height
let
  width = size.col.int
  height = size.row.int - 1

# Create a new canvas and write it to the screen
var c = newColourCanvas(width, height)
echo c

var
  paused = false
  step = false
for j in 0..int.high:
  # ANSI codes to go clear the area we use for our drawing
  stdout.write "\e[A\e[K".repeat(height)
  # Draw the canvas
  echo c
  # Do life
  if not paused or step:
    var changes = newSeq[tuple[x: int, y: int, dead: bool, colour: Colour]]()
    var wx, wy: int
    for x in 0..<width*2:
      for y in 0..<height*4:
        var red, green, blue: int = 0
        var alive =
          if c.get(x, y):
            -1
          else:
            0
        for nx in (x-1)..(x+1):
          wx = nx
          if nx<0:
            wx = width*2+nx
          wx = wx mod (width*2)
          for ny in (y-1)..(y+1):
            wy = ny
            if ny<0:
              wy = height*4+ny
            wy = wy mod (height*4)
            if c.get(wx, wy):
              alive+=1
              let col = c.getColour(wx, wy)
              red += col.red.int
              green += col.green.int
              blue += col.blue.int
        if c.get(x, y):
          if alive < 2 or alive > 3:
            changes.add((x: x, y: y, dead: true, colour: Colour(red: 0, green: 0, blue: 0)))
        else:
          if alive == 3:
            let
              rgbColourObj = Colour(red: (red div alive).uint8, green: (green div alive).uint8, blue: (blue div alive).uint8)
            changes.add((x: x, y: y, dead: false, colour: rgbColourObj))

    for change in changes:
      if change.dead:
        c.unset(change.x, change.y)
      else:
        c.set(change.x, change.y, change.colour)
    step = false

  discard execCmd("stty raw")
  var n:cint = 0
  if (ioctl(0, FIONREAD, n.addr) == 0 and n > 0):
    var buf = newString(n)
    if stdin.readBuffer(buf[0].addr, n) == n:
      for i in 0..<n:
        case buf[i]:
        of 'q':
          discard execCmd("stty cooked")
          stdout.write "\e[A\e[K".repeat(height)
          quit(0)
        of 'p':
          paused = not paused
        of 'f':
          step = true
        of 'l':
          let png = loadPNG32("input.png")
          for i in 0..<png.height:
            for j in 0..<png.width:
              if png.data[(i*png.width+j)*4+3].int > 128:
                if c.grid.len*2 > j and c.grid[0].len*4 > i:
                  c.set(j, i, Colour(red: png.data[(i*png.width+j)*4].uint8, green: png.data[(i*png.width+j)*4 + 1].uint8, blue: png.data[(i*png.width+j)*4 + 2].uint8))
        of 's':
          var pngData = newString(c.grid.len*2*c.grid[0].len*4*4)
          for i in 0..<c.grid[0].len*4:
            for j in 0..<c.grid.len*2:
              if c.get(j, i):
                let colour = c.getColour(j, i)
                pngData[(i*c.grid.len*2+j)*4] = colour.red.char
                pngData[(i*c.grid.len*2+j)*4 + 1] = colour.green.char
                pngData[(i*c.grid.len*2+j)*4 + 2] = colour.blue.char
                pngData[(i*c.grid.len*2+j)*4 + 3] = 255.char
              else:
                pngData[(i*c.grid.len*2+j)*4] = 0.char
                pngData[(i*c.grid.len*2+j)*4 + 1] = 0.char
                pngData[(i*c.grid.len*2+j)*4 + 2] = 0.char
                pngData[(i*c.grid.len*2+j)*4 + 3] = 0.char
          discard savePNG32("output.png", pngData, c.grid.len*2, c.grid[0].len*4)

        of 'c':
          var
            rgbColour = (hue: random(255).uint8, saturation: 255'u8, value: (127+random(128)).uint8).toRgb
            rgbColourObj = Colour(red: rgbColour.red, green: rgbColour.green, blue: rgbColour.blue)
            size = random(255)
          for x in 0..<width*2:
            for y in 0..<height*4:
              if random(20) == 0:
                c.set(x, y, rgbColourObj)
                size -= 1
                if size == 0:
                  rgbColour = (hue: random(255).uint8, saturation: 255'u8, value: 255'u8).toRgb
                  rgbColourObj = Colour(red: rgbColour.red, green: rgbColour.green, blue: rgbColour.blue)
                  size = random(255)
        else:
          discard
  discard execCmd("stty cooked")

  sleep(150)
