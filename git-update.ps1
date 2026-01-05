#!/usr/bin/env pwsh
# push git commits quicker

param ([string]$commitdescription)

git add .
git commit -m "$commitdescription"
git push