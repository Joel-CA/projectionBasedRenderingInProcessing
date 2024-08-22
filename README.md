# Projection-Based Rendering In Processing
Rederiving and implementing projection-based rendering in Processing
Implemented optimizations include:
<ul>
  <li>Backface Culling</li>
  <div style="display: flex; justify-content: center; gap: 20px;">
    <img src="demo clips/unculled_cube.gif" alt="frustumCulled+backfaceCulled_jet.gif"  style="width: 400px;">
    <img src="demo clips/backfaceCulled_cube.gif" alt="demo clips/unoptimized_jet.gif"  style="width: 400px;">
  </div>
  <div style="display: flex; justify-content: center; gap: 20px;">
    <img src="demo clips/unoptimized_jet.gif" alt="demo clips/unoptimized_jet.gif"  style="width: 400px;">
    <img src="demo clips/frustumCulled+backfaceCulled_jet.gif" alt="frustumCulled+backfaceCulled_jet.gif"  style="width: 400px;">
  </div>
  
  <li>Frustum Culling</li>
  <img alt="frustumbackfaced_fishScene.gif" src="https://github.com/Joel-CA/projectionBasedRenderingInProcessing/blob/main/demo%20clips/frustumbackfaced_fishScene.gif?raw=true" data-hpc="true" class="Box-sc-g0xbh4-0 kzRgrI">
  <div style="display: flex; justify-content: center; gap: 20px;">
    <img src="demo clips/unoptimized_fishScene.gif"  style="width: 400px;">
    <img src="demo clips/frustumCulled+backfaceCulled_fishScene.gif"  style="width: 400px;">
  </div>
</ul>

My derivation notes can be found [here](Projection-Based Rendering Notebook.pdf), though they are a bit chaotic. Future work may include formalizing this written theory in Overleaf as an exercise.
