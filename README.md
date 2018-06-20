DRAWILLE
========

Drawing in terminal with Unicode [Braille][] characters. This is the Nim
version of the [Python original][].

[Braille]: http://en.wikipedia.org/wiki/Braille
[Python original]: https://github.com/asciimoo/drawille

Drawille is a way to draw pixel graphics in the terminal with higher resolution
than the size of a single character. It works by using the 2x4 unicode braille
characters. This means that each character can be used to draw a 2x4 section of
an image as long as your font supports it. The name and idea comes from
https://github.com/asciimoo/drawille however not all functions from there are
implemented while some new functionality is added.

For a canvas only simple set/unset/toggle functions exists, along with the
convenience functions drawLine, toggleLine, fill, clear, and toggle for an area.

A new type is also added which creates a layered canvas. It works in mostly the
same way but the rendering of layers are XOR-ed. This means you don't have to
redraw everything each time you want to move something, only that layer.

Drawille now also supports colours! This is only available for regular canvases
and not layers. Since each 2x4 character can only have a single colour all the
pixels that make up a character has their colours blended into one. For examples
of this look at the `example_colour.nim` file, or a more elaborate program in
`gameoflife.nim`. The game of life implementation supports colours, along with
saving and loading PNG images (requires `nimPNG`). It also takes commands, `q`
to quit (it plays with your terminals display mode, so use this to ensure that
it works afterwards), `p` to pause the simulation, `f` to take a single step,
`l` to load the PNG file "input.png", `s` to save the current image to
"output.png", and `c` to create dots of random colour around the canvas.
