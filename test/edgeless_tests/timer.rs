// SPDX-FileCopyrightText: © 2024 Technical University of Crete
// SPDX-License-Identifier: MIT

/**
 * This source code is used in the edgeless_node crate of the EDGELESS project to calculate the start up latency
 * of the function that is going to be executed.
 * 
 * More specifically, the start timer can be initialised inside the ‘RuntimeTask::run()’ function of 
 * base_runtime/runtime.rs, which is responsible for handling requests, as shown below:
 * 
 * pub async fn run(&mut self) {
 *      ...
 *      while let Some(req) = self.receiver.next().await {
 *          match req {
 *              RuntimeRequest::Start(spawn_request) => {   
 *                  timer::start_timer(); // A new Start Request was received
 *                  self.start_function(spawn_request).await;
 *              }
 *          ...
 * 
 * The duration can then be calculated as soon as the edgefunction_handle_init() function is 
 * executed from the wasmi_runner/mod.rs file. This function internally executes the 
 * handle_init() callback of the target function.
 * 
 *      ...   
 *      let ret = tokio::task::block_in_place(|| {
 *      self.edgefunctione_handle_init
 *          .call(...)
 *      });
 *      log::info!(">>>>  Start-up latency: {}ms", timer::get_duration());
 *      ...
 * 
 * Even though this approach includes the entire initialization of the function rather than 
 * just the start-up time, it can provide valuable initial measurements to determine the 
 * level of future optimization that would be required.
 * 
 * In the next phase of verification, the duration API call can be invoked from a different location
 * to determine only the initialization time.
 * 
 */
use std::sync::Mutex;
use std::time::{Duration, Instant};

// Global Timer instance, initialized as None
static TIMER: Mutex<Option<Instant>> = Mutex::new(None);

pub fn start_timer() {
    let mut start = TIMER.lock().unwrap();     // Lock the mutex for safe access
    *start = Some(Instant::now());                                              // Set the start time
}

pub fn stop_timer() -> Duration {
    let start = TIMER.lock().unwrap();         // Lock the mutex to access the start time
    if let Some(start_instant) = *start {
        return start_instant.elapsed();
    } else {
        panic!("Timer was not started!");
    }
}

pub fn get_duration() -> u128 {
    let duration = stop_timer();
    duration.as_millis()
}
