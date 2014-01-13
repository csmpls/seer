# seer

![collablab logo](http://collablab.northwestern.edu/images/logo_horiz.png)

Given a group of people wearing neurosky headsets, Seer sees who in the group is paying attention to their work.

Grayed-out names are busy (focusing), names in white are available (not focusing).

![client screencap](http://cosmopol.is/sauron/client.png)

To test it out locally, first run the server application, then run the client application.

# Details
The client/server framework this is built on will allow you to build any multi-user BCI applicaton, and indeed sort of multi-user application in Processing.

![server screencap](http://cosmopol.is/sauron/server.png)

Seer works with an arbitrary number of Neurosky headsets. It connects over a LAN or over the Internet.

For details on the focus detector, check [its repo here](https://github.com/csmpls/focus-detector).

# Setup

1. Open & run server.pde

2. In client.pde, set

~~~
String server_ip = "";
~~~

to the server's IP. if you're just testing this locally (i.e. on the same computer), set server_ip to 127.0.0.1

3. In client.pde, take a look at this line:

~~~
String com_port = "/dev/tty.MindWave";
~~~
S
This is the default com port for the Neurosky MindWave on Mac or Linux. A different Neurosky model may have a different ending from .MindWave. On Windows, the path will be different - consult Google for com port path names in Windows.


## requirements
[Processing](http://processing.org)

[MindSet library](http://addi.tv/mindset/)
