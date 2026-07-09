;Header and description

(define (domain artifacts-2-4-tunnel-hall)

(:requirements :strips :typing :durative-actions)

(:types
robot artifact hall pod
alpha-artifact beta-artifact cryo-artifact - artifact
land-robot - robot
standard-robot heavy-transporter - land-robot
loading-drone - robot ;additional subtypes of a robot
)

(:predicates
(at ?r - robot ?h - hall)

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
(empty ?r - land-robot)
(carrying ?r - land-robot ?a - artifact)
(haspod ?r - standard-robot ?p - pod)

;two-state battery for loading drones
(batteryfull ?d - loading-drone)
(batteryempty ?d - loading-drone)
(dronepair ?d1 - loading-drone ?d2 - loading-drone)
)

;robot enters the sealed mode
(:action seal
    :parameters (?r - land-robot)
    :precondition (and 
        (unsealed ?r)
    )
    :effect (and 
        (not (unsealed ?r))
        (sealed ?r)
    )
)

;robot exits the sealed mode
(:action unseal
    :parameters (?r - land-robot ?h - hall)
    :precondition (and 
        (sealed ?r)
        (at ?r ?h)
    )
    :effect (and
        (not (sealed ?r))
        (unsealed ?r)
    )
)

(:durative-action cool
    :parameters (?r - land-robot)
    :duration (and (= ?duration 2))
    :condition (and 
        (at start (coolingoff ?r))
    )
    :effect (and 
        (at start (not (coolingoff ?r)))
        (at end (coolingon ?r))
    )
)

(:action cool-off
    :parameters (?r - land-robot)
    :precondition (and 
        (coolingon ?r)
    )
    :effect (and 
        (not (coolingon ?r))
        (coolingoff ?r)
    )
)

;take a pod from the storing location
(:action take-pod
    :parameters (?r - standard-robot ?p - pod ?h - hall)
    :precondition (and 
        (podstored ?p)
        (at ?r ?h)
        (istunnel ?h)
        (empty ?r)
    )
    :effect (and 
        (not (podstored ?p))
        (not (empty ?r))
        (haspod ?r ?p)
    )
)

;return a pod to the storing location
(:action return-pod
    :parameters (?r - standard-robot ?p - pod ?h - hall)
    :precondition (and 
        (sealed ?r)
        (podempty ?p)
        (at ?r ?h)
        (istunnel ?h)
        (haspod ?r ?p)
    )
    :effect (and 
        (podstored ?p)
        (not (haspod ?r ?p))
        (empty ?r)
    )
)

;moving between halls requires land robots to be sealed
(:durative-action move-standard
    :parameters (?r - standard-robot ?from ?to - hall)
    :duration (and (= ?duration 2))
    :condition (and 
        (at start (sealed ?r))
        (over all (sealed ?r))
        (at start (at ?r ?from))
        (over all (at ?r ?from))
        (at start (adjacent ?from ?to))
        (at start (hallfree ?to))
    )
    :effect (and 
        (at start (not (hallfree ?to)))
        (at end (not (at ?r ?from)))
        (at end (hallfree ?from))
        (at end (at ?r ?to))
    )
)

(:durative-action move-heavy
    :parameters (?r - heavy-transporter ?from ?to - hall)
    :duration (and (= ?duration 3))
    :condition (and 
        (at start (sealed ?r))
        (over all (sealed ?r))
        (at start (at ?r ?from))
        (over all (at ?r ?from))
        (at start (adjacent ?from ?to))
        (at start (hallfree ?to))
    )
    :effect (and 
        (at start (not (hallfree ?to)))
        (at end (not (at ?r ?from)))
        (at end (hallfree ?from))
        (at end (at ?r ?to))
    )
)

(:durative-action move-drone
    :parameters (?d - loading-drone ?from ?to - hall)
    :duration (and (= ?duration 1))
    :condition (and 
        (at start (at ?d ?from))
        (over all (at ?d ?from))
        (at start (adjacent ?from ?to))
    )
    :effect (and 
        (at end (not (at ?d ?from)))
        (at end (at ?d ?to))
    )
)

;actions for land robot + drone
(:durative-action load-artifact-alpha
    :parameters (?r - standard-robot ?d - loading-drone ?a - alpha-artifact ?h - hall)
    :duration (and (= ?duration 1))
    :condition (and 
        (at start (at ?r ?h))
        (over all (at ?r ?h))
        (at start (at ?d ?h))
        (over all (at ?d ?h))
        (at start (isalpha ?h))
        (at start (available ?a))
        (over all (unsealed ?r))
        (over all (coolingon ?r))
        (at start (batteryfull ?d))
        (at start (empty ?r))
    )
    :effect (and 
        (at start (not (empty ?r)))
        (at start (not (available ?a)))
        (at start (not (batteryfull ?d)))
        (at start (batteryempty ?d))
        (at end (carrying ?r ?a))
    )
)

(:durative-action deposit-artifact-alpha
    :parameters (?r - standard-robot ?d - loading-drone ?a - alpha-artifact ?h - hall)
    :duration (and (= ?duration 1))
    :condition (and 
        (at start (at ?r ?h))
        (over all (at ?r ?h))
        (at start (at ?d ?h))
        (over all (at ?d ?h))
        (at start (carrying ?r ?a))
        (at start (iscryochamber ?h))
        (over all (unsealed ?r))
        (at start (batteryfull ?d))
    )
    :effect (and 
        (at start (not (carrying ?r ?a)))
        (at start (not (batteryfull ?d)))
        (at start (batteryempty ?d))
        (at end (indestination ?a))
        (at end (empty ?r))
    )
)

(:durative-action load-artifact-beta
    :parameters (?r - standard-robot ?d - loading-drone ?a - beta-artifact ?h - hall ?p - pod)
    :duration (and (= ?duration 1))
    :condition (and 
        (at start (at ?r ?h))
        (over all (at ?r ?h))
        (at start (at ?d ?h))
        (over all (at ?d ?h))
        (at start (isbeta ?h))
        (at start (available ?a))
        (at start (podempty ?p))
        (at start (haspod ?r ?p))
        (over all (unsealed ?r))
        (over all (coolingoff ?r))
        (at start (batteryfull ?d))
    )
    :effect (and 
        (at start (not (available ?a)))
        (at start (not (podempty ?p)))
        (at start (not (batteryfull ?d)))
        (at start (batteryempty ?d))
        (at end (artifactinpod ?a ?p))
        (at end (carrying ?r ?a))
    )
)

(:durative-action deposit-artifact-beta
    :parameters (?r - standard-robot ?d - loading-drone ?a - beta-artifact ?h - hall ?p - pod)
    :duration (and (= ?duration 1))
    :condition (and 
        (at start (at ?r ?h))
        (over all (at ?r ?h))
        (at start (at ?d ?h))
        (over all (at ?d ?h))
        (at start (artifactinpod ?a ?p))
        (at start (carrying ?r ?a))
        (at start (haspod ?r ?p))
        (at start (iscryochamber ?h))
        (over all (unsealed ?r))
        (at start (batteryfull ?d))
    )
    :effect (and 
        (at start (not (artifactinpod ?a ?p)))
        (at start (not (carrying ?r ?a)))
        (at start (not (batteryfull ?d)))
        (at start (batteryempty ?d))
        (at end (indestination ?a))
        (at end (podempty ?p))
    )
)

(:durative-action load-core-sample
    :parameters (?r - heavy-transporter ?d1 - loading-drone ?d2 - loading-drone ?a - cryo-artifact ?h - hall)
    :duration (and (= ?duration 2))
    :condition (and 
        (at start (at ?r ?h))
        (over all (at ?r ?h))
        (at start (at ?d1 ?h))
        (over all (at ?d1 ?h))
        (at start (at ?d2 ?h))
        (over all (at ?d2 ?h))
        (at start (iscryochamber ?h))
        (at start (available ?a))
        (over all (unsealed ?r))
        (over all (coolingon ?r))
        (at start (batteryfull ?d1))
        (at start (batteryfull ?d2))
        (at start (dronepair ?d1 ?d2))
        (at start (empty ?r))
    )
    :effect (and 
        (at start (not (empty ?r)))
        (at start (not (available ?a)))
        (at start (not (batteryfull ?d1)))
        (at start (not (batteryfull ?d2)))
        (at start (batteryempty ?d1))
        (at start (batteryempty ?d2))
        (at end (carrying ?r ?a))
    )
)

(:durative-action deposit-core-sample
    :parameters (?r - heavy-transporter ?d1 - loading-drone ?d2 - loading-drone ?a - cryo-artifact ?h - hall)
    :duration (and (= ?duration 2))
    :condition (and 
        (at start (at ?r ?h))
        (over all (at ?r ?h))
        (at start (at ?d1 ?h))
        (over all (at ?d1 ?h))
        (at start (at ?d2 ?h))
        (over all (at ?d2 ?h))
        (at start (isstasislab ?h))
        (over all (unsealed ?r))
        (over all (coolingon ?r))
        (at start (batteryfull ?d1))
        (at start (batteryfull ?d2))
        (at start (dronepair ?d1 ?d2))
        (at start (carrying ?r ?a))
    )
    :effect (and 
        (at start (not (carrying ?r ?a)))
        (at start (not (batteryfull ?d1)))
        (at start (not (batteryfull ?d2)))
        (at start (batteryempty ?d1))
        (at start (batteryempty ?d2))
        (at end (empty ?r))
        (at end (indestination ?a))
    )
)

(:durative-action charge-drone
    :parameters (?d - loading-drone ?h - hall)
    :duration (and (= ?duration 2))
    :condition (and 
        (at start (at ?d ?h))
        (over all (at ?d ?h))
        (at start (istunnel ?h))
        (at start (batteryempty ?d))
    )
    :effect (and 
        (at start (not (batteryempty ?d)))
        (at end (batteryfull ?d))
    )
)

)
