;; GreenTrack - Carbon Credit Management System with NFT Integration and Oracle Support
;; A transparent platform for tracking and trading carbon credits as NFTs with automated data feeds

;; SIP-009 Compatible NFT Functions (without trait implementation for Clarinet compatibility)

;; Error codes
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-INVALID-AMOUNT (err u101))
(define-constant ERR-INSUFFICIENT-BALANCE (err u102))
(define-constant ERR-CREDIT-NOT-FOUND (err u103))
(define-constant ERR-INVALID-OFFSET (err u104))
(define-constant ERR-ALREADY-VERIFIED (err u105))
(define-constant ERR-INVALID-PARAMS (err u106))
(define-constant ERR-NFT-NOT-OWNED (err u107))
(define-constant ERR-INVALID-NFT-ID (err u108))
(define-constant ERR-ORACLE-NOT-AUTHORIZED (err u109))
(define-constant ERR-INVALID-DATA-SOURCE (err u110))
(define-constant ERR-DATA-TOO-OLD (err u111))
(define-constant ERR-THRESHOLD-NOT-MET (err u112))

;; Contract owner
(define-constant CONTRACT-OWNER tx-sender)

;; NFT collection name and symbol
(define-constant NFT-NAME "GreenTrack Carbon Credits")
(define-constant NFT-SYMBOL "GTCC")

;; Oracle configuration constants
(define-constant MAX-DATA-AGE u144) ;; Maximum age of oracle data in blocks (approximately 24 hours)
(define-constant MIN-CARBON-THRESHOLD u100) ;; Minimum carbon offset required for automatic credit generation

;; Data structures
(define-map carbon-credits
  { credit-id: uint }
  {
    issuer: principal,
    amount: uint,
    project-type: (string-ascii 50),
    verification-status: bool,
    created-at: uint,
    retired: bool,
    project-id: (optional uint),
    oracle-generated: bool,
    data-source: (optional (string-ascii 100))
  }
)

(define-map user-balances
  { user: principal }
  { balance: uint }
)

(define-map project-registry
  { project-id: uint }
  {
    name: (string-ascii 100),
    location: (string-ascii 100),
    project-type: (string-ascii 50),
    verified: bool,
    total-credits: uint,
    oracle-enabled: bool,
    data-source: (optional (string-ascii 100))
  }
)

;; Oracle-specific data structures
(define-map authorized-oracles
  { oracle: principal }
  { 
    active: bool,
    data-source: (string-ascii 100),
    last-update: uint
  }
)

(define-map environmental-data
  { data-id: uint }
  {
    oracle: principal,
    project-id: uint,
    carbon-offset: uint,
    timestamp: uint,
    data-source: (string-ascii 100),
    processed: bool
  }
)

;; NFT-specific maps
(define-map token-count
  { owner: principal }
  { count: uint }
)

(define-map market-listings
  { nft-id: uint }
  {
    price: uint,
    seller: principal
  }
)

;; Data variables
(define-data-var next-credit-id uint u1)
(define-data-var next-project-id uint u1)
(define-data-var next-data-id uint u1)
(define-data-var total-credits-issued uint u0)
(define-data-var total-credits-retired uint u0)
(define-data-var last-token-id uint u0)
(define-data-var total-oracle-credits uint u0)

;; SIP-009 NFT trait functions
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://greentrack.io/api/metadata/"))
)

(define-read-only (get-owner (token-id uint))
  (let (
    (credit-info (map-get? carbon-credits { credit-id: token-id }))
  )
    (match credit-info
      info (ok (some (get issuer info)))
      (ok none)
    )
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (let (
    (credit-info (unwrap! (get-credit-info token-id) ERR-CREDIT-NOT-FOUND))
    (current-owner (unwrap! (unwrap! (get-owner token-id) ERR-INVALID-NFT-ID) ERR-NFT-NOT-OWNED))
  )
    (asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) ERR-UNAUTHORIZED)
    (asserts! (is-eq sender current-owner) ERR-NFT-NOT-OWNED)
    (asserts! (not (is-eq sender recipient)) ERR-INVALID-PARAMS)
    (asserts! (not (get retired credit-info)) ERR-INVALID-OFFSET)
    
    (try! (internal-transfer-credit token-id sender recipient))
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-credit-info (credit-id uint))
  (map-get? carbon-credits { credit-id: credit-id })
)

(define-read-only (get-user-balance (user principal))
  (default-to u0 (get balance (map-get? user-balances { user: user })))
)

(define-read-only (get-project-info (project-id uint))
  (map-get? project-registry { project-id: project-id })
)

(define-read-only (get-contract-stats)
  {
    total-issued: (var-get total-credits-issued),
    total-retired: (var-get total-credits-retired),
    next-credit-id: (var-get next-credit-id),
    next-project-id: (var-get next-project-id),
    total-nfts: (var-get last-token-id),
    oracle-generated-credits: (var-get total-oracle-credits)
  }
)

(define-read-only (get-balance (owner principal))
  (default-to u0 (get count (map-get? token-count { owner: owner })))
)

(define-read-only (get-market-listing (nft-id uint))
  (map-get? market-listings { nft-id: nft-id })
)

;; Oracle read-only functions
(define-read-only (get-oracle-info (oracle principal))
  (map-get? authorized-oracles { oracle: oracle })
)

(define-read-only (get-environmental-data (data-id uint))
  (map-get? environmental-data { data-id: data-id })
)

(define-read-only (is-oracle-authorized (oracle principal))
  (match (map-get? authorized-oracles { oracle: oracle })
    oracle-info (get active oracle-info)
    false
  )
)

;; Private functions
(define-private (is-valid-amount (amount uint))
  (> amount u0)
)

(define-private (is-valid-string (str (string-ascii 100)))
  (> (len str) u0)
)

(define-private (is-valid-ascii-50 (str (string-ascii 50)))
  (> (len str) u0)
)

(define-private (is-valid-principal (user principal))
  (not (is-eq user 'SP000000000000000000002Q6VF78))
)

(define-private (is-data-fresh (timestamp uint))
  (let (
    (current-height stacks-block-height)
  )
    (<= (- current-height timestamp) MAX-DATA-AGE)
  )
)

(define-private (meets-carbon-threshold (carbon-offset uint))
  (>= carbon-offset MIN-CARBON-THRESHOLD)
)

(define-private (internal-transfer-credit (credit-id uint) (sender principal) (recipient principal))
  (let (
    (credit-info (unwrap! (get-credit-info credit-id) ERR-CREDIT-NOT-FOUND))
    (credit-amount (get amount credit-info))
    (sender-balance (get-user-balance sender))
    (recipient-balance (get-user-balance recipient))
    (sender-nft-count (get-balance sender))
    (recipient-nft-count (get-balance recipient))
  )
    (asserts! (>= sender-balance credit-amount) ERR-INSUFFICIENT-BALANCE)
    
    ;; Update credit ownership
    (map-set carbon-credits
      { credit-id: credit-id }
      (merge credit-info { issuer: recipient })
    )
    
    ;; Update balances
    (map-set user-balances
      { user: sender }
      { balance: (- sender-balance credit-amount) }
    )
    
    (map-set user-balances
      { user: recipient }
      { balance: (+ recipient-balance credit-amount) }
    )
    
    ;; Update NFT counts
    (map-set token-count
      { owner: sender }
      { count: (- sender-nft-count u1) }
    )
    
    (map-set token-count
      { owner: recipient }
      { count: (+ recipient-nft-count u1) }
    )
    
    (ok true)
  )
)

;; Public functions
(define-public (register-project (name (string-ascii 100)) (location (string-ascii 100)) (project-type (string-ascii 50)))
  (let (
    (project-id (var-get next-project-id))
  )
    (asserts! (is-valid-string name) ERR-INVALID-PARAMS)
    (asserts! (is-valid-string location) ERR-INVALID-PARAMS)
    (asserts! (is-valid-ascii-50 project-type) ERR-INVALID-PARAMS)
    
    (map-set project-registry
      { project-id: project-id }
      {
        name: name,
        location: location,
        project-type: project-type,
        verified: false,
        total-credits: u0,
        oracle-enabled: false,
        data-source: none
      }
    )
    
    (var-set next-project-id (+ project-id u1))
    (ok project-id)
  )
)

(define-public (issue-credit (amount uint) (project-type (string-ascii 50)) (project-id-opt (optional uint)))
  (let (
    (credit-id (var-get next-credit-id))
    (current-block stacks-block-height)
    (current-nft-count (get-balance tx-sender))
  )
    (asserts! (is-valid-amount amount) ERR-INVALID-AMOUNT)
    (asserts! (is-valid-ascii-50 project-type) ERR-INVALID-PARAMS)
    
    ;; Validate project-id if provided
    (match project-id-opt
      some-id (asserts! (is-some (get-project-info some-id)) ERR-INVALID-PARAMS)
      true
    )
    
    ;; Create credit as NFT
    (map-set carbon-credits
      { credit-id: credit-id }
      {
        issuer: tx-sender,
        amount: amount,
        project-type: project-type,
        verification-status: false,
        created-at: current-block,
        retired: false,
        project-id: none,
        oracle-generated: false,
        data-source: none
      }
    )
    
    ;; Update project-id after validation if provided
    (match project-id-opt
      some-id (map-set carbon-credits
        { credit-id: credit-id }
        {
          issuer: tx-sender,
          amount: amount,
          project-type: project-type,
          verification-status: false,
          created-at: current-block,
          retired: false,
          project-id: (some some-id),
          oracle-generated: false,
          data-source: none
        }
      )
      true
    )
    
    ;; Update balances
    (map-set user-balances
      { user: tx-sender }
      { balance: (+ (get-user-balance tx-sender) amount) }
    )
    
    ;; Update NFT count
    (map-set token-count
      { owner: tx-sender }
      { count: (+ current-nft-count u1) }
    )
    
    ;; Update counters
    (var-set next-credit-id (+ credit-id u1))
    (var-set last-token-id credit-id)
    (var-set total-credits-issued (+ (var-get total-credits-issued) amount))
    
    (ok credit-id)
  )
)

;; Oracle management functions
(define-public (authorize-oracle (validated-oracle principal) (validated-data-source (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (is-valid-principal validated-oracle) ERR-INVALID-PARAMS)
    (asserts! (is-valid-string validated-data-source) ERR-INVALID-PARAMS)
    
    (map-set authorized-oracles
      { oracle: validated-oracle }
      {
        active: true,
        data-source: validated-data-source,
        last-update: stacks-block-height
      }
    )
    
    (ok true)
  )
)

(define-public (revoke-oracle (validated-oracle principal))
  (let (
    (oracle-info (unwrap! (get-oracle-info validated-oracle) ERR-ORACLE-NOT-AUTHORIZED))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (is-valid-principal validated-oracle) ERR-INVALID-PARAMS)
    
    (map-set authorized-oracles
      { oracle: validated-oracle }
      {
        active: false,
        data-source: (get data-source oracle-info),
        last-update: (get last-update oracle-info)
      }
    )
    
    (ok true)
  )
)

(define-public (enable-project-oracle (validated-project-id uint) (validated-data-source (string-ascii 100)))
  (let (
    (project-info (unwrap! (get-project-info validated-project-id) ERR-INVALID-PARAMS))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (is-valid-string validated-data-source) ERR-INVALID-PARAMS)
    (asserts! (is-valid-amount validated-project-id) ERR-INVALID-PARAMS)
    
    (map-set project-registry
      { project-id: validated-project-id }
      {
        name: (get name project-info),
        location: (get location project-info),
        project-type: (get project-type project-info),
        verified: (get verified project-info),
        total-credits: (get total-credits project-info),
        oracle-enabled: true,
        data-source: (some validated-data-source)
      }
    )
    
    (ok true)
  )
)

;; Oracle data submission
(define-public (submit-environmental-data (project-id uint) (carbon-offset uint) (data-source (string-ascii 100)))
  (let (
    (data-id (var-get next-data-id))
    (oracle-info (unwrap! (get-oracle-info tx-sender) ERR-ORACLE-NOT-AUTHORIZED))
    (project-info (unwrap! (get-project-info project-id) ERR-INVALID-PARAMS))
    (current-block stacks-block-height)
    (project-data-source (get data-source project-info))
  )
    (asserts! (get active oracle-info) ERR-ORACLE-NOT-AUTHORIZED)
    (asserts! (get oracle-enabled project-info) ERR-INVALID-DATA-SOURCE)
    (asserts! (is-valid-amount carbon-offset) ERR-INVALID-AMOUNT)
    (asserts! (is-valid-string data-source) ERR-INVALID-PARAMS)
    (asserts! (meets-carbon-threshold carbon-offset) ERR-THRESHOLD-NOT-MET)
    
    ;; Validate data source matches project configuration
    (asserts! (is-some project-data-source) ERR-INVALID-DATA-SOURCE)
    (asserts! (is-eq data-source (unwrap! project-data-source ERR-INVALID-DATA-SOURCE)) ERR-INVALID-DATA-SOURCE)
    
    ;; Store environmental data
    (map-set environmental-data
      { data-id: data-id }
      {
        oracle: tx-sender,
        project-id: project-id,
        carbon-offset: carbon-offset,
        timestamp: current-block,
        data-source: data-source,
        processed: false
      }
    )
    
    ;; Update oracle last update time
    (map-set authorized-oracles
      { oracle: tx-sender }
      {
        active: (get active oracle-info),
        data-source: (get data-source oracle-info),
        last-update: current-block
      }
    )
    
    (var-set next-data-id (+ data-id u1))
    (ok data-id)
  )
)

;; Process environmental data and generate credits
(define-public (process-environmental-data (data-id uint) (recipient principal))
  (let (
    (env-data (unwrap! (get-environmental-data data-id) ERR-CREDIT-NOT-FOUND))
    (oracle-info (unwrap! (get-oracle-info (get oracle env-data)) ERR-ORACLE-NOT-AUTHORIZED))
    (project-info (unwrap! (get-project-info (get project-id env-data)) ERR-INVALID-PARAMS))
    (credit-id (var-get next-credit-id))
    (current-block stacks-block-height)
    (carbon-offset (get carbon-offset env-data))
    (data-timestamp (get timestamp env-data))
    (current-nft-count (get-balance recipient))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (not (get processed env-data)) ERR-ALREADY-VERIFIED)
    (asserts! (is-data-fresh data-timestamp) ERR-DATA-TOO-OLD)
    (asserts! (is-valid-principal recipient) ERR-INVALID-PARAMS)
    (asserts! (meets-carbon-threshold carbon-offset) ERR-THRESHOLD-NOT-MET)
    
    ;; Mark environmental data as processed
    (map-set environmental-data
      { data-id: data-id }
      {
        oracle: (get oracle env-data),
        project-id: (get project-id env-data),
        carbon-offset: (get carbon-offset env-data),
        timestamp: (get timestamp env-data),
        data-source: (get data-source env-data),
        processed: true
      }
    )
    
    ;; Create oracle-generated credit as NFT
    (map-set carbon-credits
      { credit-id: credit-id }
      {
        issuer: recipient,
        amount: carbon-offset,
        project-type: (get project-type project-info),
        verification-status: true, ;; Oracle data is pre-verified
        created-at: current-block,
        retired: false,
        project-id: (some (get project-id env-data)),
        oracle-generated: true,
        data-source: (some (get data-source env-data))
      }
    )
    
    ;; Update recipient balances
    (map-set user-balances
      { user: recipient }
      { balance: (+ (get-user-balance recipient) carbon-offset) }
    )
    
    ;; Update NFT count
    (map-set token-count
      { owner: recipient }
      { count: (+ current-nft-count u1) }
    )
    
    ;; Update project total credits
    (map-set project-registry
      { project-id: (get project-id env-data) }
      {
        name: (get name project-info),
        location: (get location project-info),
        project-type: (get project-type project-info),
        verified: (get verified project-info),
        total-credits: (+ (get total-credits project-info) carbon-offset),
        oracle-enabled: (get oracle-enabled project-info),
        data-source: (get data-source project-info)
      }
    )
    
    ;; Update counters
    (var-set next-credit-id (+ credit-id u1))
    (var-set last-token-id credit-id)
    (var-set total-credits-issued (+ (var-get total-credits-issued) carbon-offset))
    (var-set total-oracle-credits (+ (var-get total-oracle-credits) carbon-offset))
    
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
    (current-owner (get issuer credit-info))
  )
    (asserts! (is-valid-principal recipient) ERR-INVALID-PARAMS)
    (asserts! (is-eq tx-sender current-owner) ERR-UNAUTHORIZED)
    (asserts! (not (get retired credit-info)) ERR-INVALID-OFFSET)
    
    (try! (internal-transfer-credit credit-id tx-sender recipient))
    (ok true)
  )
)

(define-public (retire-credit (credit-id uint))
  (let (
    (credit-info (unwrap! (get-credit-info credit-id) ERR-CREDIT-NOT-FOUND))
    (credit-amount (get amount credit-info))
    (current-owner (get issuer credit-info))
    (sender-balance (get-user-balance tx-sender))
    (sender-nft-count (get-balance tx-sender))
  )
    (asserts! (is-eq tx-sender current-owner) ERR-UNAUTHORIZED)
    (asserts! (not (get retired credit-info)) ERR-INVALID-OFFSET)
    (asserts! (get verification-status credit-info) ERR-UNAUTHORIZED)
    (asserts! (>= sender-balance credit-amount) ERR-INSUFFICIENT-BALANCE)
    
    ;; Mark credit as retired
    (map-set carbon-credits
      { credit-id: credit-id }
      (merge credit-info { retired: true })
    )
    
    ;; Update balance
    (map-set user-balances
      { user: tx-sender }
      { balance: (- sender-balance credit-amount) }
    )
    
    ;; Update NFT count (burned)
    (map-set token-count
      { owner: tx-sender }
      { count: (- sender-nft-count u1) }
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

;; NFT Marketplace functions
(define-public (list-for-sale (nft-id uint) (price uint))
  (let (
    (credit-info (unwrap! (get-credit-info nft-id) ERR-CREDIT-NOT-FOUND))
    (current-owner (get issuer credit-info))
  )
    (asserts! (is-eq tx-sender current-owner) ERR-UNAUTHORIZED)
    (asserts! (not (get retired credit-info)) ERR-INVALID-OFFSET)
    (asserts! (is-valid-amount price) ERR-INVALID-AMOUNT)
    
    (map-set market-listings
      { nft-id: nft-id }
      {
        price: price,
        seller: tx-sender
      }
    )
    
    (ok true)
  )
)

(define-public (unlist-from-sale (nft-id uint))
  (let (
    (listing-info (unwrap! (get-market-listing nft-id) ERR-CREDIT-NOT-FOUND))
    (seller (get seller listing-info))
  )
    (asserts! (is-eq tx-sender seller) ERR-UNAUTHORIZED)
    (asserts! (is-some (get-credit-info nft-id)) ERR-INVALID-NFT-ID)
    
    (begin
      (map-delete market-listings { nft-id: nft-id })
      (ok true)
    )
  )
)

(define-public (buy-listed-nft (nft-id uint))
  (let (
    (listing-info (unwrap! (get-market-listing nft-id) ERR-CREDIT-NOT-FOUND))
    (seller (get seller listing-info))
    (price (get price listing-info))
  )
    (asserts! (not (is-eq tx-sender seller)) ERR-INVALID-PARAMS)
    (asserts! (is-some (get-credit-info nft-id)) ERR-INVALID-NFT-ID)
    
    ;; Transfer payment (simplified - in real implementation, use STX transfer)
    ;; Transfer NFT
    (try! (transfer nft-id seller tx-sender))
    
    ;; Remove listing
    (begin
      (map-delete market-listings { nft-id: nft-id })
      (ok true)
    )
  )
)