# color map
lightgrey='9f9f9f';
blue='007ec6';
brightgreen='4c1';
green='97ca00';
yellowgreen='fe7d37';
yellow='e05d44';
orange='dfb317';
red='a4a61d';

# custom label
bugs='bugs'; # Number of bug issues. (number)
code_smells='code smells'; # Total count of Code Smell issues. (number)
coverage='coverage'; # Coverage (percentage)
duplicated_lines_density='duplicated'; # duplicated_lines / lines * 100 (percentage)
ncloc='code line'; # Lines of code (number k,m suffix)
sqale_rating='maintainability'; # Maintainability Rating
alert_status='quality status'; # Quality Gate Status 
reliability_rating='reliability'; # Reliability Rating (A-E)
security_rating='security'; # Security Rating (A-E)
sqale_index='debt'; # Technical Debt 
vulnerabilities='vulnerabilities'; # Number of vulnerability issues. (number)

# default values
COLOR='lightgrey';
STYLE='flat-square';

getRatingColor() {
  [[ "${1}" -le "A" ]] && COLOR='brightgreen';
  [[ "${1}" -lt "B" ]] && COLOR='green';
  [[ "${1}" -lt "C" ]] && COLOR='yellow';
  [[ "${1}" -lt "D" ]] && COLOR='orange';
  [[ "${1}" -lt "E" ]] && COLOR='red';
}
getPercentageAscColor() {
  ARG=$(echo $1 | sed 's/%$//')
  # avoid floating point compare
  [[ "$(awk "BEGIN {print ${ARG}*100}")" -ge "8000" ]] && COLOR='red';
  [[ "$(awk "BEGIN {print ${ARG}*100}")" -lt "8000" ]] && COLOR='orange';
  [[ "$(awk "BEGIN {print ${ARG}*100}")" -lt "6000" ]] && COLOR='yellow';
  [[ "$(awk "BEGIN {print ${ARG}*100}")" -lt "4000" ]] && COLOR='yellowgreen';
  [[ "$(awk "BEGIN {print ${ARG}*100}")" -lt "2000" ]] && COLOR='green';
  [[ "$(awk "BEGIN {print ${ARG}*100}")" -lt "1000" ]] && COLOR='brightgreen';
}
getPercentageDescColor() {
  ARG=$(echo $1 | sed 's/%$//')
  # avoid floating point compare
  [[ "$(awk "BEGIN {print ${ARG}*100}")" -le "10000" ]] && COLOR='brightgreen';
  [[ "$(awk "BEGIN {print ${ARG}*100}")" -lt "9000" ]] && COLOR='green';
  [[ "$(awk "BEGIN {print ${ARG}*100}")" -lt "8000" ]] && COLOR='yellowgreen';
  [[ "$(awk "BEGIN {print ${ARG}*100}")" -lt "7000" ]] && COLOR='yellow';
  [[ "$(awk "BEGIN {print ${ARG}*100}")" -lt "5000" ]] && COLOR='orange';
  [[ "$(awk "BEGIN {print ${ARG}*100}")" -lt "3000" ]] && COLOR='red';
}
getNumberAscColor() {
  [[ "${1}" -eq "0" ]] && COLOR='brightgreen' || COLOR='red';
}
getStatusColor() {
  [[ "${1}" == "passed" ]] && COLOR='brightgreen' || COLOR='red';
}
setColor() {
  [ $1 == "bugs" ] && getNumberAscColor $2
  [ $1 == "code_smells" ] && getNumberAscColor $2
  [ $1 == "coverage" ] && getPercentageDescColor $2
  [ $1 == "duplicated_lines_density" ] && getPercentageAscColor $2
  [ $1 == "ncloc" ] && COLOR='blue'
  [ $1 == "sqale_rating" ] && getRatingColor $2
  [ $1 == "alert_status" ] && getStatusColor $2
  [ $1 == "reliability_rating" ] && getRatingColor $2
  [ $1 == "security_rating" ] && getRatingColor $2
  [ $1 == "sqale_index" ] && COLOR='blue'
  [ $1 == "vulnerabilities" ] && getNumberAscColor $2
}

# tested by sonarqube v7.9.2
postGist() {
  METRIC='coverage'
  [ ! -z $1 ] && METRIC="$1"
  COLOR='lightgrey';
  METRIC_RESPONSE=($(bash -c "curl -sS -u $SONAR_TOKEN: '$SONAR_HOST/api/project_badges/measure?project=$SONAR_PROJECT&metric=$METRIC' | grep -Eo '[A-E0-9a-z]+.?[0-9]*[%a-z]?<\/text>'")) >/dev/null 2>&1;
  # LABEL=$(echo ${METRIC_RESPONSE[0]} | sed 's/<\/text>//')
  LABEL=${!METRIC}
  VALUE=$(echo ${METRIC_RESPONSE[2]} | sed 's/<\/text>//')
  
  if [ -z $VALUE ]; then
    VALUE='unknown'
  else
    setColor $METRIC $VALUE
  fi
  # echo "${LABEL}: $VALUE ($COLOR)"
  MESSAGE=$(echo "$VALUE" | sed 's/%$/%25/')
  CONTENT=$(curl -sS "https://img.shields.io/badge/${LABEL}-$MESSAGE-$COLOR?style=$STYLE" | sed 's/"/\\"/g')
  PAYLOAD="{ \"files\": { \"$SONAR_PROJECT.sonarqube.$METRIC.svg\": { \"content\": \"$CONTENT\" } } }"
  # echo $PAYLOAD | jq
  curl --silent --output /dev/null --show-error --fail -X PATCH -H "Authorization: token $GIST_TOKEN" https://api.github.com/gists/$GIST_ID -d "$PAYLOAD"
}

[[ -z $SONAR_PROJECT && -f "$(pwd)/sonar-project.properties" ]] && SONAR_PROJECT=$(grep -E "^sonar.projectKey" $(pwd)/sonar-project.properties | cut -c 18-)
[[ -z $SONAR_HOST && -f "$(pwd)/sonar-project.properties" ]] && SONAR_HOST=$(grep -E "^sonar.host.url" $(pwd)/sonar-project.properties | cut -c 16-)
[ -z $SONAR_TOKEN ] && exit 0;
[ -z $SONAR_PROJECT ] && exit 0;
[ -z $SONAR_HOST ] && exit 0;
[ -z $GIST_TOKEN ] && exit 0;
[ -z $GIST_ID ] && exit 0;

postGist bugs # Number of bug issues. (number)
postGist code_smells # Total count of Code Smell issues. (number)
postGist coverage # Coverage (percentage)
postGist duplicated_lines_density # duplicated_lines / lines * 100 (percentage)
postGist ncloc # Lines of code (number k,m suffix)
postGist sqale_rating # Maintainability Rating
postGist alert_status # Quality Gate Status 
postGist reliability_rating # Reliability Rating (A-E)
postGist security_rating # Security Rating (A-E)
postGist sqale_index # Technical Debt 
postGist vulnerabilities # Number of vulnerability issues. (number)
