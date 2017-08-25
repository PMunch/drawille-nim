import "../drawille"
import math
import strutils
import os

# Set an arbitrary width and height
let
  width = 70
  height = 20

# Create a new canvas and write it to the screen
var c = newLayeredCanvas(width, height, 3)
echo c

# Fill a region
c.fill((width)-1,(height)*2-1,(width)*2-1,(height)*4-1, 0)

for j in 0..int.high:
  # ANSI codes to go clear the area we use for our drawing
  echo "\r" & "\e[A\e[K".repeat(height+4)
  # Draw a nice sine curve
  for i in 0..<(width*2):
    c.toggle(i, height*2+(degToRad(((i+j)*4).float).sin*(height*2-1).float).int, 1)
  # And a line to trace the end of it
  c.toggleLine(0, height*2, width*2-1, height*2+(degToRad((((width*2-1)+j)*4).float).sin*(height*2-1).float).int, 1)
  # Every fifth step, move the box on layer 2
  if (j mod 5) == 1:
    c.clear(2)
    let pos = j mod width*2-1
    c.fill(pos,height, min(pos+30, width*2-1), min(height + 30, height*4-1), 2)
  # Check for collision, then draw the dot
  echo "Something collides with dot 1: " & $c.get(10,height+5)
  c.set(10,height+5, 1)
  # Check for collision, then draw the dot
  echo "Something collides with dot 2: " & $c.get(80,height*2+7)
  c.set(80,height*2+7, 1)
  # Check for collision, then draw the dot
  echo "Something collides with dot 3: " & $c.getSum(100,height*2+7)
  c.set(100,height*2+7, 1)
  # Draw the canvas
  echo c
  # Empty the canvas so we're clear for another round
  c.clear(1)
  sleep(50)