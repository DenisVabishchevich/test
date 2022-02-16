#!/bin/bash

echo "Start Script"

keycloak_url=${KEYCLOAK_BASE_URL}
realm=${KEYCLOAK_USER_REALM}
client_id=${KEYCLOAK_USER_CLIENT_ID}
client_secret=${KEYCLOAK_USER_CLIENT_SECRET}
username=${KEYCLOAK_USER}
password=${KEYCLOAK_PASS}
report_manager_url=${REPORT_MANAGER_BASE_URL}

echo "Retrieving token for user: $username"
token=$(curl -sS -X POST --location "$keycloak_url/auth/realms/$realm/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Accept: application/json" \
  -d "client_id=$client_id&client_secret=$client_secret&username=$username&password=$password&grant_type=password" |
  jq -r '.access_token')

[ -z "$token" ] && echo "Token is empty, exit" && exit 1 || echo "Token found"

files=$(git diff --name-only HEAD~1)
for file in $files; do
  # run only for existing files
  if [ -f "$file" ]; then

    IFS='/' read -ra file_tokens <<<"$file"                      # i.e. file: PROFILE/Profile_DOC_en.docx
    IFS='_' read -ra file_tokens_format <<<"${file_tokens[1]}"   # i.e. file_tokens[1]: Profile_DOC_en.docx
    IFS='.' read -ra file_lang_ext <<<"${file_tokens_format[2]}" # i.e. file_tokens_format[2]: en.docx

    # finding pattern like Profile_DOC_en.docx i.e. 3 underscores, create/update templates
    if [ "${#file_tokens_format[@]}" -eq "3" ]; then

      report_name="${file_tokens[0]}"   # i.e. PROFILE
      format="${file_tokens_format[1]}" # i.e. DOC
      lang="${file_lang_ext[0]}"        # i.e. en

      echo "Uploading template for file: $file, reportName: $report_name, format: $format, lang: $lang"
      template_status=$(curl -sS -X POST --form file=@"$file" \
        --location "$report_manager_url/api/template/upload?reportName=$report_name&format=$format&lang=$lang" \
        -o /dev/null \
        -H "Authorization: Bearer $token" \
        -w "%{http_code}")

      [ "$template_status" != 200 ] && echo "Upload template error, status: $template_status" && exit 1 || echo "Template updated"

    fi

    # finding files .mjs or .js, create/update scripts
    if [ "${file_tokens[0]}" != "modules" ] && [ "${file_tokens[1]: -2}" == "js" ]; then

      report_name="${file_tokens[0]}" # i.e. PROFILE

      data_source_reader_id=$(curl -sS -X GET --location "$report_manager_url/api/report-config/$report_name" \
        -H "Authorization: Bearer $token" |
        jq '.reader.id')

      echo "Uploading script file: $file, report_name: $report_name, data_source_reader_id: $data_source_reader_id"
      upload_file_status=$(curl -sS -X POST --form file=@"$file" \
        --location "$report_manager_url/api/reader/script/$data_source_reader_id" \
        -o /dev/null \
        -H "Authorization: Bearer $token" \
        -w "%{http_code}")

      [ "$upload_file_status" != 200 ] && echo "Upload script error, status: $upload_file_status" && exit 1 || echo "Script updated"

    fi

    # finding files .mjs under modules folder, create/update js modules
    if [ "${file_tokens[0]}" == "modules" ] && [ "${file_tokens[1]: -4}" == ".mjs" ]; then
      file_name=${file_tokens[1]}

      # check if module exist
      existing_module_id=$(curl -sS -X GET --location "$report_manager_url/api/module" \
        -H "Authorization: Bearer $token" |
        jq ".[] | select(.fileName == \"$file_name\").id")

      # create module if not exists
      if [ -z "$existing_module_id" ]; then
        echo "Creating new module for file $file"
        existing_module_id=$(curl -sS -X POST --location "$report_manager_url/api/module" \
          -H "Authorization: Bearer $token" \
          -H "Content-Type: application/json" \
          -d "{ \"name\": \"$file_name\", \"fileName\": \"$file_name\" }" |
          jq ".id")
        [ -z "$existing_module_id" ] && echo "Module create error" && exit 1 || echo "Module created id: $existing_module_id"
      fi

      # finally update existing module or new created module
      echo "Updating module script file: $file, module_id: $existing_module_id"
      upload_module_file_status=$(curl -sS -X POST --form file=@"$file" \
        --location "$report_manager_url/api/module/script/$existing_module_id" \
        -o /dev/null \
        -H "Authorization: Bearer $token" \
        -w "%{http_code}")

      [ "$upload_module_file_status" != 200 ] && echo "Update module script error, status: $upload_module_file_status" && exit 1 || echo "Module Script updated"
    fi

  fi
done

echo "End Script"
