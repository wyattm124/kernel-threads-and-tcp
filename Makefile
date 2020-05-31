# put the path to your copy to the boost 1.71.0 library under this varaible
BOOST_PATH := /home/wyatt/Desktop/git_repos/BostonDynamicsTest/

INC_PATH := -I$(BOOST_PATH)boost_1_71_0
LINK_PATH := -L$(BOOST_PATH)boost_1_71_0/stage/lib
THREAD_FLAGS := -lboost_system -lboost_thread -lpthread
STACK_PROTECT := -fno-stack-protector
CUSTOM_LIBRARIES := ./libs/Utilz.hpp ./libs/Utilz.C
COMPILE_HELPER := $(CUSTOM_LIBRARIES) $(THREAD_FLAGS) $(STACK_PROTECT) $(LINK_PATH) $(INC_PATH)

R := mv R
T := mv T
TCPDat := ./data/TCP_tests/
UDPDat := ./data/UDP_tests/

TTB := TCP_TX_broken.csv
TRB := TCP_RX_broken.csv
TTF := TCP_TX_fixed.csv
TRF := TCP_RX_fixed.csv

UTB := UDP_TX_broken.csv
URB := UDP_RX_broken.csv
UTF := UDP_TX_fixed.csv
URF := UDP_RX_fixed.csv


RUN_TCP_RX := ./bin/TCP_RX 1031 R
RUN_TCP_TX := ./bin/TCP_TX 127.0.0.1 1031 ./data/walk_data/walk T
RUN_UDP_RX := ./bin/UDP_RX 1031 R 
RUN_UDP_TX := ./bin/UDP_TX 127.0.0.1 1031 ./data/walk_data/walk T

# need the 1ms delay so that things don't spiral out of control
# sudo tc qdisc replace dev lo root netem limit 100000 delay 1ms
# tc qdisc del dev eth1 root
FIX_NET := sudo tc qdisc del dev lo root
BREAK_NET := sudo tc qdisc replace dev lo root netem loss 5% limit 100000

MTCP_B:= $(R) $(TCPDat)$(TRB); $(T) $(TCPDat)$(TTB)
MTCP_F:= $(R) $(TCPDat)$(TRF); $(T) $(TCPDat)$(TTF)

MUDP_B:= $(R) $(UDPDat)$(URB); $(T) $(UDPDat)$(UTB)
MUDP_F:= $(R) $(UDPDat)$(URF); $(T) $(UDPDat)$(UTF)

MegaTest:
	@exec $(RUN_TCP_RX) &
	sleep 1s
	@$(RUN_TCP_TX)
	sleep 1s
	@$(MTCP_F)
	sleep 3s
	@exec $(RUN_UDP_RX) &
	sleep 1s
	@$(RUN_UDP_TX)
	sleep 1s
	@$(MUDP_F)
	sleep 3s
	@$(BREAK_NET)
	sleep 1s
	@exec $(RUN_TCP_RX) &
	sleep 1s
	@$(RUN_TCP_TX)
	sleep 1s
	@$(MTCP_B)
	sleep 3s
	@exec $(RUN_UDP_RX) &
	sleep 1s
	@$(RUN_UDP_TX)
	sleep 1s
	@$(MUDP_B)
	@$(FIX_NET)
	echo "Mega test complete\n"

cleanBin:
	rm ./bin/TCP_RX
	rm ./bin/TCP_TX
	rm ./bin/UDP_RX
	rm ./bin/UDP_TX
cleanData:
	rm $(TCPDat)$(TTB)
	rm $(TCPDat)$(TTF)
	rm $(TCPDat)$(TRB)
	rm $(TCPDat)$(TRF)
	rm $(UDPDat)$(UTB)
	rm $(UDPDat)$(UTF)
	rm $(UDPDat)$(URB)
	rm $(UDPDat)$(URF)
	echo "Test Data WIPED\n"

TCPBuild: ./libs/Utilz.hpp ./libs/Utilz.C
	g++ ./src/TCP/StringBuffer/RX.cpp $(COMPILE_HELPER) -o TCP_RX
	g++ ./src/TCP/StringBuffer/TX.cpp $(COMPILE_HELPER) -o TCP_TX
	mv TCP_RX ./bin/
	mv TCP_TX ./bin/

UDPBuild: ./libs/Utilz.hpp ./libs/Utilz.C 
	g++ ./src/UDP/StringBuffer/RX.cpp $(COMPILE_HELPER) -o UDP_RX
	g++ ./src/UDP/StringBuffer/TX.cpp $(COMPILE_HELPER) -o UDP_TX
	mv UDP_RX ./bin/
	mv UDP_TX ./bin/

WalkGenBuild: ./libs/RandWalkGen.cpp
	g++ ./libs/RandWalkGen.cpp $(COMPILE_HELPER) -o RandWalkGen
	mv RandWalkGen ./bin/

GenWalk:
	./bin/RandWalkGen 1100 walk
	mv walk ./data/walk_data

TCP_RX:
	$(RUN_TCP_RX)

TCP_TX:
	$(RUN_TCP_TX)

UDP_RX:
	$(RUN_UDP_RX)

UDP_TX:
	$(RUN_UDP_TX)

breakNet:
	#sudo tc qdisc change dev lo root netem delay 1ms 1ms
	$(BREAK_NET)

fixNet:
	$(FIX_NET)

showNet:
	sudo tc qdisc show dev lo

