date=$(date +"%Y.%m.%d")
assetsFolder="source/assets/$date"

if ! [ -d $assetsFolder ]; then
    mkdir $assetsFolder
fi
echo $1
hexo new post $1


