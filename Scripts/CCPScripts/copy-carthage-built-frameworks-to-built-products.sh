#!/bin/bash
#
#   copy-carthage-built-frameworks-to-built-products.sh
#
#   Created by Torsten Louland on 06/04/2016.
#   Copyright (c) 2016 Torsten Louland. All rights reserved.
#   Clone https://github.com/t0rst/CCPScripts.git for licence and latest improved version.
#
#   Input is from Xcode environment vars: BUILT_PRODUCTS_DIR, SCRIPT_INPUT_FILE_{COUNT,0..n}
#
#   What:   Each SCRIPT_INPUT_FILE_<n> is expected to give a path to a framework built/fetched by
#   carthage. Copy it to the built products directory if the framework binary is newer than
#   existing or no existing, and if this is the case and we are not stripping symbols, then also
#   copy its dSYM if available.
#
#   How:    In your Xcode project's target's build phases, add a run script phase that invokes
#   this script with the paths of frameworks built by carthage, and position the run script phase
#   before the Link Binary With Libraries and, if used, the Embed Frameworks phase.
#
#   Why:    For use in a project file that can be built both a) stand-alone using frameworks
#   built/fetched by carthage (the simplest set up), b) as part of enclosing xcworkspace using
#   frameworks built by sibling projects in the workspace (advantageous when developing frameworks
#   in parallel with host app and easier to debug). To unify these two routes, choose the built
#   products directory as the common location for the Embed Frameworks build phase to expect
#   frameworks to be in. (It's possible, but very tricky to achieve this through the xcode UI; its
#   often easier to carefully hand edit the PBXFileReference section of your (closed) xcodeproj
#   file so that you have framework entries of the form: AEA6FE4D1C917D94005C3A8B = {isa =
#   PBXFileReference; lastKnownFileType = wrapper.framework; path = FrameworkName.framework;
#   sourceTree = BUILT_PRODUCTS_DIR; }; - i.e. the path attribute just gives the leaf relative to
#   the built products directory, i.e. only the framework name, and hence the separate name
#   attribute is unnecessary.) When building as part of a workspace, the frameworks are placed
#   there directly and this script is a no-op, but when building host project standalone, this
#   script copies the frameworks over.
#
#   If you only build the host project standalone, then you can tell the Embed Frameworks build
#   phase the original location for frameworks and you do not need this script.
# 

verbose=1

for var in ${!SCRIPT_INPUT_FILE_*} ; do
    src_fwk="${!var}"

    # Have we got a framework parameter? (i.e. not SCRIPT_INPUT_FILE_COUNT)
    if [[ -e "${src_fwk}" ]] ; then

        fwk_name="$(basename -s .framework "${src_fwk}")"
        src_fwk_bin="${src_fwk}/${fwk_name}"
        dst_fwk="${BUILT_PRODUCTS_DIR}/${fwk_name}.framework"
        dst_fwk_bin="${dst_fwk}/${fwk_name}"

        # Do we need to copy it?
        if [[ "$src_fwk_bin" -nt "$dst_fwk_bin" ]] ; then

            verb="copied"
            if [[ -e "$dst_fwk" ]] ; then
                rm -rf "$dst_fwk"
                verb="updated"
            fi
            cp -R "${src_fwk}" "${BUILT_PRODUCTS_DIR}"

            # dSYM as well?
            if ! ((COPY_PHASE_STRIP)) && [[ -e "${src_fwk}.dSYM" ]] ; then
                if [[ -e "${dst_fwk}.dSYM" ]] ; then
                    rm -rf "${dst_fwk}.dSYM"
                fi
                cp -R "${src_fwk}.dSYM" "${BUILT_PRODUCTS_DIR}"
                verb="$verb with dSYM"
            fi
            
            if ((verbose)) ; then
                echo "${fwk_name}.framework $verb"
            fi
        fi
    fi
done
