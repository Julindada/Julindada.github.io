#! /bin/bash
hexo clean
hexo g -d
git add .deploy_git/ db.json public/
var1=date +%Y-%m-%d
var2="deploy and commit all "$var1
git commit -a -m $var2
git push origin blogsrc
git status
