#![allow(
    non_camel_case_types,
    non_snake_case,
    clippy::pub_underscore_fields,
    clippy::style,
    clippy::empty_structs_with_brackets,
    clippy::too_many_arguments,
    clippy::type_complexity,
    missing_docs,
    dead_code
)]

pub mod counter;

// Re-export provider types and other bindings from the git dependency
// (but not counter, since we have our own local implementation)
pub use commonware_avs_bindings_git::{ReadOnlyProvider, WalletProvider};
pub use commonware_avs_bindings_git::{blsapkregistry, blssigcheckoperatorstateretriever};
