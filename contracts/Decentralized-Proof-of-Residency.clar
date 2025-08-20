(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-already-voted (err u103))
(define-constant err-voting-closed (err u104))
(define-constant err-insufficient-votes (err u105))
(define-constant err-invalid-location (err u106))

(define-data-var next-claim-id uint u1)
(define-data-var minimum-votes uint u3)
(define-data-var voting-period uint u144)

(define-map residency-claims
  { claim-id: uint }
  {
    resident: principal,
    location: (string-ascii 128),
    created-at: uint,
    voting-ends: uint,
    yes-votes: uint,
    no-votes: uint,
    status: (string-ascii 20)
  }
)

(define-map claim-voters
  { claim-id: uint, voter: principal }
  { voted: bool, vote: bool }
)

(define-map verified-residents
  { resident: principal }
  { location: (string-ascii 128), verified-at: uint }
)

(define-map voter-reputation
  { voter: principal }
  { score: uint, total-votes: uint }
)

(define-public (submit-claim (location (string-ascii 128)))
  (let (
    (claim-id (var-get next-claim-id))
    (current-block stacks-block-height)
  )
    (asserts! (> (len location) u0) err-invalid-location)
    (asserts! (is-none (map-get? verified-residents { resident: tx-sender })) err-already-exists)
    
    (map-set residency-claims
      { claim-id: claim-id }
      {
        resident: tx-sender,
        location: location,
        created-at: current-block,
        voting-ends: (+ current-block (var-get voting-period)),
        yes-votes: u0,
        no-votes: u0,
        status: "pending"
      }
    )
    
    (var-set next-claim-id (+ claim-id u1))
    (ok claim-id)
  )
)

(define-public (vote-on-claim (claim-id uint) (vote bool))
  (let (
    (claim (unwrap! (map-get? residency-claims { claim-id: claim-id }) err-not-found))
    (current-block stacks-block-height)
    (voter-key { claim-id: claim-id, voter: tx-sender })
  )
    (asserts! (< current-block (get voting-ends claim)) err-voting-closed)
    (asserts! (is-none (map-get? claim-voters voter-key)) err-already-voted)
    (asserts! (not (is-eq tx-sender (get resident claim))) err-owner-only)
    
    (map-set claim-voters voter-key { voted: true, vote: vote })
    
    (map-set residency-claims
      { claim-id: claim-id }
      (merge claim {
        yes-votes: (if vote (+ (get yes-votes claim) u1) (get yes-votes claim)),
        no-votes: (if vote (get no-votes claim) (+ (get no-votes claim) u1))
      })
    )
    
    (update-voter-reputation tx-sender)
    (ok true)
  )
)

(define-public (finalize-claim (claim-id uint))
  (let (
    (claim (unwrap! (map-get? residency-claims { claim-id: claim-id }) err-not-found))
    (current-block stacks-block-height)
    (total-votes (+ (get yes-votes claim) (get no-votes claim)))
    (approval-rate (if (> total-votes u0) (/ (* (get yes-votes claim) u100) total-votes) u0))
  )
    (asserts! (>= current-block (get voting-ends claim)) err-voting-closed)
    (asserts! (>= total-votes (var-get minimum-votes)) err-insufficient-votes)
    (asserts! (is-eq (get status claim) "pending") err-already-exists)
    
    (if (>= approval-rate u60)
      (begin
        (map-set residency-claims
          { claim-id: claim-id }
          (merge claim { status: "approved" })
        )
        (map-set verified-residents
          { resident: (get resident claim) }
          { location: (get location claim), verified-at: current-block }
        )
        (ok "approved")
      )
      (begin
        (map-set residency-claims
          { claim-id: claim-id }
          (merge claim { status: "rejected" })
        )
        (ok "rejected")
      )
    )
  )
)

(define-public (update-settings (new-minimum-votes uint) (new-voting-period uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set minimum-votes new-minimum-votes)
    (var-set voting-period new-voting-period)
    (ok true)
  )
)

(define-private (update-voter-reputation (voter principal))
  (let (
    (current-rep (default-to { score: u0, total-votes: u0 } (map-get? voter-reputation { voter: voter })))
  )
    (map-set voter-reputation
      { voter: voter }
      {
        score: (+ (get score current-rep) u1),
        total-votes: (+ (get total-votes current-rep) u1)
      }
    )
  )
)

(define-read-only (get-claim (claim-id uint))
  (map-get? residency-claims { claim-id: claim-id })
)

(define-read-only (get-verified-resident (resident principal))
  (map-get? verified-residents { resident: resident })
)

(define-read-only (get-voter-reputation (voter principal))
  (map-get? voter-reputation { voter: voter })
)

(define-read-only (has-voted (claim-id uint) (voter principal))
  (is-some (map-get? claim-voters { claim-id: claim-id, voter: voter }))
)

(define-read-only (get-settings)
  {
    minimum-votes: (var-get minimum-votes),
    voting-period: (var-get voting-period),
    next-claim-id: (var-get next-claim-id)
  }
)

(define-read-only (is-voting-active (claim-id uint))
  (match (map-get? residency-claims { claim-id: claim-id })
    claim (< stacks-block-height (get voting-ends claim))
    false
  )
)
