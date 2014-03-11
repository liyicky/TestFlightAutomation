#!/usr/bin/env sh

# set -e exits the terminal once a command returns a non 0 exit code. Use this to not push any broken code.
set -e

# Paths
PROJECT_PATH=""
PROJECT_NAME=""
RELEASE_BUILD_PATH=""
IPA_PATH="${PROJECT_PATH}/${PROJECT_NAME}.ipa"
DSYM_ZIP="${PROJECT_PATH}/${PROJECT_NAME}.app.dSYM.zip"
PROVISIONING_PROFILE=""

# TestFlight Vars
DEVELOPER=""
API_TOKEN="abc"
TEAM_TOKEN="123"
APP="${HOME}/Library/Developer/Xcode/Archives/${DATE}/${ARCHIVE}/Products/Applications/${PROJECT_NAME}.app"
DISTRIBUTION_LIST="Your_TestFlight_Teams"
DATE=$(/bin/date +%"Y-%m-%d")


# Clean up
/bin/rm -f /tmp/testflightnotes.txt
/bin/rm -f $IPA_PATH
/bin/rm -f $DSYM_ZIP

/usr/bin/vim /tmp/testflightnotes.txt
NOTES=$(/bin/cat /tmp/testflightnotes.txt)


# Git the latest version
git checkout YOUR_BRANCH 
git fetch
git reset --hard remotes/origin/AppOrchard

# Build
$HOME/.rbenv/shims/ipa build --verbose --scheme YOUR_SCHEME

# curl everything to TestFlight
/usr/bin/curl "http://testflightapp.com/api/builds.json" \
  -F file=@"${IPA_PATH}"        \
  -F dsym=@"${DSYM_ZIP}"        \
  -F api_token="${API_TOKEN}"   \
  -F team_token="${TEAM_TOKEN}" \
  -F notify=True                \
  -F notes="${NOTES}"           \
  -F distribution_list="${DISTRIBUTION_LIST}"

git wood --summary HEAD^..HEAD
/usr/bin/open "https://testflightapp.com/dashboard/builds/"
$HOME/.rbenv/shims/terminal-notifier -title "${PROJECT_NAME}" -subtitle "New Build ${NEW_VERSION}" -message "${NOTES}" 
