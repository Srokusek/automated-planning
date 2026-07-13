#include "fake_action.hpp"

int main(int argc, char ** argv)
{
  return run_fake_action(
    argc, argv, "fake_load_core_sample_action", "load-core-sample",
    std::chrono::seconds(2));
}
