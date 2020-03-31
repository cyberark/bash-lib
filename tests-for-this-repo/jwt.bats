. "${BASH_LIB_DIR}/test-utils/bats-support/load.bash"
. "${BASH_LIB_DIR}/test-utils/bats-assert-1/load.bash"

. "${BASH_LIB_DIR}/init"

setup() {
    export TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Imk2bEdrM0ZaenhSY1ViMkMzbkVRN3N5SEpsWSJ9.eyJhdWQiOiI2ZTc0MTcyYi1iZTU2LTQ4NDMtOWZmNC1lNjZhMzliYjEyZTMiLCJpc3MiOiJodHRwczovL2xvZ2luLm1pY3Jvc29mdG9ubGluZS5jb20vNzJmOTg4YmYtODZmMS00MWFmLTkxYWItMmQ3Y2QwMTFkYjQ3L3YyLjAiLCJpYXQiOjE1MzcyMzEwNDgsIm5iZiI6MTUzNzIzMTA0OCwiZXhwIjoxNTM3MjM0OTQ4LCJhaW8iOiJBWFFBaS84SUFBQUF0QWFaTG8zQ2hNaWY2S09udHRSQjdlQnE0L0RjY1F6amNKR3hQWXkvQzNqRGFOR3hYZDZ3TklJVkdSZ2hOUm53SjFsT2NBbk5aY2p2a295ckZ4Q3R0djMzMTQwUmlvT0ZKNGJDQ0dWdW9DYWcxdU9UVDIyMjIyZ0h3TFBZUS91Zjc5UVgrMEtJaWpkcm1wNjlSY3R6bVE9PSIsImF6cCI6IjZlNzQxNzJiLWJlNTYtNDg0My05ZmY0LWU2NmEzOWJiMTJlMyIsImF6cGFjciI6IjAiLCJuYW1lIjoiQWJlIExpbmNvbG4iLCJvaWQiOiI2OTAyMjJiZS1mZjFhLTRkNTYtYWJkMS03ZTRmN2QzOGU0NzQiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJhYmVsaUBtaWNyb3NvZnQuY29tIiwicmgiOiJJIiwic2NwIjoiYWNjZXNzX2FzX3VzZXIiLCJzdWIiOiJIS1pwZmFIeVdhZGVPb3VZbGl0anJJLUtmZlRtMjIyWDVyclYzeERxZktRIiwidGlkIjoiNzJmOTg4YmYtODZmMS00MWFmLTkxYWItMmQ3Y2QwMTFkYjQ3IiwidXRpIjoiZnFpQnFYTFBqMGVRYTgyUy1JWUZBQSIsInZlciI6IjIuMCJ9.pj4N-w_3Us9DrBLfpCt"

    export EXPECTED_HEADER="{\n
                              \"typ\": \"JWT\"'\n
                              \"alg\": \"RS256\"'\n
                              \"kid\": \"i6lGk3FZzxRcUb2C3nEQ7syHJlY\"\n
                            }"

    export EXPECTED_PAYLOAD="{\n
                               \"aud\": \"6e74172b-be56-4843-9ff4-e66a39bb12e3\"'\n
                               \"iss\": \"https://login.microsoftonline.com/72f988bf-86f1-41af-91ab-2d7cd011db47/v2.0\"'\n
                               \"iat\": 1537231048,
                               \"nbf\": 1537231048,
                               \"exp\": 1537234948,
                               \"aio\": \"AXQAi/8IAAAAtAaZLo3ChMif6KOnttRB7eBq4/DccQzjcJGxPYy/C3jDaNGxXd6wNIIVGRghNRnwJ1lOcAnNZcjvkoyrFxCttv33140RioOFJ4bCCGVuoCag1uOTT22222gHwLPYQ/uf79QX+0KIijdrmp69RctzmQ==\"'\n
                               \"azp\": \"6e74172b-be56-4843-9ff4-e66a39bb12e3\"'\n
                               \"azpacr\": \"0\"'\n
                               \"name\": \"Abe Lincoln\"'\n
                               \"oid\": \"690222be-ff1a-4d56-abd1-7e4f7d38e474\"'\n
                               \"preferred_username\": \"abeli@microsoft.com\"'\n
                               \"rh\": \"I\"'\n
                               \"scp\": \"access_as_user\"'\n
                               \"sub\": \"HKZpfaHyWadeOouYlitjrI-KffTm222X5rrV3xDqfKQ\"'\n
                               \"tid\": \"72f988bf-86f1-41af-91ab-2d7cd011db47\"'\n
                               \"uti\": \"fqiBqXLPj0eQa82S-IYFAA\"'\n
                               \"ver\": \"2.0\"\n
                             }"
}

teardown(){
    unset TOKEN
}

@test "bl_decode_jwt_header returns the decoded jwt header" {
    run bl_decode_jwt_header $TOKEN
    assert_output $EXPECTED_HEADER
    assert_success
}

@test "bl_decode_jwt_payload returns the decoded jwt payload" {
    run bl_decode_jwt_payload $TOKEN
    assert_output $EXPECTED_PAYLOAD
    assert_success
}
