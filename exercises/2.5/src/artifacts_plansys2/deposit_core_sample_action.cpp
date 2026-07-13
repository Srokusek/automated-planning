#include "fake_action.hpp"

int main(int argc, char ** argv)
{
  return run_fake_action(
    argc, argv, "fake_deposit_core_sample_action", "deposit-core-sample",
    std::chrono::seconds(2));
}
