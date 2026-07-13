#include "fake_action.hpp"

int main(int argc, char ** argv)
{
  return run_fake_action(
    argc, argv, "fake_unseal_action", "unseal", std::chrono::milliseconds(100));
}
