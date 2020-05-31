#include <cstdlib>
#include <iostream>
#include <utility>
#include <string>
#include <cstring>

//boost
#include <boost/asio.hpp>
#include <boost/filesystem/fstream.hpp>

// My Utilities
#include "./../myLib/Utilz.hpp"

using namespace boost::filesystem;
using namespace boost::asio;
using boost::asio::ip::tcp;

const int max_length = 256;
const int out_buffer_size = 32768;

void streamDataIn(tcp::socket& sock, ofstream& dump) {
  char temp = '\0';
  char to_file[out_buffer_size];
  char data[max_length];
  data[max_length - 1] = '\0';
  int processing_num = 0;
  char *first = to_file;
  char *last = to_file;
  char *file_ptr = to_file;
  std::size_t length; 
  boost::system::error_code error;
  try {
    length = sock.receive(buffer(data, max_length - 1), NULL, error);
    if (error == error::eof) {
	sock.close();
        return; // Connection closed cleanly by peer.
    }  else if (error) {
        throw boost::system::system_error(error); // Some other error.
    }
    first = strchr(data, '\n');
    if (first != NULL) {
	*first = '\0';
	std::string s(data);
	std::cout << "TCP RX start : " << s << std::endl;
        Utilz::Seed(std::stod(s));
	*first = '\n';
    } else { 
      return;
    }
    last = first + 1;
    std::cout << "TO PROCESS\n";
    while(processing_num < 1000) {
      std::cout << "TOP of Process\n";
      first = strchr(last, '\n');
      // assume that we always get full lines in data
      while(first != NULL && first < data + max_length) {
	  std::cout << "Top of the search\n";
	  std::string stmp = std::to_string(Utilz::Stamp());
          std::string proc_num = std::to_string(processing_num);
          processing_num++;
	  std::size_t stmp_len = stmp.length();
	  std::size_t proc_num_len = proc_num.length();
std::cout << "ONE\n";
	  memcpy(file_ptr, stmp.c_str(), stmp_len);
	  file_ptr += stmp_len;
	  *file_ptr = ',';
	  file_ptr++;
	  *file_ptr = ' ';
	  file_ptr++;
std::cout << "TWO for : " << (file_ptr - to_file) << '\n';
	  memcpy(file_ptr, proc_num.c_str(), proc_num_len);
std::cout << "FAULT?\n";
	  file_ptr += proc_num_len;
          *file_ptr = ',';
	  file_ptr++;
	  *file_ptr = ' ';
	  file_ptr++;
std::cout << "THREE\n";
          memcpy(file_ptr, last, (first - last) + 1);
	  file_ptr += (first - last) + 1;

          //temp = *last;
          //*last = '\0';
          //std::string s(first);
          //std::cout << s;
          //*last = temp;

          last = first + 1;
	  if (last-data < max_length) {
	    std::cout << "NO BREAK\n";
	    first = strchr(last, '\n');
	  } else {
            std::cout << "Making a break for it !!!\n";
	    break;
	  }
	  std::cout << "BOTTOM OF SEARCH\n";
      }
      std::cout << "POP OUT of search\n";
      // grab new data
      first = data;
      last = data; 
      length = sock.receive(buffer(data, max_length), NULL, error);
      std::cout << "GRABING DATA\n";
      if (error == error::eof) { 
	std::cout << "HIT EOF" << std::flush;
	break;
      } else if (error) {
	std::cerr << "error while reading" << std::flush; 
        throw boost::system::system_error(error);  
      }
      std::cout << "out \n \n";
    }
    sock.close();
    *file_ptr = '\0';
    std::cout << "POW !!!" << std::flush;
    std::cout << "length should be : " << (file_ptr - to_file);
    std::string final_out(to_file);
    dump << final_out << std::flush;
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
    tcp::acceptor a(io_context, tcp::endpoint(tcp::v4(), port));
    // grab the connection (this is the blocking point)
    tcp::socket sock = a.accept();
    streamDataIn(sock, dump);
  } catch (std::exception& e) {
    std::cerr << "Exception while seting up connection : " << e.what() << "\n";
  }
  return 0;
}
