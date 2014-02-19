if [ ! -d $SC_EXTENSIONS_PATH ]
then
    mkdir $SC_EXTENSIONS_PATH
fi

if [ ! -d $SC_HER_EXTENSIONS_PATH ]
then
    mkdir $SC_HER_EXTENSIONS_PATH
fi

SC_HER_LIB_FILES="$SC_HER_LIB_PATH/*"

rm "$SC_HER_EXTENSIONS_PATH/*.sc"

for f in $SC_HER_LIB_FILES
do
    echo "linking $f to $SC_HER_EXTENSIONS_PATH..."
    ln $f $SC_HER_EXTENSIONS_PATH
done

echo "done linking, her extensions directory: "

ls $SC_HER_EXTENSIONS_PATH
