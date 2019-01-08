#! /bin/bash
hexo clean
hexo g -d
git add _config.yml        deployAndCommit.sh package-lock.json  public             source
git add db.json   .deploy_git    node_modules       package.json       scaffolds          themes
var1=$(date "+%Y-%m-%d %H:%M:%S")
var2="deploy and commit all "$var1
echo $var2
git commit -a -m "$var2"
git push origin blogsrc
git status
