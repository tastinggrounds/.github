set -e	

VERSION=v$(cat package.json | jq .version -r)	
EXIT_CODE=0	

git tag ${VERSION} || EXIT_CODE=$?	

if [ $EXIT_CODE -ne 0 ];	
then	
  echo "Skip taging $VERSION because it already exists."	
  exit 0
else	
  git push origin $VERSION	
  echo "Tagged $VERSION"	
fi
echo "export CIRCLE_TAG=$VERSION" >> $BASH_ENV

echo "Creating GitHub Release: $VERSION"

RELEASE_LINE_NUM=$(grep -n "\[$VERSION\]" CHANGELOG.md | cut -d : -f 1)
CHANGELOG_START=$(($RELEASE_LINE_NUM + 1))

mkdir -p /tmp/ghr
sed -n "$CHANGELOG_START,/^$/p" CHANGELOG.md > /tmp/ghr/release-notes.md

LINK=$(gh release create $VERSION --notes-file /tmp/ghr/release-notes.md --title $VERSION)

echo "Created Release: $VERSION"
echo $LINK

rm -rf .ghr
exit 0

