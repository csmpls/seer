# Eye of Sauron 
Given a group of people wearing neurosky headsets, Eye of Sauron sees who in the group is paying attention.

Grayed-out names are busy (focusing), names in white are available (not focusing).

![client screencap](http://cosmopol.is/sauron/client.png)

To test it out locally, first run the server application, then run the client application.

# Details
The client/server framework is a simple implementation of multi-user BCI applications. 

![server screencap](http://cosmopol.is/sauron/server.png)

More abstractly, it is a simple framework for building any sort of multi-user application in Processing - a useful thing to have around in a collaborative software lab.

Eye of Sauron with an arbitrary number of Neurosky headsets. Connection can be over a LAN or over the Internet.

For convenience, all code is written in Processing.

## requirements
[Processing](http://processing.org)

[MindSet library](http://addi.tv/mindset/)

[ControlP5](http://www.sojamo.de/libraries/controlP5/)

[Minim](http://code.compartmental.net/tools/minim/) for sound effects