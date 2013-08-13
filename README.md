# many skies
Many Skies is a framework for creating multi-user applications with an arbitrary number of Neurosky EEG headsets. For the sake of fun and convenience, all code is written in Processing.

To test it out, first run the server application, then run the client application.

## requirements
[Processing](http://processing.org)

[MindSet library](http://addi.tv/mindset/)

## notes/best practices
We're concerned with privacy, security and with lightweight client/server communication. Whenever possible, process EEG data on the client-side. Preferably in the Neurosky class. Do not send more EEG information to the server than is absolutely necessary.
