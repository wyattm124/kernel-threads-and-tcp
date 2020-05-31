#include "Utilz.hpp"
#include <string>
#include <iostream>
#include <boost/filesystem/fstream.hpp>

int main (int argc, char *argv[]) {
  using namespace boost::filesystem;
  if(argc != 3) {
    std::cout << "usage : RandWalkGen <number of lines> <outputfile>" << std::endl;
    return 1;
  }
  int n;
  try {
    n = std::stoi(argv[1]);
  } catch (const std::invalid_argument& e) {
    std::cout << "invalid number of lines entered" << std::endl;
    return 1;
  }
  path p{argv[2]};
  ofstream dump{p};
  for(int i = 0; i < n; i++)
    dump << i << ", " << Utilz::GenPoint();
  dump << std::endl;
}
