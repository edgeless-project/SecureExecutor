// SPDX-FileCopyrightText: © 2024 Technical University of Crete
// SPDX-License-Identifier: MIT

#include "lambda_function.hpp"
#include <iostream>

// ----------------------------------------------------------------------------------
//          MODIFY THIS SOURCE FILE TO IMPLEMENT REQUIRED LAMBDA FUNCTION
// ----------------------------------------------------------------------------------

json lambda_handler(json& event, json& context) {
    // TODO: implement your lambda function
    std::cout << "Hello CPP" << std::endl;

    // Create response
    json response = { {"status", "success"} };
    return response;
}
