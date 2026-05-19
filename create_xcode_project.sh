#!/bin/bash
set -e

PROJECT_NAME="ArcanaCodex"
BUNDLE_ID="com.tokyonasu.ArcanaCodex"
DIR="$(cd "$(dirname "$0")" && pwd)"
PROJ_DIR="$DIR/$PROJECT_NAME.xcodeproj"

mkdir -p "$PROJ_DIR"

# Collect all Swift files
SWIFT_FILES=()
while IFS= read -r f; do
    SWIFT_FILES+=("$f")
done < <(find "$DIR/$PROJECT_NAME" -name "*.swift" | sort)

# Collect JSON data files
JSON_FILES=()
while IFS= read -r f; do
    JSON_FILES+=("$f")
done < <(find "$DIR/$PROJECT_NAME/Data" -name "*.json" -not -path "*/.omc/*" | sort)

# Collect asset catalogs
XCASSET_FILES=()
while IFS= read -r f; do
    XCASSET_FILES+=("$f")
done < <(find "$DIR/$PROJECT_NAME" -name "*.xcassets" -type d -prune | sort)

# Collect generated image assets
IMAGE_FILES=()
while IFS= read -r f; do
    IMAGE_FILES+=("$f")
done < <(find "$DIR/$PROJECT_NAME/Assets" \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) 2>/dev/null | sort)

# Generate unique IDs
gen_id() {
    local input="$1"
    if command -v md5sum >/dev/null 2>&1; then
        echo -n "$input" | md5sum | cut -c1-24 | tr 'a-f' 'A-F'
    elif command -v md5 >/dev/null 2>&1; then
        echo -n "$input" | md5 | cut -c1-24 | tr 'a-f' 'A-F'
    else
        python3 -c "import hashlib; print(hashlib.md5('$input'.encode()).hexdigest()[:24].upper())"
    fi
}

# Fixed IDs
ROOT_GROUP_ID="AA0000000000000000000001"
MAIN_GROUP_ID="AA0000000000000000000002"
PRODUCTS_GROUP_ID="AA0000000000000000000003"
APP_TARGET_ID="AA0000000000000000000004"
PRODUCT_REF_ID="AA0000000000000000000005"
PROJECT_ID="AA0000000000000000000006"
BUILD_CONFIG_DEBUG_ID="AA0000000000000000000007"
BUILD_CONFIG_RELEASE_ID="AA0000000000000000000008"
BUILD_CONFIG_LIST_PROJ_ID="AA0000000000000000000009"
BUILD_CONFIG_DEBUG_T_ID="AA000000000000000000000A"
BUILD_CONFIG_RELEASE_T_ID="AA000000000000000000000B"
BUILD_CONFIG_LIST_TARGET_ID="AA000000000000000000000C"
SOURCES_PHASE_ID="AA000000000000000000000D"
RESOURCES_PHASE_ID="AA000000000000000000000E"
FRAMEWORKS_PHASE_ID="AA000000000000000000000F"

# Build file references and build files
FILE_REFS=""
BUILD_FILE_REFS=""
SOURCE_BUILD_FILES=""
RESOURCE_BUILD_FILES=""
CHILDREN_REFS=""

for f in "${SWIFT_FILES[@]}"; do
    rel="${f#$DIR/$PROJECT_NAME/}"
    fid=$(gen_id "fileref_$rel")
    bid=$(gen_id "buildfile_$rel")
    FILE_REFS+="
        $fid = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"$rel\"; sourceTree = \"<group>\"; };
"
    BUILD_FILE_REFS+="
        $bid = {isa = PBXBuildFile; fileRef = $fid; };
"
    SOURCE_BUILD_FILES+="$bid, "
    CHILDREN_REFS+="$fid, "
done

for f in "${JSON_FILES[@]}"; do
    rel="${f#$DIR/$PROJECT_NAME/}"
    fid=$(gen_id "fileref_$rel")
    bid=$(gen_id "buildfile_$rel")
    FILE_REFS+="
        $fid = {isa = PBXFileReference; lastKnownFileType = text.json; path = \"$rel\"; sourceTree = \"<group>\"; };
"
    BUILD_FILE_REFS+="
        $bid = {isa = PBXBuildFile; fileRef = $fid; };
"
    RESOURCE_BUILD_FILES+="$bid, "
    CHILDREN_REFS+="$fid, "
done

for f in "${XCASSET_FILES[@]}"; do
    rel="${f#$DIR/$PROJECT_NAME/}"
    fid=$(gen_id "fileref_$rel")
    bid=$(gen_id "buildfile_$rel")
    FILE_REFS+="
        $fid = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = \"$rel\"; sourceTree = \"<group>\"; };
"
    BUILD_FILE_REFS+="
        $bid = {isa = PBXBuildFile; fileRef = $fid; };
"
    RESOURCE_BUILD_FILES+="$bid, "
    CHILDREN_REFS+="$fid, "
done

for f in "${IMAGE_FILES[@]}"; do
    rel="${f#$DIR/$PROJECT_NAME/}"
    ext="${rel##*.}"
    fid=$(gen_id "fileref_$rel")
    bid=$(gen_id "buildfile_$rel")
    FILE_REFS+="
        $fid = {isa = PBXFileReference; lastKnownFileType = image.$ext; path = \"$rel\"; sourceTree = \"<group>\"; };
"
    BUILD_FILE_REFS+="
        $bid = {isa = PBXBuildFile; fileRef = $fid; };
"
    RESOURCE_BUILD_FILES+="$bid, "
    CHILDREN_REFS+="$fid, "
done

cat > "$PROJ_DIR/project.pbxproj" << PBXEOF
// !\$*UTF8*\$!
{
    archiveVersion = 1;
    classes = {};
    objectVersion = 56;
    objects = {
        $FILE_REFS
        $BUILD_FILE_REFS

        $PRODUCT_REF_ID = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = "$PROJECT_NAME.app"; sourceTree = BUILT_PRODUCTS_DIR; };

        $ROOT_GROUP_ID = {
            isa = PBXGroup;
            children = ($MAIN_GROUP_ID, $PRODUCTS_GROUP_ID);
            sourceTree = "<group>";
        };
        $MAIN_GROUP_ID = {
            isa = PBXGroup;
            children = ($CHILDREN_REFS);
            path = "$PROJECT_NAME";
            sourceTree = "<group>";
        };
        $PRODUCTS_GROUP_ID = {
            isa = PBXGroup;
            children = ($PRODUCT_REF_ID);
            name = Products;
            sourceTree = "<group>";
        };

        $SOURCES_PHASE_ID = {
            isa = PBXSourcesBuildPhase;
            buildActionMask = 2147483647;
            files = ($SOURCE_BUILD_FILES);
            runOnlyForDeploymentPostprocessing = 0;
        };
        $RESOURCES_PHASE_ID = {
            isa = PBXResourcesBuildPhase;
            buildActionMask = 2147483647;
            files = ($RESOURCE_BUILD_FILES);
            runOnlyForDeploymentPostprocessing = 0;
        };
        $FRAMEWORKS_PHASE_ID = {
            isa = PBXFrameworksBuildPhase;
            buildActionMask = 2147483647;
            files = ();
            runOnlyForDeploymentPostprocessing = 0;
        };

        $APP_TARGET_ID = {
            isa = PBXNativeTarget;
            buildConfigurationList = $BUILD_CONFIG_LIST_TARGET_ID;
            buildPhases = ($SOURCES_PHASE_ID, $RESOURCES_PHASE_ID, $FRAMEWORKS_PHASE_ID);
            buildRules = ();
            dependencies = ();
            name = "$PROJECT_NAME";
            productName = "$PROJECT_NAME";
            productReference = $PRODUCT_REF_ID;
            productType = "com.apple.product-type.application";
        };

        $PROJECT_ID = {
            isa = PBXProject;
            attributes = {
                BuildIndependentTargetsInParallel = 1;
                LastSwiftUpdateCheck = 1540;
                LastUpgradeCheck = 1540;
            };
            buildConfigurationList = $BUILD_CONFIG_LIST_PROJ_ID;
            compatibilityVersion = "Xcode 14.0";
            developmentRegion = ja;
            hasScannedForEncodings = 0;
            knownRegions = (ja, en, Base);
            mainGroup = $ROOT_GROUP_ID;
            productRefGroup = $PRODUCTS_GROUP_ID;
            projectDirPath = "";
            projectRoot = "";
            targets = ($APP_TARGET_ID);
        };

        $BUILD_CONFIG_DEBUG_ID = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ALWAYS_SEARCH_USER_PATHS = NO;
                CLANG_ENABLE_MODULES = YES;
                SWIFT_OPTIMIZATION_LEVEL = "-Onone";
                DEBUG_INFORMATION_FORMAT = dwarf;
                SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
            };
            name = Debug;
        };
        $BUILD_CONFIG_RELEASE_ID = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ALWAYS_SEARCH_USER_PATHS = NO;
                CLANG_ENABLE_MODULES = YES;
                SWIFT_OPTIMIZATION_LEVEL = "-Owholemodule";
                DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
                SWIFT_COMPILATION_MODE = wholemodule;
            };
            name = Release;
        };
        $BUILD_CONFIG_LIST_PROJ_ID = {
            isa = XCConfigurationList;
            buildConfigurations = ($BUILD_CONFIG_DEBUG_ID, $BUILD_CONFIG_RELEASE_ID);
            defaultConfigurationIsVisible = 0;
            defaultConfigurationName = Release;
        };

        $BUILD_CONFIG_DEBUG_T_ID = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
                CODE_SIGN_STYLE = Automatic;
                CURRENT_PROJECT_VERSION = 1;
                DEVELOPMENT_TEAM = 83VGKGSQUH;
                GENERATE_INFOPLIST_FILE = YES;
                INFOPLIST_KEY_CFBundleDisplayName = "Arcana Codex";
                INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
                INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
                INFOPLIST_KEY_UILaunchScreen_Generation = YES;
                INFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;
                INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
                IPHONEOS_DEPLOYMENT_TARGET = 17.0;
                MARKETING_VERSION = 1.0;
                PRODUCT_BUNDLE_IDENTIFIER = "$BUNDLE_ID";
                PRODUCT_NAME = "\$(TARGET_NAME)";
                SDKROOT = iphoneos;
                SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
                SWIFT_EMIT_LOC_STRINGS = YES;
                SWIFT_VERSION = 5.0;
                TARGETED_DEVICE_FAMILY = "1,2";
            };
            name = Debug;
        };
        $BUILD_CONFIG_RELEASE_T_ID = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
                CODE_SIGN_STYLE = Automatic;
                CURRENT_PROJECT_VERSION = 1;
                DEVELOPMENT_TEAM = 83VGKGSQUH;
                GENERATE_INFOPLIST_FILE = YES;
                INFOPLIST_KEY_CFBundleDisplayName = "Arcana Codex";
                INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
                INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
                INFOPLIST_KEY_UILaunchScreen_Generation = YES;
                INFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;
                INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
                IPHONEOS_DEPLOYMENT_TARGET = 17.0;
                MARKETING_VERSION = 1.0;
                PRODUCT_BUNDLE_IDENTIFIER = "$BUNDLE_ID";
                PRODUCT_NAME = "\$(TARGET_NAME)";
                SDKROOT = iphoneos;
                SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
                SWIFT_EMIT_LOC_STRINGS = YES;
                SWIFT_VERSION = 5.0;
                TARGETED_DEVICE_FAMILY = "1,2";
            };
            name = Release;
        };
        $BUILD_CONFIG_LIST_TARGET_ID = {
            isa = XCConfigurationList;
            buildConfigurations = ($BUILD_CONFIG_DEBUG_T_ID, $BUILD_CONFIG_RELEASE_T_ID);
            defaultConfigurationIsVisible = 0;
            defaultConfigurationName = Release;
        };
    };
    rootObject = $PROJECT_ID;
}
PBXEOF

echo "Xcode project created at $PROJ_DIR"
