#![allow(clippy::result_large_err)]

//! Log projector for Angzarr.
//!
//! Pretty-prints events to stdout (or a file) with ANSI-colored categorization
//! and optional JSON decoding via `prost-reflect`. If `DESCRIPTOR_PATH` is set,
//! events are decoded to JSON; otherwise they're displayed as hex dumps.

pub mod log;
pub mod output;

pub use log::{LogService, LogServiceHandle};
pub use output::{
    BoxedLogOutput, ColorizingOutput, DecodedEvent, EventCategory, EventColorConfig, FileOutput,
    LogOutput, StdoutOutput,
};
