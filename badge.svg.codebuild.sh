# color map
lightgrey='9f9f9f';
blue='007ec6';
brightgreen='4c1';
green='97ca00';
yellowgreen='fe7d37';
yellow='e05d44';
orange='dfb317';
red='a4a61d';

DIRECTORY=$(pwd)
COLOR='lightgrey';

[ -z $GIST_TOKEN ] && exit 0;
[ -z $GIST_ID ] && exit 0;
[[ -z $GIST_FILENAME && ! -z $CODEBUILD_INITIATOR ]] && GIST_FILENAME=$CODEBUILD_INITIATOR
[ -z $GIST_FILENAME ] && exit 0;

if [ -f "$DIRECTORY/coverage/lcov-report/index.html" ]; then
  COVERAGE=$(bash -c "cat coverage/lcov-report/index.html | grep -Eo '[0-9]+.[0-9]+' | head -n 1") >/dev/null 2>&1;
fi

if [ -z $COVERAGE ]; then
  COVERAGE='unknown'
else
  # codebuild has not bc command
  # (( $(echo "$COVERAGE < 100.00" | /usr/bin/bc -l) )) && COLOR='brightgreen';
  # (( $(echo "$COVERAGE < 95.00" | /usr/bin/bc -l) )) && COLOR='green';
  # (( $(echo "$COVERAGE < 90.00" | /usr/bin/bc -l) )) && COLOR='yellowgreen';
  # (( $(echo "$COVERAGE < 80.00" | /usr/bin/bc -l) )) && COLOR='yellow';
  # (( $(echo "$COVERAGE < 70.00" | /usr/bin/bc -l) )) && COLOR='orange';
  # (( $(echo "$COVERAGE < 60.00" | /usr/bin/bc -l) )) && COLOR='red';
  # avoid floating point compare
  [[ "$(awk "BEGIN {print ${COVERAGE}*100}")" -le "10000" ]] && COLOR='brightgreen';
  [[ "$(awk "BEGIN {print ${COVERAGE}*100}")" -lt "9500" ]] && COLOR='green';
  [[ "$(awk "BEGIN {print ${COVERAGE}*100}")" -lt "9000" ]] && COLOR='yellowgreen';
  [[ "$(awk "BEGIN {print ${COVERAGE}*100}")" -lt "8000" ]] && COLOR='yellow';
  [[ "$(awk "BEGIN {print ${COVERAGE}*100}")" -lt "7000" ]] && COLOR='orange';
  [[ "$(awk "BEGIN {print ${COVERAGE}*100}")" -lt "6000" ]] && COLOR='red';
fi

# https://img.shields.io/badge/coverage-100%25-brightgreen?style=flat-square
GIST_FILENAME=$(echo $GIST_FILENAME | cut -b 14- | sed 's/$/.svg/')
CONTENT="<svg xmlns=\\\"http://www.w3.org/2000/svg\\\" xmlns:xlink=\\\"http://www.w3.org/1999/xlink\\\" width=\\\"114\\\" height=\\\"20\\\"><g shape-rendering=\\\"crispEdges\\\"><path fill=\\\"#555\\\" d=\\\"M0 0h61v20H0z\\\"/><path fill=\\\"#${!COLOR}\\\" d=\\\"M61 0h53v20H61z\\\"/></g><g fill=\\\"#fff\\\" text-anchor=\\\"middle\\\" font-family=\\\"DejaVu Sans,Verdana,Geneva,sans-serif\\\" font-size=\\\"110\\\"> <text x=\\\"315\\\" y=\\\"140\\\" transform=\\\"scale(.1)\\\" textLength=\\\"510\\\">coverage</text><text x=\\\"865\\\" y=\\\"140\\\" transform=\\\"scale(.1)\\\" textLength=\\\"430\\\">$COVERAGE%</text></g> </svg>"
PAYLOAD="{ \"files\": { \"$GIST_FILENAME.svg\": { \"content\": \"$CONTENT\" } } }"

curl --silent --output /dev/null --show-error --fail -X PATCH -H "Authorization: token $GIST_TOKEN" https://api.github.com/gists/$GIST_ID -d "$PAYLOAD"
