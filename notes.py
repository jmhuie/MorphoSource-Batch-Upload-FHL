# -*- coding: utf-8 -*-
"""
These are the functions to support Notes metadata extraction
They are written to allow use in the morphosource batch code.
"""
from __future__ import division
from builtins import range
from past.utils import old_div
import os, re, csv
import pandas as pd
	
def pull_nts_files(INPUT_PATH):
    # check to make sure paths exist, that files are there.
    if os.path.isdir(INPUT_PATH): #check to make sure the folder exists
    	print('Path to Notes metadata files found.')
    	FileNames = [] #make a list of the pca files in the folder
    	for root, dirs, files in os.walk(INPUT_PATH):
    		for file in files:
    			if file.endswith(".txt"):
    				FileNames.append(os.path.join(root, file))
    	print('Notes files found in this directory:')
    	for file in FileNames: #list those files so the user can check to see if these are the files they're looking for
    		print(file)
    else:
    	print('Path to Notes metadata files not found.')
    return(FileNames)
	
def read_txt(Text2,Filename): #a string object split into list of lines.
    for Line in range(len(Text2)): #search through lines for relevant values
        SearchSymbol = re.search('^Symbol: (.*)$',Text2[Line])
        if SearchSymbol:
            CutoutSymbol = SearchSymbol.group(1)
            if CutoutSymbol: 
                cutoutnote = f"Specimen Scan Symbol is {CutoutSymbol}"
            else:
                cutoutnote = None
        SearchOvertNum = re.search('^oVert: (.*)$', Text2[Line])
        if SearchOvertNum:
            OvertNum = SearchOvertNum.group(1)
            if OvertNum:
                overtnumbernote = f"oVert number is {OvertNum}"
            else:
                overtnumbernote = None
    if overtnumbernote is not None and cutoutnote is not None:
        NoteText = f"{overtnumbernote}; {cutoutnote}"
    if overtnumbernote is None and cutoutnote is not None:
        NoteText = f"{cutoutnote}"
    if overtnumbernote is not None and cutoutnote is None:
        NoteText = f"{overtnumbernote}"
    if overtnumbernote is None and cutoutnote is None:
        NoteText = None	
    FileID = re.search('([^\\\/]*)\.txt',Filename).group(1) # pull out file name
    RowEntry = [FileID, OvertNum, CutoutSymbol, NoteText]
    return(RowEntry)
def nts_table(FileNames):
    # write the header for values
    ColumnNames = ['file_name','oVert_number','scan_symbol_cutout','note_text']
    #set up holder list for information
    Results = [[]]*(len(FileNames)+1)
    Results[0] = ColumnNames
    i = 1
    # extract relevant information from each file
    for filename in FileNames:
        InFile = open(filename,'r') #open file
        Text1 = InFile.read()
        InFile.close() #close file, leaving behind the text object
        Text2 = str.splitlines(Text1) #split text object into lines
        Line2 = None
        if filename.endswith(".txt"): 
            RowEntry = read_txt(Text2,filename)
        Results[i] = RowEntry
        i = i+1
    return(Results)
    
def ntsmeta_from_raw_files(InputPath,IndexColumn):
    NTSfiles = pull_nts_files(InputPath)
    Results = nts_table(NTSfiles)
    NTSdf = pd.DataFrame(Results[1:], columns = Results[0])
    NTSdf.index = NTSdf[IndexColumn]
    return(NTSdf)

def fill_notes(Worksheet, NTS_metadata_dataframe):
    Worksheet.iloc[3:,50] = NTS_metadata_dataframe['note_text'].values
    return Worksheet
