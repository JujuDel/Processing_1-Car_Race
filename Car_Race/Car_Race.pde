Population population;
Car bestCar, previousBestCar;
PImage circuit;

boolean isUserPlaying = false;
boolean showOnlyBest  = false;

int sizePopulation = 500;
int incrementStart = 100;
int incEvery       = 10; 
int incMovesBy     = 100;

PVector sizeCar = new PVector(50, 20);

float mutationRate = 0.15;
float accUp = 0.5, vel_max = 6;
float angUp = 0.125;

void setup()
{
  size(800, 800);
  
  previousBestCar = new Car();
  bestCar = new Car();
  
  population = new Population(sizeCar, sizePopulation, incrementStart);
  
  circuit = loadImage("whiteBack2.png");
}

void draw()
{
  background(255);
  image(circuit, 0, 0);
  
  String textChangePlayer = "Press 'P' to change the mode";
  String textRestart = "Press 'R' to restart";
  textSize(32);
  fill(0);
  text(textChangePlayer, 10, 560);
  text(textRestart, 10, 600);
  
  if (!isUserPlaying)
  {
    // Display messages
    String textPlayer = "Genetic incremental algorithm:";
    String textBest = "  Press SPACE to change the view";
    String textGen = "  Gen " + population.gen;
    String textStep = "  Number of moves allowed: " + (incrementStart + (int)((float)population.gen / incEvery) * incMovesBy);
    
    text(textPlayer, 10, 640);
    text(textBest, 10, 680);
    text(textGen, 10, 720);
    text(textStep, 10, 760);
  
    // A car dies if :
    //   - it crashed through an obstacle
    //   - it achieved his max amount of moves
    if (population.allCarsDead())
    {
      // Genetic Algorithm
      population.computeFitness(); //<>//
      population.naturalSelection(); //<>//
      
      if (population.gen % incEvery == 0)
      {
        if (previousBestCar.fitness < bestCar.fitness)
          population.increaseMoves(incMovesBy); //<>//
      }
    }
    else
    {
      population.update();
      population.show();
    }
  }
  else
  {
    // The user is Playing
    String textPlayer = "Use the arrows to move";
    text(textPlayer, 10, 680);
    
    population.update();
    population.show();
  }
}

///////////////////////
// Key Events
///////////////////////

void keyPressed()
{
  if (key == CODED)
  {
    if (isUserPlaying && !bestCar.isDead)
    {
      if (keyCode == UP || keyCode == DOWN)
        bestCar.user_acc = (keyCode == UP) ? -1 : 1;
      
      if ((keyCode == LEFT || keyCode == RIGHT))
        bestCar.user_angle = (keyCode == LEFT) ? -1 : 1;
    }
  }
  else
  {
    if (key == ' ')
      showOnlyBest = !showOnlyBest;
    else if (key == 'P'|| key == 'p')
    {
      isUserPlaying = !isUserPlaying;
      
      population = new Population(sizeCar, sizePopulation, incrementStart);
    }
    else if (key == 'R'|| key == 'r')
    {
      population = new Population(sizeCar, sizePopulation, incrementStart);
    }
  }
}

void keyReleased()
{
  if (isUserPlaying && (keyCode == UP || keyCode == DOWN))
    bestCar.user_acc = 0;
  
  if (isUserPlaying && (keyCode == LEFT || keyCode == RIGHT))
    bestCar.user_angle = 0;
}
