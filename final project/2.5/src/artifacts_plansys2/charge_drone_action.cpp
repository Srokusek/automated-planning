#include "fake_action.hpp"

int main(int argc, char ** argv)
{
  return run_fake_action(
    argc, argv, "fake_charge_drone_action", "charge-drone", std::chrono::seconds(2));
}
