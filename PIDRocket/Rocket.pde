class Rocket {
  float xPos = 0;
  float yPos = 0;

  float speedX = 0;
  float speedY = 0;

  float curAngle = 0;
  float angularVel = 0;
  float angularAccel = 0;

  float accelX = 0;
  float accelY = 0;

  float maxThrust = 230;
  float curThrust = 0;
  float mass = 1200;
  float engineAngle = 0;
  float thruster = 0;
  
  float legPos = 0;

  float L = 4;

  void update() {
    mass = mass - (curThrust / 2000);
    if (mass < 0) mass = 1;

    float forceY = ((curThrust* cos(curAngle) - ((10+mass) * (9.8/60))) / (10+mass)) ;
    float forceX = ((curThrust* sin(curAngle)) / (mass));
    float T = ((curThrust * sin(engineAngle)) / mass);
    T += -thruster * 0.05;
    T += (noise(frameCount) - .5) * 0.2;

    angularAccel = T / moi();
    angularVel += angularAccel;
    curAngle += angularVel;


    accelY = forceY;
    accelX = forceX;
    speedY += accelY;
    speedX += accelX;
    xPos += speedX;
    yPos += speedY;
    if (yPos - cos(curAngle) * 10 < 5) {
      yPos = (cos(curAngle) * 10) + 5;
      speedY = 0;
      speedX = 0;
    }
    //println("Force: " + force + " mass: " + mass + " xPos: " + xPos + " yPos: " + yPos + " throttle: " + curThrust + " accelY: " + accelY);
  }
  void throttle(float pos) {
    if (pos < 0) pos = 0;
    else if (pos > 100) pos = 100;
    curThrust = maxThrust * (pos/100.0);
    //println("updating thrust: " + curThrust);
  }
  float moi() {
    return (1/12.0) * (mass) * (L*L);
  }
}