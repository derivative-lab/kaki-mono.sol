# !/usr/bin/env sh

branch=$(git branch --show-current)
network=$1
echo "${branch}:${network} $(date)" >> ./.github/npm_trigger

git add ./.github/npm_trigger

git commit -m "$(date) @${branch} :npm :${network} "
git push origin ${branch}:${branch}
