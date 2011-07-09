Title: Quadrotor Motors Are Alive!
Date:  2011-04-24 14:48:36
Id:    38b56

I found some time today to work on my quadrotor project some more. A few weeks ago I got one motor mounted and spinning, just using the RC receiver and trasmitter. Today, I mounted the motors and set up a little test program on the arduino to make them spin. Check it out:

<iframe title="YouTube video player" width="550" height="390" src="http://www.youtube.com/embed/TuMfhkaHe0w" frameborder="0" allowfullscreen></iframe>

Test program and more info after the fold.

--fold--

Among other things, this entailed soldering the speed controllers to the motors, mounting the motors, putting more headers on the arduino, and figuring out the basic wiring. Here's the test program:

    #include <Servo.h>
    
    #define ARMING_SPEED 900
    #define ZERO_SPEED 1300
    #define MAX_SPEED 1850
    
    Servo front;
    Servo right;
    Servo back;
    Servo left;
    
    void write_speed(int in_speed) {
      front.writeMicroseconds(in_speed);
      right.writeMicroseconds(in_speed);
      back.writeMicroseconds(in_speed);
      left.writeMicroseconds(in_speed);
    }
    
    void setup() {
      front.attach(10);
      right.attach(11);
      back.attach(12);
      left.attach(13);
      write_speed(ARMING_SPEED);
      delay(10000);
    }
      
    int speed = 0;
    void loop() {
      for(speed = ZERO_SPEED; speed < MAX_SPEED; speed++) {
        write_speed(speed);
        delay(20);
      }
      for(speed = MAX_SPEED; speed > ZERO_SPEED; speed--) {
        write_speed(speed);
        delay(20);
      }
    }

All this does is setup four instances of the built-in Servo object on four different pins. After attaching the servo objects to pins, it sets them all to `ARMING_SPEED`, which is really just a speed that the speed controllers recognize as the throttle being completely off. Then, it waits for 10 seconds and then starts sweeping from `ZERO_SPEED` (idle but running) to `MAX_SPEED` (could be up to 2000 but the propellers have a tendency to fall off at that speed). 

One note about these speeds. The way an RC receiver controls a servo is via PWM, "pulse width modification". The receiver sends out a train of pulses, each 2000 microseconds apart, to the servo. A width of 1000 indicates "full left", a width of 2000 indicates "full right", and 1500 "centered". A speed controller uses the same protocol, except it can't reverse direction and the range is a little bigger. 1300 is about idle, 2000 is full power, 900 is "safe". 

The next step is to get the frame together the rest of the way and mounting the electronics. Oh, and adding in the Wii Motion Plus and Nunchuck boards to get the six axis IMU running. That's for another day, though.