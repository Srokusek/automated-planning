#include "fake_action.hpp"

int main(int argc, char ** argv)
{
  return run_fake_action(
    argc, argv, "fake_deposit_artifact_alpha_action", "deposit-artifact-alpha",
    std::chrono::seconds(1));
}
