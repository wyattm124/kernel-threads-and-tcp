#include <chrono>
#include <time.h>
#include <string>
#include "Utilz.hpp"

unsigned long int Utilz::start;

// Times are in micro seconds
unsigned long int Utilz::Start() {
  using namespace std::chrono;
  std::srand(time(NULL));
  auto curr_time = system_clock::now();
  auto dur_in_seconds = duration<double>(curr_time.time_since_epoch());
  Utilz::start = static_cast<unsigned long int>(dur_in_seconds.count()*1000000);
  return Utilz::start;
}

void Utilz::Seed(unsigned long int s) {
  std::srand(time(NULL));
  Utilz::start = s;
}

unsigned long int Utilz::Stamp() {
  using namespace std::chrono;
  auto curr_time = system_clock::now();
  auto dur_in_seconds = duration<double>(curr_time.time_since_epoch());
  return static_cast<unsigned long int>(dur_in_seconds.count()*1000000 - Utilz::start);
}

std::string Utilz::GenPoint() {
  using namespace std;
  return to_string((rand() % 3) - 1) +
	  ", " + 
	  to_string((rand() % 3) - 1) +
	  "\n";
}
