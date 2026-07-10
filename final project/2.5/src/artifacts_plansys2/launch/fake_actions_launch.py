from launch import LaunchDescription
from launch_ros.actions import Node


ACTION_EXECUTABLES = [
    'seal_action',
    'unseal_action',
    'cool_action',
    'cool_off_action',
    'take_pod_action',
    'return_pod_action',
    'move_standard_action',
    'move_heavy_action',
    'move_drone_action',
    'load_artifact_alpha_action',
    'deposit_artifact_alpha_action',
    'load_artifact_beta_action',
    'deposit_artifact_beta_action',
    'load_core_sample_action',
    'deposit_core_sample_action',
    'charge_drone_action',
]


def generate_launch_description():
    performers = []

    for executable in ACTION_EXECUTABLES:
        performers.append(
            Node(
                package='artifacts_plansys2',
                executable=executable,
                name=executable,
                output='screen',
            )
        )

    return LaunchDescription(performers)
