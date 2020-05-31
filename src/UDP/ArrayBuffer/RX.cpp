#include <cstdlib>
#include <iostream>
#include <utility>
#include <string>

//boost
#include <boost/asio.hpp>
#include <boost/filesystem/fstream.hpp>

// My Utilities
#include "./../myLib/Utilz.hpp"

using namespace boost::filesystem;
using namespace boost::asio;
using boost::asio::ip::udp;

const int max_length = 256;

void streamDataIn(udp::socket& sock, ofstream& dump) {
  int processing_num = 0;
  char data[max_length];
  std::string step;
  std::string dumpStr;
  std::size_t first;
  std::size_t last;
  std::size_t length;
  boost::system::error_code error;
  try {
    length = sock.receive(buffer(data, max_length - 1), NULL, error);
    step.append(data, length);
    if (error == error::eof)
      return;
    else if (error)
      throw boost::system::system_error(error); // Some other error.
    first = step.find("\n");
    if (first != std::string::npos) {
      std::cout << "UDP RX start time : " << step.substr(0, first) << std::endl;
      Utilz::Seed(std::stod(step.substr(0,first)));
    } else {
      return;
    }
    last = first + 1;
    while (processing_num < 1000) {
      step.erase(0, last);
      first = 0;
      last = 0;
      length = sock.receive(buffer(data, max_length), NULL, error);
      step.append(data, length);
      if (error == error::eof)
        break;
      else if (error)
        throw boost::system::system_error(error);
      first = step.find("\n");
      while(first != std::string::npos) {
	  dumpStr.append(std::to_string(Utilz::Stamp()));
	  dumpStr.append(", "); 
	  dumpStr.append(std::to_string(processing_num++)); 
	  dumpStr.append(", ");
	  dumpStr.append(step.substr(last, (first - last) + 1));
	  last = first + 1;
	  first = step.find("\n", last);
      }
    }
    sock.close();
    dump << dumpStr << std::flush;
  } catch (std::exception& e) {
    std::cerr << "Exception while streaming in data : " << e.what() << "\n";
  }
}

int main(int argc, char* argv[]) {
  try {
    if (argc != 3) {
      std::cerr << "Usage: TCP_RX <port> <dump_file>\n";
      return 1;
    }
    // open file for writing
    path p{argv[2]};
    ofstream dump{p};
    // wait for a connection
    io_context io_context;
    unsigned short port = (unsigned short)std::strtoul(argv[1], NULL, 0);
    udp::socket sock(io_context, udp::endpoint(udp::v4(), port));
    char data[max_length];
    streamDataIn(sock, dump);
  } catch (std::exception& e) {
    std::cerr << "Exception while seting up connection : " << e.what() << "\n";
  }
  return 0;
}
