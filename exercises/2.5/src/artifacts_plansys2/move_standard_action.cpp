#include "fake_action.hpp"

int main(int argc, char ** argv)
{
  return run_fake_action(
    argc, argv, "fake_move_standard_action", "move-standard", std::chrono::seconds(2));
}
