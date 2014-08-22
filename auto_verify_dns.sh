#!/bin/bash
# ./auto_verify_dns.sh [OPTION...]
# desc: Test to see if a list of (or one) nameserver(s) (IP or hostnames)
#+are able to resolve a particular $domain within a set $timeoutsec
# by: Sahal Ansari (github@sahal.info)
# TODO: print timeout lengths but save only dns servers

# learning: http://www.davidpashley.com/articles/writing-robust-shell-scripts/
# unset variable issues: http://www.fvue.nl/wiki/Bash:_Error_%60Unbound_variable%27_when_testing_unset_variable
set -u

# a domain to resolve
domain="baidu.com"
# $DIR is from http://stackoverflow.com/questions/59895/
DIR="$( cd "$( dirname "$0" )" && pwd )"
# path to timeout3 (included in bash4.0 source)
# http://www.bashcookbook.com/bashinfo/source/bash-4.0/examples/scripts/timeout3
timeout3="$DIR/timeout3.sh"
# path to dns servers (ips or hostnames)
dns="$DIR/servers"
# stop trying to resolve after $timeoutsec
timeoutsec="3"

function main { #yeah, son; this is #HowToBeABashPro

if [ ! -e "$timeout3" ]; then
	echo "OOps, you don't have timeout3"
	echo "Get it in the bash-4.0 source code: examples/scripts/timeout3"
	exit 1
fi

echo "Domain to test against: ""$domain"
echo "Timeout: ""$timeoutsec""s"

if [ -n "${server:-}" ]; then
	echo "DNS server: ""${server:-}"
	echo
	echo "Working DNS Server:"
	checkdns "${server:-}"
else
	if [ ! -e "$dns" ]; then
	   echo "OOps, Cannot find your list of DNS servers!?"
	   exit 1
	fi

	echo "List of DNS servers: ""$dns"
	echo
	echo "Working DNS Servers:"
	breaklist
fi

}

function show_help {
cat << EOF
Usage: ${0##*/:-} [OPTION...]
A quick test to see if one (\$server) or more nameservers (\$dns)
are able to resolve a particular \$domain within a set \$timeoutsec

   -l specify a non-default dns server list (Default: \$DIR/servers)
   -s test a particular domain name server (Default: unset)
   -d test using a particular domain (Default: baidu.com)
   -t set the timeoutsec in seconds (Default: 3)
   -h print this help

EOF
}

function checkopts {
# TODO: check to see if valid options were given for each parameter
	case "${1:-}" in
	  \-*)
	   echo "WARNING: syntax error, please try again!"
	   exit 1
	;;
	esac
}

function checkdns {
	temp="$(mktemp)"
	"$timeout3" -t "$timeoutsec" dig @"$1" "$domain" > "$temp" 2>&1
	grep "status\:\ NOERROR" < "$temp" > /dev/null 2>&1
	if [ "$?" -eq "0" ]; then
		echo "$1"
	fi
}

function breaklist {
# you can mess with the input file (i remove dupes via sort+uniq)
# e.g.: for server in $(cut -d, -f2 < $dns)
for each_server in $(cat "$dns" | sort | uniq)
do
	checkdns "$each_server"
#	sleep "$timeoutsec"s
done
}

# getopts howtos: (mainly for me)
# http://www.theunixschool.com/2012/08/getopts-how-to-pass-command-line-options-shell-script-Linux.html
# http://mywiki.wooledge.org/BashFAQ/035
# http://wiki.bash-hackers.org/howto/getopts_tutorial

while getopts ":l:s:d:t:h" opt; do
	case "${opt:-}" in
		l)
		   echo "-l was triggered, Parameter: ""${OPTARG:-}" >&2
		   dns="${OPTARG:-}"
		;;

		s)
		   echo "-s was triggered, Parameter: ""${OPTARG:-}" >&2
		   checkopts "${OPTARG:-}"
		   server="${OPTARG:-}"
		;;

		d)
		   echo "-d was triggered, Parameter: ""${OPTARG:-}" >&2
		   checkopts "${OPTARG:-}"
		   domain="${OPTARG:-$domain}"
		;;

		t)
		   echo "-t was triggered, Parameter: ""${OPTARG:-}" >&2
		   checkopts "${OPTARG:-}"
		   timeoutsec="${OPTARG:-}"
		;;

		h)
		   show_help
		   exit 0
		;;

		\?) # any other single character
		   echo "Invalid option: -""${OPTARG:-}" >&2
		   echo
		   show_help
		   exit 1
		;;

		:)
		   echo "Option -""${OPTARG:-}"" requires an argument." >&2
		   echo
		   show_help
		   exit 1
		;;
	esac
done

# call the main function; see above
main
