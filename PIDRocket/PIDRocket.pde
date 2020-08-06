Rocket r;
Barge b;
PID tPID;
PID vPID;
PID lPID;
PID aPID;


boolean landing = false;

void setup() {
  size(1080, 720);
  r = new Rocket();
  b = new Barge();
  r.yPos = 300;//random(400);
  r.xPos = random(-720/2, 720/2);
  r.curAngle = radians(2);

  lPID = new PID();

  lPID.lastTime = 2;
  lPID.Setpoint = -1;
  lPID.maxI = 100;
  lPID.kp = 40;
  lPID.ki = 1;
  lPID.kd = 50;
  lPID.maxPoint = true;
  lPID.maxValue = 100;
  lPID.minValue = 30;

  tPID = new PID();

  tPID.lastTime = 2;
  tPID.Setpoint = 400;
  tPID.maxPoint = true;
  tPID.maxValue = 100;
  tPID.minValue = 1;
  tPID.maxI = 2000;
  tPID.kp = 2;
  tPID.ki = .04;
  tPID.kd = 100;

  vPID = new PID();
  vPID.lastTime = 2;
  vPID.Setpoint = 0;
  vPID.kp = 300;
  vPID.kd = 8000;
  vPID.ki = .1;
  vPID.maxPoint = true;
  vPID.maxValue = 20;
  vPID.minValue = -20;
  vPID.maxI = 30;

  aPID = new PID();
  aPID.lastTime = 2;
  aPID.Setpoint = 0;
  aPID.kp = .06;
  aPID.ki = 0;
  aPID.kd = 8;
  aPID.maxPoint = true;
  aPID.maxValue = 4;
  aPID.minValue = -4;
  aPID.maxI = 20000;
  for (int i = 0; i < aPID.val.length; i++) {
    aPID.val[i] = Integer.MAX_VALUE;
    tPID.val[i] = Integer.MAX_VALUE;
  }
}
void draw() {

  float idealAngle = aPID.update(r.xPos);
  //vPID.Setpoint = idealAngle;
  vPID.Setpoint = radians(idealAngle);
  float a = radians(vPID.update(r.curAngle));
  //println(idealAngle);
  //r.curAngle = a;
  /*if (r.curAngle > radians(5)) {
   r.engineAngle = radians(-15);
   } else if (r.curAngle < radians(-5)) {
   r.engineAngle = radians(15);
   } else */
  if (degrees(a) > 7) {
    r.thruster = -2;
  } else if (degrees(a) < -7) {
    r.thruster = 2;
  } else {
    r.thruster = 0;
  }
  r.engineAngle = a;
  //println(a);

  if (!landing) {
    r.throttle(tPID.update(r.yPos));
    if (r.legPos > 0) {
      r.legPos -= .5;
    }
  } else {
    lPID.Setpoint = min(-(r.yPos / 400), -.1);
    float o = lPID.update(r.speedY);
    //println(o);
    r.throttle(o);

    // Show landing legs if close to ground
    if (r.yPos < 200) {
      if (r.legPos < 120) {
        r.legPos += 1;
      }
    } else {
      if (r.legPos > 0) {
        r.legPos -= 1;
      }
    }
  }
  for (int i = aPID.val.length-1; i > 0; i--) {
    aPID.val[i] = aPID.val[i-1];
    tPID.val[i] = tPID.val[i-1];
    vPID.val[i] = vPID.val[i-1];
  }
  aPID.val[0] = aPID.lastErr;
  tPID.val[0] = tPID.lastErr;
  vPID.val[0] = vPID.lastErr;
  background(255);

  stroke(220);
  line((width/2) - aPID.Setpoint, 0.0f, (width / 2) - aPID.Setpoint, (float) height);
  line(0, height - tPID.Setpoint, width, height - tPID.Setpoint);
  fill(0);
  stroke(0);
  pushMatrix();
  translate((width/4) * 3, (height/4) * 3);
  scale(.25);

  line(0, height/2, width, height/2);
  fill(0);
  for (int i = 0; i < vPID.val.length-1; i++) {
    if (vPID.val[i] != Integer.MAX_VALUE && vPID.val[i+1] != Integer.MAX_VALUE) {
      line(i, (vPID.val[i] * 100.0) + height/2, i+1, (vPID.val[i+1]*100.0) + height/2);
    }
  }
  popMatrix();
  pushMatrix();
  translate(0, (height/4) *3);
  scale(.25);
  fill(255, 0, 0);
  line(0, height/2, width, height/2);
  fill(0);
  for (int i = 0; i < tPID.val.length-1; i++) {
    if (tPID.val[i] != Integer.MAX_VALUE && tPID.val[i+1] != Integer.MAX_VALUE) {
      line(i, (tPID.val[i]) + height/2, i+1, (tPID.val[i+1]) + height/2);
    }
  }
  popMatrix();

  stroke(0);
  noFill();
  rect((width/4) * 3, (height/4)*3, width/4, height/4);
  rect(0, (height/4)*3, (width/4), height/4);
  float lineX = width - r.xPos - (width/2);
  float lineY = height-r.yPos;
  strokeWeight(4);
  // Draw Rocket Body
  line(lineX+sin(r.curAngle)*10, lineY+cos(r.curAngle)*10, lineX-sin(r.curAngle)*10, lineY-cos(r.curAngle)*10);
  if (r.legPos > 0) {
    strokeWeight(1);
    line(lineX+sin(r.curAngle)*10, lineY+cos(r.curAngle)*10, (lineX+sin(r.curAngle)*10)-(sin(radians(-r.legPos))*10), (lineY+cos(r.curAngle)*10)-(cos(radians(-r.legPos))*10));
    line(lineX+sin(r.curAngle)*10, lineY+cos(r.curAngle)*10, (lineX+sin(r.curAngle)*10)+(sin(radians(-r.legPos))*10), (lineY+cos(r.curAngle)*10)-(cos(radians(-r.legPos))*10));
  }
  stroke(255, 0, 0);
  strokeWeight(1);
  if (r.thruster <= -1) {
    float x = lineX - sin(r.curAngle) * 10;
    float y = lineY - cos(r.curAngle) * 10;
    line(x, y, x - sin(r.curAngle - radians(90)) * 10, y + cos(r.curAngle + radians(90)) * 10);
  }
  if (r.thruster >= 1) {
    float x = lineX - sin(r.curAngle) * 10;
    float y = lineY - cos(r.curAngle) * 10;
    line(x, y, x - sin(r.curAngle + radians(90)) * 10, y - cos(r.curAngle + radians(90)) * 10);
  }


  float endX = lineX+sin(r.curAngle)*10;
  float endY = lineY+cos(r.curAngle)*10;
  strokeWeight(1);
  float eLength = (r.curThrust / 10) + random(2);
  // Draw engine thrust exhast
  line(endX, endY, endX + sin(r.engineAngle - r.curAngle + radians(180))*eLength*1.2, endY - cos(r.engineAngle - r.curAngle + radians(180))*eLength*1.2); 
  line(endX, endY, endX + sin(r.engineAngle - r.curAngle + radians(180-5))*eLength, endY - cos(r.engineAngle - r.curAngle + radians(180-5))*eLength); 
  line(endX, endY, endX + sin(r.engineAngle - r.curAngle + radians(180+5))*eLength, endY - cos(r.engineAngle - r.curAngle + radians(180+5))*eLength); 

  float bargeX = width-b.xPos - (width/2);
  float bargeY = height-b.yPos;
  line(bargeX-20, bargeY-2, bargeX+20, bargeY-2);
  strokeWeight(1);
  textAlign(LEFT);
  text("accelY: " + r.accelY * frameRate, 10, 20);
  text("mass: " + r.mass, 10, 80);
  text("thrust: " + r.curThrust, 10, 60);
  text("accelX: " + r.accelX, 10, 40);
  text("speedY: " + r.speedY, 10, 120);
  text("yPos: " + r.yPos, 10, 160);
  text("xPos: " + r.xPos, 10, 140);
  text("fps: " + frameRate, 10, 180);

  text("errSum: " + vPID.errSum, 10, 240);
  text("error: " + vPID.lastErr, 10, 260);
  text("Setpoint: " + vPID.Setpoint, 10, 280);
  text("angle: " + degrees(r.curAngle), 10, 300);
  text("eAngle: " + degrees(r.engineAngle), 10, 320);
  text("framecount: " + frameCount, 10, 340);
  textAlign(CENTER);
  text("Status: " + (landing ? "Landing" : "Hovering"), width/2, 50);

  r.update();
}



void keyPressed() {
  println(keyCode);
  switch(keyCode) {
  case 38:
    r.throttle(40);
    break;
  case 39:
    r.curAngle -= radians(2);
    break;
  case 37:
    r.curAngle += radians(2);
    break;
  case 76:
    aPID.Setpoint = 0;
    //tPID.Setpoint = 0;
    landing = true;
  }
}
void keyReleased() {
  println(keyCode);
  switch(keyCode) {
  case 38:
    r.throttle(0);
    break;
  }
}
void mousePressed() {
  println(mouseY);
  aPID.Setpoint = (width /2) - mouseX;
  tPID.Setpoint = height - mouseY;
  landing = false;
}