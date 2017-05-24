RED='\033[0;31m'
NC='\033[0m'

if [ $# -eq 0 ]
  then
    echo ""
    echo -e "${RED}Usage: $0 <function>${NC}" 1>&2
    echo ""
    echo "Example: $0 ui_iscsi.interfaces "
  else
    curl -sSk http://salt:8000/login -c /tmp/ds-runner-cookies.txt -H 'Accept: application/x-yaml' -d username=admin -d password=admin -d eauth=auto
    curl -sSk http://salt:8000 -b /tmp/ds-runner-cookies.txt -H 'Accept: application/x-yaml' -d client=runner -d fun=$1
fi
