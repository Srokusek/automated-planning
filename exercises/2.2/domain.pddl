;Header and description

(define (domain artifacts-2-1)

(:requirements :strips :typing :negative-preconditions)

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

(artifactorigin ?a - artifact ?h - hall)
(artifactinpod ?a - artifact ?p - pod)
(podstored ?p - pod)
(podempty ?p - pod)

(indestination ?a - artifact)

;new heavy artifact type
(isheavy ?a - artifact)

(iscryochamber ?h - hall)
(isstasislab ?h - hall)
(isalpha ?h - hall)
(isbeta ?h - hall)

(intunnel ?r - robot)
(coolingon ?r - robot)
(coolingoff ?r - robot)
(sealed ?r - robot)
(unsealed ?r - robot)

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
    :parameters (?r - robot)
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
    :parameters (?r - robot ?h - hall)
    :precondition (and 
        (sealed ?r)
        (at ?r ?h)
    )
    :effect (and
        (not (sealed ?r))
        (unsealed ?r)
    )
)

(:action cool
    :parameters (?r - robot)
    :precondition (and 
        (coolingoff ?r)
    )
    :effect (and 
        (not (coolingoff ?r))
        (coolingon ?r)
    )
)

(:action cool-off
    :parameters (?r - robot)
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
(:action exit-hall
    :parameters (?r - land-robot ?h - hall)
    :precondition (and 
        (sealed ?r)
        (at ?r ?h)
        (not (tunneloccupied))
    )
    :effect (and 
        (not (at ?r ?h))
        (not (occupied ?h))
        (intunnel ?r)
        (tunneloccupied)
    )
)

(:action exit-hall-drone
    :parameters (?d - loading-drone ?h - hall)
    :precondition (and 
        (sealed ?d)
        (at ?d ?h)
    )
    :effect (and 
        (not (at ?d ?h))
        (intunnel ?d)
    )
)

;enter a hall from the maintanance tunnel
(:action enter-hall
    :parameters (?r - land-robot ?h - hall)
    :precondition (and 
        (intunnel ?r)
        (not (occupied ?h))
    )
    :effect (and 
        (at ?r ?h)
        (occupied ?h)
        (not (intunnel ?r))
        (not (tunneloccupied))
    )
)

(:action enter-hall-drone
    :parameters (?d - loading-drone ?h - hall)
    :precondition (and 
        (intunnel ?d)
    )
    :effect (and 
        (at ?d ?h)
        (not (intunnel ?d))
    )
)

;actions for land robot + drone
(:action load-artifact-alpha
    :parameters (?r - land-robot ?d - loading-drone ?a - artifact ?h - hall ?s - slot)
    :precondition (and 
        (at ?r ?h)
        (at ?d ?h)
        (artifactorigin ?a ?h)
        (isalpha ?h)
        (unsealed ?r)
        (coolingon ?r)
        (not (isheavy ?a))
        (batteryfull ?d)
        (slotof ?s ?r)
        (slotempty ?s)
    )
    :effect (and 
        (not (slotempty ?s))
        (artifactinslot ?a ?s)
        (not (batteryfull ?d))
        (batteryempty ?d)
    )
)

(:action deposit-artifact-alpha
    :parameters (?r - land-robot ?d - loading-drone ?a - artifact ?h1 - hall ?h2 - hall ?s - slot)
    :precondition (and 
        (isalpha ?h1)
        (artifactorigin ?a ?h1)
        (at ?r ?h2)
        (at ?d ?h2)
        (artifactinslot ?a ?s)
        (slotof ?s ?r)
        (iscryochamber ?h2)
        (unsealed ?r)
        (batteryfull ?d)
    )
    :effect (and 
        (indestination ?a)
        (not (artifactinslot ?a ?s))
        (slotempty ?s)
        (not (batteryfull ?d))
        (batteryempty ?d)
    )
)

(:action load-artifact-beta
    :parameters (?r - land-robot ?d - loading-drone ?a - artifact ?h - hall ?p - pod ?s - slot)
    :precondition (and 
        (at ?r ?h)
        (at ?d ?h)
        (artifactorigin ?a ?h)
        (isbeta ?h)
        (podempty ?p)
        (podinslot ?p ?s)
        (slotof ?s ?r)
        (unsealed ?r)
        (coolingoff ?r)
        (not (isheavy ?a))
        (batteryfull ?d)
    )
    :effect (and 
        (not (podempty ?p))
        (artifactinpod ?a ?p)
        (artifactinslot ?a ?s)
        (not (batteryfull ?d))
        (batteryempty ?d)
    )
)

(:action deposit-artifact-beta
    :parameters (?r - land-robot ?d - loading-drone ?a - artifact ?h1 - hall ?h2 - hall ?p - pod ?s - slot)
    :precondition (and 
        (isbeta ?h1)
        (artifactorigin ?a ?h1)
        (at ?r ?h2)
        (at ?d ?h2)
        (artifactinpod ?a ?p)
        (artifactinslot ?a ?s)
        (podinslot ?p ?s)
        (slotof ?s ?r)
        (iscryochamber ?h2)
        (unsealed ?r)
        (batteryfull ?d)
    )
    :effect (and 
        (indestination ?a)
        (not (artifactinpod ?a ?p))
        (not (artifactinslot ?a ?s))
        (podempty ?p)
        (not (batteryfull ?d))
        (batteryempty ?d)
    )
)

(:action load-core-sample
    :parameters (?r - land-robot ?d1 - loading-drone ?d2 - loading-drone ?a - artifact ?h - hall ?s1 - slot ?s2 - slot)
    :precondition (and 
        (at ?r ?h)
        (at ?d1 ?h)
        (at ?d2 ?h)
        (artifactorigin ?a ?h)
        (iscryochamber ?h)
        (unsealed ?r)
        (coolingon ?r)
        (isheavy ?a)
        (batteryfull ?d1)
        (batteryfull ?d2)
        (dronepair ?d1 ?d2)
        (slotpair ?r ?s1 ?s2)
        (slotof ?s1 ?r)
        (slotof ?s2 ?r)
        (slotempty ?s1)
        (slotempty ?s2)
    )
    :effect (and 
        (not (slotempty ?s1))
        (not (slotempty ?s2))
        (artifactinslot ?a ?s1)
        (artifactinslot ?a ?s2)
        (not (batteryfull ?d1))
        (not (batteryfull ?d2))
        (batteryempty ?d1)
        (batteryempty ?d2)
    )
)

(:action deposit-core-sample
    :parameters (?r - land-robot ?d1 - loading-drone ?d2 - loading-drone ?a - artifact ?h1 - hall ?h2 - hall ?s1 - slot ?s2 - slot)
    :precondition (and 
        (at ?r ?h2)
        (at ?d1 ?h2)
        (at ?d2 ?h2)
        (artifactorigin ?a ?h1)
        (iscryochamber ?h1)
        (isstasislab ?h2)
        (unsealed ?r)
        (coolingon ?r)
        (isheavy ?a)
        (batteryfull ?d1)
        (batteryfull ?d2)
        (dronepair ?d1 ?d2)
        (slotpair ?r ?s1 ?s2)
        (slotof ?s1 ?r)
        (slotof ?s2 ?r)
        (artifactinslot ?a ?s1)
        (artifactinslot ?a ?s2)
    )
    :effect (and 
        (not (artifactinslot ?a ?s1))
        (not (artifactinslot ?a ?s2))
        (slotempty ?s1)
        (slotempty ?s2)
        (indestination ?a)
        (not (batteryfull ?d1))
        (not (batteryfull ?d2))
        (batteryempty ?d1)
        (batteryempty ?d2)
    )
)

(:action charge-drone
    :parameters (?d - loading-drone)
    :precondition (and 
        (intunnel ?d)
        (batteryempty ?d)
    )
    :effect (and 
        (not (batteryempty ?d))
        (batteryfull ?d)
    )
)

)
