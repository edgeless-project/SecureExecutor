// SPDX-FileCopyrightText: © 2024 Technical University of Crete
// SPDX-License-Identifier: MIT

#ifndef LAMBDA_FUNCTION_HPP
#define LAMBDA_FUNCTION_HPP

// ----------------------------------------------------------------------------------
//                   IMPORTANT: YOU SHOULD NOT MODIFY THIS CODE!
// ----------------------------------------------------------------------------------

#include "nlohmann/json.hpp"

using json = nlohmann::json;

json lambda_handler(json& event, json& context);

#endif //LAMBDA_FUNCTION_HPP
