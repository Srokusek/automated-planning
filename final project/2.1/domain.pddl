;Header and description

(define (domain artifacts-2-1)

(:requirements :strips :typing)

(:types
robot artifact hall pod
)

(:predicates
(at ?r - robot ?h - hall)
(artifactorigin ?a - artifact ?h - hall)
(artifactinpod ?a - artifact ?p - pod)
(podstored ?p - pod)
(haspod ?r - robot ?p - pod)
(podempty ?p - pod)
(carrying ?r - robot ?a - artifact)

(indestination ?a - artifact)
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
        (empty ?r)
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
        (empty ?r)
    )
    :effect (and 
        (not (coolingon ?r))
        (coolingoff ?r)
    )
)

;take a pod from the storing location
(:action take-pod
    :parameters (?r - robot ?p - pod)
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
    :parameters (?r - robot ?p - pod)
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
    :parameters (?r - robot ?h - hall)
    :precondition (and 
        (sealed ?r)
        (at ?r ?h)
    )
    :effect (and 
        (not (at ?r ?h))
        (intunnel ?r)
    )
)

;enter a hall from the maintanance tunnel
(:action enter-hall
    :parameters (?r - robot ?h - hall)
    :precondition (and 
        (intunnel ?r)
    )
    :effect (and 
        (at ?r ?h)
        (not (intunnel ?r))
    )
)

;take an artifact from beta
;requires the vibration pod, also requires the robot to be unsealed
(:action take-artifact-beta
    :parameters (?r - robot ?a - artifact ?h - hall ?p - pod)
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
    :parameters (?r - robot ?a - artifact ?h - hall)
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

(:action take-core-sample
    :parameters (?r - robot ?a - artifact ?h - hall)
    :precondition (and 
        (at ?r ?h)
        (iscryochamber ?h)
        (artifactorigin ?a ?h)
        (empty ?r)
        (unsealed ?r)
        (coolingoff ?r)
    )
    :effect (and 
        (carrying ?r ?a)
        (not (empty ?r))
    )
)

(:action deposit-core-sample
    :parameters (?r - robot ?a - artifact ?h1 - hall ?h2 - hall)
    :precondition (and 
        (carrying ?r ?a)
        (artifactorigin ?a ?h1)
        (iscryochamber ?h1)
        (at ?r ?h2)
        (isstasislab ?h2)
        (unsealed ?r)
    )
    :effect (and 
        (not (carrying ?r ?a))
        (indestination ?a)
        (empty ?r)
    )
)


;deposit an alpha artifact
(:action deposit-artifact-alpha
    :parameters (?r - robot ?a - artifact ?h1 - hall ?h2 - hall)
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
    :parameters (?r - robot ?a - artifact ?h1 - hall ?h2 - hall ?p - pod)
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
        (not (artifactinpod ?a ?p))
        (podempty ?p)
    )
)
)
