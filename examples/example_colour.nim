import "../drawille"
import math
import strutils
import os

# Set an arbitrary width and height
let
  width = 70
  height = 20

# Create a new canvas and write it to the screen
var c = newColourCanvas(width,height)
echo c

for j in 0..int.high:
  # ANSI codes to go clear the area we use for our drawing
  stdout.write "\e[A\e[K".repeat(height+1)
  # Fill a region
  c.fill((width)-1,(height)*2-1,(width)*2-1,(height)*4-1, Colour(red: 100, blue: 240, green: 0))
  # Draw a nice sine curve
  for i in 0..<(width*2):
    c.toggle(i, height*2+(degToRad(((i+j)*4).float).sin*(height*2-1).float).int, Colour(red: 240, blue: 40, green: 40))
  # And a line to trace the end of it
  c.toggleLine(0, height*2, width*2-1, height*2+(degToRad((((width*2-1)+j)*4).float).sin*(height*2-1).float).int, Colour(red: 40, blue: 240, green: 40))
  # Check for collision, then draw the dot
  stdout.write "Something collides with dot: " & $c.get(10,height)
  c.toggle(10,height, Colour(red:73, blue: 10, green: 100))
  # Draw the canvas
  echo "\n" & $c
  # Empty the canvas so we're clear for another round
  c.clear()
  sleep(50)
