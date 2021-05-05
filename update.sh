
INDEX_FILE="README.md"
SIDECAR_FILE="_sidebar.md"

echo -e "# Pyfdtic Documents \n" > $INDEX_FILE
cat $SIDECAR_FILE >> $INDEX_FILE
gsed -i 's/^* /\n## /g' $INDEX_FILE

echo -e '\n## AboutMe\n Email: `MjAxNi5ib2IuYmlAZ21haWwuY29t  (base64 encode)`' >> $INDEX_FILE

gitci
