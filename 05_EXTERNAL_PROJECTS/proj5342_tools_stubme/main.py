import tkinter
from tkinter import filedialog
import pandas as pd
import logging

def choose_file():
    # initiate tinker and hide window
    main_win = tkinter.Tk()
    main_win.withdraw()

    main_win.overrideredirect(True)
    main_win.geometry('0x0+0+0')

    main_win.deiconify()
    main_win.lift()
    main_win.focus_force()

    # open file selector
    main_win.sourceFile = filedialog.askopenfilename(parent=main_win, initialdir="/",
                                                     title='Please the SMI file')

    # close window after selection
    main_win.destroy()
    return main_win.sourceFile



# ----------------------------------------------------

# ----------------------------------------------------
def extract_data(df,index):
    data_typesign = ""
    data_typelen = ""
    name=str(df['Name'].iloc[index])
    #value = df['Physical Value'].iloc[index]
    Dimen = str(df['Dimensions'].iloc[index])
    Descrip = str(df['Description'].iloc[index])
    stor_class = str(df['Storage Class'].iloc[index])
    header_file = str(df['Header File'].iloc[index])
    val_temp = 0
    try:
        value = df['Value'].iloc[index]
        val_temp =1
    except:
        pass


    data_typ = str(df['Data type'].iloc[index])
    if "fixdt" in str(data_typ):
        if data_typ[6] == "0":
            data_typesign = "u"
        if data_typ[8] == "8":
            data_typelen = "8_T"
        elif data_typ[8] == "1":
            data_typelen = "16_T"
        elif data_typ[8] == "3":
            data_typelen = "32_T"
        elif data_typ[8] == "6":
            data_typelen = "64_T"
        data_typ = data_typesign + "int" + data_typelen
    else:
        data_typ=data_typ+"_T"

    if val_temp == 0:
        #               0    , 1   ,  2      , 3     ,    4        ,  5
        extracted_data = [name, Dimen, data_typ, Descrip, stor_class, header_file]
    elif val_temp == 1 :
        #               0    , 1   ,  2      , 3     ,    4        ,  5            ,  6
        extracted_data = [name, Dimen, data_typ, Descrip, stor_class, header_file , value]





    return extracted_data
# ----------------------------------------------------
def write_header(file_name,data):
    f = open(file_name, "a+")
    f.write("\n/* ----------------------------------- */\n")
    f.write("\n\t/*"+ sheet_list[i]+"*/\n")
    f.close()


# ----------------------------------------------------
def value_len(val):
    val = list(val.split(" "))
    return len(val)

# ----------------------------------------------------

def dimension_datatype(dimen):
    dimen=int(dimen)
    if dimen < 256:
        argument = "unit8_T"
    elif dimen >= 256 and dimen < 65536:
        argument = "unit16_T"
    elif dimen >= 65536:
        argument = "unit32_T"
    else:
        argument = "void"

    return argument

# ----------------------------------------------------
def dimension_arg(dimen,tab , name):
    argument1 = "void"
    argument2 = "void"
    arguments_num = 1

    try:
        dimension = dimen[1:]
        dimension = dimension[:-1]
        dimension1 = int(dimension.rpartition(' ')[0])
        dimension2 = int(dimension.rpartition(' ')[2])

        if tab == "Inputs":
            if dimension1 == 1 and dimension2 == 1:
                arguments_num = 1
                argument1 = "void"
                argument2 = "void"
            else:
                temp_arg = max(dimension1, dimension2)
                arguments_num = 1
                argument1 = dimension_datatype(temp_arg)

        elif tab == "Outputs":
            if dimension1 == 1 and dimension2 == 1:
                arguments_num = 1
                argument1 = "void"
                argument2 = "void"
            else:
                arguments_num = 2
                argument1 = dimension_datatype(dimension1)
                argument2 = dimension_datatype(dimension2)

        # elif tab == "PublicData":
    except Exception as e:
        print("issue in dimension extraction in tab :", tab , e," in parameter ",name)

    arg = [arguments_num , argument1 , argument2 ]

    return arg

# ----------------------------------------------------

def write_H(file_name , df_data,tab):
    arg = list()

#extracted_data=[name,Dimen,data_typ,Descrip,stor_class,header_file]
#               [ 0    , 1   ,  2      , 3     ,    4        ,  5  ]
    try:
        name = df_data[0]
        Dimen = df_data[1]
        data_typ = df_data[2]
        Descrip = str(df_data[3])
        stor_class = str(df_data[4])
        header_file = str(df_data[5])
        try:
            value = df_data[6]
        except:
            pass

        arg = dimension_arg(Dimen, tab,name)

        if tab == "Inputs":
            if arg[0] == 1 and arg[1] == "void":
                f = open(header_file, "a+")
                f.write("\n/* " + Descrip + "*/")
                f.write("\nextern " + data_typ + " get_" + name + "(" + arg[1] + ")" + ";")
                f.close()
            elif arg[1] != "void":
                f = open(header_file, "a+")
                f.write("\n/* " + Descrip + "*/")
                f.write("\nextern " + data_typ + " get_" + name + "(" + arg[1] + " index)" + ";")
                f.close()


        elif tab == "Outputs":
            if arg[0] == 1:
                f = open(header_file, "a+")
                f.write("\n/* " + Descrip + "*/")
                f.write("\nextern void " + " set_" + name + "(" + data_typ + " value)" + ";")
                f.close()

            elif arg[0] != 1:
                f = open(header_file, "a+")
                f.write("\n/* " + Descrip + "*/")
                f.write("\nextern void " + "set_" + name + "(" + arg[1] + " index ," + arg[2] + " value )" + ";")
                f.close()


        elif tab == "PublicData":
            value = str(value)
            data_typesign = ""
            data_typelen = ""
            if stor_class == "Define" or stor_class == "ImportedDefine":
                f = open(header_file, "a+")

                f.write("\n/* " + Descrip + "*/")

                f.write("\n#define " + name + "\t\t" + value)
                f.close()
    except Exception as e:
        print("issue for header in tab :",tab," : ", e)


# ----------------------------------------------------

def write_C(file_name , df_data, tab):
    arg = list()

    # extracted_data=[name,Dimen,data_typ,Descrip,stor_class,header_file]
    #               [ 0    , 1   ,  2      , 3     ,    4        ,  5  ]
    try:
        name = str(df_data[0])
        Dimen = str(df_data[1])
        data_typ = str(df_data[2])
        Descrip = str(str(df_data[3]))
        stor_class = str(df_data[4])
        header_file = str(df_data[5])
        arg = dimension_arg(Dimen, tab , name)
        data_typesign = ""
        data_typelen = ""

        if tab == "Inputs":
            if arg[0] == 1 and arg[1] == "void":
                f = open(file_name, "a+")
                f.write("\n/* " + Descrip + "*/")
                f.write("\n" + data_typ + " get_" + name + "(" + arg[1] + ")" + "{return 0 ; } ")
                f.close()
            elif arg[1] != "void":
                f = open(file_name, "a+")
                f.write("\n/* " + Descrip + "*/")
                f.write("\n" + data_typ + " get_" + name + "(" + arg[1] + " index)" + "{return 0 ; }")
                f.close()


        elif tab == "Outputs":
            if arg[0] == 1:
                f = open(file_name, "a+")
                f.write("\n/* " + Descrip + "*/")
                f.write("\nvoid " + " set_" + name + "(" + data_typ + " value)" + "{ }")
                f.close()
            elif arg[0] != 1:
                f = open(file_name, "a+")
                f.write("\n/* " + Descrip + "*/")
                f.write("\nvoid " + "set_" + name + "(" + arg[1] + " index ," + arg[2] + " value )" + "{ }")
                f.close()


        elif tab == "PublicData":
            if stor_class == "ImportedExternPointer":
                if "fixdt" in data_typ:
                    if data_typ[6] == "0":
                        data_typesign = "u"
                    if data_typ[8] == "8":
                        data_typelen = "8_T"
                    elif data_typ[8] == "1":
                        data_typelen = "16_T"
                    elif data_typ[8] == "3":
                        data_typelen = "32_T"
                    elif data_typ[8] == "6":
                        data_typelen = "64_T"
                    data_type = data_typesign + "int" + data_typelen
                    f = open(file_name, "a+")
                    f.write("\n/* " + file_name + "*/")
                    f.write("\n" + data_type + " *" + name + ";")
                else:
                    f = open(file_name, "a+")
                    f.write("\n/* " + Descrip + "*/")
                    f.write("\n" + data_typ + " *" + name + ";")
                    f.close()
    except Exception as e:
        print("issue for definition in tab :",tab," : ", e)


# ----------------------------------------------------

#-------- main function-----------------------------
file_path=choose_file()
workbook = pd.ExcelFile(file_path)
sheet_list = workbook.sheet_names

daf = pd.read_excel(workbook, sheet_list[1])
h_file = daf['Header File'].iloc[1]
c_file = h_file.replace(h_file[-1], "c")


f = open(h_file, "w+")
h_=h_file.replace(".h", "_h__")
h_="__"+h_
f.write("#ifndef "+h_+"\n")
f.write("#define "+h_+"\n")
f.close()


f = open(c_file, "w+")
f.write("#include "+'"'+h_file+'"'+"\n")
f.close()

i = 1
name=""
value=""
value_l=1
data_type=""


while i < len(sheet_list):
    df1 = pd.read_excel(workbook, sheet_list[i])
    #----------------------
    write_header(h_file,sheet_list[i])
    write_header(c_file,sheet_list[i])

    #loop for tabs

    j=0
    if sheet_list[i] == "Inputs" or sheet_list[i] == "Outputs" or sheet_list[i] == "PublicData":
        while j<len(df1):
            index=j
            df_data=extract_data(df1,index)
            write_H(h_file , df_data,sheet_list[i])
            write_C(c_file , df_data,sheet_list[i])
            j=j+1 #loop for tabs

    i=i+1 #main_loop



# ----------------------------------------------------


print("Converting done!")
input("press any key to continue...")
