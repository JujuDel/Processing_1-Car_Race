class Car 
{
  boolean isDeadByObst, isDead, isBest;

  PImage imgCar, imgCarDead, imgBestCar, imgBestCarDead;
  
  // Obstacle Detection
  PVector[] listOfDetectionVectorsFront, listOfDetectionVectorsBack;
  PVector[] detectedBlackPixelDistancesFront, detectedBlackPixelDistancesBack;
  int range, carCircle, nbOfDetectionRays, defaultDetectedValue;
  color pixelDetectedColor;
  
  // Car movements
  PVector pos, sizeRect;
  float angle, user_angle, vel, acc, user_acc;
  
  Brain brain;
  
  // Checkpoints
  Checkpoints checkpoints;
  
  // Score
  int scoreMove;
  float fitness;
  int[] checkpointSteps;
  
  Car()
  {
    isDead = true;
    
    if (!isUserPlaying)
      brain = new Brain();
  }
  
  Car(PVector sizeCar, int sizeBrain)
  {
    isBest       = false;
    isDead       = false;
    isDeadByObst = false;
    
    imgCar         = loadImage("usualCar.png");
    imgCarDead     = loadImage("usualCarDead.png");
    imgBestCar     = loadImage("bestCar.png");
    imgBestCarDead = loadImage("bestCarDead.png");
    
    pos      = new PVector(470, 450);
    sizeRect = sizeCar;
    
    vel        = 0;
    acc        = 0;
    user_acc   = 0;
    angle      = 0;
    user_angle = 0;
    
    checkpoints = new Checkpoints();
    checkpoints.addCheckPoints();
    
    scoreMove       = 0;
    fitness         = 0;
    checkpointSteps = new int[0];
    
    // Obstacle Detection
    range                = 100 ;
    carCircle            = (int)(sqrt(sizeRect.x * sizeRect.x + sizeRect.y * sizeRect.y) * 0.75);
    nbOfDetectionRays    = 3;
    defaultDetectedValue = 777;
    pixelDetectedColor   = color(255);
    generateDetectionRays();
    initDetectedBlackPixelDistances();
    
    // Construct the brain
    if (!isUserPlaying)
      brain = new Brain(sizeBrain, nbOfDetectionRays);
  }
  
  void initBestCar()
  {
    isBest       = true;
    isDead       = false;
    isDeadByObst = false;
    
    pos   = new PVector(470, 450);
    vel   = 0;
    acc   = 0;
    angle = 0;
    
    checkpoints = new Checkpoints();
    checkpoints.addCheckPoints();
    
    brain.initBestBrain();
  }
  
  ///////////////////////
  // Fitness
  ///////////////////////
  
  float computeRewards()
  {
    if (checkpointSteps.length > 0)
    {
      float reward = 1.0 / (float)(checkpointSteps[0]);
      for (int i = 1; i < checkpointSteps.length; i++)
      {
        int step = checkpointSteps[i] - checkpointSteps[i-1];
        reward += 10 * i / (float)(step);
      }
      return reward;
    }
    else
      return 0;
  }
  
  void computeFitness()
  {
    fitness = max(0, scoreMove) + 100f * computeRewards();
    if (isDeadByObst)
      fitness = fitness / 2f;
  }
  
  ///////////////////////
  // Displays
  ///////////////////////
  
  void show()
  {
    if (isBest)
      checkpoints.show();
    
    pushMatrix();
    {
      translate(pos.x, pos.y);
      rotate(angle);
      
      if (isDead)
        image(isBest ? imgBestCarDead : imgCarDead, -sizeRect.x/2, -sizeRect.y/2, sizeRect.x, sizeRect.y);
      else if (isBest)
      {
        image(imgBestCar, -sizeRect.x/2, -sizeRect.y/2, sizeRect.x, sizeRect.y);
      }
      else
        image(imgCar, -sizeRect.x/2, -sizeRect.y/2, sizeRect.x, sizeRect.y);
    }
    popMatrix();
    if (isBest)
      displayRaysAndDetectionPoints();
  }
  
  void displayRaysAndDetectionPoints()
  {
    for (int i = 0; i < nbOfDetectionRays; i++)
      {
        line(pos.x, pos.y, pos.x + range * listOfDetectionVectorsFront[i].x, pos.y + range * listOfDetectionVectorsFront[i].y);
        if (detectedBlackPixelDistancesFront[i].x < 777 && detectedBlackPixelDistancesFront[i].y < range)
        {
          fill(255, 0, 0);
          rect((int)(pos.x + detectedBlackPixelDistancesFront[i].y * listOfDetectionVectorsFront[i].x), (int)(pos.y + detectedBlackPixelDistancesFront[i].y * listOfDetectionVectorsFront[i].y), 5, 5); 
        }
        line(pos.x, pos.y, pos.x + range * listOfDetectionVectorsBack[i].x, pos.y + range * listOfDetectionVectorsBack[i].y);
        if (detectedBlackPixelDistancesBack[i].x < 777 && detectedBlackPixelDistancesBack[i].y < range)
        {
          fill(255, 0, 0);
          rect((int)(pos.x + detectedBlackPixelDistancesBack[i].y * listOfDetectionVectorsBack[i].x), (int)(pos.y + detectedBlackPixelDistancesBack[i].y * listOfDetectionVectorsBack[i].y), 5, 5); 
        }
      }
  }
  
  ///////////////////////
  // Update
  ///////////////////////
  
  void update()
  {
    // Choose the next move to do and return true if a decision has been made
    if (!isUserPlaying)
      isDead = isDead || !brain.update(detectedBlackPixelDistancesFront, detectedBlackPixelDistancesBack, carCircle);
    
    if (!isDead)
    {
      move();
      
      generateDetectionRays();
      
      obstacleDetection();
      
      checkpointDetection();
    }
  }
  
  ///////////////////////
  // Compute the movement
  ///////////////////////
  
  void move()
  {
    // Acceleration
    if (isUserPlaying)
    {
      if (user_acc == 0)
        acc = 0;
      else
        acc += user_acc * accUp;
    }
    else
    {
      if (brain.step < brain.accChoice.length)
      {
        if (brain.accChoice[brain.step] == 0)
        {
          acc = 0;
        }
        else
        {
          acc += brain.accChoice[brain.step] * accUp;
          if (brain.accChoice[brain.step] > 0)
            scoreMove+=2;
          else
            scoreMove-=2;
        }
      }
      else
        isDead = true;
    }
    
    // Norm of the velocity
    if (acc != 0)
    { 
      vel += acc;
      if (vel > vel_max) vel = vel_max;
      else if (vel < -vel_max) vel = -vel_max;
    }
    else
      vel = lerp(vel, 0, 0.2);
    
    // Angle
    if (isUserPlaying)
    {
      if (user_acc == 0)
      {
        if (abs(vel) > 1)
          angle += user_angle * angUp;
      }
      else
        angle += user_angle * angUp;
    }
    else
    {
      if (!isDead)
      {
        if (brain.accChoice[brain.step] == 0)
        {
          if (abs(vel) > 1)
            angle += brain.angChoice[brain.step] * angUp;
          else
            scoreMove--;
        }
        else
          angle += brain.angChoice[brain.step] * angUp;
          
        brain.step++;
      }
    }
    
    // Update of the position
    pos.x += vel * cos(angle);
    pos.y += vel * sin(angle);
  }
  
  ///////////////////////
  // Obstacle Detection
  ///////////////////////
  
  void initDetectedBlackPixelDistances()
  {
    // PVector.x = distanceK1, PVector.y = distance
    detectedBlackPixelDistancesFront  = new PVector[nbOfDetectionRays];
    detectedBlackPixelDistancesBack   = new PVector[nbOfDetectionRays];
    for (int i = 0; i < detectedBlackPixelDistancesFront.length; i++)
    {
      detectedBlackPixelDistancesFront[i] = new PVector(defaultDetectedValue, defaultDetectedValue);
      detectedBlackPixelDistancesBack[i]  = new PVector(defaultDetectedValue, defaultDetectedValue);
    }
  }
  
  void generateDetectionRays()
  {
    listOfDetectionVectorsFront = new PVector[nbOfDetectionRays];
    listOfDetectionVectorsBack = new PVector[nbOfDetectionRays];
    
    for (int i = 0; i < listOfDetectionVectorsFront.length; i++)
    {
      listOfDetectionVectorsFront[i] = new PVector(
        cos(PI/4 + i * (PI/2) / (nbOfDetectionRays - 1) + (PI/2) + angle),
        sin(PI/4 + i * (PI/2) / (nbOfDetectionRays - 1) + (PI/2) + angle));
      
      listOfDetectionVectorsBack[i] = new PVector(
        cos((PI/4 + i * (PI/2) / (nbOfDetectionRays - 1)) + (PI/2) + PI + angle),
        sin((PI/4 + i * (PI/2) / (nbOfDetectionRays - 1)) + (PI/2) + PI + angle));
    }
  }
  
  void obstacleDetection()
  {
    // Partie Avant
    for (int i = 0; i < listOfDetectionVectorsFront.length; i++)
    {
      //For element attribution in detectedBlackPixelDistances see constructor
      detectedBlackPixelDistancesFront[i].x = 777; 
      detectedBlackPixelDistancesFront[i].y = 777;          
      for (int j = 0; j < range + 1; j++)
      {
        pixelDetectedColor = circuit.get((int)(pos.x + j * listOfDetectionVectorsFront[i].x), (int)(pos.y + j * listOfDetectionVectorsFront[i].y));
        if (pixelDetectedColor == color(0))
        {
          detectedBlackPixelDistancesFront[i].y = j;
          if (detectedBlackPixelDistancesFront[i].y < detectedBlackPixelDistancesFront[i].x)
          {
            detectedBlackPixelDistancesFront[i].x = detectedBlackPixelDistancesFront[i].y;                        
          }
          if (detectedBlackPixelDistancesFront[i].y <= carCircle/2)
          {
             isDead = true;
             isDeadByObst = true;
          }
          break;
        }            
      }
    }
    
    //Partie Arriere
    for (int i = 0; i < listOfDetectionVectorsBack.length; i++)
    {
      detectedBlackPixelDistancesBack[i].x = 777;
      detectedBlackPixelDistancesBack[i].y = 777;
      for (int j = 0; j < range + 1; j++)
      {
        pixelDetectedColor = circuit.get((int)(pos.x + j * listOfDetectionVectorsBack[i].x), (int)(pos.y + j * listOfDetectionVectorsBack[i].y));
        if (pixelDetectedColor == color(0))
        {
          detectedBlackPixelDistancesBack[i].y = j;
          if (detectedBlackPixelDistancesBack[i].y < detectedBlackPixelDistancesBack[i].x)
          {
            detectedBlackPixelDistancesBack[i].x = detectedBlackPixelDistancesBack[i].y;                        
          }
          if (detectedBlackPixelDistancesBack[i].y <= carCircle/2)
          {
             isDead = true;
             isDeadByObst = true;
          }
          break;
        }
      }
    }
  }
  
  ///////////////////////
  // Reward Detection
  ///////////////////////
  
  void checkpointDetection()
  {
    // Always (2*i+1).x >= 2*i.x and (2*i+1).y >= 2*i.y
    for (int i = 0; i < checkpoints.display.length; i++)
    {
      if (checkpoints.display[i])
      {
        if (checkpoints.checkpoints[2*i].x == checkpoints.checkpoints[2*i + 1].x)
        {
          if (abs(checkpoints.checkpoints[2*i].x - pos.x) < carCircle / 2f)
            if (pos.y - carCircle / 2f > checkpoints.checkpoints[2*i].y && pos.y + carCircle / 2f < checkpoints.checkpoints[2*i+1].y)
            {
              checkpoints.display[i] = false;
              checkpoints.display[i == checkpoints.display.length - 1 ? 0 : i+1] = true;
              
              if (!isUserPlaying)
                checkpointSteps = (int[])append(checkpointSteps, brain.step);
            }
        }
        else if (checkpoints.checkpoints[2*i].y == checkpoints.checkpoints[2*i + 1].y)
        {
          if (abs(checkpoints.checkpoints[2*i].y - pos.y) < carCircle / 2f)
            if (pos.x - carCircle / 2f > checkpoints.checkpoints[2*i].x && pos.x + carCircle / 2f < checkpoints.checkpoints[2*i+1].x)
            {
              checkpoints.display[i] = false;
              checkpoints.display[i == checkpoints.display.length - 1 ? 0 : i+1] = true;
              
              if (!isUserPlaying)
                checkpointSteps = (int[])append(checkpointSteps, brain.step);
            }
        }
        
        break;
      }
    }
  }
  
  ///////////////////////
  // Clone
  ///////////////////////
  
  Car giveBirth()
  {
    Car newCar = new Car(sizeRect, brain.accChoice.length);
    
    newCar.brain = brain.giveBirth(nbOfDetectionRays);
      
    return newCar;
  }
}
