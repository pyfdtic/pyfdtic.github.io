
INDEX_FILE="README.md"
SIDECAR_FILE=""

echo "# Pyfdtic Documents" > $INDEX_FILE
cat _sidebar.md >> $INDEX_FILE

gitci