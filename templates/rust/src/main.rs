// SPDX-FileCopyrightText: © 2024 Technical University of Crete
// SPDX-License-Identifier: MIT

use serde_json::{json,Value};
use std::env;
use base64::{decode, encode};
use std::str;

mod lambda_function;

fn decode_base64_to_json(base64_string: &str) -> Result<Value, String> {
    // Decode the base64 string
    let decoded_bytes = decode(base64_string).map_err(|e| format!("Base64 decoding error: {}", e))?;
    
    // Convert bytes to string
    let decoded_str = str::from_utf8(&decoded_bytes).map_err(|e| format!("UTF-8 conversion error: {}", e))?;
    
    // Parse the string as JSON
    let json_value: Value = serde_json::from_str(decoded_str).map_err(|e| format!("JSON parsing error: {}", e))?;
    
    Ok(json_value)
}

fn main() {
    // Read environment variables
    let event_input_base64 = match env::var("LAMBDA_EVENT") {
        Ok(val) => val,
        Err(_) => encode("{\"\":\"\"}")
    };

    let context_input_base64 = match env::var("LAMBDA_CONTEXT") {
        Ok(val) => val,
        Err(_) => encode("{\"\":\"\"}")
    };

    // Check and parse the environment variables if they exist
    let event = match decode_base64_to_json(&event_input_base64) {
        Ok(json_value) => json_value,
        Err(_) => json!({"": ""})
    };

    let context = match decode_base64_to_json(&context_input_base64) {
        Ok(json_value) => json_value,
        Err(_) => json!({"": ""})
    };
    
    println!("Environment variable LAMBDA_EVENT: {}", event);
    println!("Environment variable LAMBDA_CONTEXT: {}", context);

    // Call lambda function
    let response = lambda_function::lambda_handler(&event, &context);

    // FIXME: return response
    println!("{}", response.to_string());
}