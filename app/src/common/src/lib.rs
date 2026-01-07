pub mod types;
pub mod validator;

// Re-export from commonware-avs-core eigenlayer module
pub use commonware_avs_core::eigenlayer::config::AvsDeployment;
pub use commonware_avs_core::eigenlayer::network::{EigenStakingClient, QuorumInfo};

pub use types::CounterTaskData;
pub use validator::CounterValidator;
