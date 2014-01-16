#!/usr/bin/env sh

# set -e exits the terminal once a command returns a non 0 exit code. Use this to not push any broken code.
set -e

HOME="/Users/liyicky"
PROJECT_NAME="LaughingShame"
RELEASE_BUILD_PATH="${HOME}/Library/Developer/Xcode/DerivedData/LaughingShame-frowannnqdcmquagdfadutbqzjxp/Build/Products/Release-iphoneos"
IPA_PATH="/tmp/${PROJECT_NAME}.ipa"
DSYM_ZIP="/tmp/${PROJECT_NAME}.dSYM.zip"
DEVELOPER="iPhone Developer: Jason Cheladyn (L5VBPXXUXF)"
PROVISIONING_PROFILE="${HOME}/Library/MobileDevice/Provisioning Profiles/5C43D101-905E-45D4-9AD4-1ACFE82D2F8E.mobileprovision"
API_TOKEN="42b1d039a90f6d66e6607df3c2e021ea_MTA0NTEyNDIwMTMtMDUtMTMgMTY6MDY6MjEuNTQ3NjA5"
TEAM_TOKEN="f4a1b4074b9af86fde51f9ecc16b119c_MzEwMjEyMjAxMy0xMi0wNiAxNDo1MToyNC45MjAxNTk"
DATE=$(date +%"Y-%m-%d")
APP="${HOME}/Library/Developer/Xcode/Archives/${DATE}/${ARCHIVE}/Products/Applications/${PROJECT_NAME}.app"


# Clean up
/bin/rm -f /tmp/testflightnotes.txt
/bin/rm -f $IPA_PATH
/bin/rm -f $DSYM_ZIP

vim /tmp/testflightnotes.txt
NOTES=$(cat /tmp/testflightnotes.txt)


#echo "Building...#
cd $HOME/Catode/AppOrchard/laughing-shame
#git checkout deployment
#git pull origin deployment
#
#git checkout master
#git pull origin master
#
#git checkout deployment
#git merge master

# Check for failure
#/usr/bin/xcodebuild -configuration release -sdk iphoneos -workspace "${PROJECT_NAME}.xcworkspace/" -scheme ${PROJECT_NAME} archive
/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${RELEASE_BUILD_PATH}/${PROJECT_NAME}.app" -o "$IPA_PATH" --sign "${DEVELOPER}" --embed "${PROVISIONING_PROFILE}"


ARCHIVE=$(/bin/ls -t "${HOME}/Library/Developer/Xcode/Archives/${DATE}" | /usr/bin/grep xcarchive | sed -n 1p)
DSYM="${HOME}/Library/Developer/Xcode/Archives/${DATE}/${ARCHIVE}/dSYMs/${PROJECT_NAME}.app.dSYM"
/usr/bin/zip -r "${DSYM_ZIP}" "${DSYM}"

## Get the current version
#version=$(agvtool what-version)
#version=$(echo $version | awk -F "." '{print $1, $2, $3, $4, $5, $6, $7, $8, $9}' )
#set -- $version
#
## Split the version numbers 
#export v1=$7
#export v2=$8
#export v3=$9
#
## Increment version
#v3=$((v3+1))
#if [ $v3 -gt 9 ]
#then
  #v3=0
  #v2=$((v2+1))
#fi
# 
#if [ $v2 -gt 9 ]
#then
  #v2=0
  #v1=$((v1+1))
#fi
# 
#NEW_VERSION="$v1.$v2.$v3"
#agvtool new-version -all $NEW_VERSION
# 
## Commit new version and push
#git add .
#git commit -m "Build $NEW_VERSION"

#git push origin deployment

# curl ecerything to TestFlight
/usr/bin/curl "http://testflightapp.com/api/builds.json" \
  -F file=@"${IPA_PATH}"        \
  -F dsym=@"${DSYM_ZIP}"        \
  -F api_token="${API_TOKEN}"   \
  -F team_token="${TEAM_TOKEN}" \
  -F notes="${NOTES}"

git wood --summary HEAD^..HEAD
/usr/bin/open "https://testflightapp.com/dashboard/builds/"
terminal-notifier -title "${PROJECT_NAME}" -subtitle "New Build ${NEW_VERSION}" -message "${NOTES}" 

echo $DSYM
