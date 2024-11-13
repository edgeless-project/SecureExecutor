// SPDX-FileCopyrightText: © 2024 Technical University of Crete
// SPDX-License-Identifier: MIT

#include <iostream>
#include "lambda_function.hpp"

// ----------------------------------------------------------------------------------
//                   IMPORTANT: YOU SHOULD NOT MODIFY THIS CODE!
// ----------------------------------------------------------------------------------

// Base64 decoding table
static constexpr unsigned char decoding_table[] = {64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 62, 64, 64, 64, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 64, 64, 64, 0, 64, 64, 64, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 64, 64, 64, 64, 64, 64, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 64, 64, 64, 64, 64};
std::string decode_base64(const std::string &input) {
    size_t in_len = input.size();
    size_t out_len = in_len / 4 * 3;
    if (input[in_len - 1] == '=') out_len--;
    if (input[in_len - 2] == '=') out_len--;
    std::string out(out_len, '\0');

    for (size_t i = 0, j = 0; i < in_len;) {
        uint32_t a = input[i] == '=' ? 0 & i++ : decoding_table[static_cast<unsigned char>(input[i++])];
        uint32_t b = input[i] == '=' ? 0 & i++ : decoding_table[static_cast<unsigned char>(input[i++])];
        uint32_t c = input[i] == '=' ? 0 & i++ : decoding_table[static_cast<unsigned char>(input[i++])];
        uint32_t d = input[i] == '=' ? 0 & i++ : decoding_table[static_cast<unsigned char>(input[i++])];

        uint32_t triple = (a << 18) + (b << 12) + (c << 6) + d;

        if (j < out_len) out[j++] = (triple >> 16) & 0xFF;
        if (j < out_len) out[j++] = (triple >> 8) & 0xFF;
        if (j < out_len) out[j++] = triple & 0xFF;
    }

    return out;
}

int main(){
    // Attempt to read the environment variables
    char* ENVVAR_lambda_event = std::getenv("LAMBDA_EVENT");
    char* ENVVAR_lambda_context = std::getenv("LAMBDA_CONTEXT");

    // Define JSON objects (here we will store env var contents)
    json event, context;

    // Check and parse the environment variables if they exist
    if (ENVVAR_lambda_event) {
        try {
            event = json::parse(decode_base64(ENVVAR_lambda_event));
        } catch (json::parse_error& e) {
            std::cerr << "LAMBDA_EVENT is invalid! Either it is not a base64 value, or error regarding its JSON format."  << std::endl;
            return EXIT_FAILURE;
        }
    } else {
        event = { {"", ""} };
    }

    if (ENVVAR_lambda_context) {
        try {
            context = json::parse(decode_base64(ENVVAR_lambda_context));
        } catch (json::parse_error& e) {
            std::cerr << "LAMBDA_CONTEXT is invalid! Either it is not a base64 value, or error regarding its JSON format." << std::endl;
            return EXIT_FAILURE;
        }
    } else {
        context = { {"", ""} };
    }

    // Calling the function from lambda_function.hpp
    json response = lambda_handler(event, context);

    // FIXME: return response
    std::cout << response.dump() << std::endl;

    return 0;
}