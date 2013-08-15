
/*

//////////////////////////////////////////

          eye of sauron
          server
          (c) nick merrill 2013

//////////////////////////////////////////

*/

// Import the net libraries
import processing.net.*;

// Declare a server
Server server;

// Keep track of connected clients
ArrayList<EEGUser> users;

// make a thread that occasionally broadcasts all users' states
BroadcastThread broadcastThread;

// Used to indicate a new message has arrived
float newMessageColor = 255;
PFont f;
String incomingMessage = "";


void setup() {
  size(400,200);
  f = createFont("Arial",9,true);
  
  // Create the Server on port 5204
  server = new Server(this, 5204);
  users = new ArrayList<EEGUser>(); 
  

  broadcastThread = new BroadcastThread();
  broadcastThread.start();

}

void draw() {
  background(newMessageColor);
  
  // newMessageColor fades to white over time
  newMessageColor = constrain(newMessageColor + 0.3,0,255);
  textFont(f);
  textAlign(CENTER);
  fill(255);

  if (newMessageColor>120 && newMessageColor < 200) {
    disconnectAllUsers();
  }
  
  // Print names or IPs of all connected users to the screen
  if (users.size() > 0) { 
    for (int i=0; i<users.size(); i++) {

      try {
     
        EEGUser u = users.get(i);
        String output = "";

        if (u.name == null)
          output += u.client.ip();
        else
          output += u.name();

        if (u.data() != -666)
          output += "......" + u.data;

        text(output,60,height/2+(20*i));

      } catch (Exception e) { /* if everyone's disconnected we'll just pass*/ }

    } 
  }

  //print the last raw server message we received
  text(incomingMessage, width/2,150);

  // If a client is available, we will find out
  // If there is no client, it will be"null"
  Client client = server.available();
  // We should only proceed if the client is not null
  if (client!= null) {
    
    // Receive the message
    // The message is read using readString().
    incomingMessage = client.readString(); 
    // The trim() function is used to remove the extra line break that comes in with the message.
    incomingMessage = incomingMessage.trim();
    
    // Print to Processing message window
    //println( "Client says:" + incomingMessage);

    //attempt to process the request
    try {
      process(incomingMessage);
    } catch (Exception e) {
      println("some problem reading the client message...");
    }

    // Reset newMessageColor to black
    newMessageColor = 0;
  }
}


void disconnectAllUsers() {
  for (int i = 0; i < users.size(); i++) {
    EEGUser u = (EEGUser)users.get(i);
    server.disconnect(u.client);  
  }
  users = new ArrayList<EEGUser>();
}

void process(String m) {

    // --------------- !
    // ----------------------- !
    // ---------------------------------!
    // processing user requests
    // --
    // This is a template for processing requests from the users.
    // 
    // The first bit is concerned with matching a client's IP 
    // to the server's internal represetnation of that user.
    //
    // The later bits are concerned with processing the user's
    // request and updating our representation of the user
    // appropriately, given whatever request the user sent.
    //
    // ---------------------------------!
    // ----------------------- !
    // --------------- !

    // PART 1. MATCHING IPs TO THE SERVER'S REPRESENTATION OF THE USER
    // messages from the client come in this format: [ip]:[type_of_request],[request]
    String[] message = m.split("[:]");
    //so, let's use the ip to find which client it refers to
    EEGUser u = flindUserByIP(message[0]);
    //now that we have the right user, 
    //we can interpret the request part of the message
    String[] request = message[1].split("[,]");
    
    // PART 2. HANDLING HANDSHAKES
    //if this is a name request (ie. a handshake),
    if (request[0].equals("name")) {
      // set the second part of this message gets assigned to that user
      u.setName(request[1]);
      //and we complete the handshake, allowing the user to begin transmitting data
      // template for this message is [ip]:ok 
      server.write(message[0] + ":ok\n");
    }
    
    // PART 3. HANDLING UPDATES ABOUT USER DATA
    if (request[0].equals("data")) {
      // set the second part of this message gets assigned to that user
      u.setData(Integer.parseInt(request[1]));
    }
}

// The serverEvent function is called whenever a new client connects.
void serverEvent(Server server, Client client) {
  incomingMessage = "A new client has connected: " + client.ip();
  server.write("new:" + client.ip());
  println(incomingMessage);

  //IMPT NOTE! we're making a new EEGUser with a processing.net.Client as its argument
  // inspect the EEGUser class for the deets.
  users.add(new EEGUser(client));  
}


// TODO: WHY ISN'T THIS CODE BEING REACHED?
// -
// ClientEvent message is generated when a client disconnects.
// we remove the disconnected user from the users arraylist.
void disconnectEvent(Client client) {
  println("someone disconnected: " + client.ip());
  EEGUser u = flindUserByIP(client.ip());
  boolean s = users.remove(u);
  println("was the user removed successfully?" + s);
}



EEGUser flindUserByIP(String ip) {

  if (users.size() > 0) { 
    
    for (int i=0; i<users.size(); i++) {
      EEGUser u = users.get(i);
      if (ip.equals(u.client.ip()))
        return u;
    }

  }

  return null;

}

String getUserDataList() {
  String list = "list:";

  for (int i=0; i<users.size(); i++) {
    EEGUser u = users.get(i);
    list += u.name + "," + u.data + ";"; 
  }

  return list;
}

public class EEGUser {
  Client client;
  private String name;
  int data;

  EEGUser(Client c) {
    client = c;
    name = null;
    data = -666;
  }

  String name() {
    return name;
  }

  int data() {
    return data;
  }

  void setName(String _name) {
    name = _name;
  }

  void setData(int _data) {
    data = _data;
  }
}



public class BroadcastThread extends Thread {

  private boolean running;

  void BroadcastThread() {
    running = false;
  }

  void start() {
    running = true;
    super.start();
  }

  void run() {
    while (running) {

      if (users.size()>0) {
        
        //  WE CANNOT EXECUTE THIS CODE IF WE JUST GOT "CLIENT GOT END OF STREAM."
        // USER MUST BE REMOVED FROM OUR ARRAYLIST AND THIS CODE CANNOT BE REACHED!
        //if (client.input !=null)
          //tell everyone about everyone's state
          server.write(getUserDataList());
        
      }

      try { 
        sleep((long)(1000));
      } 
      catch (Exception e) {
      }
    }
  }
}



