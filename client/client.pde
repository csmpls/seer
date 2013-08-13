import java.io.*;
import processing.serial.*;
import mindset.*;
import processing.net.*;
import java.util.Iterator;
import controlP5.*;

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

//Neurosky business
Neurosky neurosky = new Neurosky();
//on mac /dev/     on windows, COM#
String com_port = "/dev/tty.MindWave";

PFont f;
ControlP5 cp5; 

void setup() {
  
  //graphics
  size(400,600);
  f = createFont("Arial*",16,true);

  //initialize neurosky
  neurosky.initialize(this, com_port, false);

  //connect to the server
  client = new Client(this,"127.0.0.1", 5204);
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


void draw() {
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

    // is this a handshake?
    if (message[0].equals(client.ip())) {
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


void sendUserHandshake() {
  //format for all messages to server: [ip]:[message]
  //handshake format is: [ip]:name,[name]
  String handshake = client.ip() + ":name," + name;
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
void sendUserData() {
  //format for all messages to server: [ip]:[message]
  //format for user data is: [ip]:data,[name]
  int userData = (int)neurosky.attn_pulse;
  String request = client.ip() + ":data," + userData;
  println("sent my data over         " + request);
  client.write(request);
}


void stop() {
  client.stop();
}






public class RequestThread extends Thread {

  private boolean running;

  void RequestThread() {
    running = false;
  }

  void start() {
    running = true;
    super.start();
  }

  void run() {

    while (running) { //
      if (!serverReceivedHandshake && name!=null) {
        sendUserHandshake();
        println("attempted handshake");
      } else {
        sendUserData();
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
