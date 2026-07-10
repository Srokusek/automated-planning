#include "fake_action.hpp"

int main(int argc, char ** argv)
{
  return run_fake_action(
    argc, argv, "fake_cool_action", "cool", std::chrono::seconds(2));
}
