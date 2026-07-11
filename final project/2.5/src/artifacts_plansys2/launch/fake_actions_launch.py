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

# Number of concurrent performer nodes to launch for each action executable.
# Action executables not listed here use one performer by default.
ACTION_PERFORMER_COUNTS = {
    'seal_action': 2,
    'unseal_action': 2,
    'cool_action': 2,
    'cool_off_action': 2,
    'move_drone_action': 2,
    'charge_drone_action': 2,
    'load_artifact_beta_action': 2,
    'deposit_artifact_beta_action': 2,
    'load_artifact_alpha_action': 2,
    'deposit_artifact_alpha_action': 2,
}


def generate_launch_description():
    performers = []

    for executable in ACTION_EXECUTABLES:
        performer_count = ACTION_PERFORMER_COUNTS.get(executable, 1)

        for replica_index in range(performer_count):
            node_name = (
                executable if replica_index == 0 else f'{executable}_{replica_index + 1}'
            )

            performers.append(
                Node(
                    package='artifacts_plansys2',
                    executable=executable,
                    name=node_name,
                    output='screen',
                )
            )

    return LaunchDescription(performers)
