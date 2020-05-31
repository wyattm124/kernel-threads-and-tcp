#include <cstdlib>
#include <cstring>
#include <iostream>
#include <utility>

// boost
#include <boost/asio.hpp>
#include <boost/filesystem/fstream.hpp>

// My Utilities
#include "./../../../libs/Utilz.hpp"

using namespace boost::filesystem;
using namespace boost::asio;
using boost::asio::ip::tcp;

const int max_length = 256;

void streamDataOut(tcp::socket& sock, ifstream& grab, ofstream& dump) {
  int processing_num = 0;
  std::string step;
  boost::system::error_code error;
  size_t length;
  try {
    while(getline(grab, step)){
      dump << Utilz::Stamp() << ", " << processing_num++ << ", " << step << "\n";
      write(sock, buffer(step + "\n", step.length() + 1));
    }
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
    tcp::socket sock(io_context); 
    tcp::resolver resolver(io_context);
    connect(sock, resolver.resolve(argv[1], argv[2]));
    // NEED THIS TO DISABLE THE NAGLE ALGORITHIM : 
    tcp::no_delay op(true);
    sock.set_option(op);

    // send the start time
    std::string temp;
    temp = temp + std::to_string(Utilz::Start()) + "\0" + '\n';
    std::cout << "TCP TX start time : " << temp << std::endl;
    write(sock, buffer(temp, temp.length()));

    // start the data stream loop
    streamDataOut(sock, grab, dump);

  } catch (std::exception& e) {
    std::cerr << "Exception while setting up connection : " << e.what() << "\n";
  }
  return 0;
}
