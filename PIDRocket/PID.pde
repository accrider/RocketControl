class PID {
  long lastTime;
  float Input, Output, Setpoint;
  float errSum, lastErr;
  float kp = 3;
  float ki = .01;
  float kd = 80;
  float maxI = 0;
  boolean maxPoint = false;
  float maxValue = 0;
  float minValue = 0;
  float[] val = new float[1080];

  float update(float Input) {
    float deltaT = frameCount - lastTime;
    float error = Setpoint - Input;
    errSum += (error * deltaT);
    //println(errSum);
    if (errSum > maxI) {
      errSum = maxI;
    } else if (errSum < -maxI) {
      errSum = -maxI;
    }
    float dErr = (error - lastErr) / deltaT;

    lastErr = error;
    lastTime = frameCount;
    float out = (float) (kp * error + ki * errSum + kd * dErr);
    if (out > maxValue && maxPoint) {
      out = maxValue;
    } else if (out < minValue && maxPoint) {
      out = minValue;
    }
    //println(out);
    return out;
  }
}