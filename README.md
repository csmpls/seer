# Eye of Sauron 

![collablab logo](http://collablab.northwestern.edu/images/logo_horiz.png)

Given a group of people wearing neurosky headsets, Eye of Sauron sees who in the group is paying attention.

Grayed-out names are busy (focusing), names in white are available (not focusing).

![client screencap](http://cosmopol.is/sauron/client.png)

To test it out locally, first run the server application, then run the client application.

# Details
The client/server framework is a simple implementation of a multi-user BCI application. 

![server screencap](http://cosmopol.is/sauron/server.png)

More generally, it is a simple framework for building any sort of multi-user application in Processing, which is a useful thing to have lying around.

Eye of Sauron works with an arbitrary number of Neurosky headsets. Connects over a LAN or over the Internet.

For details on the focus detector, check [its repo here](https://github.com/csmpls/focus-detector).

## requirements
[Processing](http://processing.org)

[MindSet library](http://addi.tv/mindset/)

[ControlP5](http://www.sojamo.de/libraries/controlP5/)

[Minim](http://code.compartmental.net/tools/minim/) for sound effects
