# SecureExecutor
$SecureExecutor$ is a utility that automatically builds and runs [SCONE](https://sconedocs.github.io/) containers.

These containers wrap C++/Python/Rust applications and are designed to run within SGX enclaves to leverage Trusted Execution Environment (TEE) functionality.

The ultimate goal of $SecureExecutor$ is to automate the process of running applications in enclaves. To achieve this, the utility was initially designed to collect minimal computational units, known as lambda functions, to build trusted images capable of leveraging TEEs. Following this, research activities are conducted to extend this functionality to a broader range of existing applications.

For this tool, the [Community/Evaluation edition](https://scontain.com/#services) of SCONE is used, providing services that run inside enclaves in prerelease mode. For this reason, before using the tool, first create an [account](https://sconedocs.github.io/registry/) and login in its registry.

## Usage
$SecureExecutor$  can take a large number of different input parameters. Just to name a few of them:
```bash
Usage: ./SecureExecutor [Option]... [Option]...                                                                                                                                              
Usage: ./SecureExecutor --lambda --function-name hello [--cpp/--rust/--python] [--new/--build/--run/--clean]                                                                                 
Usage: ./SecureExecutor --app --path Dockerfiles/apps/steganography.Dockerfile [--build/--run]                                                                                               
Usage: ./SecureExecutor --edgeless-node [--build/--run]                                                                                                                                      
Usage: ./SecureExecutor --edgeless-function --function-name hello [--rust/--python] [--new/--build]                                                                                          
                                                                                                                                                                                             
Options:                                                                                                                                                                                     
  -b, --build                         Use this flag to build the target image from the given function                                                                                        
  -c, --clean                         Clean the generated image (this requires to give the function function name you want to clean)                                                         
  -d, --dynamic                       In case you want to dynamically link your executable use this flag (only for --lambda in --cpp, this produces smaller in size images TBI)              
  -e, --env-var var                   You can use this, to pass multiple ENV vars during 'docker run ..'                                                                                     
  -f, --function-name function        Select the name of the function you want to build or run (requires --lambda/--edgeless-function)                                                       
  -g, --tag tag_name                  If you want to provide an optional tag for your image, do it using this flag                                                                           
  -h, --help                          Print this help menu and exit                                                                                                                          
  -n, --new                           Use this flag if you want to create a new lambda function                                                                                              
  -p, --path                          Use this flag to specify the path to the Dockerfile you want to use (requires --app)                                                                   
  -r, --run                           Pass this flag to run a container                                                                                                                      
  -s, --static                        In case you want to statically link your executable use this flag (only for --lambda in --cpp, this produces larger in size images, default operation) 
  -v, --volume absolute_path          If you want to bind mound a directory use this option (MUST provide an absolute path)                                                                  
                                                                                                                                                                                             
      --lambda                        Use this to build a lambda function                                                                                                                    
      --app                           Use this to build from a Dockerfile                                                                                                                    
      --edgeless-node                 Use the edgeless node as target                                                                                                                        
      --edgeless-function             Use this to build an edgeless-function                                                                                                                                                                                                                         
                                                                                                                                                                                             
      --cpp                           Use a cpp function as target (requires --lambda)                                                                                                       
      --python                        Use a python function as target (requires --lambda/--edgeless-function)                                                                                
      --rust                          Use a rust function as target (requires --lambda/--edgeless-function)                                                                                  

```

## Project Tree Explanation
```bash
.
├── doc                     # Extra documentation files for the repository
├── Dockerfiles             # Dockerfiles for base images, applications, and lambda functions
├── LAS                     # Initial scripts for Local Attestation
├── scripts                 # Auxiliary scripts to simplify tasks
├── src                     # Source code for SecureExecutor
├── sysinfo                 # Modified Sysinfo Rust crate code (see sysinfo problem related to EDGELESS)
├── sysinfo_untrusted       # Untrusted portion of sysinfo sources
├── templates               # Templates for creating target lambda functions
├── test                    # Test scripts
├── SecureExecutor          # Core of SecureExecutor (main function)
└── README.md               # This documentation file
```

## Lambdas
To understand how to create and run a lambda function, please read [this](./doc/lambda.md) file.

## Applications
For more information regarding the applications that $SecureExecutor$ has been tested on so far, please refer to [this](./doc/applications.md) file.
* Specifically to `EDGELESS` execute [edgeless_node in TEE](./doc/applications.md#edgeless)
* Specifically to `EDGELESS` execute [function using containers and (Rust/Python API) in TEE](./doc/edgeless-function.md)

### Demos
- EDGELESS: This [demo](https://www.youtube.com/watch?v=Fp0HqZN3FmY) video showcases the creation of the trusted binary for the EDGELESS node using $SecureExecutor$, followed by the execution of a function on the node within the EDGELESS platform.

## Dependencies
- A Linux based machine with Intel SGX capabilities (developed/tested on a NUC device that runs Ubuntu 22.04).
Read [this](./doc/system-setup.md) if you want to know how to setup a system that is ready to run this tool.

- [Docker](https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script)
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```
- [Rust](https://www.rust-lang.org/learn/get-started) (Only needed for EDGELESS, related to [sysinfo workaround](./doc/edgeless.md#sysinfo-workaround))
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```
## Known issues
- Attestation: To ensure end-to-end secure execution, the appropriate attestation mechanisms have yet to be integrated into the current system.

  See SCONE [CAS](https://sconedocs.github.io/cas_intro/), [LAS](https://sconedocs.github.io/LASIntro/) and [Initial LAS experiments in this repository](./LAS/).

- Encryption during transfer: To ensure end-to-end secure execution, encryption should also be enabled during the transmission of data from the client to the enclave.

- ~~Evaluate the system while running different workflows that contain diverse functions.~~
 Read [EDGELESS examples tested section](./doc/edgeless.md#examples-started-when-edgeless_node-executed-in-tee) to gain more information.

## Publication
[Zenodo](https://zenodo.org/records/13986642) | [IEEE Xplore](https://ieeexplore.ieee.org/document/10679349)

The following publication: ["SecureExecutor: An Automated Way to Leverage SCONE to Enhance Application Security"](https://ieeexplore.ieee.org/document/10679349) explains the high-level purpose of this tool and provides additional information about its internal behavior. Hence, it serves as a good starting point for understanding the tool’s internals.
A pre-print version, is also available [here](https://zenodo.org/records/13986642).

## Tests
This repository also includes an automated unit test mechanism. In the [test/](./test/) directory, the [run_tests.sh](./test/run_tests.sh) file is available to execute all tests.
```bash
./test/run_tests.sh
```

Test files exist in the respective folders in the [test/](./test/) directory.
If you want to run only for a specific case tests, then pass as an input argument the relative path.
```bash
# Syntax: ./test/run_tests.sh <file1_path> <file2_path> ...
./test/run_tests.sh ./test/lambdas/cpp.sh
```

## Cite
If you would like to cite this work in another publication, please use the following citation.

[Zenodo](https://zenodo.org/records/13986642)
```tex
[1]C. Spyridakis, A. Aktypi, T. Kyriakakisand S. Ioannidis, “SecureExecutor: An Automated Way to Leverage SCONE to Enhance Application Security”, Oct. 2024. doi: 10.5281/zenodo.13986642.
```

[IEEE Xplore](https://ieeexplore.ieee.org/document/10679349)
```tex
@INPROCEEDINGS{10679349,
  author={Spyridakis, Christos and Aktypi, Angeliki and Kyriakakis, Thomas and Ioannidis, Sotiris},
  booktitle={2024 IEEE International Conference on Cyber Security and Resilience (CSR)}, 
  title={SecureExecutor: An Automated Way to Leverage SCONE to Enhance Application Security}, 
  year={2024},
  volume={},
  number={},
  pages={827-832},
  keywords={Linux;Containers;Software;Silicon;Libraries;Complexity theory;Security;Security;TEE;Intel SGX;SCONE},
  doi={10.1109/CSR61664.2024.10679349}}
```

## Funding & Support
This project has received funding from the [European Health and Digital Executive Agency (HADEA)](https://hadea.ec.europa.eu/) program under Grant Agreement No 101092950 ([EDGELESS](https://edgeless-project.eu) project) and support from the [SCONTAIN](https://scontain.com/) team.
