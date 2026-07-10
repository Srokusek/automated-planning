#include "fake_action.hpp"

int main(int argc, char ** argv)
{
  return run_fake_action(
    argc, argv, "fake_load_artifact_alpha_action", "load-artifact-alpha",
    std::chrono::seconds(1));
}
