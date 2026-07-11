#ifndef ARTIFACTS_PLANSYS2__FAKE_ACTION_HPP_
#define ARTIFACTS_PLANSYS2__FAKE_ACTION_HPP_

#include <algorithm>
#include <chrono>

#include "lifecycle_msgs/msg/transition.hpp"
#include "plansys2_executor/ActionExecutorClient.hpp"
#include "rclcpp/rclcpp.hpp"

class FakeAction : public plansys2::ActionExecutorClient
{
public:
  explicit FakeAction(
    const char * node_name,
    std::chrono::milliseconds duration)
  : plansys2::ActionExecutorClient(node_name, std::chrono::milliseconds(10)),
    duration_(duration)
  {
  }

protected:
  void do_work() override
  {
    if (duration_.count() <= 0) {
      finish(true, 1.0F, "Fake action completed");
      return;
    }

    const auto elapsed = this->now() - get_start_time();
    const auto elapsed_seconds = std::max(0.0, elapsed.seconds());
    const auto duration_seconds =
      std::chrono::duration<double>(duration_).count();
    const auto completion = static_cast<float>(
      std::clamp(elapsed_seconds / duration_seconds, 0.0, 1.0));

    if (completion >= 1.0F) {
      finish(true, 1.0F, "Fake action completed");
    } else {
      send_feedback(completion, "Fake action in progress");
    }
  }

private:
  std::chrono::milliseconds duration_;
};

inline int run_fake_action(
  int argc,
  char ** argv,
  const char * node_name,
  const char * action_name,
  std::chrono::milliseconds duration)
{
  rclcpp::init(argc, argv);

  auto node = std::make_shared<FakeAction>(node_name, duration);
  node->set_parameter(rclcpp::Parameter("action_name", action_name));
  node->trigger_transition(
    lifecycle_msgs::msg::Transition::TRANSITION_CONFIGURE);

  rclcpp::spin(node->get_node_base_interface());

  rclcpp::shutdown();
  return 0;
}

#endif  // ARTIFACTS_PLANSYS2__FAKE_ACTION_HPP_
