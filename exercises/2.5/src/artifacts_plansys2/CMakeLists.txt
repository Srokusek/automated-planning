cmake_minimum_required(VERSION 3.8)
project(artifacts_plansys2)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# find dependencies
find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(rclcpp_lifecycle REQUIRED)
find_package(lifecycle_msgs REQUIRED)
find_package(plansys2_executor REQUIRED)

set(ACTION_EXECUTABLES
  seal_action
  unseal_action
  cool_action
  cool_off_action
  take_pod_action
  return_pod_action
  move_standard_action
  move_heavy_action
  move_drone_action
  load_artifact_alpha_action
  deposit_artifact_alpha_action
  load_artifact_beta_action
  deposit_artifact_beta_action
  load_core_sample_action
  deposit_core_sample_action
  charge_drone_action
)

foreach(action_executable IN LISTS ACTION_EXECUTABLES)
  add_executable(${action_executable} ${action_executable}.cpp)

  ament_target_dependencies(${action_executable}
    rclcpp
    lifecycle_msgs
    plansys2_executor
  )
endforeach()

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  # the following line skips the linter which checks for copyrights
  # comment the line when a copyright and license is added to all source files
  set(ament_cmake_copyright_FOUND TRUE)
  # the following line skips cpplint (only works in a git repo)
  # comment the line when this package is in a git repo and when
  # a copyright and license is added to all source files
  set(ament_cmake_cpplint_FOUND TRUE)
  ament_lint_auto_find_test_dependencies()
endif()

install(TARGETS
  ${ACTION_EXECUTABLES}
  DESTINATION lib/${PROJECT_NAME}
)

install(DIRECTORY
  pddl
  launch
  DESTINATION share/${PROJECT_NAME}
)

ament_package()
