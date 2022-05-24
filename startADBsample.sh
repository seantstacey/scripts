#!/bin/bash
 
## ####################################################################################
## SAMPLE Entries:
## user=ocid1.user.oc1..aaaaaaaa7dxxxxxfakexxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxbbbbbfake
## fingerprint=99:31:6d:c5:fa:ke:a6:93:d3:cb:24:ef:3c:c8:fa:ke
## tenancy=ocid1.tenancy.oc1..aaaaaaaa36trvmlbfjkgx4jgeo5yefakeskrtdfewshgfdqwir3r4ipzfake
## region=us-ashburn-1
## key_file=/Users/homedir/adb_db_key.pem
##
##  <Cut-and-paste your tenancy values here>
##
## Add a value for adb_list List of ADB names: "[ServiceName]|[Database-OCID]"
## adbList="ADBDEMO|ocid1.autonomousdatabase.oc1.iad.abcwcljaaabbbcccdddefakef123456789123456789abcdefghijklmfake 
##          DB21C|ocid1.autonomousdatabase.oc1.iad.abewcljaaabbbcccdddeefake123456789123456rqponmlkjihgfedcbafake"
##
adbList="<service name>|<database OCID>"
##
## Uncomment the following line to see a verbose version of the script when it runs
# set -x 
## ####################################################################################

# Create host string
host="database.$region.oraclecloud.com"

# Empty json file 
body="./request.json"

# Additional headers required for a POST/PUT request
body_arg=(--data-binary @${body})
content_sha256="$(openssl dgst -binary -sha256 < $body | openssl enc -e -base64)";
content_sha256_header="x-content-sha256: $content_sha256"
content_length="$(wc -c < $body | xargs)";
content_length_header="content-length: $content_length"
headers="(request-target) date host"
headers=$headers" x-content-sha256 content-type content-length"
content_type_header="content-type: application/json";

date=`date -u "+%a, %d %h %Y %H:%M:%S GMT"`
date_header="date: $date"
host_header="host: $host"

for srvnm in $adbList
do
  printf "\n\n================================================================================================= \n"
  printf "\n ADB ServiceName: ${srvnm%%|*} \n"

  rest_api="/20160918/autonomousDatabases/ocid1.autonomousdatabase.oc1.${srvnm##*|}/actions/start"

  # Uncomment the following line to see the rest-endpoint
  # printf " Rest API is: $rest_api \n"

  request_target="(request-target): post $rest_api"
  signing_string="$request_target\n$date_header\n$host_header"
  signing_string="$signing_string\n$content_sha256_header\n$content_type_header\n$content_length_header"
  sig=`printf '%b' "$signing_string" | openssl dgst -sha256 -sign $key_file | openssl enc -e -base64 | tr -d '\n'`

  printf " ---------------------------------------\n"

  curl -X POST --data-binary "@request.json" -sS https://$host$rest_api -H "date: $date" -H "x-content-sha256: $content_sha256" -H "content-type: application/json" -H "content-length: $content_length" -H "Authorization: Signature version=\"1\",keyId=\"$tenancy/$user/$fingerprint\",algorithm=\"rsa-sha256\",headers=\"$headers\",signature=\"$sig\""

done
printf "\n\n============================= $date ===================================== \n\n"

