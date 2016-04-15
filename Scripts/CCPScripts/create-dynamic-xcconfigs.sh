#!/bin/bash
#
#   create-dynamic-xcconfigs.sh
#
#   Created by Torsten Louland on 08/04/2016.
#   Copyright (c) 2016 Torsten Louland. All rights reserved.
#   Clone https://github.com/t0rst/CCPScripts.git for licence and latest improved version.
#
#   Detect whether dependencies have been fetched with Carthage or CocoaPods and set the dynamic
#   xcconfig files to match. 
#   
#   This script is to be invoked from the Xcode scheme that builds the app, and be executed as the 
#   first Pre-action of the Build action.
#

cmd="$0"
cmd_name="$(basename "$cmd")"

#   At the time of execution (as xcode scheme build phase pre-action), stdout has not yet been
#   redirected to the build log hence the user doesn't see any diagnostics presented in the Xcode
#   UI. We have to dump info to a log file of our own making, and alert the developer directly
#   using osascript.
#
#   A Logs folder is always a sibling of Builds (may not exist yet)
#   BUILD_DIR is generally ${DERIVED_DATA_DIR}/${PROJECT}-uniqueifier/Build/Products
log_dir="${BUILD_DIR}/../../Logs"
mkdir -p "${log_dir}"
log="${log_dir}/${cmd_name}.log"

{ # output from this group redirected to log

oops()
{
    msg="### ${cmd_name}\n### $1"
    echo "$msg"
    # Tell the user directly because our log messages fly under the radar
    osascript -e "tell app \"System Events\" to display dialog \"$msg\"" &
    exit 1
}


have_cart=0
if [[ -d "${SRCROOT}/Carthage/Checkouts" ]] ; then
    have_cart=1
fi

have_pods=0
if [[ -d "${SRCROOT}/Pods" ]] ; then
    have_pods=1
fi


dependency_manager=""
if  ((have_cart && !have_pods)) ; then
    dependency_manager="carthage"
elif ((!have_cart && have_pods)) ; then
    dependency_manager="cocoapods"
elif ((have_cart && have_pods)) ; then
    oops "Error: both Carthage/Checkouts and Pods subdirectories found.\n\nYou can use carthage or cocoapods but not both. Remove either Carthage/Checkouts or Pods. See $SRCROOT/README.md."
else
    oops "You need to install subprojects using either Carthage or CocoaPods as described in README.md"
fi


update_xcconfig()
{
    local configuration=$1
    local static_xcconfig="${SRCROOT}/Config/$configuration($dependency_manager).xcconfig"
    local dynamic_xcconfig="${SRCROOT}/Config/$configuration(dynamic).xcconfig"

    if ! [[ -e "${dynamic_xcconfig}" ]] ; then
        cat < "${static_xcconfig}" > "${dynamic_xcconfig}"
        echo "Created ${dynamic_xcconfig}"
    else
        diff "${dynamic_xcconfig}" "${static_xcconfig}" > /dev/null
        if [[ $? != 0 ]] ; then
            cat < "${static_xcconfig}" > "${dynamic_xcconfig}"
            echo "Updated ${dynamic_xcconfig}"
        fi
    fi
}
update_xcconfig "Debug"
update_xcconfig "Release"

} > "${log}" 2>&1
