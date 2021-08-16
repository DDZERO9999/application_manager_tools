###UPDATE STRING IN APPWORX .EXP FILE for Process flows/chains.###
###DAVE DESALVO Created: 8/23/2017###
###Last updated: 7/9/2019 Added functions###
###Last update: 12/11/2019 Created two new functions to speed up process###
###Last update: 12/18/2019 Use class inplace of function###
###Last update: 03/8/2021 Set up tkinter GUI###
###Last update: 04/9/2021 Added CSV options###


import csv
import tkinter as tk
from tkinter import filedialog
from tkinter.messagebox import showinfo
from datetime import datetime

def create_list(string):
    #Create lists for ^ place holder for search and replace
    count = (len(string))
    fstr_pos = 1
    frst_char = 1
    the_list = []
    #Add ^ to string  
    while count >= 1:
        str1 = string[0:frst_char]
        str2 = string[fstr_pos:]
        the_list.append(f'{str1}^{str2}')
        fstr_pos += 1
        frst_char +=1
        count -= 1
    print(the_list)
    return the_list

class Replace:
    def __init__(self, file, search, replace):
        self.file = file
        self.search = search
        self.replace = replace
    '''REPLACE SINGLE STRING '''
    def repsingle(self):
        global FILE
        FILE = self.file.replace(self.search, self.replace)
        return FILE

    #REPLACE STRINGS FROM A LIST
    def rep(self):
        #set variables
        global FILE
        count = len(self.search)
        X = 0   
        #change character
        FILE = self.file
        while X < count:
            try:
                FILE = FILE.replace(self.search[X], self.replace[X])
            except IndexError:
                FILE = FILE.replace(self.search[X], '')
            X += 1 
        return FILE

def activate_schedule(FILE):
    if choice == 'Y':
        repactive = Replace(FILE, 'aw_active=N', 'aw_active=Y')
        repactive.repsingle()
    elif choice == 'N':
        repactive = Replace(FILE, 'aw_active=Y', 'aw_active=N')
        repactive.repsingle()
    else:
        print('Nothing to do')

def backup_file(exp_file):
    now = datetime.now()
    timestamp = now.strftime("%H%M%S")
    with open(exp_file,"r") as FR:
        FILEBK = FR.read()
        with open(f'{exp_file}.{timestamp}.bak',"w") as F:
            F.write(FILEBK)
           
def update_file(string_search, string_replace):
    string_search = string_search.upper()
    string_replace = string_replace.upper()

    #Run create_list function for replace proccess. 
    search_list = create_list(string_search)
    replace_list = create_list(string_replace)

    #Convert .csv file into lists.
    if csv_file is not None:
        with open(csv_file) as inputData:
            data = csv.reader(inputData)
            list_search_csv = [row[0] for row in data]
            inputData.seek(0)
            list_replace_csv = [row[1] for row in data]

    global FILE

    #Open exp_file
    with open(exp_file,"r") as FR:
        FILE = FR.read()
        
        #Rename string without changes
        strings = Replace(FILE,string_search,string_replace)
        strings.repsingle()
        #CSV
        if csv_file is not None:
            for j, f in zip(list_search_csv,list_replace_csv):
                strings = Replace(FILE, j, f)
                strings.repsingle()
                
        #Remove new line
        delnewline = Replace(FILE,'\n', '~~')
        delnewline.repsingle()

        #Perform search and replace for chains.
        remove_strings = ('\\~~DELETE=', '\\~~START=', '\\~~so_predecessors=', '\\~~so_pred_ref_names=')

        #Run list search string srch_str
        for x in remove_strings:
            #Remove string replace ^
            repwithcarot = Replace(FILE, x, '^')
            repwithcarot.repsingle()
            #Rename ^ strings
            repsearchstring = Replace(FILE,search_list,replace_list)
            repsearchstring.rep()
            #Rename ^ CSV
            if csv_file is not None:
                for a, b in zip(list_search_csv,list_replace_csv):
                    search_csv = create_list(a)
                    replace_csv = create_list(b)
                    repsearchstring = Replace(FILE,search_csv,replace_csv)
                    repsearchstring.rep()            
            #Add srch_st1 back
            removecarot = Replace(FILE,'^',x)
            removecarot.repsingle()

        #Add new line
        addnewline = Replace(FILE,'~~', '\n')
        addnewline.repsingle()

        if choice is not None:
            activate_schedule(FILE)

    #Write to the file     
    with open(exp_file,"w") as F:
        F.write(FILE)
    
    global complete
    complete = 'Change Complete'

#GUI FUNCTIONS

def browse_button():
    global exp_file
    filetypes = [('Export Files', '*.exp')]
    folder_path = r'C:\Users\aico0r\OneDrive - Arrow Electronics, Inc'
    exp_file = filedialog.askopenfilename(title = 'Open export file', initialdir = folder_path, filetypes = filetypes)
    showinfo(message = exp_file)

def browse_button_2():
    global csv_file
    filetypes = [('CSV Files', '*.csv')]
    folder_path = r'C:\Users\aico0r\OneDrive - Arrow Electronics, Inc'
    csv_file = filedialog.askopenfilename(title = 'Open CSV file', initialdir = folder_path, filetypes = filetypes)
    showinfo(message = csv_file)

def clear_button_3():
    global csv_file
    csv_file = None
    showinfo(message = 'Cleared CSV File')

def set_choice_var():
    global choice
    choice = var.get()
    
def submit():
    backup_file(exp_file)
    string_search_02 = string_search_01.get()
    string_replace_02 = string_replace_01.get()
    update_file(string_search_02, string_replace_02)
    showinfo(message = complete)

#set variables
    
choice = None
csv_file = None

#Define window
wind = tk.Tk()
wind.geometry("450x250")
wind.title('APPWORX RENAME')

BANNER = tk.Label(wind, fg="red", font='Helvetica 10 bold', text=
"This program renames chains/process flows for .exp files\n\
It is a good idea to check .exp for errors with editor before importing.\n")

BANNER.grid(row=0, column=0)

#Export file select

button1 = tk.Button(text="SELECET .exp File", command=browse_button)
button1.grid(row=4, column=0, sticky=tk.W)

#CSV file select
button2 = tk.Button(text="SELECET .csv File", command=browse_button_2)
button2.grid(row=5, column=0, sticky=tk.W)

#CSV file clear
clear_csv_button = tk.Button(text="Clear CSV", command = clear_button_3 )
clear_csv_button.grid(row=5, column=0, sticky=tk.W, padx=100, ipadx=10)


#string entries
tk.Label(wind, text="Old String").grid(row=9, column=0, sticky=tk.W)
tk.Label(wind, text="New String").grid(row=12, column=0, sticky=tk.W)

string_search_01 = tk.Entry()
string_replace_01 = tk.Entry()

string_search_01.grid(row=9, column=0, sticky=tk.W, padx=65, ipadx=40)
string_replace_01.grid(row=12, column=0, sticky=tk.W, padx=65, ipadx=40)

#radiobutton
var = tk.StringVar()
Y_radio = tk.Radiobutton(wind, text="Turn off schedules", variable = var, value='N', command = set_choice_var)
Y_radio.grid(row=14, column=0, sticky=tk.W)
N_radio = tk.Radiobutton(wind, text="Turn on schedules", variable = var, value='Y', command = set_choice_var)
N_radio.grid(row=15, column=0, sticky=tk.W)

#submit button
SubmitButton = tk.Button(text="Submit", command = submit)
SubmitButton.grid(row=17, column=0, sticky=tk.W)

wind.mainloop()



