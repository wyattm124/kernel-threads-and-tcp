# kernel-threads-and-tcp

## Purpose of the Experiment
The purpose of this experiment is to see how the operating system decides to schedual the kernel threads affects a high 
speed TCP data transfer. UDP does not require as much logic to be executed by the operating system, so it is also tested in
the experiment to see how a connection that requires minimal work on the operating system's part performs under similar
circumstances. To run the experiment for yourself, feel free to follow the setup. if you would also like to watch the transfer
happen under a packet analyzer, feel free to have a Wireshark capture running while you run ```MegaTest```.

## Looking at the Source Code
The source code for the TCP Transmitter (TX) is in ```/src/TCP/StringBuffer/``` and the UDP TX is in ```/src/UDP/StringBuffer/```. Similarly the TCP reciever (RX) is in ```/src/TCP/StringBuffer/``` and the UDP RX is in ```/src/UDP/StringBuffer/```. The ```ArrayBuffer``` and ```FileBuffer``` are experimental RXs and TXs that do not work properly and I did not get my results from them, but they where helpful in trying to figure out what was holding up the data transfer for my presentation.

## Setup
1) Change the variable BOOST_PATH in the Makefile to be the path to your copy of the Boost 1.71.0 library.
2) Build the Random Walk Generator by running ```make WalkGenBuild``` then make a random walk to use in the experiment by running ```GenWalk```.
3) Build the UDP and TCP recievers (RX) and transmitters (TX) by running ```make TCPBuild``` then  ```make UDPBuild```.
4) Run the experiment and create test data by running ```make MegaTest```.
5) You can view the processed data by openining and running ```processingScript.m``` within the ```tools``` directory. However, make sure to change on all 8 file imports the prefix ```~/Desktop/git_repos/KernelThreadsAndTCP/``` to the location of your local clone of the git repo.
6) The script should generate two windows for you, each containing multiple graphs.

## My Results
You can view the power point presentation (exported as a pdf) that explains my results and the design of the experiment under
```/presentation/Computer_Networks_in_the_Control_Loop.pdf```. This experiment was originally conducted to investigate how
robot control inputs that travel to a robot through a TCP connection could be effected by Kernel thread schedualing, and
ultimalty the control of a robot. Honestly I was able to shed some light on the subject, but this experiment would need to 
be analyzed with some tools that could really see what the kernel is doing to fully explain the data that this experiment generates.
