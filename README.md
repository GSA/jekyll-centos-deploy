# jekyll-centos-deploy
Deploy jekyll site and run jekyll-rebuilder on centos 6

This will deploy your jekyll files hosted on github.com onto a fresh CentOS 6 box, set up jekyll-rebuilder to be managed by supervisord, so that it is ready for webhook calls from github.com. Any commit made to master branch will trigger a git pull and jekyll build, so new changes can go live right away.

The only files that matter are those in deployment folder. The rest is plain jekyll dummy files created by jekyll build command.

WARNING: This is supposed to be run on a fresh CentOS box. It will configure the system based on this assumption.

- Set up the site
```
# cd /tmp
# curl -LO https://github.com/GSA/jekyll-centos-deploy/raw/master/deployment/build.sh
# chmod +x build.sh
You might want to change the APPNAME and SECRET values before next step
# ./build.sh
```
- Verify everything is ready.
http://server.ip.address/ should load the "Your awesome title" site, and http://server.ip.address/webhook/myjekyll/abcdefghijk will trigger jekyll-rebuilder process.

- Add a webhook by at the setting page on github.com for your repo, use http://server.ip.address/webhook/myjekyll/abcdefghijk as Payload URL, applicaiton-json as Content Type, leave Secret blank, then save to add webhook.

That is it.

