# Projection-Based Rendering In Processing
Rederiving and implementing projection-based rendering in Processing
I have always wondered how in the world we take 3D spatial information and somehow display that in a way that makes sense to us on our flat 2D screens. Curiosity got the best of me one day and I booted up a quick Processing instance because I thought surely this was a couple hour task and I couldn't be bother to implement line-drawing myself-- I have been here for a week and a half :/. It was a really fun and informative experience though, I think I'll do more like this in the future! Without further adue, I present projection-based rendering in Processing, built with nothing more than the built in *line* function (not using any of the built in P3D functions here!).

## Rendering mechanics include:
<ul>
  <li>Support for custom meshes (manually specify vertices and which face(s) each vertex belongs to).</li>
  <li>Support for importing pre-compiled meshes. Another option is to yoink vertex/face data from the internet by parsing common 3D files types. Currently I have implemented such a parser for both STL and OBJ input files.</li>
  <li>3D model translation/scaling in world space and player scene traversal (keys: ^, >, <, v, Shift, Ctrl)</li>
</ul>

This is probably as good as any place to mention that Processing is a processor-based application (i.e. no GPU). As such, the performace of this project (both the unoptimized and optimized iterations of it) are still going to run rather slow (well below 60FPS). After all, this is primairly intended as a learning exercise for myself as far as rendering math and subsequent rendering optimization algorithms and I by no means think you should run with my work to build Unreal Engine 6. Still, hopefully you will be as pleasantly surprised as I was by the non-negligable performance improvement you can squeze out with a few tricks. 
## Implemented rendering optimizations include:
<ul>
  <li>Backface Culling:</li>
  <div style="display: flex; justify-content: center; gap: 20px;">
    <img src="demo clips/unculled_cube.gif" alt="unculled_cube.gif"  style="width: 250px;">
    <img src="demo clips/backfaceCulled_cube.gif" alt="backfaceCulled_cube.gif"  style="width: 250px;">
  </div>
  Unculled (left) vs backface culled (right) cube render.
  <div style="display: flex; justify-content: center; gap: 20px;">
    <img src="demo clips/unoptimized_jet.gif" alt="unoptimized_jet.gif"  style="width: 400px;">
    <img src="demo clips/frustumCulled+backfaceCulled_jet.gif" alt="frustumCulled+backfaceCulled_jet.gif"  style="width: 400px;">
  </div>
  Example of performance difference. Screencapture software had effect on framerate, but benchmarking without screencapture found a 1.283 FPS w/out backface culling (left), and 3.521 FPS avg with backface culling (right). 

  
  <li>Frustum Culling/Clipping:</li>
  <img alt="frustumbackfaced_fishScene.gif" src="demo clips/frustumbackfaced_fishScene.gif" data-hpc="true" class="Box-sc-g0xbh4-0 kzRgrI">
  
  Walking through scene.
  <div style="display: flex; justify-content: center; gap: 20px;">
    <img src="demo clips/unoptimized_fishScene.gif"  style="width: 400px;">
    <img src="demo clips/frustumCulled_fishScene.gif"  style="width: 400px;">
  </div>
  The showcased scene has 3 fish and a cube immediately in view; however, out of view, there are an additional 4 fish the program is still performing the render calculations for. These unviewable fish will serve to make the performance difference more obvious when frustum culling is implemented and they are not rendered. The results reveal how this scene performs frustum unclipped (left) vs clipped (right).
  Interestingly, FPS seemed roughly the same with the unclipped scene's FPS dipping only a bit more frequently. Still, once again re-running the benchmark without screencapture impedence, a 17.903 FPS avg w/out clipping and 22.329 FPS avg was observed with clipping.
</ul>


These optimizations shine through the best when paired and the clipping algorithm need only be performed on faces that are worth considering (i.e. facing the viewer). Here is that last fish scene one more time with both frustum clipping and backface culling enabled:
<img alt="frustumCulled+backfaceCulled_fishScene.gif" src="demo clips/frustumCulled+backfaceCulled_fishScene.gif" data-hpc="true" class="Box-sc-g0xbh4-0 kzRgrI">

Upwards of 17 FPS! That's a ~7 frame difference from the screen captured un-fully-optimized fish scene.

Computer Specs: OS, Windows 11; Processor, Intel(R) Core(TM) i7-1065G7 CPU @ 1.30GHz; Installed Ram, 1.50 GHz. 32.0 GB (31.6 GB usable).

### Future work: 
The next logical optimization step would likely be to implement occlussion culling and LOD optimizations based on distance away from mesh(es). This would likely prove impractical in Processing as, on CPU alone, the overhead of these methods might outway the cost of the wasteful rendering they might prevent; but again could be a fun learning exercise! Perhaps a venture to be continued on Vulkan.

My **math derivation** notes on both the projection and optimization techniques can be found <a href="Projection-Based Rendering (scratch) Notebook.pdf" target="_blank">here</a>,
though they are a bit chaotic. Future work may also work include formalizing this written theory in Overleaf as an exercise.
