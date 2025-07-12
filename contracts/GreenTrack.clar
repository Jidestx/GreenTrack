;; GreenTrack - Carbon Credit Management System
;; A transparent platform for tracking and trading carbon credits

;; Error codes
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-INVALID-AMOUNT (err u101))
(define-constant ERR-INSUFFICIENT-BALANCE (err u102))
(define-constant ERR-CREDIT-NOT-FOUND (err u103))
(define-constant ERR-INVALID-OFFSET (err u104))
(define-constant ERR-ALREADY-VERIFIED (err u105))
(define-constant ERR-INVALID-PARAMS (err u106))

;; Contract owner
(define-constant CONTRACT-OWNER tx-sender)

;; Data structures
(define-map carbon-credits
  { credit-id: uint }
  {
    issuer: principal,
    amount: uint,
    project-type: (string-ascii 50),
    verification-status: bool,
    created-at: uint,
    retired: bool
  }
)

(define-map user-balances
  { user: principal }
  { balance: uint }
)

(define-map credit-ownership
  { credit-id: uint }
  { owner: principal }
)

(define-map project-registry
  { project-id: uint }
  {
    name: (string-ascii 100),
    location: (string-ascii 100),
    project-type: (string-ascii 50),
    verified: bool,
    total-credits: uint
  }
)

;; Data variables
(define-data-var next-credit-id uint u1)
(define-data-var next-project-id uint u1)
(define-data-var total-credits-issued uint u0)
(define-data-var total-credits-retired uint u0)

;; Read-only functions
(define-read-only (get-credit-info (credit-id uint))
  (map-get? carbon-credits { credit-id: credit-id })
)

(define-read-only (get-user-balance (user principal))
  (default-to u0 (get balance (map-get? user-balances { user: user })))
)

(define-read-only (get-credit-owner (credit-id uint))
  (map-get? credit-ownership { credit-id: credit-id })
)

(define-read-only (get-project-info (project-id uint))
  (map-get? project-registry { project-id: project-id })
)

(define-read-only (get-contract-stats)
  {
    total-issued: (var-get total-credits-issued),
    total-retired: (var-get total-credits-retired),
    next-credit-id: (var-get next-credit-id),
    next-project-id: (var-get next-project-id)
  }
)

;; Private functions
(define-private (is-valid-amount (amount uint))
  (> amount u0)
)

(define-private (is-valid-string (str (string-ascii 100)))
  (> (len str) u0)
)

(define-private (is-valid-principal (user principal))
  (not (is-eq user 'SP000000000000000000002Q6VF78))
)

;; Public functions
(define-public (register-project (name (string-ascii 100)) (location (string-ascii 100)) (project-type (string-ascii 50)))
  (let (
    (project-id (var-get next-project-id))
  )
    (asserts! (is-valid-string name) ERR-INVALID-PARAMS)
    (asserts! (is-valid-string location) ERR-INVALID-PARAMS)
    (asserts! (is-valid-string project-type) ERR-INVALID-PARAMS)
    
    (map-set project-registry
      { project-id: project-id }
      {
        name: name,
        location: location,
        project-type: project-type,
        verified: false,
        total-credits: u0
      }
    )
    
    (var-set next-project-id (+ project-id u1))
    (ok project-id)
  )
)

(define-public (issue-credit (amount uint) (project-type (string-ascii 50)))
  (let (
    (credit-id (var-get next-credit-id))
    (current-block stacks-block-height)
  )
    (asserts! (is-valid-amount amount) ERR-INVALID-AMOUNT)
    (asserts! (is-valid-string project-type) ERR-INVALID-PARAMS)
    
    (map-set carbon-credits
      { credit-id: credit-id }
      {
        issuer: tx-sender,
        amount: amount,
        project-type: project-type,
        verification-status: false,
        created-at: current-block,
        retired: false
      }
    )
    
    (map-set credit-ownership
      { credit-id: credit-id }
      { owner: tx-sender }
    )
    
    (map-set user-balances
      { user: tx-sender }
      { balance: (+ (get-user-balance tx-sender) amount) }
    )
    
    (var-set next-credit-id (+ credit-id u1))
    (var-set total-credits-issued (+ (var-get total-credits-issued) amount))
    
    (ok credit-id)
  )
)

(define-public (verify-credit (credit-id uint))
  (let (
    (credit-info (unwrap! (get-credit-info credit-id) ERR-CREDIT-NOT-FOUND))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (not (get verification-status credit-info)) ERR-ALREADY-VERIFIED)
    
    (map-set carbon-credits
      { credit-id: credit-id }
      (merge credit-info { verification-status: true })
    )
    
    (ok true)
  )
)

(define-public (transfer-credit (credit-id uint) (recipient principal))
  (let (
    (credit-info (unwrap! (get-credit-info credit-id) ERR-CREDIT-NOT-FOUND))
    (ownership (unwrap! (get-credit-owner credit-id) ERR-CREDIT-NOT-FOUND))
    (credit-amount (get amount credit-info))
    (owner-principal (get owner ownership))
    (sender-balance (get-user-balance tx-sender))
    (recipient-balance (get-user-balance recipient))
    (validated-recipient recipient)
  )
    (asserts! (is-valid-principal validated-recipient) ERR-INVALID-PARAMS)
    (asserts! (is-eq tx-sender owner-principal) ERR-UNAUTHORIZED)
    (asserts! (not (get retired credit-info)) ERR-INVALID-OFFSET)
    (asserts! (>= sender-balance credit-amount) ERR-INSUFFICIENT-BALANCE)
    
    (begin
      (map-set credit-ownership
        { credit-id: credit-id }
        { owner: validated-recipient }
      )
      
      (map-set user-balances
        { user: tx-sender }
        { balance: (- sender-balance credit-amount) }
      )
      
      (map-set user-balances
        { user: validated-recipient }
        { balance: (+ recipient-balance credit-amount) }
      )
      
      (ok true)
    )
  )
)

(define-public (retire-credit (credit-id uint))
  (let (
    (credit-info (unwrap! (get-credit-info credit-id) ERR-CREDIT-NOT-FOUND))
    (ownership (unwrap! (get-credit-owner credit-id) ERR-CREDIT-NOT-FOUND))
    (credit-amount (get amount credit-info))
    (owner-principal (get owner ownership))
    (sender-balance (get-user-balance tx-sender))
  )
    (asserts! (is-eq tx-sender owner-principal) ERR-UNAUTHORIZED)
    (asserts! (not (get retired credit-info)) ERR-INVALID-OFFSET)
    (asserts! (get verification-status credit-info) ERR-UNAUTHORIZED)
    (asserts! (>= sender-balance credit-amount) ERR-INSUFFICIENT-BALANCE)
    
    (map-set carbon-credits
      { credit-id: credit-id }
      (merge credit-info { retired: true })
    )
    
    (map-set user-balances
      { user: tx-sender }
      { balance: (- sender-balance credit-amount) }
    )
    
    (var-set total-credits-retired (+ (var-get total-credits-retired) credit-amount))
    
    (ok true)
  )
)

(define-public (batch-retire-credits (credit-ids (list 10 uint)))
  (let (
    (results (map retire-credit credit-ids))
  )
    (ok results)
  )
)