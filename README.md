# Projection-Based Rendering In Processing
Rederiving and implementing projection-based rendering in Processing.

I have always wondered how in the world we take 3D spatial information and somehow display that in a way that makes sense to us on our flat 2D screens. Curiosity got the best of me one day and I booted up a quick Processing instance because I thought surely this was only a few hours-long task, plus I couldn't be bothered to implement line drawing myself-- I have been here for a week and a half :/. However, It was an enjoyable and informative experience. Without further ado, I present projection-based rendering in Processing, built with nothing more than the built-in *line* function (not using any of the built-in P3D functions here!).

## Executable Download:
Hosted on [itch.io](https://joel-ca.itch.io/projection-based-rendering). Only Windows and Linux exports are supported (well) by Processing (though you can still run it on a Mac as a sketch if you download Processing yourself and open this project).

## Rendering mechanics include:
<ul>
  <li>Support for custom meshes (manually specify vertices and which face(s) each vertex belongs to).</li>
  <li>Support for importing pre-compiled meshes. Another option is to yoink vertex/face data from the internet by parsing common 3D file types. Currently, I have implemented such a parser for both STL and OBJ input files.</li>
  <li>3D model translation/scaling in world space and player scene traversal (keys: forward, ^ or W; backward, v or S; right, > or D; left, < or A; up, Shift; down, Ctrl; toggle frustum culling, F; toggle backface culling), B</li>
  <img alt="frustumbackfaced_fishScene.gif" src="demo clips/frustumbackfaced_fishScene.gif" data-hpc="true" class="Box-sc-g0xbh4-0 kzRgrI">
  <li>3 pre-made scenes. Press 1 for the cube scene, 2 for the fish scene, and 3 for the jet scene (or feel free to download and edit the program to import/create your own).</li>
</ul>

This is probably as good as any place to mention that Processing is a processor-based application (i.e. no GPU). As such, the performance of this project (both the unoptimized and optimized iterations of it) are going to run rather slowly (well below 60FPS). After all, this is primarily intended as a learning exercise for myself in rendering math and optimization algorithms, and I by no means think you should use this particular implementation  to build Unreal Engine 6. Still, I believe the theory to be broadly applicable. Further, hopefully, you will be as pleasantly surprised as I was by the non-negligible performance improvement you can squeeze out with a few tricks. 
## Implemented rendering optimizations include:
<ul>
  <li>Backface Culling:</li>
  <div style="display: flex; justify-content: center; gap: 20px;">
    <img src="demo clips/unculled_cube.gif" alt="unculled_cube.gif"  style="width: 250px;">
    <img src="demo clips/backfaceCulled_cube.gif" alt="backfaceCulled_cube.gif"  style="width: 250px;">
  </div>
  Unculled (left) vs backface culled (right) cube render.
  <div style="display: flex; justify-content: center; gap: 20px;">
    <img src="demo clips/unoptimized_jet.gif" alt="unoptimized_jet.gif"  style="width: 350px;">
    <img src="demo clips/frustumCulled+backfaceCulled_jet.gif" alt="frustumCulled+backfaceCulled_jet.gif"  style="width: 350px;">
  </div>
  Example of performance difference. Screencapture software had effect on framerate, but benchmarking without screencapture found a 1.283 FPS w/out backface culling (left), and a 3.521 FPS average with backface culling (right).

  <li>Frustum Culling/Clipping:</li>
  <img alt="demo clips/frustumCulled_cube.gif" src="demo clips/frustumCulled_cube.gif" data-hpc="true" class="Box-sc-g0xbh4-0 kzRgrI">
  
  Walking through the cube scene. The frustum is tightened to showcase clipping (otherwise, it is lined up with the viewable space and clipping is not easily detectable).
  <div style="display: flex; justify-content: center; gap: 20px;">
    <img src="demo clips/unoptimized_fishScene.gif"  style="width: 350px;">
    <img src="demo clips/frustumCulled_fishScene.gif"  style="width: 350px;">
  </div>
  The showcased scene has 3 fish and a cube immediately in view; however, out of view, there are an additional 4 fish the program is still performing the render calculations for. These unviewable fish will serve to make the performance difference more obvious when frustum culling is implemented and they are not rendered. The results reveal how this scene performs frustum unclipped (left) vs clipped (right).
  Interestingly, FPS seemed roughly the same with the unclipped scene's FPS dipping only a bit more frequently. Still, once again re-running the benchmark without screen capture impedance, a 17.903 FPS average w/out clipping and a 22.329 FPS average was observed with clipping.
</ul>

Clipping algorithm [wiki page](https://en.wikipedia.org/wiki/Sutherland%E2%80%93Hodgman_algorithm#:~:text=The%20Sutherland%E2%80%93Hodgman%20algorithm%20is,are%20on%20the%20visible%20side).

These optimizations shine through the best when paired and the clipping algorithm need only be performed on faces that are worth considering (i.e. facing the viewer). Here is that last fish scene one more time with both frustum clipping and backface culling enabled:
<img alt="frustumCulled+backfaceCulled_fishScene.gif" src="demo clips/frustumCulled+backfaceCulled_fishScene.gif" data-hpc="true" class="Box-sc-g0xbh4-0 kzRgrI">

Upwards of 17 FPS! That's a ~7-frame difference from before.

Computer Specs: OS, Windows 11; Processor, Intel(R) Core(TM) i7-1065G7 CPU @ 1.30GHz; Installed Ram, 1.50 GHz. 32.0 GB (31.6 GB usable). Note that I also had like infinite Chrome tabs open while benchmarking/recording-- may have impacted performance.

### Future work: 
The next logical optimization step would likely be to implement occlusion culling and LOD optimizations based on distance away from mesh(es). This would likely prove impractical in Processing as, on CPU alone, the overhead of these methods might outway the cost of the wasteful rendering they may prevent; but again could be a fun learning exercise! Perhaps a venture to be continued on Vulkan.

My **math derivation** notes on both the projection and optimization techniques can be found <a href="Projection-Based Rendering (scratch) Notebook.pdf" target="_blank">here</a>,
though they are a bit chaotic. Future work may also include formalizing this written theory in Overleaf as an exercise.
