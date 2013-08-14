import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.io.*; 
import processing.serial.*; 
import mindset.*; 
import processing.net.*; 
import java.util.Iterator; 
import controlP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class client extends PApplet {


/*

//////////////////////////////////////////

          eye of sauron
          client
          (c) nick merrill 2013

//////////////////////////////////////////

*/









String server_ip = "127.0.0.1";

// Declare a client
Client client;
// A thread to send requests every so often
RequestThread requestThread;
// boolean to check if the server has accepted our handshake
boolean serverReceivedHandshake = false;

// String to hold the user's name
String name;
// Used to indicate a new message
float newMessageColor = 0;
// A String to hold whatever the server says
String messageFromServer = "";
String my_ip;

//Neurosky business
Neurosky neurosky = new Neurosky();
//on mac /dev/     on windows, COM#
String com_port = "/dev/tty.MindWave";

PFont f;
ControlP5 cp5; 

public void setup() {
  
  //graphics
  size(400,600);
  f = createFont("Arial*",16,true);

  //initialize neurosky
  neurosky.initialize(this, com_port, false);

  //connect to the server
  client = new Client(this,server_ip, 5204);
  // start a request thread
  requestThread = new RequestThread();
  requestThread.start();

  cp5 = new ControlP5(this);

  cp5.addTextfield("username")
     .setPosition(20,100)
     .setSize(200,40)
     .setFont(f)
     .setFocus(true)
     .setColor(color(220,220,220))
     ;
}


public void draw() {
  background(0);

  neurosky.update();
  
  // Display message from server
  fill(newMessageColor);
  textFont(f);
  textAlign(CENTER);

  // if the user's set her name but we still aren't connected to server,
  if (!serverReceivedHandshake && name !=null) 
    text("havent met server yet",width/2,140);

  else
    //draw list of all users
    text(messageFromServer,width/2,200);

  // Fade message from server to white
  newMessageColor = constrain(newMessageColor+1,0,255); 
  
  
  // If there is information available to read
  // (we know there is a message from the Server when there are greater than zero bytes available.)
  if (client.available() > 0) { 
    // Read it as a String
    messageFromServer = client.readString();
    //messages will either be server handshakes 
    // (in the format [ip]:[name] )
    // or lists of user data
    // (in the format list:name,data;name,data )
    String[] message = messageFromServer.split("[:]");

    //is this the packet telling us our IP, as the server sees it?
    //if our ip is null, we assume that the new ip being announced is ours
    if (message[0].equals("new") && my_ip == null) {
      my_ip = message[1];
    }
    // is this a handshake?
    if (message[0].equals(my_ip)) {
      //if so, we're all set.
      serverReceivedHandshake = true;
    }

    //this is where we collect everyone's user data
    // we might use this to show all connected users and what they're status is
    else if (message[0].equals("list")) {

      //user data stream comes in the format:
      //list:name,data;name,data
      String[] data = message[1].split(";");

      for (int i=0; i<data.length; i++) {
        // the first string in this array is the username
        // the second string in this array is that user's data
        String[] user = data[i].split(",");
      
       }

      //this is just for testing - seeing what the raw message stream is
      messageFromServer = message[1];
    }

    // Set brightness to 0 to commemorate a received message
    newMessageColor = 0;
  }
}


public void username(String theText) {
  // automatically receives results from controller input
  name = theText;
  cp5.get(Textfield.class,"username").remove();
}


public void sendUserHandshake() {
  //format for all messages to server: [ip]:[message]
  //handshake format is: [ip]:name,[name]
  String handshake = my_ip + ":name," + name;
  client.write(handshake); 
}




// --------------- !
// ----------------------- !a
// ---------------------------------!
// void sendUserData()
// --
// This is a template for function that sends
// neurosky data to the server.
// 
// We are concerned with privacy, security and lightweight client-server communication.
// Whenever possible, Neurosky data should be processed clientside.
//
// ---------------------------------!
// ----------------------- !
// --------------- !
public void sendUserData() {
  //format for all messages to server: [ip]:[message]
  //format for user data is: [ip]:data,[name]
  int userData = (int)neurosky.attn_pulse;
  String request = my_ip + ":data," + userData;
  println("sent my data over         " + request);
  client.write(request);
}


public void stop() {
  client.stop();
}






public class RequestThread extends Thread {

  private boolean running;

  public void RequestThread() {
    running = false;
  }

  public void start() {
    running = true;
    super.start();
  }

  public void run() {

    while (running) {
      if (my_ip != null) {
        if (!serverReceivedHandshake && name!=null) {
          sendUserHandshake();
          println("attempted handshake");
        } else {
          sendUserData();
        }
      }

      //wait for interval
      try { 
        sleep((long)(1000));
      } 
      catch (Exception e) {
      }
    }
  }
}
/*
NEUROSKY
whatup@cosmopol.is

los angeles august 2011

* * * / 

this class stores data from a neurosky mindset. 
it uses those data to calculate some in-house metrics:

float attn,
float med
  0-100 - e-sense attention/meditation score. 
  (these scores are produced by dark magic
  inside the neurosky API.)
  
float attn_pulse, 
float med_pulse
  0-100 - eased/smoothed version of attn
  and med. ideally, these values guard
  against the spikes we sometimes see
  in the the e-sense readings.
  
boolean is_meditating,
boolean is_attentive
  checks whether attn_pulse or med_pulse is > 75. 
  because the e-sense meters use ML, values are 
  relative to a user's past performance. we assume
  a user is meditating or attentive if the smoothed
  e-sense data reports a reading in or above the 
  75th percentile of past readings.
  
*/

public class Neurosky {
  PApplet parent;
  MindSet ns;
  
  String com_port;
  boolean god;
  
  float attn;
  float med;
  
  float attn_pulse;
  float med_pulse;
  
  boolean is_meditating = false;
  boolean is_attentive = false;
  
  //fuckwithables
   // float pulse_easing = .005; //adam bazih fan favorite
   // float pulse_easing = .25;  //looks like a fucking TV laboratory
    float pulse_easing = .1f; //works great with the enigma


  
  public void initialize(PApplet parent, String com_port, boolean god) {
    this.god = god;
    this.parent = parent;
    this.com_port = com_port;
    ns = new MindSet(parent);
    ns.connect(this.com_port);
  }
  
  public void update() {
  try {
    if (!god) {
      med = ns.data.meditation;
      attn = ns.data.attention;
    }
    set_attn_pulse();
    set_med_pulse();
  } catch( ArrayIndexOutOfBoundsException e ) {
      println("the neurosky stream stuttered"); 
      exit();
  }
  }
  
  public void set_attn_pulse() {
    attn_pulse += (attn - attn_pulse) * pulse_easing;
    attn_pulse = constrain(attn_pulse, 0.0f, 100.0f);
  }
  
  public void set_med_pulse() {
    med_pulse += (med - med_pulse) * pulse_easing;
    med_pulse = constrain(med_pulse, 0.0f, 100.0f);
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "client" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
