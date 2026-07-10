#include "fake_action.hpp"

int main(int argc, char ** argv)
{
  return run_fake_action(
    argc, argv, "fake_seal_action", "seal", std::chrono::milliseconds(0));
}
