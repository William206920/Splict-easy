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
/// A positive transfer from a debtor to a creditor, expressed in integer cents.
pub(all) struct Transfer {
  from : String
  to : String
  amount_cents : Int64
} derive(Debug)

///|
pub extend Transfer with @debug.Debug::{to_repr}

///|
/// Always follows Ledger.people order. Positive balance means receivable.
pub(all) struct PersonBalance {
  person : String
  paid_cents : Int64
  owed_cents : Int64
  balance_cents : Int64
} derive(Debug)

///|
pub extend PersonBalance with @debug.Debug::{to_repr}

///|
pub(all) struct BalanceSheet {
  total_cents : Int64
  balances : Array[PersonBalance]
} derive(Debug)

///|
pub extend BalanceSheet with @debug.Debug::{to_repr}

///|
/// Core settlement data only; formatted reports belong to stage 5.
pub(all) struct Settlement {
  total_cents : Int64
  balances : Array[PersonBalance]
  transfers : Array[Transfer]
} derive(Debug)

///|
pub extend Settlement with @debug.Debug::{to_repr}

///|
/// Read-only fields; allocated shares follow Ledger.people order.
pub struct PaymentReport {
  payer : String
  amount_cents : Int64
  split_mode : SplitMode
  shares : Array[Share]
  description : String
  date : String
} derive(Debug)

///|
pub extend PaymentReport with @debug.Debug::{to_repr}

///|
/// Created from validated input. No source arrays are reused.
pub struct SettlementReport {
  total_cents : Int64
  payments : Array[PaymentReport]
  balances : Array[PersonBalance]
  transfers : Array[Transfer]
} derive(Debug)

///|
pub extend SettlementReport with @debug.Debug::{to_repr}

///|
pub(all) enum ReportFormat {
  Markdown
  Html
  Json
} derive(Debug)

///|
pub extend ReportFormat with @debug.Debug::{to_repr}
