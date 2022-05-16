#!/bin/bash

#Usage: ./package-manifest.sh <url to package on jamf fileshare distibution-point>

#chunksize in byte
CHUNKSIZE=10485760

#md5 and sha256 are valid 
HASHTYPE=md5

SPLITDEST="/tmp/package-manifest_${RANDOM}_"

PACKAGEURI=$1

curl $PACKAGEURI|split -b ${CHUNKSIZE} - ${SPLITDEST}

HASHES=$(${HASHTYPE}sum ${SPLITDEST}*|awk '{print "            <string>"$1"</string>"}')

rm -rf ${SPLITDEST}*

echo \
"<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
  <!-- array of downloads. -->
  <key>items</key>
  <array>
   <dict>
    <!-- an array of assets to download -->
     <key>assets</key>
      <array>
        <dict>
         <!-- Required. The asset kind. -->
          <key>kind</key>
          <string>software-package</string>
          <!-- Optional. md5 is used here for chunking every 10 MB; Can also use sha256-size. -->
          <key>${HASHTYPE}-size</key>
          <integer>${CHUNKSIZE}</integer>
          <!-- Array of md5 hashes for each \"md5-size\" sized chunk; Can also use sha256s. -->
          <key>${HASHTYPE}s</key>
          <array>
${HASHES}
          </array>
          <!-- required. the URL of the package to download. -->
          <key>url</key>
          <string>${PACKAGEURI}</string>
        </dict>
      </array>
    </dict>
  </array>
</dict>
</plist>"
