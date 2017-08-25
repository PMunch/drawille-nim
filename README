DRAWILLE
========

Drawing in terminal with Unicode [Braille][] characters. This is the Nim
version of the [Python original][].

[Braille]: http://en.wikipedia.org/wiki/Braille
[Python original]: https://github.com/asciimoo/drawille

Drawille is a way to draw monocolor pixel graphics in the terminal with higher
resolution than the size of a single character. It works by using the 2x4
unicode braille characters. This means that each character can be used to draw
a 2x4 section of an image as long as your font supports it. The name and idea
comes from https://github.com/asciimoo/drawille however not all functions from
there are implemented while some new functionality is added.

For a canvas only simple set/unset/toggle functions exists, along with the
convenience functions drawLine, toggleLine, fill, clear, and toggle for an area.

A new type is also added which creates a layered canvas. It works in mostly the
same way but the rendering of layers are XOR-ed. This means you don't have to
redraw everything each time you want to move something, only that layer.