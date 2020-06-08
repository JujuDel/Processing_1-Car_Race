class Brain
{
  int step = 0;
  int[] accParent, angParent;
  int[] accChoice, angChoice;
  int currentDir;

  float[][] seuils, gainFront, gainBack;
  float sumFront, sumBack;
  float aIrand, learningRate;
  PVector[] aiOptDefault;

  PVector[][] aiOptimizedRandomRange;

  Brain()
  {
    accChoice = new int[0];
    angChoice = new int[0];
  }

  Brain(int size, int nbOfDetectionRays)
  {
    step = 0;
    
    accParent = new int[0];
    angParent = new int[0];    
    accChoice = new int[size];
    angChoice = new int[size];

    //AI control parameters
    currentDir   = 0;
    sumFront     = 0;
    sumBack      = 0;
    aIrand       = 0.5;
    learningRate = 0.125;
    
    aiOptDefault    = new PVector[4];
    aiOptDefault[0] = new PVector(0, 10);
    aiOptDefault[1] = new PVector(0, 10);
    aiOptDefault[2] = new PVector(0, 10);
    aiOptDefault[3] = new PVector(0, 5);
    aiOptimizedRandomRange = new PVector[size - previousBestCar.brain.accChoice.length][4];
    for (int i = 0; i < aiOptimizedRandomRange.length; i++)
    {
      aiOptimizedRandomRange[i] = aiOptDefault;
    }
    
    gainFront = new float[size - previousBestCar.brain.accChoice.length][nbOfDetectionRays];
    gainBack = new float[size - previousBestCar.brain.accChoice.length][nbOfDetectionRays];
    seuils = new float[size - previousBestCar.brain.accChoice.length][4];
    for (int i = 0; i < seuils.length; i++)
    {
      for (int j = 0; j < seuils[i].length; j++)
      {
        seuils[i][j] = random(aiOptDefault[j].x, aiOptDefault[j].y); //random definition of decision making tresholds
      }

      for (int j = 0; j < nbOfDetectionRays; j++)
      {
        gainFront[i][j] = gainBack[i][j] = 7;
      }
    }
  }

  void initBestBrain()
  {
    step = 0;
  }

  ///////////////////////
  // Update
  ///////////////////////

  // Choose the next move to do and return true if a decision has been made
  boolean update(PVector[] distFront, PVector[] distBack, int carSize)
  {
    if (step < previousBestCar.brain.accChoice.length)
    {
      accChoice[step] = previousBestCar.brain.accChoice[step];
      angChoice[step] = previousBestCar.brain.angChoice[step];
      return true;
    }
    else
    {
      if (step < accChoice.length)
      {
        float rand = random(1);
        if ( (step - previousBestCar.brain.angChoice.length < accParent.length) && (rand > mutationRate) )
        {
          // we just copy the father
          computeGains(distFront, distBack, carSize);
          accChoice[step] = accParent[step - previousBestCar.brain.angChoice.length];
          angChoice[step] = angParent[step - previousBestCar.brain.angChoice.length];
        }
        else
        {
          // We don't have the father's knowledge : we move on our own        
          computeGains(distFront, distBack, carSize);
          randomizeMargins();
          accChoice[step] = chooseDirection();
          angChoice[step] = chooseAngle();
        }
        return true;
      }
      else
        return false;
    }
  }

  ///////////////////////
  // Computes gains 
  ///////////////////////
  
  void computeGains(PVector[] distFront, PVector[] distBack, int carSize)
  {
    sumFront = 0;
    sumBack = 0;
    for (int i = 0; i < distFront.length; i++)
    {
      gainFront[step - previousBestCar.brain.angChoice.length][i] = log(distFront[i].y - carSize/2);
      gainBack[step - previousBestCar.brain.angChoice.length][i] = log(distBack[i].y - carSize/2);
      sumFront = sumFront + gainFront[step - previousBestCar.brain.angChoice.length][i];
      sumBack = sumBack + gainBack[step - previousBestCar.brain.angChoice.length][i];
    }
  }

  ///////////////////////
  // Current direction computation methods
  ///////////////////////

  int chooseDirection()
  {
    if (gainFront[step - previousBestCar.brain.angChoice.length][1] >= seuils[step - previousBestCar.brain.angChoice.length][1])
      currentDir = -1;
    else if (gainFront[step - previousBestCar.brain.angChoice.length][1] < seuils[step - previousBestCar.brain.angChoice.length][0] && sumBack > sumFront)
      currentDir = 1;
    else 
      currentDir = 0;
    
    return currentDir;
  }

  int chooseAngle()
  {
    if (currentDir == -1)
    {
      if (gainFront[step - previousBestCar.brain.angChoice.length][0] - gainFront[step - previousBestCar.brain.angChoice.length][2] >= seuils[step - previousBestCar.brain.angChoice.length][3])
        return -1;
      else if (gainFront[step - previousBestCar.brain.accChoice.length][0] - gainFront[step - previousBestCar.brain.angChoice.length][2] <= -seuils[step - previousBestCar.brain.angChoice.length][3])
        return 1;
      else 
        return 0;
    }
    else if (currentDir == 1)
    {
      if (gainBack[step - previousBestCar.brain.angChoice.length][0] - gainBack[step - previousBestCar.brain.angChoice.length][2] >= seuils[step - previousBestCar.brain.angChoice.length][3] )
        return -1;
      else if (gainBack[step - previousBestCar.brain.angChoice.length][0] - gainBack[step - previousBestCar.brain.angChoice.length][2] <= -seuils[step - previousBestCar.brain.angChoice.length][3] )
        return 1;
      else
        return 0;
    }
    else
    {
      if (sumFront >= sumBack)
      {
        if (gainFront[step - previousBestCar.brain.angChoice.length][2] <= seuils[step - previousBestCar.brain.angChoice.length][2] && gainFront[step - previousBestCar.brain.angChoice.length][2] < gainFront[step - previousBestCar.brain.angChoice.length][0])
          return -1;
        else if (gainFront[step - previousBestCar.brain.angChoice.length][0] <= seuils[step - previousBestCar.brain.angChoice.length][2] && gainFront[step - previousBestCar.brain.angChoice.length][2] > gainFront[step - previousBestCar.brain.angChoice.length][0])
          return 1;
        else
          return 0;
      }
      else
      {
        if (gainFront[step - previousBestCar.brain.angChoice.length][2] <= seuils[step - previousBestCar.brain.angChoice.length][2] && gainBack[step - previousBestCar.brain.angChoice.length][2] < gainBack[step - previousBestCar.brain.angChoice.length][0])
          return -1;
        else if (gainFront[step - previousBestCar.brain.angChoice.length][0] <= seuils[step - previousBestCar.brain.angChoice.length][2] && gainBack[step - previousBestCar.brain.angChoice.length][2] > gainBack[step - previousBestCar.brain.angChoice.length][0])
          return 1;
        else
          return 0;
      }
    }
  }

  ///////////////////////
  // Randomly alters decision making margins
  ///////////////////////

  void randomizeMargins()
  {
    for (int i = 0; i < aiOptimizedRandomRange[step - previousBestCar.brain.angChoice.length].length; i++)
    {
      aIrand = random(1);
      if (aIrand <= 0.5)
        aiOptimizedRandomRange[step - previousBestCar.brain.angChoice.length][i].x += learningRate;
      else
        aiOptimizedRandomRange[step - previousBestCar.brain.angChoice.length][i].x -= learningRate;

      aiOptimizedRandomRange[step - previousBestCar.brain.angChoice.length][i].x = max(0,
                                                                                      min(aiOptimizedRandomRange[step - previousBestCar.brain.angChoice.length][i].x,
                                                                                          aiOptimizedRandomRange[step - previousBestCar.brain.angChoice.length][i].y));

      aIrand = random(1);
      if (aIrand <= 0.5)
        aiOptimizedRandomRange[step - previousBestCar.brain.angChoice.length][i].y += learningRate;
      else
        aiOptimizedRandomRange[step - previousBestCar.brain.angChoice.length][i].y -= learningRate;

      aiOptimizedRandomRange[step - previousBestCar.brain.angChoice.length][i].y = min(7,
                                                                                      max(aiOptimizedRandomRange[step - previousBestCar.brain.angChoice.length][i].x,
                                                                                          aiOptimizedRandomRange[step - previousBestCar.brain.angChoice.length][i].y));
      
      seuils[step - previousBestCar.brain.angChoice.length][i] = random(aiOptimizedRandomRange[step - previousBestCar.brain.angChoice.length][i].x,
                                                                   aiOptimizedRandomRange[step - previousBestCar.brain.angChoice.length][i].y);
    }
  }

  ///////////////////////
  // Genetic Algorithm :
  //   - giveBirth()
  //   - increaseMoves()
  ///////////////////////

  Brain giveBirth(int nbOfDetectionRays)
  {
    Brain childBrain = new Brain(accChoice.length, nbOfDetectionRays);

    childBrain.accParent = new int[accChoice.length - previousBestCar.brain.angChoice.length];
    childBrain.angParent = new int[accChoice.length - previousBestCar.brain.angChoice.length];
    for (int i = previousBestCar.brain.angChoice.length; i < accChoice.length; i++)
    {
      childBrain.accParent[i - previousBestCar.brain.angChoice.length] = accChoice[i];
      childBrain.angParent[i - previousBestCar.brain.angChoice.length] = angChoice[i];
    }
    //
    childBrain.aiOptimizedRandomRange = aiOptimizedRandomRange;
    childBrain.seuils = seuils;
    //
    return childBrain;
  }

  void increaseMoves(int inc)
  {
    previousBestCar = bestCar;
    
    accParent = new int[0];
    angParent = new int[0];
    accChoice = new int[accChoice.length + inc];
    angChoice = new int[angChoice.length + inc];

    float[] newGain = new float[3];
    for (int j = 0; j < newGain.length; j++)
    {
      newGain[j] = 7;
    }

    aiOptimizedRandomRange = new PVector[inc][4];
    gainFront = new float[inc][3];
    gainBack = new float[inc][3];
    seuils = new float[inc][4];
    for (int i = 0; i < inc; i++)
    {
      aiOptimizedRandomRange[i] = aiOptDefault;

      float[] newSeuils = new float[4];
      for (int j = 0; j < newSeuils.length; j++)
      {
        newSeuils[j] = random(aiOptDefault[j].x, aiOptDefault[j].y); //random definition of decision making tresholds
      }
      seuils[i] = newSeuils;
      gainBack[i] = newGain;
      gainFront[i] = newGain;
    }
  }
}
