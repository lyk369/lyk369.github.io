import os
import subprocess
import glob
import shutil


def wrap_in_try_catch(command):
    wrapped_command = "try " + command + \
        "disp('Stage Succeeded');" + "quit(0);" + "catch " + \
        "disp('Stage Failed');" + "quit(-1);" + "end"

    return wrapped_command


def execute_task(command, cwd=None, log=False, log_file_path=""):
    if log:
        if os.path.exists(log_file_path):
            logfile = open(log_file_path, 'a')
        else:
            logfile = open(log_file_path, 'w')
        process = subprocess.Popen(
            command, cwd=cwd, stdout=logfile, shell=True)
    else:
        process = subprocess.Popen(
            command, cwd=cwd, stdout=subprocess.PIPE, shell=True)
    out, err = process.communicate()
    if err is None and process.poll() == 0:
        return True
    else:
        return False


def clean_cache(project_abs_path):
    # Clean Cache
    files = glob.glob(project_abs_path + "\\01_SRC\\04_CACHE\\*")
    for f in files:
        if os.path.isdir(f):
            shutil.rmtree(f)
        elif ".gitignore" not in f:
            os.remove(f)
    if os.path.exists(project_abs_path + "\\01_SRC\\03_MDL\\Temp_Paths_SVT.m"):
        os.remove(project_abs_path + "\\01_SRC\\03_MDL\\Temp_Paths_SVT.m")
    files = glob.glob(project_abs_path + "\\06_CODE_GEN\\*")
    list_of_strings = ["01_STUBS", "02_CODE",
                       "03_SHARED_UTILS", "04_REPORT", "05_DLL", "06_A2L"]
    for f in files:
        if not (os.path.isdir(f) and any(substring in f for substring in list_of_strings)):
            if os.path.isdir(f):
                shutil.rmtree(f)
            else:
                os.remove(f)
