#!/bin/bash
# Set the build number to the current git commit count.
# Based on: http://w3facility.info/question/how-do-i-force-xcode-to-rebuild-the-info-plist-file-in-my-project-every-time-i-build-the-project/
# Updated so that future commits don't affect past build numbers.

git=`sh /etc/profile; which git`
# Add 13 so that build numbers match up with old way of counting.
appBuild=`echo $(( $($git log --oneline | wc -l) + 13 ))`
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $appBuild" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
