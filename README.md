# Compiling / Running

This project was made in GameMaker 2 while using the Beta branch. You may or may not be able to run this with the normal branch but, if on the beta branch, to run the project simply clone the repo and import the yyp project file. Pressing 'Run' will compile the project and run the 3D character demo. 

The other demos can be accessed by setting their Scene room as the active room in the GameMaker project itself.

# About

This is a proof-of-concept implementation of 3D Splatoon-style ink mechanics in GameMaker. This project is NOT a demonstration of fancy 3D graphics or physics and these elements will be very bare-bones. All the mechanics, however, are designed very modularly so it should be simple enough to expand things as needed or port elements to another project.

As a note, this project was made for Linux first and only modified in places to make it run on Windows. As such, some of the rendering setup is pretty janky due to the differences between OpenGL and DirectX but it should appear visually the same when running. This only applies to building some matrices and the game world runs on a consistent Y-up, X+, Z+, Y+ coordinate system.

I am uploading this project for anyone who may be able to learn from it.

# Features

This project contains the following features:

* Dynamic terrain coloring w/ ink
* Ink color detection when moving the character around
* Ink swimming (including up walls)
* Controller support for character movement
* Basic AABB and ray -> triangle collisions

The demo **requires** that you are using a controller. I did this because I built this on Linux w/ a Wayland compositor and you can't set the mouse position with GameMaker in this case (so mouse look was right out). You could add this yourself by creating a virtual controller with the input system and mapping mouse movement / keyboard to the relevant axes / button presses if you need it. The other demo rooms do support the mouse if you are just interested in seeing how the ink painting works.

Note that the spinning cube doesn't have proper character collisions (as that would require OBB and I haven't implemented that). It is there for paint demonstration purposes. All the other terrain is properly interactible.

# Controls

There are three demo rooms:

1. Full 3D character interaction; this requires a controller to test
2. Painting a spinning cube; this requires a mouse to test
3. Simple paint surface for splat shader testing; this requires a mouse to test

For character movement the controls are as follows:

* Left-joy: Move
* Right-joy: Look
* South-face: Jump
* West-face: Swim
* L2: Shoot ink
* L1: Cycle ink color