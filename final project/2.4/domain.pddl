;Header and description

(define (domain artifacts-2-4)

(:requirements :strips :typing :durative-actions)

(:types
robot artifact hall pod slot
land-robot - robot
standard-robot heavy-transporter - land-robot
loading-drone - robot ;additional subtypes of a robot
)

(:predicates
(at ?r - robot ?h - hall)

;keeping track of hall occupancy
(occupied ?h - hall)
(tunneloccupied)
(hallfree ?h - hall)
(tunnelfree)

(artifactinpod ?a - artifact ?p - pod)
(podstored ?p - pod)
(podempty ?p - pod)
(available ?a - artifact)

(indestination ?a - artifact)

;new heavy artifact type
(isheavy ?a - artifact)
(islight ?a - artifact)
(isalphaartifact ?a - artifact)
(isbetaartifact ?a - artifact)
(iscryoartifact ?a - artifact)

(iscryochamber ?h - hall)
(isstasislab ?h - hall)
(isalpha ?h - hall)
(isbeta ?h - hall)

(intunnel ?r - robot)
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
    :parameters (?r - land-robot ?p - pod ?s - slot)
    :precondition (and 
        (podstored ?p)
        (intunnel ?r)
        (slotof ?s ?r)
        (slotempty ?s)
    )
    :effect (and 
        (not (podstored ?p))
        (not (slotempty ?s))
        (podinslot ?p ?s)
    )
)

;return a pod to the storing location
(:action return-pod
    :parameters (?r - land-robot ?p - pod ?s - slot)
    :precondition (and 
        (sealed ?r)
        (podempty ?p)
        (intunnel ?r)
        (slotof ?s ?r)
        (podinslot ?p ?s)
    )
    :effect (and 
        (podstored ?p)
        (not (podinslot ?p ?s))
        (slotempty ?s)
    )
)

;exitting a hall into the maintanance tunnel requires the robot to be sealed
(:durative-action exit-hall-standard
    :parameters (?r - standard-robot ?h - hall)
    :duration (and (= ?duration 2))
    :condition (and 
        (at start (sealed ?r))
        (at start (at ?r ?h))
        (over all (at ?r ?h))
        (at start (tunnelfree))
    )
    :effect (and 
        (at start (not (tunnelfree)))
        (at start (tunneloccupied))
        (at end (not (at ?r ?h)))
        (at end (not (occupied ?h)))
        (at end (hallfree ?h))
        (at end (intunnel ?r))
    )
)

(:durative-action exit-hall-heavy
    :parameters (?r - heavy-transporter ?h - hall)
    :duration (and (= ?duration 3))
    :condition (and 
        (at start (sealed ?r))
        (at start (at ?r ?h))
        (over all (at ?r ?h))
        (at start (tunnelfree))
    )
    :effect (and 
        (at start (not (tunnelfree)))
        (at start (tunneloccupied))
        (at end (not (at ?r ?h)))
        (at end (not (occupied ?h)))
        (at end (hallfree ?h))
        (at end (intunnel ?r))
    )
)

(:durative-action exit-hall-drone
    :parameters (?d - loading-drone ?h - hall)
    :duration (and (= ?duration 1))
    :condition (and 
        (at start (at ?d ?h))
        (over all (at ?d ?h))
    )
    :effect (and 
        (at end (not (at ?d ?h)))
        (at end (intunnel ?d))
    )
)

;enter a hall from the maintanance tunnel
(:durative-action enter-hall-standard
    :parameters (?r - standard-robot ?h - hall)
    :duration (and (= ?duration 2))
    :condition (and 
        (at start (intunnel ?r))
        (over all (intunnel ?r))
        (at start (tunneloccupied))
        (at start (hallfree ?h))
    )
    :effect (and 
        (at start (not (hallfree ?h)))
        (at start (occupied ?h))
        (at end (at ?r ?h))
        (at end (not (intunnel ?r)))
        (at end (not (tunneloccupied)))
        (at end (tunnelfree))
    )
)

(:durative-action enter-hall-heavy
    :parameters (?r - heavy-transporter ?h - hall)
    :duration (and (= ?duration 3))
    :condition (and 
        (at start (intunnel ?r))
        (over all (intunnel ?r))
        (at start (tunneloccupied))
        (at start (hallfree ?h))
    )
    :effect (and 
        (at start (not (hallfree ?h)))
        (at start (occupied ?h))
        (at end (at ?r ?h))
        (at end (not (intunnel ?r)))
        (at end (not (tunneloccupied)))
        (at end (tunnelfree))
    )
)

(:durative-action enter-hall-drone
    :parameters (?d - loading-drone ?h - hall)
    :duration (and (= ?duration 1))
    :condition (and 
        (at start (intunnel ?d))
        (over all (intunnel ?d))
    )
    :effect (and 
        (at end (at ?d ?h))
        (at end (not (intunnel ?d)))
    )
)

;actions for land robot + drone
(:durative-action load-artifact-alpha
    :parameters (?r - land-robot ?d - loading-drone ?a - artifact ?h - hall ?s - slot)
    :duration (and (= ?duration 1))
    :condition (and 
        (at start (at ?r ?h))
        (over all (at ?r ?h))
        (at start (at ?d ?h))
        (over all (at ?d ?h))
        (at start (isalpha ?h))
        (at start (isalphaartifact ?a))
        (at start (available ?a))
        (over all (unsealed ?r))
        (over all (coolingon ?r))
        (at start (islight ?a))
        (at start (batteryfull ?d))
        (at start (slotof ?s ?r))
        (at start (slotempty ?s))
    )
    :effect (and 
        (at start (not (slotempty ?s)))
        (at start (not (available ?a)))
        (at start (not (batteryfull ?d)))
        (at start (batteryempty ?d))
        (at end (artifactinslot ?a ?s))
    )
)

(:durative-action deposit-artifact-alpha
    :parameters (?r - land-robot ?d - loading-drone ?a - artifact ?h - hall ?s - slot)
    :duration (and (= ?duration 1))
    :condition (and 
        (at start (isalphaartifact ?a))
        (at start (at ?r ?h))
        (over all (at ?r ?h))
        (at start (at ?d ?h))
        (over all (at ?d ?h))
        (at start (artifactinslot ?a ?s))
        (at start (slotof ?s ?r))
        (at start (iscryochamber ?h))
        (over all (unsealed ?r))
        (at start (batteryfull ?d))
    )
    :effect (and 
        (at start (not (artifactinslot ?a ?s)))
        (at start (not (batteryfull ?d)))
        (at start (batteryempty ?d))
        (at end (indestination ?a))
        (at end (slotempty ?s))
    )
)

(:durative-action load-artifact-beta
    :parameters (?r - land-robot ?d - loading-drone ?a - artifact ?h - hall ?p - pod ?s - slot)
    :duration (and (= ?duration 1))
    :condition (and 
        (at start (at ?r ?h))
        (over all (at ?r ?h))
        (at start (at ?d ?h))
        (over all (at ?d ?h))
        (at start (isbeta ?h))
        (at start (isbetaartifact ?a))
        (at start (available ?a))
        (at start (podempty ?p))
        (at start (podinslot ?p ?s))
        (at start (slotof ?s ?r))
        (over all (unsealed ?r))
        (over all (coolingoff ?r))
        (at start (islight ?a))
        (at start (batteryfull ?d))
    )
    :effect (and 
        (at start (not (available ?a)))
        (at start (not (podempty ?p)))
        (at start (not (batteryfull ?d)))
        (at start (batteryempty ?d))
        (at end (artifactinpod ?a ?p))
        (at end (artifactinslot ?a ?s))
    )
)

(:durative-action deposit-artifact-beta
    :parameters (?r - land-robot ?d - loading-drone ?a - artifact ?h - hall ?p - pod ?s - slot)
    :duration (and (= ?duration 1))
    :condition (and 
        (at start (isbetaartifact ?a))
        (at start (at ?r ?h))
        (over all (at ?r ?h))
        (at start (at ?d ?h))
        (over all (at ?d ?h))
        (at start (artifactinpod ?a ?p))
        (at start (artifactinslot ?a ?s))
        (at start (podinslot ?p ?s))
        (at start (slotof ?s ?r))
        (at start (iscryochamber ?h))
        (over all (unsealed ?r))
        (at start (batteryfull ?d))
    )
    :effect (and 
        (at start (not (artifactinpod ?a ?p)))
        (at start (not (artifactinslot ?a ?s)))
        (at start (not (batteryfull ?d)))
        (at start (batteryempty ?d))
        (at end (indestination ?a))
        (at end (podempty ?p))
    )
)

(:durative-action load-core-sample
    :parameters (?r - land-robot ?d1 - loading-drone ?d2 - loading-drone ?a - artifact ?h - hall ?s1 - slot ?s2 - slot)
    :duration (and (= ?duration 2))
    :condition (and 
        (at start (at ?r ?h))
        (over all (at ?r ?h))
        (at start (at ?d1 ?h))
        (over all (at ?d1 ?h))
        (at start (at ?d2 ?h))
        (over all (at ?d2 ?h))
        (at start (iscryochamber ?h))
        (at start (iscryoartifact ?a))
        (at start (available ?a))
        (over all (unsealed ?r))
        (over all (coolingon ?r))
        (at start (isheavy ?a))
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
        (at start (not (slotempty ?s1)))
        (at start (not (slotempty ?s2)))
        (at start (not (available ?a)))
        (at start (not (batteryfull ?d1)))
        (at start (not (batteryfull ?d2)))
        (at start (batteryempty ?d1))
        (at start (batteryempty ?d2))
        (at end (artifactinslot ?a ?s1))
        (at end (artifactinslot ?a ?s2))
    )
)

(:durative-action deposit-core-sample
    :parameters (?r - land-robot ?d1 - loading-drone ?d2 - loading-drone ?a - artifact ?h - hall ?s1 - slot ?s2 - slot)
    :duration (and (= ?duration 2))
    :condition (and 
        (at start (at ?r ?h))
        (over all (at ?r ?h))
        (at start (at ?d1 ?h))
        (over all (at ?d1 ?h))
        (at start (at ?d2 ?h))
        (over all (at ?d2 ?h))
        (at start (iscryoartifact ?a))
        (at start (isstasislab ?h))
        (over all (unsealed ?r))
        (over all (coolingon ?r))
        (at start (isheavy ?a))
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
        (at start (not (artifactinslot ?a ?s1)))
        (at start (not (artifactinslot ?a ?s2)))
        (at start (not (batteryfull ?d1)))
        (at start (not (batteryfull ?d2)))
        (at start (batteryempty ?d1))
        (at start (batteryempty ?d2))
        (at end (slotempty ?s1))
        (at end (slotempty ?s2))
        (at end (indestination ?a))
    )
)

(:durative-action charge-drone
    :parameters (?d - loading-drone)
    :duration (and (= ?duration 2))
    :condition (and 
        (at start (intunnel ?d))
        (over all (intunnel ?d))
        (at start (batteryempty ?d))
    )
    :effect (and 
        (at start (not (batteryempty ?d)))
        (at end (batteryfull ?d))
    )
)

)
