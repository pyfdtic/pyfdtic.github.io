
INDEX_FILE="README.md"
SIDECAR_FILE=""

echo -e "# Pyfdtic Documents \n" > $INDEX_FILE
cat _sidebar.md >> $INDEX_FILE

gitci
