#!/usr/bin/env bash
# Values $1-$4 passed by DSM to the script 
# with values entered by the user in DDNS dialog
# this is the username/email  -> Cloudflare username@email.com
email="$1"
# this is the password/key in DSM -> Cloudflare DNS API token
api_token="$2"
#this is the hostname: web.example.com
dns_record="$3"
# provided automatically by DDNS 
ext_ip="$4" 

# let's extract the domain + tld from the dns_record provided
# we will store that in our zone_name variable
main_domain=${dns_record%.*}
main_domain=${main_domain##*.}
tld=${dns_record##*.}
zone_name="${main_domain}.${tld}"

user_id=$(curl -s \
	-X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
	-H "Authorization: Bearer $api_token" \
	-H "Content-Type:application/json" \
	| jq -r '{"result"}[] | .id')

zone_id=$(curl -s \
	-X GET "https://api.cloudflare.com/client/v4/zones?name=$zone_name&status=active" \
	-H "Content-Type: application/json" \
	-H "X-Auth-Email: $email" \
	-H "Authorization: Bearer $api_token" \
	| jq -r '{"result"}[] | .[0] | .id')

record_data=$(curl -s \
	-X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=A&name=$dns_record"  \
	-H "Content-Type: application/json" \
	-H "X-Auth-Email: $email" \
	-H "Authorization: Bearer $api_token")

record_id=$(jq -r '{"result"}[] | .[0] | .id' <<< $record_data)
cf_ip=$(jq -r '{"result"}[] | .[0] | .content' <<< $record_data)

if [[ $cf_ip != $ext_ip ]]; then
	result=$(curl -s \
		-X PUT "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id" \
		-H "Content-Type: application/json" \
		-H "X-Auth-Email: $email" \
		-H "Authorization: Bearer $api_token" \
		--data "{\"type\":\"A\",\"name\":\"$dns_record\",\"content\":\"$ext_ip\",\"ttl\":1,\"proxied\":false}" \
		| jq .success)
	if [[ $result == "true" ]]; then
		echo "good"
		exit 0
	else
		echo "badauth"
		exit 1
	fi
else
	# No errors, but Ip is the same, no change done
	echo "nochg"
	exit 0
fi
