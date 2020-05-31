#include <string>

class Utilz {
  private:
    static unsigned long int start;
  public:
    static void Seed(unsigned long int);
    static unsigned long int Start();
    static unsigned long int Stamp();
    static std::string GenPoint();
};
