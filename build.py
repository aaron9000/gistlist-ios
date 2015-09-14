#!/usr/bin/env python
import json
import subprocess
import os
import datetime
import sys
import plistlib
import urllib

# Helpers
def line():
    print "----------------------------------------------------------"


# Get command line argument for config file
config_filename = ""
for arg in sys.argv:
    if arg != "build.py":
        config_filename = arg.strip()

if config_filename == "":
    print "please provide a config file e.g. 'python build.py config.json'"
    exit(0)

# Load configuration JSON file
if os.path.exists(config_filename) == 0:
    print "config file " + config_filename + " not found"
    exit(0)
config_file = open(config_filename)
config_json = json.load(config_file)
config_file.close()


# Extract necessary values
config_app_title = config_json["app_title"]
config_bundle_identifier = config_json["bundle_identifier"]
config_bundle_version = config_json["bundle_version"]
config_configuration = config_json["configuration"]
config_scheme = config_json["scheme"]
config_ipa_filename = config_json["ipa_filename"]
config_s3_bucket_name = config_json["s3_bucket_name"]
config_s3_bucket_url = config_json["s3_bucket_url"]


# Print config values for sanity
line()
print "app title: " + config_app_title
print "bundle identifier: " + config_bundle_identifier
print "bundle version: " + config_bundle_version
print "configuration: " + config_configuration
print "scheme: " + config_scheme
print "ipa filename: " + config_ipa_filename
print "s3 bucket name: " + config_s3_bucket_name
print "s3 bucket url: " + config_s3_bucket_url

# Build ipa
line()
print "building IPA"
build_command = "ipa build --Configuration=" + config_configuration + " --Scheme=" + config_scheme
returncode = subprocess.call(build_command, shell=True)
if returncode != 0:
    print "failed to build IPA"
    exit(0)

# Move ipa into BUILD folder
line()
print "moving IPA into BUILD folder"
if os.path.isdir("BUILD") == 0 or os.path.exists("BUILD") == 0:
    print "could not find BUILD folder, creating one"
    os.mkdir("BUILD")

move_command = "cp \"" + config_ipa_filename + "\" BUILD"
returncode = subprocess.call(move_command, shell=True)
if returncode != 0:
    print "failed to move IPA into BUILD folder"
    exit(0)

# Build Manifest Dictionary
line()
print "writing manifest"
ipa_url = config_s3_bucket_url + urllib.quote(config_ipa_filename)
assets = [{
    'kind': 'software-package',
    'url': ipa_url
}]
metadata = {
    'bundle-identifier': config_bundle_identifier,
    'bundle-version': config_bundle_version,
    'kind': 'software',
    'title': config_app_title
}
manifest = {'items': [{'assets': assets, 'metadata': metadata}]}

# Write Manifest to output folder
try:
    filename = "BUILD/manifest.plist"
    o = open(filename, "wb")
    plistlib.writePlist(manifest, o)
    o.close()
except:
    print("failed to write manifest")
    exit(0)

# Build download page
line()
print "writing download page"
try:
    manifest_url = config_s3_bucket_url + "manifest.plist"
    formatted_environment = "Build Configuration: " + config_configuration
    formatted_app_name = config_app_title + " " + config_bundle_version
    formatted_title = config_app_title + " - " + config_configuration
    formatted_date = "Last Updated: " + str(datetime.datetime.now())
    new_page = open("tokenized-download-page.html").read()
    new_page = new_page.replace("APP_NAME_KEY", formatted_app_name)
    new_page = new_page.replace("URL_KEY", manifest_url)
    new_page = new_page.replace("LAST_UPDATED_KEY", formatted_date)
    new_page = new_page.replace("PAGE_TITLE_KEY", formatted_title)

    # Write new download page
    filename = "BUILD/index.html"
    o = open(filename, "wb")
    o.write(new_page)
    o.close()

except:
    print("failed to create download page")
    exit(0)

# Deploy to Amazon S3
line()
print "deploying to S3"
deploy_command = "aws s3 sync BUILD/ s3://" + config_s3_bucket_name + "/ --profile personal"
subprocess.call(deploy_command, shell=True)
