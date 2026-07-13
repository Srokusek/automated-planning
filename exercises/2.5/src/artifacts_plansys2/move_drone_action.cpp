#include "fake_action.hpp"

int main(int argc, char ** argv)
{
  return run_fake_action(
    argc, argv, "fake_move_drone_action", "move-drone", std::chrono::seconds(1));
}
