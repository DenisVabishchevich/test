#!/bin/bash

keycloak_url="https://keycloak.dev.g42a.ae"
realm="g42a"
client_id="damba-test"
client_secret="2b5dcb7d-5807-455f-ad0d-b479c583f3c8"
username="dzianis"
password="Denis441869456357!"
report_manager_url="http://localhost:8081"

files=$(git diff --name-only HEAD~1)

for file in $files; do
  if [ -f "@file" ]; then
    IFS='/' read -ra file_tokens <<<"$file"                      # i.e. file: PROFILE/Profile_DOC_en.docx
    IFS='_' read -ra file_tokens_format <<<"${file_tokens[1]}"   # i.e. file_tokens[1]: Profile_DOC_en.docx
    IFS='.' read -ra file_lang_ext <<<"${file_tokens_format[2]}" # i.e. file_tokens_format[2]: en.docx

    report_name="${file_tokens[0]}"   # i.e. PROFILE
    format="${file_tokens_format[1]}" # i.e. DOC
    lang="${file_lang_ext[0]}"        # i.e. en

    echo "Retrieving token for user: $username"
    token=$(curl -X POST -s --location "$keycloak_url/auth/realms/$realm/protocol/openid-connect/token" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -H "Accept: application/json" \
      -d "client_id=$client_id&client_secret=$client_secret&username=$username&password=$password&grant_type=password" | jq -r ".access_token")

    echo "Uploading template for file: $file, reportName: $report_name, format: $format, lang: $lang"
    curl -X POST --form file=@"$file" \
      --location "$report_manager_url/api/template/upload?reportName=$report_name&format=$format&lang=$lang" \
      -H "Authorization: Bearer $token" \
      -w "\n"
  fi
done
