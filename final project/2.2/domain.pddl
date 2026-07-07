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
(haspod ?r - robot ?p - pod)
(podempty ?p - pod)
(carrying ?r - robot ?a - artifact)

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
(empty ?r - robot)

;two-state battery for loading drones
(batteryfull ?d - loading-drone)
(batteryempty ?d - loading-drone)

;heavy transporter slots
(slotof ?s - slot ?t - heavy-transporter)
(slotpair ?t - heavy-transporter ?s1 - slot ?s2 - slot)
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

;actions for standard robot

;take a pod from the storing location
(:action take-pod
    :parameters (?r - standard-robot ?p - pod)
    :precondition (and 
        (podstored ?p)
        (empty ?r)
        (intunnel ?r)
    )
    :effect (and 
        (not (podstored ?p))
        (not (empty ?r))
        (haspod ?r ?p)
    )
)

;return a pod to the storing location
(:action return-pod
    :parameters (?r - standard-robot ?p - pod)
    :precondition (and 
        (haspod ?r ?p)
        (sealed ?r)
        (empty ?r)
        (podempty ?p)
        (intunnel ?r)
    )
    :effect (and 
        (podstored ?p)
        (not (haspod ?r ?p))
        (empty ?r)
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

;take an artifact from beta
;requires the vibration pod, also requires the robot to be unsealed
(:action take-artifact-beta
    :parameters (?r - standard-robot ?a - artifact ?h - hall ?p - pod)
    :precondition (and 
        (at ?r ?h)
        (artifactorigin ?a ?h)
        (isbeta ?h)
        (haspod ?r ?p)
        (podempty ?p)
        (unsealed ?r)
        (coolingoff ?r)
    )
    :effect (and 
        (not (podempty ?p))
        (not (empty ?r))
        (carrying ?r ?a)
        (artifactinpod ?a ?p)
    )
)

;take and artifact from the alpha hall
;cooling has to beturned on to pick up the artifact
(:action take-artifact-alpha
    :parameters (?r - standard-robot ?a - artifact ?h - hall)
    :precondition (and 
        (at ?r ?h)
        (isalpha ?h)
        (artifactorigin ?a ?h)
        (empty ?r)
        (unsealed ?r)
        (coolingon ?r)

    )
    :effect (and 
        (carrying ?r ?a)
        (not (empty ?r))
    )
)

;deposit an alpha artifact
(:action deposit-artifact-alpha
    :parameters (?r - standard-robot ?a - artifact ?h1 - hall ?h2 - hall)
    :precondition (and 
        (isalpha ?h1)
        (artifactorigin ?a ?h1)
        (at ?r ?h2)
        (carrying ?r ?a)
        (iscryochamber ?h2)
        (unsealed ?r)
    )
    :effect (and 
        (not (carrying ?r ?a))
        (indestination ?a)
        (empty ?r)
    )
)

;deposit a beta artifact
(:action deposit-artifact-beta
    :parameters (?r - standard-robot ?a - artifact ?h1 - hall ?h2 - hall ?p - pod)
    :precondition (and 
        (isbeta ?h1)
        (artifactorigin ?a ?h1)
        (at ?r ?h2)
        (carrying ?r ?a)
        (iscryochamber ?h2)
        (unsealed ?r)
        (haspod ?r ?p)
    )
    :effect (and 
        (not (carrying ?r ?a))
        (indestination ?a)
        (empty ?r)
        (not (artifactinpod ?a ?p))
        (podempty ?p)
    )
)

;actions for heavy transporter + drone
(:action heavy-take-pod
    :parameters (?t - heavy-transporter ?p - pod ?s - slot)
    :precondition (and 
        (podstored ?p)
        (intunnel ?t)
        (slotof ?s ?t)
        (slotempty ?s)
    )
    :effect (and 
        (not (podstored ?p))
        (not (slotempty ?s))
        (podinslot ?p ?s)
        (haspod ?t ?p)
    )
)

(:action heavy-return-pod
    :parameters (?t - heavy-transporter ?p - pod ?s - slot)
    :precondition (and 
        (haspod ?t ?p)
        (sealed ?t)
        (podempty ?p)
        (intunnel ?t)
        (slotof ?s ?t)
        (podinslot ?p ?s)
    )
    :effect (and 
        (podstored ?p)
        (not (haspod ?t ?p))
        (not (podinslot ?p ?s))
        (slotempty ?s)
    )
)

(:action drone-load-artifact-alpha
    :parameters (?t - heavy-transporter ?d - loading-drone ?a - artifact ?h - hall ?s - slot)
    :precondition (and 
        (at ?t ?h)
        (at ?d ?h)
        (artifactorigin ?a ?h)
        (isalpha ?h)
        (unsealed ?t)
        (coolingon ?t)
        (not (isheavy ?a))
        (batteryfull ?d)
        (slotof ?s ?t)
        (slotempty ?s)
    )
    :effect (and 
        (not (slotempty ?s))
        (artifactinslot ?a ?s)
        (carrying ?t ?a)
        (not (batteryfull ?d))
        (batteryempty ?d)
    )
)

(:action drone-deposit-artifact-alpha
    :parameters (?t - heavy-transporter ?d - loading-drone ?a - artifact ?h1 - hall ?h2 - hall ?s - slot)
    :precondition (and 
        (isalpha ?h1)
        (artifactorigin ?a ?h1)
        (at ?t ?h2)
        (at ?d ?h2)
        (carrying ?t ?a)
        (artifactinslot ?a ?s)
        (slotof ?s ?t)
        (iscryochamber ?h2)
        (unsealed ?t)
        (batteryfull ?d)
    )
    :effect (and 
        (not (carrying ?t ?a))
        (indestination ?a)
        (not (artifactinslot ?a ?s))
        (slotempty ?s)
        (not (batteryfull ?d))
        (batteryempty ?d)
    )
)

(:action drone-load-artifact-beta
    :parameters (?t - heavy-transporter ?d - loading-drone ?a - artifact ?h - hall ?p - pod ?s - slot)
    :precondition (and 
        (at ?t ?h)
        (at ?d ?h)
        (artifactorigin ?a ?h)
        (isbeta ?h)
        (haspod ?t ?p)
        (podempty ?p)
        (podinslot ?p ?s)
        (slotof ?s ?t)
        (unsealed ?t)
        (coolingoff ?t)
        (not (isheavy ?a))
        (batteryfull ?d)
    )
    :effect (and 
        (not (podempty ?p))
        (carrying ?t ?a)
        (artifactinpod ?a ?p)
        (artifactinslot ?a ?s)
        (not (batteryfull ?d))
        (batteryempty ?d)
    )
)

(:action drone-deposit-artifact-beta
    :parameters (?t - heavy-transporter ?d - loading-drone ?a - artifact ?h1 - hall ?h2 - hall ?p - pod ?s - slot)
    :precondition (and 
        (isbeta ?h1)
        (artifactorigin ?a ?h1)
        (at ?t ?h2)
        (at ?d ?h2)
        (carrying ?t ?a)
        (artifactinpod ?a ?p)
        (artifactinslot ?a ?s)
        (podinslot ?p ?s)
        (slotof ?s ?t)
        (iscryochamber ?h2)
        (unsealed ?t)
        (haspod ?t ?p)
        (batteryfull ?d)
    )
    :effect (and 
        (not (carrying ?t ?a))
        (indestination ?a)
        (not (artifactinpod ?a ?p))
        (not (artifactinslot ?a ?s))
        (podempty ?p)
        (not (batteryfull ?d))
        (batteryempty ?d)
    )
)

(:action drone-load-core-sample
    :parameters (?t - heavy-transporter ?d - loading-drone ?a - artifact ?h - hall ?s1 - slot ?s2 - slot)
    :precondition (and 
        (at ?t ?h)
        (at ?d ?h)
        (artifactorigin ?a ?h)
        (iscryochamber ?h)
        (unsealed ?t)
        (coolingon ?t)
        (isheavy ?a)
        (batteryfull ?d)
        (slotpair ?t ?s1 ?s2)
        (slotof ?s1 ?t)
        (slotof ?s2 ?t)
        (slotempty ?s1)
        (slotempty ?s2)
    )
    :effect (and 
        (not (slotempty ?s1))
        (not (slotempty ?s2))
        (artifactinslot ?a ?s1)
        (artifactinslot ?a ?s2)
        (carrying ?t ?a)
        (not (batteryfull ?d))
        (batteryempty ?d)
    )
)

(:action drone-deposit-core-sample
    :parameters (?t - heavy-transporter ?d - loading-drone ?a - artifact ?h1 - hall ?h2 - hall ?s1 - slot ?s2 - slot)
    :precondition (and 
        (at ?t ?h2)
        (at ?d ?h2)
        (artifactorigin ?a ?h1)
        (iscryochamber ?h1)
        (isstasislab ?h2)
        (unsealed ?t)
        (coolingon ?t)
        (isheavy ?a)
        (batteryfull ?d)
        (slotpair ?t ?s1 ?s2)
        (slotof ?s1 ?t)
        (slotof ?s2 ?t)
        (artifactinslot ?a ?s1)
        (artifactinslot ?a ?s2)
        (carrying ?t ?a)
    )
    :effect (and 
        (not (carrying ?t ?a))
        (not (artifactinslot ?a ?s1))
        (not (artifactinslot ?a ?s2))
        (slotempty ?s1)
        (slotempty ?s2)
        (indestination ?a)
        (not (batteryfull ?d))
        (batteryempty ?d)
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
