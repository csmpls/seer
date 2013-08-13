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
    float pulse_easing = .1; //works great with the enigma


  
  void initialize(PApplet parent, String com_port, boolean god) {
    this.god = god;
    this.parent = parent;
    this.com_port = com_port;
    ns = new MindSet(parent);
    ns.connect(this.com_port);
  }
  
  void update() {
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
  
  void set_attn_pulse() {
    attn_pulse += (attn - attn_pulse) * pulse_easing;
    attn_pulse = constrain(attn_pulse, 0.0, 100.0);
  }
  
  void set_med_pulse() {
    med_pulse += (med - med_pulse) * pulse_easing;
    med_pulse = constrain(med_pulse, 0.0, 100.0);
  }
}
