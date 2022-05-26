#!/bin/bash
 
## ####################################################################################
## SAMPLE Entries:
## user=ocid1.user.oc1..aaaaaaaa7dxxxxx-SAMPLE-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxbbbbbfake
## fingerprint=99:31:6d:c5:SA:MP:LE:f8:d3:cb:24:ef:3c:c8:fa:ke
## tenancy=ocid1.tenancy.oc1..aaa-SAMPLE-t6vmlbfkgx4jgeo5yefakeskrtdfewshgfdqwir3r4ipzfake
## region=us-ashburn-1
## key_file=/Users/homedir/adb_db_key.pem
##
##  <Cut-and-paste your tenancy values here>
##
## Add a value for adbList for each DB instance: "[ServiceName]|[Database-OCID]"
## adbList="ADBDEMO|ocid1.autonomousdatabase.oc1.iad.abcwcljaa-SAMPLE-ddefakef12345123456789abcdefghijklmfake 
##          DB21C|ocid1.autonomousdatabase.oc1.iad.abewcljaaab-SAMPLE-eefake12345678912rqponmlkjihgfedcbafake
           "
##
   adbList="<service name>|<database OCID>"
##   
## Set the following variable to "start" or "stop" to START or STOP your instance:
start_or_stop="start"
#
## OPTIONAL- Control start | stop from the command-line when calling the script:
# start_or_stop=$1  
##
## OPTIONAL- Uncomment to see a verbose output
# set -x
## ####################################################################################
## NO NEED TO MODIFY ANYTHING BELOW THIS LINE...
        
# Create host string
host="database.$region.oraclecloud.com"

# Additional headers required for a POST/PUT request
content_sha256="$(openssl dgst -binary -sha256 < /dev/null | openssl enc -e -base64)";
content_sha256_header="x-content-sha256: $content_sha256"
content_length="0"
content_length_header="content-length: $content_length"
headers="(request-target) date host"
# add on the extra fields required for a POST/PUT
headers=$headers" x-content-sha256 content-type content-length"
content_type_header="content-type: application/json";

date=`date -u "+%a, %d %h %Y %H:%M:%S GMT"`
date_header="date: $date"
host_header="host: $host"

for srvnm in $adbList
do
  printf "\n\n===========================================================================================\n"
  printf "\n ADB ServiceName: ${srvnm%%|*} "
  printf "\n Action: ${start_or_stop} \n"

  rest_api="/20160918/autonomousDatabases/${srvnm##*|}/actions/${start_or_stop}"

  # Uncomment the following line to see the REST-ENDPOINT:
  # printf "\n Rest API is: \n$rest_api\n"

  request_target="(request-target): post $rest_api"
  signing_string="$request_target\n$date_header\n$host_header"
  signing_string="$signing_string\n$content_sha256_header\n$content_type_header\n$content_length_header"
  sig=`printf '%b' "$signing_string" | openssl dgst -sha256 -sign $key_file | openssl enc -e -base64 | tr -d '\n'`

  printf " ==============================\n"

  curl -X POST --data-binary -sS https://$host$rest_api -H "date: $date" -H "x-content-sha256: $content_sha256" -H "content-type: application/json" -H "content-length: $content_length" -H "Authorization: Signature version=\"1\",keyId=\"$tenancy/$user/$fingerprint\",algorithm=\"rsa-sha256\",headers=\"$headers\",signature=\"$sig\""

done
printf "\n\n============================= $date =============================== \n\n"
