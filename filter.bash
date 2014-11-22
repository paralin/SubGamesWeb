#!/bin/bash
git filter-branch --force --index-filter \
    'git rm --cached --ignore-unmatch server/config/environment/development.js server/config/environment/production.js' \
    --prune-empty --tag-name-filter cat -- --all
