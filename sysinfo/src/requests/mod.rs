/**
 *  These are needed in your Cargo.toml file:
 *   tokio = { version = "1", features = ["full"] }    # Full support for async operations
 *   reqwest = { version = "0.11" }
 */

 use reqwest::Client;
 use tokio::runtime::Runtime;
 use tokio::task;
 use tokio::runtime::Handle;

#[allow(dead_code)]
static BASE_URL: &str = "http://localhost:3000"; // TODO: maybe DO NOT hardcode this

/// Sends a request to the specified URL and returns the response as a `String`.
///
/// # Arguments
///
/// * `url` - A string slice that holds the URL to request.
///
/// # Returns
///
pub fn request(url: &str) -> String {
    // Create the full URL for the request
    let full_url: String = format!("{}{}", BASE_URL, url);
    
    // Create the client
    let client: Client = Client::new();
    
    // Use block_in_place to perform the request in a blocking manner
    let result: String = task::block_in_place(|| {
        // Check if we are already in a Tokio runtime
        if Handle::try_current().is_ok() {
            // If a runtime exists, use the current runtime to make the request
            let rt: Handle = Handle::current();
            rt.block_on(async {
                match client.get(&full_url).send().await {
                    Ok(response) => {
                        if response.status().is_success() {
                            response.text().await.unwrap_or_else(|_| "0".to_string())
                        } else {
                            "0".to_string()
                        }
                    }
                    Err(_) => "0".to_string(),
                }
            })
        } else {
            // If no runtime exists, create a new runtime to make the request
            let new_runtime = Runtime::new().expect("Failed to create runtime");
            new_runtime.block_on(async {
                match client.get(&full_url).send().await {
                    Ok(response) => {
                        if response.status().is_success() {
                            response.text().await.unwrap_or_else(|_| "0".to_string())
                        } else {
                            "0".to_string()
                        }
                    }
                    Err(_) => "0".to_string(),
                }
            })
        }
    });

    result
}