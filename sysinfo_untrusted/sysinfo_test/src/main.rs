/**
 * Based on e98477c48823f79d1ae3a490ab17f071b4f70293 commit
 * of https://github.com/edgeless-project/edgeless.git
 * 
 * Last tested on : 12 Noe 2024
 */
use sysinfo;

// ===============================================================================================
//  __  __       _       
//   \/  | __ _(_)_ __  
//   |\/| |/ _` | | '_ \ 
//   |  | | (_| | | | | |
//  _|  |_|\__,_|_|_| |_|
// ===============================================================================================               
 
fn main() {
    println!("~~~~~ [ START TESTING ] ~~~~~");
    edgeless_node_lib_get_capabilities();
    println!("");
    println!("------------------------------");
    println!("");
    edgeless_node_agent_keep_alive();
    println!("------------------------------");
    println!("");
    extra_tests();
    println!("~~~~~ [ STOP TESTING ] ~~~~~");
}

// ===============================================================================================
// _____                 _   _                 
// |  ___|   _ _ __   ___| |_(_) ___  _ __  ___ 
// | |_ | | | | '_ \ / __| __| |/ _ \| '_ \/ __|
// |  _|| |_| | | | | (__| |_| | (_) | | | \__ \
// |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
// ===============================================================================================                                          

/**
 * Code exist in: edgeless/edgeless_node/src/lib.rs
 */
fn edgeless_node_lib_get_capabilities(){
    println!("> TEST edgeless_node/src/lib.rs - get_capabilities(...)");
    println!("");
    if !sysinfo::IS_SUPPORTED_SYSTEM {
        // log::warn!("sysinfo does not support (yet) this OS");
        println!("sysinfo does not support (yet) this OS");
    }

    let mut sys = sysinfo::System::new();
    sys.refresh_all();

    let mut disks = sysinfo::Disks::new();
    disks.refresh_list();
    disks.refresh();
    let unique_total_space = disks
        .iter()
        .map(|x| (x.name().to_str().unwrap_or_default(), x.total_space()))
        .collect::<std::collections::BTreeMap<&str, u64>>();

    let mut model_name_set = std::collections::HashSet::new();
    let mut clock_freq_cpu_set = std::collections::HashSet::new();
    for processor in sys.cpus() {
        model_name_set.insert(processor.brand());
        clock_freq_cpu_set.insert(processor.frequency());
    }
    let model_name_cpu = match model_name_set.iter().next() {
        Some(val) => val.to_string(),
        None => "".to_string(),
    };
    if model_name_set.len() > 1 {
        // log::debug!("CPUs have different models, using: {}", model_name_cpu);
        println!("CPUs have different models, using: {}", model_name_cpu);
    }
    let clock_freq_cpu = match clock_freq_cpu_set.iter().next() {
        Some(val) => *val as f32,
        None => 0.0,
    };
    if clock_freq_cpu_set.len() > 1 {
        // log::debug!("CPUs have different frequencies, using: {}", clock_freq_cpu);
        println!("CPUs have different frequencies, using: {}", clock_freq_cpu);
    }
    // Original code:
        // GPU information is not (yet) inferred automatically
        // edgeless_api::node_registration::NodeCapabilities {
        //     num_cpus: user_node_capabilities.num_cpus.unwrap_or(sys.cpus().len() as u32),
        //     model_name_cpu: user_node_capabilities.model_name_cpu.unwrap_or(model_name_cpu),
        //     clock_freq_cpu: user_node_capabilities.clock_freq_cpu.unwrap_or(clock_freq_cpu),
        //     num_cores: user_node_capabilities.num_cores.unwrap_or(sys.physical_core_count().unwrap_or(1) as u32),
        //     mem_size: user_node_capabilities.mem_size.unwrap_or((sys.total_memory() / (1024 * 1024)) as u32),
        //     labels: user_node_capabilities.labels.unwrap_or_default(),
        //     is_tee_running: user_node_capabilities.is_tee_running.unwrap_or(false),
        //     has_tpm: user_node_capabilities.has_tpm.unwrap_or(false),
        //     runtimes,
        //     disk_tot_space: user_node_capabilities
        //         .disk_tot_space
        //         .unwrap_or((unique_total_space.values().sum::<u64>() / (1024 * 1024)) as u32),
        //     num_gpus: user_node_capabilities.num_gpus.unwrap_or_default(),
        //     model_name_gpu: user_node_capabilities.model_name_gpu.unwrap_or_default(),
        //     mem_size_gpu: user_node_capabilities.mem_size_gpu.unwrap_or_default(),
        // }

    // Simplified to test sysinfo functionality:
    println!("1) sys.cpus().len() as u32: {}",                                             sys.cpus().len() as u32);
    println!("2) model_name_cpu: {}",                                                      model_name_cpu);
    println!("3) clock_freq_cpu: {}",                                                      clock_freq_cpu);
    println!("4) sys.physical_core_count().unwrap_or(1) as u32: {}",                       sys.physical_core_count().unwrap_or(1) as u32);
    println!("5) (sys.total_memory() / (1024 * 1024)) as u32: {}",                         (sys.total_memory() / (1024 * 1024)) as u32);
    println!("6) (unique_total_space.values().sum::<u64>() / (1024 * 1024)) as u32: {}",   (unique_total_space.values().sum::<u64>() / (1024 * 1024)) as u32);
}

// ===============================================================================================

/**
 * Code exist in: edgeless/edgeless_node/src/agent/mod.rs
 */
fn edgeless_node_agent_keep_alive(){
    println!("> TEST edgeless_node/src/agent/mod.rs - AgentRequest::KeepAlive(...)");
    println!("");
    // Internal data structures to query system/process information.
    let mut sys = sysinfo::System::new();
    if !sysinfo::IS_SUPPORTED_SYSTEM {
        // log::warn!("sysinfo does not support (yet) this OS");
        println!("sysinfo does not support (yet) this OS");
    }
    let mut networks = sysinfo::Networks::new_with_refreshed_list();
    let mut disks = sysinfo::Disks::new();
    let my_pid = sysinfo::Pid::from_u32(std::process::id());
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    // Refresh system/process information.
    sys.refresh_all();
    networks.refresh();
    disks.refresh_list();
    disks.refresh();

    let to_kb = |x| (x / 1024) as i32;
    let proc = sys.process(my_pid).unwrap();
    let load_avg = sysinfo::System::load_average();
    let mut tot_rx_bytes: i64 = 0;
    let mut tot_rx_pkts: i64 = 0;
    let mut tot_rx_errs: i64 = 0;
    let mut tot_tx_bytes: i64 = 0;
    let mut tot_tx_pkts: i64 = 0;
    let mut tot_tx_errs: i64 = 0;
    for (_interface_name, network) in &networks {
        tot_rx_bytes += network.total_received() as i64;
        tot_rx_pkts += network.total_packets_received() as i64;
        tot_rx_errs += network.total_errors_on_received() as i64;
        tot_tx_bytes += network.total_packets_transmitted() as i64;
        tot_tx_pkts += network.total_transmitted() as i64;
        tot_tx_errs += network.total_errors_on_transmitted() as i64;
    }
    let mut disk_tot_reads = 0;
    let mut disk_tot_writes = 0;
    for process in sys.processes().values() {
        let disk_usage = process.disk_usage();
        disk_tot_reads += disk_usage.total_read_bytes as i64;
        disk_tot_writes += disk_usage.total_written_bytes as i64;
    }
    let unique_available_space = disks
        .iter()
        .map(|x| (x.name().to_str().unwrap_or_default(), x.total_space()))
        .collect::<std::collections::BTreeMap<&str, u64>>();

    // Original code:
        // let health_status = edgeless_api::node_management::NodeHealthStatus {
        //     mem_free: to_kb(sys.free_memory()),
        //     mem_used: to_kb(sys.used_memory()),
        //     mem_available: to_kb(sys.available_memory()),
        //     proc_cpu_usage: proc.cpu_usage() as i32,
        //     proc_memory: to_kb(proc.memory()),
        //     proc_vmemory: to_kb(proc.virtual_memory()),
        //     load_avg_1: (load_avg.one * 100_f64).round() as i32,
        //     load_avg_5: (load_avg.five * 100_f64).round() as i32,
        //     load_avg_15: (load_avg.fifteen * 100_f64).round() as i32,
        //     tot_rx_bytes,
        //     tot_rx_pkts,
        //     tot_rx_errs,
        //     tot_tx_bytes,
        //     tot_tx_pkts,
        //     tot_tx_errs,
        //     disk_free_space: unique_available_space.values().sum::<u64>() as i64,
        //     disk_tot_reads,
        //     disk_tot_writes,
        //     gpu_load_perc: crate::gpu_info::get_gpu_load(),
        //     gpu_temp_cels: (crate::gpu_info::get_gpu_temp() * 1000.0) as i32,
        // };

    // Simplified to test sysinfo functionality:
    println!("01) to_kb(sys.free_memory(): {}",                             to_kb(sys.free_memory()));
    println!("02) to_kb(sys.used_memory(): {}",                             to_kb(sys.used_memory()));
    println!("03) to_kb(sys.available_memory()): {}",                       to_kb(sys.available_memory()));
    println!("04) proc.cpu_usage() as i32: {}",                             proc.cpu_usage() as i32);
    println!("05) to_kb(proc.memory()): {}",                                to_kb(proc.memory()));
    println!("06) to_kb(proc.virtual_memory()): {}",                        to_kb(proc.virtual_memory()));
    println!("07) (load_avg.one * 100_f64).round() as i32: {}",             (load_avg.one * 100_f64).round() as i32);
    println!("08) (load_avg.five * 100_f64).round() as i32: {}",            (load_avg.five * 100_f64).round() as i32);
    println!("09) (load_avg.fifteen * 100_f64).round() as i32: {}",         (load_avg.fifteen * 100_f64).round() as i32);
    println!("10) tot_rx_bytes: {}",                                        tot_rx_bytes);
    println!("11) tot_rx_pkts: {}",                                         tot_rx_pkts);
    println!("12) tot_rx_errs: {}",                                         tot_rx_errs);
    println!("13) tot_tx_bytes: {}",                                        tot_tx_bytes);
    println!("14) tot_tx_pkts: {}",                                         tot_tx_pkts);
    println!("15) tot_tx_errs: {}",                                         tot_tx_errs);
    println!("16) unique_available_space.values().sum::<u64>() as i64: {}", unique_available_space.values().sum::<u64>() as i64);
    println!("17) disk_tot_reads: {}",                                      disk_tot_reads);
    println!("18) disk_tot_writes: {}",                                     disk_tot_writes);
}

fn extra_tests(){
    println!("> Extra tests:");
    println!("");
    // Internal data structures to query system/process information.
    let mut sys = sysinfo::System::new();
    if !sysinfo::IS_SUPPORTED_SYSTEM {
        // log::warn!("sysinfo does not support (yet) this OS");
        println!("sysinfo does not support (yet) this OS");
    }

    let _my_pid = sysinfo::Pid::from_u32(std::process::id());
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    // Refresh system/process information.
    sys.refresh_all();

    println!("1) My PID: {:?}", _my_pid);               // OK
    println!("2) Sys: {:?}", sys);                      // Error with: LoadAvg, total memory, free memory, total swap, free swap
    println!("3) CPUs: {:?}", sys.cpus());              // OK
    println!("4) Processes: {:?}", sys.processes());    // Error with: Only one process is retrieved
}