#include "fake_action.hpp"

int main(int argc, char ** argv)
{
  return run_fake_action(
    argc, argv, "fake_load_artifact_beta_action", "load-artifact-beta",
    std::chrono::seconds(1));
}
