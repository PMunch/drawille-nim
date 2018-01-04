import "/home/peter/div/drawille-nim/drawille"
import math
import strutils
import os
import osproc
import random

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
var c = newCanvas(width, height)
echo c

var sx, sy: int
sx = 10
sy = 10
c.set(sx,sy+5)
c.set(sx+2, sy+4)
c.set(sx+2, sy+5)
c.set(sx+4, sy+3)
c.set(sx+4, sy+2)
c.set(sx+4, sy+1)
c.set(sx+6, sy)
c.set(sx+6, sy+1)
c.set(sx+6, sy+2)
c.set(sx+7, sy+1)
#[
sx = 200
sy = 100
c.set(sx,sy)
c.set(sx+1,sy)
c.set(sx+2,sy)
c.set(sx+3,sy)
c.set(sx+4,sy)
c.set(sx+5,sy)
c.set(sx+6,sy)
c.set(sx+7,sy)
c.set(sx+9,sy)
c.set(sx+10,sy)
c.set(sx+11,sy)
c.set(sx+12,sy)
c.set(sx+13,sy)
c.set(sx+17,sy)
c.set(sx+18,sy)
c.set(sx+19,sy)
c.set(sx+26,sy)
c.set(sx+27,sy)
c.set(sx+28,sy)
c.set(sx+29,sy)
c.set(sx+30,sy)
c.set(sx+31,sy)
c.set(sx+32,sy)
c.set(sx+34,sy)
c.set(sx+35,sy)
c.set(sx+36,sy)
c.set(sx+37,sy)
c.set(sx+38,sy)
sx = 50
sy = 150
c.set(sx,sy)
c.set(sx+1,sy)
c.set(sx+2,sy)
c.set(sx+4,sy)
c.set(sx+0,sy+1)
c.set(sx+3,sy+2)
c.set(sx+4,sy+2)
c.set(sx+1,sy+3)
c.set(sx+2,sy+3)
c.set(sx+4,sy+3)
c.set(sx+0,sy+4)
c.set(sx+2,sy+4)
c.set(sx+4,sy+4)
]#
#[
sx = 50
sy = 50
c.set(sx+1,sy)
c.set(sx+2,sy+1)
c.set(sx,sy+2)
c.set(sx+1,sy+2)
c.set(sx+2,sy+2)
]#
#c.set(30,20)

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
    var changes = newSeq[tuple[x: int, y: int, dead: bool]]()
    var wx, wy: int
    for x in 0..<width*2:
      for y in 0..<height*4:
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
        if c.get(x, y):
          if alive < 2 or alive > 3:
            changes.add((x: x, y: y, dead: true))
        else:
          if alive == 3:
            changes.add((x: x, y: y, dead: false))

    for change in changes:
      if change.dead:
        c.unset(change.x, change.y)
      else:
        c.set(change.x, change.y)
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
          quit(0)
        of 'p':
          paused = not paused
        of 's':
          step = true
        of 'c':
          for x in 0..<width*2:
            for y in 0..<height*4:
              if random(10) == 0:
                c.set(x, y)
        else:
          discard
  discard execCmd("stty cooked")

  sleep(100)

