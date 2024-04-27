# About

This is a proof-of-concept implementation of 3D Splatoon-style ink mechanics in GameMaker. This project was made as a quick personal challenge over a weeks-worth of evenings and thus is not very optimized and is a bit sloppy. That said, it was designed in a modular way so that adding in the appropriate optimizations and expanding upon its features should be relatively simple.

As a note, this project was made for Linux first and only modified in places to make it run on Windows. As such, some of the rendering setup is pretty janky due to the differences between OpenGL and DirectX but it should appear visually the same when running. Axis layout is also a bit strange with X+, Y+, Z+ being forward, up, and right.

I am uploading this project for anyone who may be able to learn from it.

# Features

This project is focused on the ink mechanics; as such the rendering and physics are only as complicated as they needed to be to accomplish this. Rendering is just a list of items to render out in-order while the physics system does just AABB and ray->triangle checks for body and ink collisions, respectively. There is one spinning block in the demo there for painting demo purposes but it doesn't have proper body collisions as that would require OBB (which I didn't bother implementing). 

For the ink itself, it can be painted on pretty much any surface. Ray collisions are used, followed by a UV look-up to find the appropriate place on the texture to paint. Each 'splattable' mesh has a 'splat surface' that can be painted to however you see fit. Also included is the 'splat buffer' that is effectively the same thing but in a buffer so that it is simple to look up when you are touching paint.

Currently the splat buffer simply copies the whole surface into itself upon update. This could be greatly optimized but is good enough for a proof-of-concept.

Lastly, the character has primary movement implemented. Moving around free of the camera, firing mode (which adds strafing), jumping, and 'swimming' mode which allows you to swim in ink and go up surfaces.

# Controls

There are three demo rooms:

1. Full 3D character interaction; this requires a controller to test
2. Painting a spinning cube; this requires a mouse to test
3. Simple paint surface for splat shader testing; this requires a mouse to test

For the controller; movement is left joy, look is right joy, southern-face is jump, western-face is 'swim', L1 is change ink color, L2 is fire ink.
