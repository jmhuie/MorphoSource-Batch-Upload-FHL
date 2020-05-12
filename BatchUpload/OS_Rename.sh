#!/bin/bash
set -e
set -u
set -o pipefail
echo "Working" #make sure the script is working
if test -f filenames.txt # test for this file and delete if exists
then
    rm filenames.txt
fi
cd ./zips/
find . -name "* *" -exec bash -c 'mv "$0" "${0// /_}"' {} \;;
cd ..
ls ./zips/ > filenames.txt #makes list of all files in zips folder
cat filenames.txt #reads out list
echo "Enter filenames.txt" #asks you to writes these words
read file #reads from filenames.txt document
while IFS= read -r line #reads through document line by line and does the following for each line one at a time
do
    if test "!" -d ./unzips #tests if directory exists, makes it if it doesn't
    then
        mkdir ./unzips
    else
        echo "unzips exists"
    fi
    if test "!" -d ./ToUpload #tests if directory exists, makes it if it doesn't
    then
	mkdir ./ToUpload
    else
	echo "ToUpload exists"
    fi
    echo $line #tells you which file it's workig on
    unzip -q ./zips/$line -d ./unzips/ #unzips VNHM download into Unzips folder
    if test -f ./unzips/*.txt # looks for Info file from VNHM
    then 
        dos2unix ./unzips/Info.txt
        Sorce=$(awk '/^Sorce: / {print $2}' ./unzips/*.txt) #looks in Info file for Museum and CatNum
        CatNum=$(awk '/^SorceID: / {print $2}' ./unzips/*.txt)
		#Sorce=$(sed '3q;d' ./unzips/*.txt)
		#Sorce=${Sorce#*=}
		#CatNum=$(sed '4q;d' ./unzips/*.txt)
		#CatNum=${CatNum#*=}
        Source=${Sorce%$'\r'} #strips carriage returns so values can be set as variables
        Number=${CatNum%$'\r'}	
		#printf -v Number "%06d" $Number #pads number with 00s
        echo $Source #prints out museum and cat num
        echo $Number
    else
        echo "Info.txt not found" #tells you if no Info file
    fi
    if [[ $Source == "OS" ]] #tests you're working with stuff from the correct museum
    then
        Museum="Os" #sets museum with correct cases for next script
        Collection="F" #sets to F for fish
        echo $Museum #reads them out
        echo $Collection
    else
        echo "Not OS" # tells you if wrong museum
    fi
    name="${Museum}_${Collection}_${Number}_head" #takes all variables to set name
    if test -f ./ToUpload/$name.log
    then
        output=$(ls ./ToUpload/$name*.log | wc -l)
        output=$( sed -n '$p' <<< "$output" )
        if (( $output >= 1 ))
        then
            var=$(($output + 1)) # adds one to the count
            name="${Museum}_${Collection}_${Number}_body${var}"
            echo $name
        fi
    fi
    echo $name
    mv ./unzips/*.log ./ToUpload/"${name}.log" #moves the log file from unzips to ToUpload and renames it with name variable
    mv ./unzips/*.txt ./ToUpload/"${name}.txt"    
	unzip -q ./unzips/*.zip -d ./unzips/"${name}" #unzips the Stack of images into a folder with the proper name
	cd ./unzips/"${name}"
    filetype="jpg"
	echo "PLEASE DO NOT CLOSE!!! PROGRAM IS RUNNING!!!"
    num=1
    for i in *.*; do mv "$i" "${name}_$(printf '%04d' $num).${filetype}"; ((num++)); done #renames each file
	zip -q -r ./"${name}.zip" . -i *
    cd ../.. 
    mv ./unzips/"${name}"/"${name}.zip" ToUpload/
    rm -r unzips/ #removes unzip folder
    rm ./zips/$line #removes the VNHM download from the zip folder for the file 
done < $file
ls ToUpload/ #lists what is in ToUpload Folder
