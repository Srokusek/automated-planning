#include "fake_action.hpp"

int main(int argc, char ** argv)
{
  return run_fake_action(
    argc, argv, "fake_return_pod_action", "return-pod", std::chrono::milliseconds(0));
}
