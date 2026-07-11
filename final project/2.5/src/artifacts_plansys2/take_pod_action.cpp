#include "fake_action.hpp"

int main(int argc, char ** argv)
{
  return run_fake_action(
    argc, argv, "fake_take_pod_action", "take-pod", std::chrono::milliseconds(100));
}
