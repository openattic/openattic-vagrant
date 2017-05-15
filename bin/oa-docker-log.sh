sudo docker exec -t `sudo docker ps -qa | head -1` tail -f /var/log/openattic/openattic.log | awk '
BEGIN {
  DEFAULT = "\033[39m"
  RED = "\033[31m"
  YELLOW = "\033[33m"
  BLUE = "\033[36m"
  GREEN = "\033[32m"
  PURPLE = "\033[34m"
  PINK = "\033[35m"
  CURRENT = DEFAULT
}
/^.* CRITICAL .*$/ {
  CURRENT = RED
}
/^.* ERROR .*$/ {
  CURRENT = RED
}
/^.* WARNING .*$/ {
  CURRENT = YELLOW
}
/^.* DEBUG .*$/ {
  CURRENT = BLUE
}
/^.*$/ {
  print CURRENT $0 DEFAULT
  CURRENT = DEFAULT
}
'
