;Header and description

(define (domain artifacts-2-5)

(:requirements :strips :typing :durative-actions)

(:types
robot artifact hall pod slot - object
alpha-artifact beta-artifact cryo-artifact - artifact
land-robot - robot
standard-robot heavy-transporter - land-robot
loading-drone - robot ;additional subtypes of a robot
)

(:predicates
(landrobotat ?r - land-robot ?h - hall)
(droneat ?d - loading-drone ?h - hall)

; Explicit resource locks.  An action removes the corresponding idle fact at
; start and restores it at end, giving the executor an unambiguous causal link
; between consecutive users of the same robot or drone.
(robot-idle ?r - land-robot)
(drone-idle ?d - loading-drone)

;keeping track of hall occupancy
(hallfree ?h - hall)

(artifactinpod ?a - artifact ?p - pod)
(podstored ?p - pod)
(podempty ?p - pod)
(available ?a - artifact)

(indestination ?a - artifact)

(iscryochamber ?h - hall)
(isstasislab ?h - hall)
(isalpha ?h - hall)
(isbeta ?h - hall)
(istunnel ?h - hall)
(adjacent ?from ?to - hall)

(coolingon ?r - land-robot)
(coolingoff ?r - land-robot)
(sealed ?r - land-robot)
(unsealed ?r - land-robot)

;two-state battery for loading drones
(batteryfull ?d - loading-drone)
(batteryempty ?d - loading-drone)
(dronepair ?d1 - loading-drone ?d2 - loading-drone)

;land robot slots
(slotof ?s - slot ?r - land-robot)
(slotpair ?r - land-robot ?s1 - slot ?s2 - slot)
(slotempty ?s - slot)
(artifactinslot ?a - artifact ?s - slot)
(podinslot ?p - pod ?s - slot)
)

;robot enters the sealed mode
(:durative-action seal
    :parameters (?r - land-robot)
    :duration (= ?duration 0.1)
    :condition (and
        (at start (robot-idle ?r))
        (at start (unsealed ?r))
    )
    :effect (and
        (at start (not (robot-idle ?r)))
        (at start (not (unsealed ?r)))
        (at end (sealed ?r))
        (at end (robot-idle ?r))
    )
)

;robot exits the sealed mode
(:durative-action unseal
    :parameters (?r - land-robot ?h - hall)
    :duration (= ?duration 0.1)
    :condition (and
        (at start (robot-idle ?r))
        (at start (sealed ?r))
        (at start (landrobotat ?r ?h))
    )
    :effect (and
        (at start (not (robot-idle ?r)))
        (at start (not (sealed ?r)))
        (at end (unsealed ?r))
        (at end (robot-idle ?r))
    )
)

(:durative-action cool
    :parameters (?r - land-robot)
    :duration (= ?duration 2)
    :condition (and
        (at start (robot-idle ?r))
        (at start (coolingoff ?r))
    )
    :effect (and
        (at start (not (robot-idle ?r)))
        (at start (not (coolingoff ?r)))
        (at end (coolingon ?r))
        (at end (robot-idle ?r))
    )
)

(:durative-action cool-off
    :parameters (?r - land-robot)
    :duration (= ?duration 0.1)
    :condition (and
        (at start (robot-idle ?r))
        (at start (coolingon ?r))
    )
    :effect (and
        (at start (not (robot-idle ?r)))
        (at start (not (coolingon ?r)))
        (at end (coolingoff ?r))
        (at end (robot-idle ?r))
    )
)

;take a pod from the storing location
(:durative-action take-pod
    :parameters (?r - land-robot ?p - pod ?s - slot ?h - hall)
    :duration (= ?duration 0.1)
    :condition (and
        (at start (robot-idle ?r))
        (at start (podstored ?p))
        (at start (landrobotat ?r ?h))
        (over all (landrobotat ?r ?h))
        (at start (istunnel ?h))
        (at start (slotof ?s ?r))
        (at start (slotempty ?s))
    )
    :effect (and
        (at start (not (robot-idle ?r)))
        (at start (not (podstored ?p)))
        (at start (not (slotempty ?s)))
        (at end (podinslot ?p ?s))
        (at end (robot-idle ?r))
    )
)

;return a pod to the storing location
(:durative-action return-pod
    :parameters (?r - land-robot ?p - pod ?s - slot ?h - hall)
    :duration (= ?duration 0.1)
    :condition (and
        (at start (robot-idle ?r))
        (at start (sealed ?r))
        (at start (podempty ?p))
        (at start (landrobotat ?r ?h))
        (over all (landrobotat ?r ?h))
        (at start (istunnel ?h))
        (at start (slotof ?s ?r))
        (at start (podinslot ?p ?s))
    )
    :effect (and
        (at start (not (robot-idle ?r)))
        (at end (podstored ?p))
        (at start (not (podinslot ?p ?s)))
        (at end (slotempty ?s))
        (at end (robot-idle ?r))
    )
)

;moving between halls requires land robots to be sealed
(:durative-action move-standard
    :parameters (?r - standard-robot ?from ?to - hall)
    :duration (= ?duration 2)
    :condition (and
        (at start (robot-idle ?r))
        (at start (sealed ?r))
        (over all (sealed ?r))
        (at start (landrobotat ?r ?from))
        (at start (adjacent ?from ?to))
        (at start (hallfree ?to))
    )
    :effect (and
        (at start (not (robot-idle ?r)))
        (at start (not (hallfree ?to)))
        (at start (not (landrobotat ?r ?from)))
        (at end (hallfree ?from))
        (at end (landrobotat ?r ?to))
        (at end (robot-idle ?r))
    )
)

(:durative-action move-heavy
    :parameters (?r - heavy-transporter ?from ?to - hall)
    :duration (= ?duration 3)
    :condition (and
        (at start (robot-idle ?r))
        (at start (sealed ?r))
        (over all (sealed ?r))
        (at start (landrobotat ?r ?from))
        (at start (adjacent ?from ?to))
        (at start (hallfree ?to))
    )
    :effect (and
        (at start (not (robot-idle ?r)))
        (at start (not (hallfree ?to)))
        (at start (not (landrobotat ?r ?from)))
        (at end (hallfree ?from))
        (at end (landrobotat ?r ?to))
        (at end (robot-idle ?r))
    )
)

(:durative-action move-drone
    :parameters (?d - loading-drone ?from ?to - hall)
    :duration (= ?duration 1)
    :condition (and
        (at start (drone-idle ?d))
        (at start (droneat ?d ?from))
        (at start (adjacent ?from ?to))
    )
    :effect (and
        (at start (not (drone-idle ?d)))
        (at start (not (droneat ?d ?from)))
        (at end (droneat ?d ?to))
        (at end (drone-idle ?d))
    )
)

;actions for land robot + drone
(:durative-action load-artifact-alpha
    :parameters (?r - land-robot ?d - loading-drone ?a - alpha-artifact ?h - hall ?s - slot)
    :duration (= ?duration 1)
    :condition (and
        (at start (robot-idle ?r))
        (at start (drone-idle ?d))
        (at start (landrobotat ?r ?h))
        (over all (landrobotat ?r ?h))
        (at start (droneat ?d ?h))
        (over all (droneat ?d ?h))
        (at start (isalpha ?h))
        (at start (available ?a))
        (over all (unsealed ?r))
        (over all (coolingon ?r))
        (at start (batteryfull ?d))
        (at start (slotof ?s ?r))
        (at start (slotempty ?s))
    )
    :effect (and
        (at start (not (robot-idle ?r)))
        (at start (not (drone-idle ?d)))
        (at start (not (slotempty ?s)))
        (at start (not (available ?a)))
        (at start (not (batteryfull ?d)))
        (at start (batteryempty ?d))
        (at end (artifactinslot ?a ?s))
        (at end (robot-idle ?r))
        (at end (drone-idle ?d))
    )
)

(:durative-action deposit-artifact-alpha
    :parameters (?r - land-robot ?d - loading-drone ?a - alpha-artifact ?h - hall ?s - slot)
    :duration (= ?duration 1)
    :condition (and
        (at start (robot-idle ?r))
        (at start (drone-idle ?d))
        (at start (landrobotat ?r ?h))
        (over all (landrobotat ?r ?h))
        (at start (droneat ?d ?h))
        (over all (droneat ?d ?h))
        (at start (artifactinslot ?a ?s))
        (at start (slotof ?s ?r))
        (at start (iscryochamber ?h))
        (over all (unsealed ?r))
        (at start (batteryfull ?d))
    )
    :effect (and
        (at start (not (robot-idle ?r)))
        (at start (not (drone-idle ?d)))
        (at start (not (artifactinslot ?a ?s)))
        (at start (not (batteryfull ?d)))
        (at start (batteryempty ?d))
        (at end (indestination ?a))
        (at end (slotempty ?s))
        (at end (robot-idle ?r))
        (at end (drone-idle ?d))
    )
)

(:durative-action load-artifact-beta
    :parameters (?r - land-robot ?d - loading-drone ?a - beta-artifact ?h - hall ?p - pod ?s - slot)
    :duration (= ?duration 1)
    :condition (and
        (at start (robot-idle ?r))
        (at start (drone-idle ?d))
        (at start (landrobotat ?r ?h))
        (over all (landrobotat ?r ?h))
        (at start (droneat ?d ?h))
        (over all (droneat ?d ?h))
        (at start (isbeta ?h))
        (at start (available ?a))
        (at start (podempty ?p))
        (at start (podinslot ?p ?s))
        (at start (slotof ?s ?r))
        (over all (unsealed ?r))
        (over all (coolingoff ?r))
        (at start (batteryfull ?d))
    )
    :effect (and
        (at start (not (robot-idle ?r)))
        (at start (not (drone-idle ?d)))
        (at start (not (available ?a)))
        (at start (not (podempty ?p)))
        (at start (not (batteryfull ?d)))
        (at start (batteryempty ?d))
        (at end (artifactinpod ?a ?p))
        (at end (artifactinslot ?a ?s))
        (at end (robot-idle ?r))
        (at end (drone-idle ?d))
    )
)

(:durative-action deposit-artifact-beta
    :parameters (?r - land-robot ?d - loading-drone ?a - beta-artifact ?h - hall ?p - pod ?s - slot)
    :duration (= ?duration 1)
    :condition (and
        (at start (robot-idle ?r))
        (at start (drone-idle ?d))
        (at start (landrobotat ?r ?h))
        (over all (landrobotat ?r ?h))
        (at start (droneat ?d ?h))
        (over all (droneat ?d ?h))
        (at start (artifactinpod ?a ?p))
        (at start (artifactinslot ?a ?s))
        (at start (podinslot ?p ?s))
        (at start (slotof ?s ?r))
        (at start (iscryochamber ?h))
        (over all (unsealed ?r))
        (at start (batteryfull ?d))
    )
    :effect (and
        (at start (not (robot-idle ?r)))
        (at start (not (drone-idle ?d)))
        (at start (not (artifactinpod ?a ?p)))
        (at start (not (artifactinslot ?a ?s)))
        (at start (not (batteryfull ?d)))
        (at start (batteryempty ?d))
        (at end (indestination ?a))
        (at end (podempty ?p))
        (at end (robot-idle ?r))
        (at end (drone-idle ?d))
    )
)

(:durative-action load-core-sample
    :parameters (?r - heavy-transporter ?d1 - loading-drone ?d2 - loading-drone ?a - cryo-artifact ?h - hall ?s1 - slot ?s2 - slot)
    :duration (= ?duration 2)
    :condition (and
        (at start (robot-idle ?r))
        (at start (drone-idle ?d1))
        (at start (drone-idle ?d2))
        (at start (landrobotat ?r ?h))
        (over all (landrobotat ?r ?h))
        (at start (droneat ?d1 ?h))
        (over all (droneat ?d1 ?h))
        (at start (droneat ?d2 ?h))
        (over all (droneat ?d2 ?h))
        (at start (iscryochamber ?h))
        (at start (available ?a))
        (over all (unsealed ?r))
        (over all (coolingon ?r))
        (at start (batteryfull ?d1))
        (at start (batteryfull ?d2))
        (at start (dronepair ?d1 ?d2))
        (at start (slotpair ?r ?s1 ?s2))
        (at start (slotof ?s1 ?r))
        (at start (slotof ?s2 ?r))
        (at start (slotempty ?s1))
        (at start (slotempty ?s2))
    )
    :effect (and
        (at start (not (robot-idle ?r)))
        (at start (not (drone-idle ?d1)))
        (at start (not (drone-idle ?d2)))
        (at start (not (slotempty ?s1)))
        (at start (not (slotempty ?s2)))
        (at start (not (available ?a)))
        (at start (not (batteryfull ?d1)))
        (at start (not (batteryfull ?d2)))
        (at start (batteryempty ?d1))
        (at start (batteryempty ?d2))
        (at end (artifactinslot ?a ?s1))
        (at end (artifactinslot ?a ?s2))
        (at end (robot-idle ?r))
        (at end (drone-idle ?d1))
        (at end (drone-idle ?d2))
    )
)

(:durative-action deposit-core-sample
    :parameters (?r - heavy-transporter ?d1 - loading-drone ?d2 - loading-drone ?a - cryo-artifact ?h - hall ?s1 - slot ?s2 - slot)
    :duration (= ?duration 2)
    :condition (and
        (at start (robot-idle ?r))
        (at start (drone-idle ?d1))
        (at start (drone-idle ?d2))
        (at start (landrobotat ?r ?h))
        (over all (landrobotat ?r ?h))
        (at start (droneat ?d1 ?h))
        (over all (droneat ?d1 ?h))
        (at start (droneat ?d2 ?h))
        (over all (droneat ?d2 ?h))
        (at start (isstasislab ?h))
        (over all (unsealed ?r))
        (over all (coolingon ?r))
        (at start (batteryfull ?d1))
        (at start (batteryfull ?d2))
        (at start (dronepair ?d1 ?d2))
        (at start (slotpair ?r ?s1 ?s2))
        (at start (slotof ?s1 ?r))
        (at start (slotof ?s2 ?r))
        (at start (artifactinslot ?a ?s1))
        (at start (artifactinslot ?a ?s2))
    )
    :effect (and
        (at start (not (robot-idle ?r)))
        (at start (not (drone-idle ?d1)))
        (at start (not (drone-idle ?d2)))
        (at start (not (artifactinslot ?a ?s1)))
        (at start (not (artifactinslot ?a ?s2)))
        (at start (not (batteryfull ?d1)))
        (at start (not (batteryfull ?d2)))
        (at start (batteryempty ?d1))
        (at start (batteryempty ?d2))
        (at end (slotempty ?s1))
        (at end (slotempty ?s2))
        (at end (indestination ?a))
        (at end (robot-idle ?r))
        (at end (drone-idle ?d1))
        (at end (drone-idle ?d2))
    )
)

(:durative-action charge-drone
    :parameters (?d - loading-drone ?h - hall)
    :duration (= ?duration 2)
    :condition (and
        (at start (drone-idle ?d))
        (at start (droneat ?d ?h))
        (over all (droneat ?d ?h))
        (at start (istunnel ?h))
        (at start (batteryempty ?d))
    )
    :effect (and
        (at start (not (drone-idle ?d)))
        (at start (not (batteryempty ?d)))
        (at end (batteryfull ?d))
        (at end (drone-idle ?d))
    )
)

)
