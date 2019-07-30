###UPDATE STRING IN APPWORX .EXP FILE for Process flows/chains.###
###Created: 9/18/2017###
###Last updated: 7/11/2019###

import fileinput
import csv

#Information to user about this program
print('This program renames chains/process flows for .exp files\n')
print('It is a good idea to check .exp for errors with editor before importing.\n')
print('Place .exp file and lists .csv in same directory as this script.\n')

#File to edit
input_file = input('File to edit (.exp): ')

#provide strings for seach and relplace in lists.csv file
#Convert .csv file into lists.
with open('lists.csv') as inputData:
    data = csv.reader(inputData)
    string1 = [row[0] for row in data]
    inputData.seek(0)
    string2 = [row[1] for row in data]

def replace(file, a, b):
    #replace strings in loop
    with fileinput.FileInput(file, inplace=True) as file:
        for line in file:
            print(line.replace(a, b), end='')
            
def string_change(string):
    #Create lists for ^ place holder for search and replace
    count = (len(string))
    fstr_pos = 1
    frst_char = 1
    list_name = []
    #Add ^ to string  
    for z in string:
        while count >= 1:
            str1 = string[0:frst_char]
            str2 = string[fstr_pos:]
            list_name.append(str1 + '^' + str2)
            fstr_pos += 1
            frst_char +=1
            count -= 1
    return list_name

#Run string_change function for replace proccess.

'''Remove new line'''
replace(input_file,'\n', '``')

#Strait name change        
for j, f in zip(string1,string2):
    replace(input_file, j, f)

#Change with special character ^
for x, k in zip(string1,string2):
    search_str = string_change(x)
    replace_str = string_change(k)

    #Perform search and replace for chains.
    
    srch_st1 = ('\``DELETE=', '\``START=', '\``so_predecessors=')    

    '''Run list search string srch_str'''
    for x in srch_st1:
        '''Remove string relace ^'''
        replace(input_file, x, '^' )
        '''Rename ^'''
        count = len(search_str)
        count -= 1 #shorten list number
        while count != -1:
            replace(input_file, search_str[count], replace_str[count])
            count -= 1
                            
        '''Add srch_st1 back'''
        replace(input_file, '^', x )                                
'''Add new line'''
replace(input_file, '``', '\n')

'''Inactivate schedules'''
replace(input_file, 'aw_active=Y', 'aw_active=N')

print('Schedules inactive')
print('Complete')

