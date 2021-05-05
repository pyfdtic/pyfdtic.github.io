
INDEX_FILE="README.md"
SIDECAR_FILE="_sidebar.md"

echo -e "# Pyfdtic Documents \n" > $INDEX_FILE
cat $SIDECAR_FILE >> $INDEX_FILE
gsed -i 's/^* /## /g' $INDEX_FILE
gsed -i 's/  * /- /g' $INDEX_FILE

gitci
