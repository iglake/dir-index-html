#

find . -name \*.org -delete
find . -name \*~ -delete
tic=$(date +%s)
# ----------------------------------------------------------------------------------------------------------------
ver=$($HOME/bin/version dir-index.html | xyml scheduled)
qm=$(ipfs add -Q -r dir-index.html gw-assets gq-assets/favicon.ico --cid-version=1 --cid-base=base58btc)
sed -e "s,/ipfs/[bz][^/]*,/ipfs/$qm,g" dir-index.html > dir-index.html~
sed -e "s,/dir-index-html/[^/]*/gw-assets/,/dir-index-html/$ver/gw-assets/,g" dir-index.html~ > dir-index.html
#v -f dir-index.html~ dir-index.html
# ----------------------------------------------------------------------------------------------------------------
qm=$(ipfs add -Q -w --cid-version=1 --cid-base=base58btc -r gw-assets/favicon.ico README.md dir-index.html dir-index-uncat.html gw-assets index.go knownIcons.txt LICENSE)
bafy=$(ipfs cid base32 $qm)
url="https://$bafy.cf-ipfs.com"
sed -e "s,/ipns/Qm[^/]*,https://$bafy.cf-ipfs.com/gw-assets,g" dir-index-uncat.html > dir-index-cf.html
sed -e "s,/ipns/Qm[^/]*,http://$bafy.ipfs.dweb.link/gw-assets,g" dir-index-uncat.html > dir-index-dweb.html
sed -e "s,/ipns/Qm[^/]*,/ipfs/$qm/gw-assets,g" dir-index-uncat.html > dir-index-ipfs.html
url=http://127.0.0.1:8080/ipfs/$(ipfs add -Q -n dir-index-ipfs.html)
echo firefox $url
git add README.md dir-index.html dir-index-*.html gw-assets index.go knownIcons.txt LICENSE revs.log
if git commit -m "publishing on $tic for $ver"; then
gitid=$(git rev-parse HEAD)
git tag -f -a $ver -m "tagging $gitid on $(date +%D)"
echo "gitid: $gitid ($ver)"
echo "$tic: $gitid ($ver)" >> revs.log
find .git/objects -type f -exec ipfs dag put --format=git --input-enc=zlib {} \; > hashes
fi
# ----------------------------------------------------------------------------------------------------------------
qm=$(ipfs add -Q -w -r README.md gw-assets dir-index.html dir-index-*.html gw-assets/favicon.ico index.go knownIcons.txt LICENSE)
tag=$(git describe --abbrev=0 --tags)
rm -f .gx/lastpubver.prv
mv .gx/lastpubver .gx/lastpubver.prv
echo $tag: $qm
echo $tag: $qm > .gx/lastpubver
# ----------------------------------------------------------------------------------------------------------------
qm=$(ipfs add -Q -w -r gw-assets dir-index.html dir-index-dweb.html .gx gw-assets/favicon.ico qm.log)
echo $tic: $qm >> qm.log
echo http://$(ipfs cid base32 $qm).cf-ipfs.com/
echo http://yoogle.com:8080/ipfs/$qm
ipfs name publish --key=gw-assets /ipfs/$qm/gw-assets &
# ----------------------------------------------------------------------------------------------------------------
if [ "x$GOPATH" != 'x' ]; then
cd $GOPATH/src/github.com/ipfs/go-ipfs/assets
go-bindata  -pkg=assets init-doc dir-index-html
gofmt -w bindata.go
fi

