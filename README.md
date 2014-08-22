auto_verify_dns
===============

Test to see if one or more nameservers are able to resolve a particular
$domain within a set $timeoutsec; This is a more robust version of
https://gist.github.com/sahal/317bb8dca6719776e10f


Changes
=======


 * added set -u which checks for unset variables
 * switched from nslookup to dig as nslookup is depreciated (or so
    they say)
 * temporary files created in /tmp with mktemp that store RAW dig results
 * added getopts support
 * a bit more robust with tests

Usage
=====

* If you’re using a fresh Debian install you’ll need to install dig,
    which comes included with the dnsutils meta package [1]

```
# apt-get update && apt-get install dnsutils -y
```

```
$ ./auto_verify_dns.sh -h
Usage: ./auto_verify_dns.sh [OPTION...]
A quick test to see if one ($server) or more nameservers ($dns)
are able to resolve a particular $domain within a set $timeoutsec

   -l specify a non-default dns server list (Default: $DIR/servers)
   -s test a particular domain name server (Default: unset)
   -d test using a particular domain (Default: baidu.com)
   -t set the timeoutsec in seconds (Default: 3)
   -h print this help

```

Examples
========

Test dns server at 8.8.8.8:
```
$ ./auto)_verify_dns.sh -s 8.8.8.8
```

Test a list of dns servers at ~/dnsservers:
```
$ ./auto)_verify_dns.sh -l ~/dnservers
```

Set timeout to 2 seconds:
```
$./auto)_verify_dns.sh -t 2
```

Test against domain google.com:
```
$./auto)_verify_dns.sh -d google.com
```

Put it all together:
```
$./auto)_verify_dns.sh -t 2 -l ~/dnsservers -d google.com
```

1: https://packages.debian.org/stable/dnsutils
