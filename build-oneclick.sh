#!/bin/bash
#
# build-oneclick.sh -- Builds Pharo based One-Click images
#
# Copyright (c) 2010-2011 Lukas Renggli <renggli@gmail.com>
#               2012      Christophe Demarey
#

# directory configuration
BASE_PATH="$(cd "$(dirname "$0")" && pwd)"
BUILD_PATH="${WORKSPACE:=$BASE_PATH/builds}"

IMAGES_PATH="$BASE_PATH/images"
TEMPLATE_PATH="$BASE_PATH/one-click/templates"
ICONS_PATH="$BASE_PATH/one-click/icons"
VM_PATH="$BUILD_PATH/vm"

# help function
function display_help() {
	echo "$(basename $0) -i input -o output [-n name] [-t title] [-v version] [-c icon] [-w timestamp]"
	echo " -i 		input product name, image from images-directory, or successful jenkins build"
	echo " -o 		output product name (e.g. pharo1.0)"
	echo " -n 		the name of the executable (e.g. pharo)"
	echo " -t 		the title of the application (e.g. Pharo)"
	echo " -v 		the version of the application (e.g. 1.0)"
	echo " -c 		the icon of the application (e.g. Pharo)"
	echo " -w 		a timestamp string (e.g. `date +'%B %d, %Y'`)"
}

# parse options
while getopts ":i:o:n:t:v:c:w:?" OPT ; do
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
		c) OPTION_ICON="$OPTARG" ;;
		w) OPTION_WHEN="$OPTARG" ;;

		# show help
		\?)	display_help
			exit 1
		;;

	esac
done

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

if [ -z "$OPTION_ICON" ] ; then
	OPTION_ICON="Pharo"
fi

if [ -z "$OPTION_WHEN" ] ; then
	OPTION_WHEN=`date +"%B %d, %Y"`
fi

# prepare output
if [ ! -e "$BUILD_PATH" ] ; then
	mkdir "$BUILD_PATH"
fi

PATH_VERSION=`echo "$OPTION_VERSION" | sed 's/\.//'`
OUTPUT_PATH="$BUILD_PATH/$OPTION_NAME.app"
OUTPUT_ARCH="$BUILD_PATH/$OUTPUT_NAME.zip"

if [ -f "$OUTPUT_ARCH" ] ; then
	rm -rf "$OUTPUT_ARCH"
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
	chmod --reference="$FILE" "${FILE%.*}"
	rm -f "$FILE"
done

# expand all the filenames
find "$OUTPUT_PATH" | while read FILE ; do
	TRANSFORMED_FILE=`echo "$FILE" | sed \
		-e "s/%{NAME}/$OPTION_NAME/g" \
		-e "s/%{TITLE}/$OPTION_TITLE/g" \
		-e "s/%{VERSION}/$OPTION_VERSION/g" \
		-e "s/%{WHEN}/$OPTION_WHEN/g"`
	if [ "$FILE" != "$TRANSFORMED_FILE" ] ; then
		mv "$FILE" "$TRANSFORMED_FILE"
	fi
done

# copy over the build contents
mkdir -p "$OUTPUT_PATH/Contents/Resources/"
ls -1 "$INPUT_PATH" | while read FILE ; do
	if [ "${FILE##*.}" != "image" ] ; then
		if [ "${FILE##*.}" != "changes" ] ; then
			cp -R "$INPUT_PATH/$FILE" "$OUTPUT_PATH/Contents/Resources/"
		fi
	fi
done

# copy over Linux VM files
LINUX_VM_PATH="pharo-linux-stable.zip"
wget http://files.pharo.org/get-files/$PATH_VERSION/$LINUX_VM_PATH
if [ -f "$LINUX_VM_PATH" ] ; then
    unzip -q "$LINUX_VM_PATH" -d "$OUTPUT_PATH/tmp"
    mv "$OUTPUT_PATH/tmp/" "$OUTPUT_PATH/Contents/Linux/"
else
    echo "Warning: Cannot find Linux VM!"
fi

# copy over Mac OS VM files
MAC_VM_PATH="pharo-mac-stable.zip"
wget http://files.pharo.org/get-files/$PATH_VERSION/$MAC_VM_PATH
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

# copy over Windows VM files
WIN_VM_PATH="pharo-win-stable.zip"
wget http://files.pharo.org/get-files/$PATH_VERSION/$WIN_VM_PATH
if [ -f "$WIN_VM_PATH" ] ; then
    unzip -q "$WIN_VM_PATH" -d "$OUTPUT_PATH"
else
    echo "Warning: Cannot find Windows VM!"
fi
# copy over specific files
cp "$INPUT_IMAGE" "$OUTPUT_PATH/Contents/Resources/$OPTION_NAME.image"
cp "$INPUT_CHANGES" "$OUTPUT_PATH/Contents/Resources/$OPTION_NAME.changes"
cp -R "$ICONS_PATH/"* "$OUTPUT_PATH/Contents/Resources" # Need to add this ugly '*' outside double-quotes to be able to copy the content of the folder (and not the folder itself) on linux


# zip up the application
cd "$BUILD_PATH"
zip -q -r -9 "$OUTPUT_ARCH" "$OPTION_NAME.app"
cd - > /dev/null

# remove the build directory
rm -rf "$OUTPUT_PATH"

# success
exit 0
