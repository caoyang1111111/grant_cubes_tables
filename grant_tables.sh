#! /bin/bash

host=$1
port=$2
projectname=$3
grant=$4
#projectname=$2
typename=$5
username=$6
cubename=$7

curl  -X GET "http://"$1":"$2"/kylin/api/projects?pageOffset=0&pageSize=100000" \
  -H 'Accept: application/vnd.apache.kylin-v2+json' \
  -H 'Accept-Language: en' \
  -H 'Authorization: Basic QURNSU46S1lMSU4=' \
  -H 'Content-Type: application/json;charset=utf-8' >project.txt




id_count=`cat project.txt  | /usr/bin/jq '.data.size'`

for ((i=0;i<$id_count;i++));do
  {
cat project.txt  | /usr/bin/jq 'if (.data.projects['${i}'].name) == "'$projectname'"  then .data.projects['${i}'].uuid else empty end' | sed 's/\"//g'>>uuid.txt
 }
 done


while read projectuuid
do
 #  echo $line
#done < ooo.txt


curl -X POST \
  "http://"$1":"$2"/kylin/api/access/ProjectInstance/"$projectuuid"" \
  -H 'Accept: application/vnd.apache.kylin-v2+json' \
  -H 'Accept-Language: en' \
  -H 'Authorization: Basic QURNSU46S1lMSU4=' \
  -H 'Content-Type: application/json;charset=utf-8' \
  -d '{
    "permission":"'$grant'",
    "principal": true, 
    "sid": "'$username'"
}'

done <uuid.txt


#projectname=$1
#cubename=$2


modelname=$(curl -X GET \
  "http://"$1":"$2"/kylin/api/cube_desc/"$projectname"/"$cubename"" \
  -H 'Accept: application/vnd.apache.kylin-v2+json' \
  -H 'Accept-Language: en' \
  -H 'Authorization: Basic QURNSU46S1lMSU4=' \
  -H 'Content-Type: application/json;charset=utf-8'|jq '.data.cube.model_name'|sed 's/\"//g' )
#}
#echo $modelname

tablesname=$(curl -X GET \
  "http://"$1":"$2"/kylin/api/models/"$projectname"/"$modelname"" \
  -H 'Accept: application/vnd.apache.kylin-v2+json' \
  -H 'Accept-Language: en' \
  -H 'Authorization: Basic QURNSU46S1lMSU4=' \
  -H 'Content-Type: application/json;charset=utf-8'|jq '.data.model.fact_table'|sed 's/\"//g' & curl -X GET \
  "http://"$1":"$2"/kylin/api/models/"$projectname"/"$modelname"" \
  -H 'Accept: application/vnd.apache.kylin-v2+json' \
  -H 'Accept-Language: en' \
  -H 'Authorization: Basic QURNSU46S1lMSU4=' \
  -H 'Content-Type: application/json;charset=utf-8'|jq '.data.model.lookups[].table'|sed 's/\"//g'
)
echo "$tablesname">tablename.txt



sort -k2n tablename.txt | sed '$!N; /^\(.*\)\n\1$/!P; D' > tables.txt

#备份IFS
OLD_IFS="$IFS"

#设置新的分隔符为;
IFS="\n"

#读取文件中的行
while read LINE

  do
    echo $LINE
    #将字符串$LINE分割到数组
    arr=($LINE) 
    # ${arr[@]}存储整个数组    
    for s in ${arr[@]}  
     do
     echo $s
     echo "****"
     curl -X POST \
  "http://"$1":"$2"/kylin/api/acl/table/"$projectname"/"$typename"/"$s"/"$username"" \
  -H 'Accept: application/vnd.apache.kylin-v2+json' \
  -H 'Accept-Language: en' \
  -H 'Authorization: Basic QURNSU46S1lMSU4=' \
  -H 'Content-Type: application/json;charset=utf-8'

     done

  done <tables.txt

#恢复IFS
IFS="$OLD_IFS"

rm -rf project.txt 
rm -rf tables.txt 
rm -rf tablename.txt 
rm -rf uuid.txt 
