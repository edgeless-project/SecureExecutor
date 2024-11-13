use hyper::service::{make_service_fn, service_fn};
use hyper::{Body, Request, Response, Server};
use std::convert::Infallible;
use std::net::SocketAddr;

#[tokio::main]
async fn main() {
    // Set the address to serve on: localhost at port 3000
    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));

    // Create a service handler for incoming requests
    let make_svc = make_service_fn(|_conn| async {
        Ok::<_, Infallible>(service_fn(handle_request))
    });

    // Create the server
    let server = Server::bind(&addr).serve(make_svc);

    // println!("Server running on http://{}", addr);

    // Run the server
    if let Err(e) = server.await {
        eprintln!("Server error: {}", e);
    }
}

// ===================================================================================
// ===================================================================================
// ===================================================================================

// This function handles incoming requests and returns the appropriate response based on the API
async fn handle_request(req: Request<Body>) -> Result<Response<Body>, Infallible> {
    let mut sys = sysinfo::System::new_all();
    let mut disks = sysinfo::Disks::new();

    let path = req.uri().path();

    let response = match path {
        // ===================================================================================

        // Refresh all system info 
        "/system/refresh_all" => {
            sys.refresh_all();
            // println!("> sys.refresh_all();");
            Response::new(Body::from("OK"))
        }

        // ===================================================================================

        // Refresh all system info 
        "/system/refresh_all/processes" => {
            sys.refresh_all();
            // println!("> sys.refresh_all(); # Processes");
            let _resp = format!("{:?}", sys.processes());
            Response::new(Body::from(_resp))
        }

        // ===================================================================================

        // Total memory
        "/system/total_memory" => {
            // println!("> sys.total_memory() => {}", sys.total_memory());
            Response::new(Body::from(sys.total_memory().to_string()))
        }
        
        // // ===================================================================================

        // Free memory
        "/system/free_memory" => {
            // println!("> sys.free_memory() => {}", sys.free_memory());
            Response::new(Body::from(sys.free_memory().to_string()))
        }
        
        
        // ===================================================================================

        // Available memory
        "/system/available_memory" => {
            // println!("> sys.available_memory() => {}", sys.available_memory());
            Response::new(Body::from(sys.available_memory().to_string()))
        }

        // ===================================================================================

        // Load average
        "/system/load_average" => {
            // println!("> sys.load_average()");
            let load = sysinfo::System::load_average();
            let resp = format!("{},{},{}", load.one, load.five, load.fifteen);
            Response::new(Body::from(resp))
        }
        
        // ===================================================================================

        // Disks refresh list
        "/disks/refresh_list" => {
            // println!("disks.refresh_list()");
            disks.refresh_list();
            let resp: String = format!("{:?}", disks);
            Response::new(Body::from(resp))
        }

        // ===================================================================================

        // Disks refresh
        "/disks/refresh" => {
            // println!("disks.refresh()");
            disks.refresh_list();
            disks.refresh();
            let resp: String = format!("{:?}", disks);
            Response::new(Body::from(resp))
        }       

        // ===================================================================================
        
        //  Not valid request
        _ => {
            eprintln!("> NOT VALID request [{}]", path); 
            Response::new(Body::from("Not found"))
        },
    };

    Ok(response)
}
