import "../drawille"
import math
import strutils
import os

# Set an arbitrary width and height
let
  width = 70
  height = 20

# Create a new canvas and write it to the screen
var c = newCanvas(width,height)
echo c

for j in 0..int.high:
  # ANSI codes to go clear the area we use for our drawing
  echo "\r" & "\e[A\e[K".repeat(height+2)
  # Fill a region
  c.fill((width)-1,(height)*2-1,(width)*2-1,(height)*4-1)
  # Draw a nice sine curve
  for i in 0..<(width*2):
    c.toggle(i, height*2+(degToRad(((i+j)*4).float).sin*(height*2-1).float).int)
  # And a line to trace the end of it
  c.toggleLine(0, height*2, width*2-1, height*2+(degToRad((((width*2-1)+j)*4).float).sin*(height*2-1).float).int)
  # Check for collision, then draw the dot
  echo "Something collides with dot: " & $c.get(10,height)
  c.toggle(10,height)
  # Draw the canvas
  echo c
  # Empty the canvas so we're clear for another round
  c.clear()
  sleep(50)