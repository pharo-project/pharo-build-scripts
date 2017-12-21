#!/bin/bash -x
#
# build-platform.sh -- Builds Pharo based platform-dependent images
#
#

# directory configuration
BASE_PATH="$(cd "$(dirname "$0")" && pwd)"
BASE_PATH="${BASE_PATH//\\//}" # Replace backslash(“\”) with forward slash(“/”) 
BUILD_PATH="${WORKSPACE:=$BASE_PATH/builds}"|sed 's#/#\\/#g'
BUILD_PATH="${BUILD_PATH//\\//}" # Replace backslash(“\”) with forward slash(“/”) 

IMAGES_PATH="$BASE_PATH/images"
ICONS_PATH="$BASE_PATH/platform/icons"
VM_PATH="$BUILD_PATH/vm"

# help function
function display_help() {
	echo "$(basename $0) -i input -o output [-n name] [-t title] [-v appversion] [-r pharoversion] [-s sourcesversion] [-c icon] [-w timestamp] [-X] -p mac|win|linux"
	echo " -i 		input product name, image from images-directory, or successful jenkins build"
	echo " -o 		output product name (e.g. pharo1.0)"
	echo " -n 		the name of the executable (e.g. pharo)"
	echo " -t 		the title of the application (e.g. Pharo)"
	echo " -v 		the version of the application (e.g. 1.0)"
	echo " -r 		the version of Pharo to use (e.g. 5.0)"
	echo " -s 		the sources to use (default is version)"
	echo " -c 		the icon of the application (e.g. Pharo)"
	echo " -w 		a timestamp string (e.g. `date +'%B %d, %Y'`)"
	echo " -X 		build 64bits version"
	echo " -p 		build a file for platform mac, win or linux (e.g. mac)"
}

# Will copy ressources found in INPUT PATH to the target ressources path
# This function handles platform specific files by only including files relevant for the targeted platform.
# You can mix common ressources (for all platforms) and platform-specific ressources in a properly named folder (e.g. linux, mac or win).
function copy_ressources() {
	mkdir -p "$OUTPUT_PATH/$RESOURCES_PATH"
	ls -1 "$INPUT_PATH" | while read FILE ; do
		if [ "${FILE##*.}" != "image" ] ; then
			if [ "${FILE##*.}" != "changes" ] ; then
				if [ "$FILE" == "mac" ] || [ "$FILE" == "win" ] || [ "$FILE" == "linux" ]  ; then
					if [ "$FILE" == $OPTION_PLATFORM ] ; then
						# copy platform specific files by removing the platform folder and only copy missing files (e.g. linux/vm/foo)
						ls -1 "$INPUT_PATH/$FILE" | while read PLATFORM_FILE ; do
							cp -ru "$INPUT_PATH/$FILE/$PLATFORM_FILE" "$OUTPUT_PATH/$RESOURCES_PATH"
						done
					fi
				else
					cp -r "$INPUT_PATH/$FILE" "$OUTPUT_PATH/$RESOURCES_PATH"
				fi
			fi
		fi
	done
}

# parse options
while getopts ":i:o:n:t:v:r:s:c:w:p:X?" OPT ; do
	case "$OPT" in

		# input
		i)	if [ -f "$BUILD_PATH/$OPTARG/$OPTARG.image" ] ; then
				INPUT_IMAGE="$BUILD_PATH/$OPTARG/$OPTARG.image"
			elif [ -f "$BUILD_PATH/$OPTARG.image" ] ; then
				INPUT_IMAGE="$BUILD_PATH/$OPTARG.image"
			elif [ -f "$IMAGES_PATH/$OPTARG/$OPTARG.image" ] ; then
				INPUT_IMAGE="$IMAGES_PATH/$OPTARG/$OPTARG.image"
			elif [ -f "$IMAGES_PATH/$OPTARG.image" ] ; then
				INPUT_IMAGE="$IMAGES_PATH/$OPTARG.image"
			elif [ -f "$WORKSPACE/$OPTARG.zip" ] ; then
				unzip -q "$WORKSPACE/$OPTARG.zip"
				rm -rf "$WORKSPACE/$OPTARG.zip"
				INPUT_IMAGE=`find "$WORKSPACE" -name "$OPTARG.image"`
			elif [ -n "$WORKSPACE" ] ; then
				INPUT_IMAGE=`find "$WORKSPACE" -name "$OPTARG.image"`
			fi

			if [ ! -f "$INPUT_IMAGE" ] ; then
				echo "$(basename $0): input image not found ($OPTARG)"
				exit 1
			fi

			INPUT_CHANGES="${INPUT_IMAGE%.*}.changes"
			if [ ! -f "$INPUT_CHANGES" ] ; then
				echo "$(basename $0): input changes not found ($INPUT_CHANGES)"
				exit 1
			fi

			INPUT_PATH=`dirname "$INPUT_IMAGE"`
			if [ ! -d "$INPUT_PATH" ] ; then
				echo "$(basename $0): input directory not found ($INPUT_PATH)"
				exit 1
			fi
		;;

		# output
		o) OUTPUT_NAME="$OPTARG" ;;

		# settings
		n) OPTION_NAME="$OPTARG" ;;
		t) OPTION_TITLE="$OPTARG" ;;
		v) OPTION_VERSION="$OPTARG" ;;
		r) OPTION_PHARO_VERSION="$OPTARG" ;;
		s) OPTION_SOURCE_VERSION="$OPTARG" ;;
		c) OPTION_ICON="$OPTARG" ;;
		w) OPTION_WHEN="$OPTARG" ;;
		# architecture
		X) ARCH="64" ;;
		# platform
		p) OPTION_PLATFORM="$OPTARG" ;;
		# show help
		\?)	display_help
			exit 1
		;;

	esac
done

# check the build platform
if [ -z "$OPTION_PLATFORM" ]; then
	echo "$(basename $0): no build platform given"
	exit 1	
fi 

# check required parameters
if [ -z "$INPUT_IMAGE" ] ; then
	echo "$(basename $0): no input product name given"
	exit 1
fi

if [ -z "$OUTPUT_NAME" ] ; then
	echo "$(basename $0): no output product name given"
	exit 1
fi

# check the default paramaters
if [ -z "$OPTION_NAME" ] ; then
	OPTION_NAME="$OUTPUT_NAME"
fi

if [ -z "$OPTION_TITLE" ] ; then
	OPTION_TITLE="$OUTPUT_NAME"
fi

if [ -z "$OPTION_VERSION" ] ; then
	OPTION_VERSION="1.0"
fi

if [ -z "$OPTION_PHARO_VERSION" ] ; then
	OPTION_PHARO_VERSION="$OPTION_VERSION"
fi

if [ -z "$OPTION_SOURCE_VERSION" ] ; then
	OPTION_SOURCE_VERSION="$OPTION_VERSION"
fi

if [ -z "$OPTION_ICON" ] ; then
	OPTION_ICON="Pharo"
fi

if [ -z "$OPTION_WHEN" ] ; then
	OPTION_WHEN=`date +"%B %d, %Y"`
fi

PHARO_VERSION_PATH=`echo "$OPTION_PHARO_VERSION" | sed 's/\.//'`
PHARO_SOURCES_VERSION_PATH=`echo "$OPTION_SOURCE_VERSION" | sed 's/\.//'`
SOURCES_NAME="PharoV$PHARO_SOURCES_VERSION_PATH.sources"
INPUT_SOURCES="$INPUT_PATH/$SOURCES_NAME"
if [ ! -f "$INPUT_SOURCES" ] ; then
	echo "$(basename $0): sources file not found ($INPUT_SOURCES)"
	exit 1
fi

# prepare output
if [ ! -e "$BUILD_PATH" ] ; then
	mkdir "$BUILD_PATH"
fi

case $OPTION_PLATFORM in 
	mac) 
		PRODUCT_NAME="$OPTION_NAME.app"
		RESOURCES_PATH="Contents/Resources"
		PLATFORM_ICONS_PATH="Contents/Resources"
		BIN_PATH="Contents/MacOS"
		;;
	win) 
		PRODUCT_NAME="$OPTION_NAME" 
		RESOURCES_PATH="."
		BIN_PATH="."
		PLATFORM_ICONS_PATH=""
		;;
	linux) 
		PRODUCT_NAME="`echo $OPTION_NAME | awk '{print tolower($0)}'`" 
		EXECUTABLE_NAME="pharo"
		RESOURCES_PATH="shared"
		PLATFORM_ICONS_PATH="icons"
		BIN_PATH="bin"
		;;
	*) 
		echo "$(basename $0): invalid platform given"
		exit 1 
		;;	
esac

OUTPUT_PATH="$BUILD_PATH/$PRODUCT_NAME"
OUTPUT_ARCH="$BUILD_PATH/$OUTPUT_NAME-$OPTION_PLATFORM.zip"
TEMPLATE_PATH="$BASE_PATH/platform/templates/$OPTION_PLATFORM"

if [ -f "$OUTPUT_ARCH" ] ; then
	rm -rf "$OUTPUT_ARCH"
fi

if [ -f "$OUTPUT_PATH" ] ; then
	rm -f "$OUTPUT_PATH"
fi

if [ -d "$OUTPUT_PATH" ] ; then
	rm -rf "$OUTPUT_PATH"
fi

# copy over the template
cp -R "$TEMPLATE_PATH" "$OUTPUT_PATH"

# expand all the templates
find "$OUTPUT_PATH" -name "*.template" | while read FILE ; do
	sed \
		-e "s/%{NAME}/$OPTION_NAME/g" \
		-e "s/%{TITLE}/$OPTION_TITLE/g" \
		-e "s/%{VERSION}/$OPTION_VERSION/g" \
		-e "s/%{WHEN}/$OPTION_WHEN/g" \
			"$FILE" > "${FILE%.*}"
	#chmod --reference="$FILE" "${FILE%.*}"
	rm -f "$FILE"
done

# expand all the filenames
find "$OUTPUT_PATH" | while read FILE ; do
	TRANSFORMED_FILE=`echo "$FILE" | sed \
		-e "s/%{NAME}/$EXECUTABLE_NAME/g" \
		-e "s/%{TITLE}/$OPTION_TITLE/g" \
		-e "s/%{VERSION}/$OPTION_VERSION/g" \
		-e "s/%{WHEN}/$OPTION_WHEN/g"`
	if [ "$FILE" != "$TRANSFORMED_FILE" ] ; then
		mv "$FILE" "$TRANSFORMED_FILE"
	fi
done

copy_ressources

# copy over Linux VM files
if [ "$OPTION_PLATFORM" = "linux" ]; then
	LINUX_VM_PATH="pharo$ARCH-linux-stable.zip"
	test -f $LINUX_VM_PATH || wget http://files.pharo.org/get-files/$PHARO_VERSION_PATH/$LINUX_VM_PATH
  
	if [ -f "$LINUX_VM_PATH" ] ; then
	    unzip -q "$LINUX_VM_PATH" -d "$OUTPUT_PATH/tmp"
	    mv "$OUTPUT_PATH/tmp/" "$OUTPUT_PATH/$BIN_PATH"
	else
	    echo "Warning: Cannot find Linux VM!"
	fi
fi

# copy over Mac OS VM files
if [ "$OPTION_PLATFORM" = "mac" ]; then
	MAC_VM_PATH="pharo$ARCH-mac-stable.zip"
	test -f $MAC_VM_PATH || wget http://files.pharo.org/get-files/$PHARO_VERSION_PATH/$MAC_VM_PATH

	if [ -f "$MAC_VM_PATH" ] ; then
	    unzip -q "$MAC_VM_PATH" -d "$OUTPUT_PATH/tmp"
    
	    #Ensuring bin and plugins
	    mv "$OUTPUT_PATH/tmp/Pharo.app/Contents/MacOS" "$OUTPUT_PATH/Contents"
	    # Need to add this ugly '*' outside double-quotes to be able to copy the content of the folder (and not the folder itself) on linux
	    cp -R "$OUTPUT_PATH/tmp/Pharo.app/Contents/Resources/"* "$OUTPUT_PATH/Contents/Resources"

	    rm -rf "$OUTPUT_PATH/tmp"
	else
	    echo "Warning: Cannot find Mac OS VM!"
	fi
fi

# copy over Windows VM files
if [ "$OPTION_PLATFORM" = "win" ]; then
	WIN_VM_PATH="pharo-win-stable.zip"
	test -f $WIN_VM_PATH || wget http://files.pharo.org/get-files/$PHARO_VERSION_PATH/$WIN_VM_PATH

	if [ -f "$WIN_VM_PATH" ] ; then
	    unzip -q "$WIN_VM_PATH" -d "$OUTPUT_PATH"
	else
	    echo "Warning: Cannot find Windows VM!"
	fi
fi

# copy over specific files
cp "$INPUT_IMAGE" "$OUTPUT_PATH/$RESOURCES_PATH/$OPTION_NAME.image"
cp "$INPUT_CHANGES" "$OUTPUT_PATH/$RESOURCES_PATH/$OPTION_NAME.changes"
cp "$INPUT_SOURCES" "$OUTPUT_PATH/$BIN_PATH"
if [ ! -z "$PLATFORM_ICONS_PATH" ]; then
	if [ ! -d "$OUTPUT_PATH/$PLATFORM_ICONS_PATH" ]; then
		mkdir $OUTPUT_PATH/$PLATFORM_ICONS_PATH
	fi
	cp -R "$ICONS_PATH/"* "$OUTPUT_PATH/$PLATFORM_ICONS_PATH" # Need to add this ugly '*' outside double-quotes to be able to copy the content of the folder (and not the folder itself) on linux
fi
# ensure the linux script is executable
if [ "$OPTION_PLATFORM" = "linux" ]; then
	chmod +x "$OUTPUT_PATH/$EXECUTABLE_NAME"
fi 
# zip up the application
cd "$BUILD_PATH"
zip -q -r -9 "$OUTPUT_ARCH" "$PRODUCT_NAME"
cd - > /dev/null

# remove the build directory
rm -rf "$OUTPUT_PATH"

# success
exit 0
