#!/bin/bash
# Create a .xar from a package.

# A .xar is just a zip of the contents of a package directory,
# named after its version.

package_dir="$1"
package_file="$package_dir/expath-pkg.xml"

if [ ! -d "$package_dir" ]; then
  echo "No package directory given. Use appsrc2packagexar.sh <directory>"
  exit 1
elif [ ! -f "$package_file" ]; then
  echo "Not a package directory, expath-pkg.xml missing."
  exit 1
fi

# Determine output file name.
package=`basename $package_dir`
version=`grep "<package" $package_file | grep -oP 'version="[^"]*'`
version=${version#version=\"}
xar_file="`pwd`/$package-$version.xar"

if [ -f "$xar_file" ]; then
  echo -e "Output file exists, exiting:\n$xar_file"
  exit 1
fi

# Zip all dir contents to file.
echo -e "Storing to:\n$xar_file"
cd "$package_dir" > /dev/null
zip -r "$xar_file" * > /dev/null
cd - > /dev/null

