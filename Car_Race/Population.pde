class Population
{
  Car[] cars;
  int gen = 1;
  
  Population(PVector sizeCar, int size, int incrementStart)
  {
    if (!isUserPlaying)
    {
      cars = new Car[size];
      for (int i = 0; i < size; i++)
      {
        cars[i] = new Car(sizeCar, incrementStart);
      }
    }
    else
      cars = new Car[0];
    bestCar = new Car(sizeCar, incrementStart);
    bestCar.isBest = true;
  }
  
  void show()
  {
    if (!isUserPlaying && !showOnlyBest)
      for (int i = 0; i < cars.length; i++)
      {
        cars[i].show();
      }
    bestCar.show();
  }
  
  void update()
  {
    for (int i = 0; i < cars.length; i++)
    {
        cars[i].update();
    }
    if (!bestCar.isDead)
    {
      bestCar.move();
      bestCar.generateDetectionRays();
      bestCar.obstacleDetection();
      bestCar.checkpointDetection();
    }
  }
  
  ///////////////////////
  // Fitness
  ///////////////////////
  
  void computeFitness()
  {
    for (int i = 0; i < cars.length; i++)
    {
      cars[i].computeFitness();
    }
  }
  
  private float computeFitnessSum()
  {
    float fitnessSum = 0;
    for (int i = 0; i < cars.length; i++)
    {
      fitnessSum += cars[i].fitness;
    }
    return fitnessSum;
  }
  
  ///////////////////////
  // Usefull methods
  ///////////////////////
  
  void setBestCar()
  {
    float max = 0;
    int maxIndex = 0;
    for (int i = 0; i < cars.length; i++)
    {
      if (cars[i].fitness > max)
      {
        max = cars[i].fitness;
        maxIndex = i;
      }
    }
    
    if (max > bestCar.fitness)
      bestCar = cars[maxIndex];
    bestCar.initBestCar();
  }
  
  boolean allCarsDead()
  {
    for (int i = 0; i < cars.length; i++)
    {
      if (!cars[i].isDead)
        return false;
    }
    return true;
  }
  
  ///////////////////////
  // Genetic Algorithm :
  //   - naturalSelection()
  //   - selectParent()
  //   - increaseMoves()
  ///////////////////////
  
  void naturalSelection()
  {
    setBestCar();
    println(bestCar.fitness);
    
    float fitnessSum = computeFitnessSum();
    
    Car[] newCars = new Car[cars.length];
    
    for (int i = 0; i < newCars.length; i++)
    {
      newCars[i] = selectParent(fitnessSum).giveBirth();
    }

    cars = newCars.clone();
    gen++;
  }
  
  Car selectParent(float fitnessSum)
  {
    float rand = random(fitnessSum);

    float runningSum = 0;
    for (int i = 0; i < cars.length; i++)
    {
      runningSum += cars[i].fitness;
      
      if (runningSum > rand)
        return cars[i];
    }

    // Should never be there
    return null;
  }
  
  public void increaseMoves(int inc)
  {
    for (int i = 0; i < cars.length; i++)
    {
      cars[i].brain.increaseMoves(inc);
    }
  }
}
