# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

import lambda_function
import os
import json
import base64

# ----------------------------------------------------------------------------------
#                   IMPORTANT: YOU SHOULD NOT MODIFY THIS CODE!
# ----------------------------------------------------------------------------------

def decode_base64(data):
    """Decode base64, padding being optional."""
    missing_padding = len(data) % 4
    if missing_padding:
        data += '='* (4 - missing_padding)
    return base64.b64decode(data).decode('utf-8')

def main():
    # Read environment variables
    envvar_lambda_event     = os.getenv('LAMBDA_EVENT')
    envvar_lambda_context   = os.getenv('LAMBDA_CONTEXT')

    # Check and parse the environment variables if they exist
    if envvar_lambda_event is None:
        event = {"": ""}
    else:
        try:
            event = json.loads(decode_base64(envvar_lambda_event))
        except:
            print("LAMBDA_EVENT is invalid! Either it is not a base64 value, or error regarding its JSON format.")
            return
        
    if envvar_lambda_context is None:
        context = {"": ""}
    else:
        try:
            context = json.loads(decode_base64(envvar_lambda_context))
        except:
            print("LAMBDA_CONTEXT is invalid! Either it is not a base64 value, or error regarding its JSON format.")
            return

    # Call lambda function
    response = lambda_function.lambda_handler(event, context)

    # FIXME: return response
    print(json.dumps(response))

    return 0

# =================================================================================
# MAIN
if __name__ == "__main__":
    main()