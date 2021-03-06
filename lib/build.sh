#!/usr/bin/env sh

# set -e exits the terminal once a command returns a non 0 exit code. Use this to not push any broken code.
set -e

HOME=""
PROJECT_PATH=""
PROJECT_NAME=""
RELEASE_BUILD_PATH=""
IPA_PATH="${PROJECT_PATH}/${PROJECT_NAME}.ipa"
DSYM_ZIP="${PROJECT_PATH}/${PROJECT_NAME}.app.dSYM.zip"
DEVELOPER=""
PROVISIONING_PROFILE=""
API_TOKEN="abc"
TEAM_TOKEN="123"
DATE=$(/bin/date +%"Y-%m-%d")
APP="${HOME}/Library/Developer/Xcode/Archives/${DATE}/${ARCHIVE}/Products/Applications/${PROJECT_NAME}.app"


# Clean up
/bin/rm -f /tmp/testflightnotes.txt
/bin/rm -f $IPA_PATH
/bin/rm -f $DSYM_ZIP

/usr/bin/vim /tmp/testflightnotes.txt
NOTES=$(/bin/cat /tmp/testflightnotes.txt)


#echo "Building...#
/usr/bin/cd $PROJECT_PATH
git checkout develop
git pull origin develop

git checkout deployment
git merge develop


# Get the current version
version=$(agvtool what-version)
version=$(echo $version | awk -F "." '{print $1, $2, $3, $4, $5, $6, $7, $8, $9}' )
set -- $version
#
# Split the version numbers 
export v1=$7
export v2=$8
export v3=$9
#
# Increment version
v3=$((v3+1))
if [ $v3 -gt 9 ]
then
  v3=0
  v2=$((v2+1))
fi
 
if [ $v2 -gt 9 ]
then
  v2=0
  v1=$((v1+1))
fi
 
NEW_VERSION="$v1.$v2.$v3"
agvtool new-version -all $NEW_VERSION
/opt/boxen/rbenv/shims/ipa build

# Commit new version and push
git add .
git commit -m "Build $NEW_VERSION"
git push origin deployment

# curl everything to TestFlight
/usr/bin/curl "http://testflightapp.com/api/builds.json" \
  -F file=@"${IPA_PATH}"        \
  -F dsym=@"${DSYM_ZIP}"        \
  -F api_token="${API_TOKEN}"   \
  -F team_token="${TEAM_TOKEN}" \
  -F notes="${NOTES}"

git wood --summary HEAD^..HEAD
/usr/bin/open "https://testflightapp.com/dashboard/builds/"
/opt/boxen/rbenv/shims/terminal-notifier -title "${PROJECT_NAME}" -subtitle "New Build ${NEW_VERSION}" -message "${NOTES}" 
