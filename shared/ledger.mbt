///|
/// Each payment chooses exactly one allocation mode.
pub(all) enum SplitMode {
  Equal
  Exact
} derive(Debug, Eq)

///|
pub extend SplitMode with @debug.Debug::{to_repr}

///|
pub extend SplitMode with Eq::{equal, not_equal}

///|
pub(all) struct Share {
  person : String
  amount_cents : Int64
} derive(Debug)

///|
pub extend Share with @debug.Debug::{to_repr}

///|
/// Untrusted input: always call validate_ledger before using a ledger.
pub(all) struct Payment {
  payer : String
  amount_cents : Int64
  split_mode : SplitMode
  participants : Array[String]
  shares : Array[Share]
  description : String
  date : String
} derive(Debug)

///|
pub extend Payment with @debug.Debug::{to_repr}

///|
pub(all) struct Ledger {
  people : Array[String]
  payments : Array[Payment]
  ambiguous : Array[String]
} derive(Debug)

///|
pub extend Ledger with @debug.Debug::{to_repr}

///|
/// Declared for the shared contract; settlement is implemented in stage 3.
pub(all) struct Transfer {
  from : String
  to : String
  amount_cents : Int64
} derive(Debug)

///|
pub extend Transfer with @debug.Debug::{to_repr}
