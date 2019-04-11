username=$2
passwd=$3
usergroup=$4

curl -X $1 \
  "http://solution-2:7070/kylin/api/kap/user/"$username"" \
  -H 'Accept: application/vnd.apache.kylin-v2+json' \
  -H 'Accept-Language: en' \
  -H 'Authorization: Basic QURNSU46S1lMSU4=' \
  -H 'Content-Type: application/json;charset=utf-8' \
  -d '{
    "password": "'$passwd'",
    "disabled": false, 
    "authorities": ["'$usergroup'"]

}'
