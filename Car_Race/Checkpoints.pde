class Checkpoints
{
  PVector[] checkpoints;
  boolean[] display;
  
  Checkpoints()
  {
    checkpoints = new PVector[0];
    display = new boolean[0];
  }
  
  void show()
  {
    for (int i = 0; i < display.length; i++)
    {
      if (display[i])
      {
        float distX = checkpoints[2*i+1].x - checkpoints[2*i].x;
        float distY = checkpoints[2*i+1].y - checkpoints[2*i].y;
        fill(0,255,0);
        rect(checkpoints[2*i].x, checkpoints[2*i].y, distX == 0 ? 5 : distX, distY == 0 ? 5 : distY);
      }
    }
  }
  
  void addCheckPoints()
  {
    // Always checkpoints[2*i+1].x >= checkpoints[2*i].x and checkpoints[2*i+1].y >= checkpoints[2*i].y
    
    checkpoints = (PVector[])append(append(checkpoints, new PVector(200, 410)), new PVector(200, 495));
    
    checkpoints = (PVector[])append(append(checkpoints, new PVector(70, 275)), new PVector(172, 275));
    
    checkpoints = (PVector[])append(append(checkpoints, new PVector(200, 48)), new PVector(200, 140));
    
    checkpoints = (PVector[])append(append(checkpoints, new PVector(600, 48)), new PVector(600, 140));
    
    checkpoints = (PVector[])append(append(checkpoints, new PVector(675, 170)), new PVector(770, 170));
    
    checkpoints = (PVector[])append(append(checkpoints, new PVector(600, 198)), new PVector(600, 295));
    
    checkpoints = (PVector[])append(append(checkpoints, new PVector(265, 295)), new PVector(369, 295));
    
    checkpoints = (PVector[])append(append(checkpoints, new PVector(500, 302)), new PVector(500, 392));
    
    checkpoints = (PVector[])append(append(checkpoints, new PVector(676, 400)), new PVector(768, 400));
    
    checkpoints = (PVector[])append(append(checkpoints, new PVector(676, 550)), new PVector(768, 550));
    
    checkpoints = (PVector[])append(append(checkpoints, new PVector(651, 589)), new PVector(651, 673));
    
    checkpoints = (PVector[])append(append(checkpoints, new PVector(525, 550)), new PVector(632, 550));
    
    checkpoints = (PVector[])append(append(checkpoints, new PVector(500, 410)), new PVector(500, 493));
    
    display = new boolean[checkpoints.length / 2];
    display[0] = true;
    for (int i = 1; i < display.length; i++)
    {
      display[i] = false;
    }
  }
}
