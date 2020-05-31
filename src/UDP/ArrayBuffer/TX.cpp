
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <utility>

// boost
#include <boost/asio.hpp>
#include <boost/filesystem/fstream.hpp>

// My Utilities
#include "./../myLib/Utilz.hpp"

using namespace boost::filesystem;
using namespace boost::asio;
using boost::asio::ip::udp;

const int max_length = 256;

void streamDataOut(udp::socket& sock, 
		   udp::resolver::results_type& endpt, 
		   ifstream& grab, 
		   ofstream& dump) {
  int processing_num = 0;
  std::string step;
  boost::system::error_code error;
  size_t length;
  try {
    while(getline(grab, step)){
      dump << Utilz::Stamp() << ", " << processing_num++ << ", " << step << "\n";
      sock.send_to(buffer((step + "\n"), (step.length() + 1)), *endpt.begin());
    }
    std::cout << "DONE\n" << std::endl;
  } catch (std::exception& e) {
    std::cerr << "Exception while streaming data out : " << e.what() << "\n";
  }
}

int main(int argc, char* argv[]) {
  try {
    if (argc != 5) {
      std::cerr << "Usage: TCP_TX <host> <port> <data_file <dump_file>\n";
      return 1;
    }
    // Open the in/out files
    path p1{argv[3]};
    path p2{argv[4]};
    ifstream grab{p1};
    ofstream dump{p2};

    // Connect, and send the start time
    io_context io_context;
    udp::socket sock(io_context, udp::endpoint(udp::v4(), 0));
    udp::resolver resolver(io_context);
    udp::resolver::results_type endpoints =
      resolver.resolve(udp::v4(), argv[1], argv[2]);

    // send the start time
    std::string temp;
    temp = temp + std::to_string(Utilz::Start()) + "\0" + '\n';
    std::cout << "UDP TX start time : " << temp << std::endl;
    sock.send_to(buffer(temp, temp.length()), *endpoints.begin());

    // start the data stream loop
    streamDataOut(sock, endpoints, grab, dump);

  } catch (std::exception& e) {
    std::cerr << "Exception while setting up connection : " << e.what() << "\n";
  }
  return 0;
}
