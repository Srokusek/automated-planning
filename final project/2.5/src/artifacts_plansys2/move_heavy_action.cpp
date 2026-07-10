#include "fake_action.hpp"

int main(int argc, char ** argv)
{
  return run_fake_action(
    argc, argv, "fake_move_heavy_action", "move-heavy", std::chrono::seconds(3));
}
