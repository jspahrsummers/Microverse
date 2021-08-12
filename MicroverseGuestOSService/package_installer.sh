#!/bin/bash

set -e
set -o errexit
set -x

binary="$BUILT_PRODUCTS_DIR/$FULL_PRODUCT_NAME"
image_folder="$TEMP_FILES_DIR/MicroverseGuestOSServices"
intermediate_image="$TEMP_FILES_DIR/MicroverseGuestOSServices-intermediate.dmg"
final_image="$DERIVED_FILE_DIR/MicroverseGuestOSServices.dmg"
volume_name="Microverse Guest OS Services"

rm -rf "$image_folder" "$intermediate_image" "$final_image"
mkdir -p "$image_folder"
cp "$binary" "$image_folder/"
hdiutil create -srcfolder "$image_folder" -volname "$volume_name" "$intermediate_image"
hdiutil convert "$intermediate_image" -format UDRW -o "$final_image"
