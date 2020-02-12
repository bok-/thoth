# 
# Thoth
#
# Supports the following commands:
# 
# make:			Builds the config bundle into .export
# clean:		Cleans up previous build runs
# test:			Runs `swift test`
# deploy:		Deploys to the configured S3 bucket using the aws-cli
#

#
# Configuration
#

# The S3 bucket to deploy to
BUCKET=cchmelb-demo

# The AWS region the bucket is in
REGION=ap-southeast-2

# The profile you've configured in the aws-cli (probably `Default`, check ~/.aws/credentials)
PROFILE=odynia


#
# Commands
#
build:
	swift run

clean:
	rm -rf ./.export ./.build

test:
	swift test
	
deploy:
	aws --profile ${PROFILE} --region ${REGION} s3 sync ./.export/ s3://${BUCKET}/ --cache-control no-cache
