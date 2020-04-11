# shields.io style badge gist cache
Make your own badges for your private repositories.

Most of badge services support open source repositories or limited

Many startup companies lack of funds, or maybe don't use coverage or code quality services like Coveralls
But you still need to work with private repositories

# setup instructions
1. Create a [gist](https://gist.github.com/).
2. find gist post id in the gist url.
3. Create gist OAuth scope and a [token](https://github.com/settings/tokens). 
4. set environment variable in your CI
```shell
export GIST_TOKEN="your gist api token"
export GIST_ID="your gist post id"
```

## Use your LCOV Code Coverage file
### badge.svg.codebiuild.sh
This script runs like this
1. find Statement coverage metrics in LCOV Code Coverage file (coverage/lcov-report/index.html) in your project working directory.
2. cache badge svg through shields.io and post to gist

first of all you need to setup codebuild with environment variables
```shell
$GIST_TOKEN # your gist api token
$GIST_ID # your gist post id
$GIST_FILENAME # gist file name you want to use
```

here is buildspec.yml sample
```yaml
version: 0.2

phases:
  install:
    commands:
      - curl -O https://raw.githubusercontent.com/jadewon/shields.io-style-badge-gist-cache/master/badge.svg.codebiuild.sh
  pre_build:
    commands:
      - npx jest --ci --coverage --no-cache --forceExit --silent --bail
      - bash ./badge.svg.codebiuild.sh
  build:
    commands:
      - npm run deploy
```

# Usage
gist only provide text/plain mime-type.

so you need to change mime-type.

[githack.com](https://gist.githack.com) is currently good to use for now.

in your README.md
```markdown
[![coverage](https://gist.githack.com/YOUR_GITHUB_ID/YOUR_GIST_ID/raw/GIST_FILENAME.svg)](https://github.com/YOUR-GITHUB-REPOSITORY)
```

## Sonarqube (tested 7.9.2 only)
### badge.svg.sonarqube.sh
This might useful when your Sonarqube server is not public.

This script runs like this
1. find sonarqube project key and host information in sonar-project.properties file
2. get metrics informations through sonarqube web api
3. cache badge svg through shields.io and post to gist

first of all you need to setup codebuild with environment variables
```shell
$GIST_TOKEN # your gist api token
$GIST_ID # your gist post id
$SONAR_TOKEN # sonarqube web api token
```

here is buildspec.yml sample
```yaml
version: 0.2

phases:
  install:
    commands:
      - curl -O https://raw.githubusercontent.com/jadewon/shields.io-style-badge-gist-cache/master/badge.svg.sonarqube.sh
  pre_build:
    commands:
      - npx jest --ci --coverage --no-cache --forceExit --silent --bail
      - bash analyze-sonarqube.sh # you probably already have this file
      - bash ./badge.svg.sonarqube.sh
  build:
    commands:
      - npm run deploy
```

### Usage
gist only provide text/plain mime-type.

so you need to change mime-type.

[githack.com](https://gist.githack.com) is currently good to use for now.

in your README.md
```markdown
[![bugs](https://gist.githack.com/YOUR_GITHUB_ID/YOUR_GIST_ID/raw/SONAR_PROJECT_KEY.bugs.svg)](https://github.com/YOUR-GITHUB-REPOSITORY)
[![code_smells](https://gist.githack.com/YOUR_GITHUB_ID/YOUR_GIST_ID/raw/SONAR_PROJECT_KEY.code_smells.svg)](https://github.com/YOUR-GITHUB-REPOSITORY)
[![coverage](https://gist.githack.com/YOUR_GITHUB_ID/YOUR_GIST_ID/raw/SONAR_PROJECT_KEY.coverage.svg)](https://github.com/YOUR-GITHUB-REPOSITORY)
[![duplicated_lines_density](https://gist.githack.com/YOUR_GITHUB_ID/YOUR_GIST_ID/raw/SONAR_PROJECT_KEY.duplicated_lines_density.svg)](https://github.com/YOUR-GITHUB-REPOSITORY)
[![ncloc](https://gist.githack.com/YOUR_GITHUB_ID/YOUR_GIST_ID/raw/SONAR_PROJECT_KEY.ncloc.svg)](https://github.com/YOUR-GITHUB-REPOSITORY)
[![sqale_rating](https://gist.githack.com/YOUR_GITHUB_ID/YOUR_GIST_ID/raw/SONAR_PROJECT_KEY.sqale_rating.svg)](https://github.com/YOUR-GITHUB-REPOSITORY)
[![alert_status](https://gist.githack.com/YOUR_GITHUB_ID/YOUR_GIST_ID/raw/SONAR_PROJECT_KEY.alert_status.svg)](https://github.com/YOUR-GITHUB-REPOSITORY)
[![reliability_rating](https://gist.githack.com/YOUR_GITHUB_ID/YOUR_GIST_ID/raw/SONAR_PROJECT_KEY.reliability_rating.svg)](https://github.com/YOUR-GITHUB-REPOSITORY)
[![security_rating](https://gist.githack.com/YOUR_GITHUB_ID/YOUR_GIST_ID/raw/SONAR_PROJECT_KEY.security_rating.svg)](https://github.com/YOUR-GITHUB-REPOSITORY)
[![sqale_index](https://gist.githack.com/YOUR_GITHUB_ID/YOUR_GIST_ID/raw/SONAR_PROJECT_KEY.sqale_index.svg)](https://github.com/YOUR-GITHUB-REPOSITORY)
[![vulnerabilities](https://gist.githack.com/YOUR_GITHUB_ID/YOUR_GIST_ID/raw/SONAR_PROJECT_KEY.vulnerabilities.svg)](https://github.com/YOUR-GITHUB-REPOSITORY)
```
