// SPDX-FileCopyrightText: © 2024 Technical University of Crete
// SPDX-License-Identifier: MIT

// ----------------------------------------------------------------------------------
//          MODIFY THIS SOURCE FILE TO IMPLEMENT REQUIRED LAMBDA FUNCTION
// ----------------------------------------------------------------------------------

use serde_json::{json, Value};

pub fn lambda_handler(_event: &Value, _context: &Value) -> Value {
    // TODO: implement your lambda function
    println!("Hello Rust");

    // Create response
    let response = json!({"status": "success"});
    response
}
