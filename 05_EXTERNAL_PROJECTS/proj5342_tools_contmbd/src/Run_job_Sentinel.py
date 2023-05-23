import sys
import os
import subprocess
from distutils.dir_util import copy_tree
from shutil import copy2
import re
import json


JSON_CONFIG_FILE_NAME = 'CI_Config.json'

def executeProcess(command, path):
    process = subprocess.Popen(
        command, stdout=subprocess.PIPE, shell=True, cwd=path)
    out, err = process.communicate()
    if err is None and process.poll() == 0:
        return out
    else:
        return False


def isIntegrationBranch(path):
    result = executeProcess('git rev-parse --abbrev-ref HEAD', path)
    return (result == 'Integration') or (result == 'origin/Integration')


def compareLatestCommitOnFile(filepath, repositoryPath):
    result = False
    currentBranchCommit = executeProcess(
        'git log --pretty=format:"%H" HEAD -1 -- '+filepath, repositoryPath)
    integrationBranchCommit = executeProcess(
        'git log --pretty=format:"%H" origin/Integration -1 --  '+filepath, repositoryPath)
    if (currentBranchCommit is False or integrationBranchCommit is False):
        result = False
    else:
        result = currentBranchCommit == integrationBranchCommit
    return result


def listAllMbdRelatedFiles(folderPath):
    result = []
    for root, dirs, files in os.walk(folderPath):
        for file in files:
            if file.endswith('.slx') or file.endswith('.m') or file.endswith('.mat'):
                result.append(os.path.normpath(os.path.join(root, file)))
    return result


def getChangedMbdComponents(projectRoot, modelsPath, components):
    result = set()
    for component in components:
        files = listAllMbdRelatedFiles(os.path.join(
            os.path.join(projectRoot, modelsPath), component))
        for file in files:
            changed = not compareLatestCommitOnFile(file, projectRoot)
            if changed:
                result.add(component)
                break
    return list(result)


def getNumberOfTestCasesFromLog(regex, file):
    lineMatcher = re.search(regex, file)
    if lineMatcher:
        numbermatcher = re.search('\d+', lineMatcher.group())
        return numbermatcher.group()
    else:
        global noError
        noError = False
        open(project_root+'\\MBD_OUTPUT\\MatlabLog.txt', "w").close()
        return 0


def execute_task(command):
    process = subprocess.Popen(
        command, stdout=subprocess.PIPE, shell=True)
    out, err = process.communicate()
    if err is None and process.poll() == 0:
        return True
    else:
        return False


def execute_sentinel_command(project_root, mil_sil_dir, logFileName='MatlabLog.txt'):
    reference_model_path = "'"+project_root+mil_sil_dir+"'"
    target_model_path = "'"+project_root+mil_sil_dir+"'"
    test_script_path = "'"+project_root+mil_sil_dir+"'"
    out_folder_path = "'"+project_root+mil_sil_dir+"\\Sentinel_MIL_SIL'"
    os.makedirs(name=project_root+mil_sil_dir +
                '\\Sentinel_MIL_SIL', exist_ok=True)
    os.environ['ReferenceModelPath'] = reference_model_path
    os.environ['TargetModelPath'] = target_model_path
    os.environ['TestScriptPath'] = test_script_path
    os.environ['OutFolderPath'] = out_folder_path
    command = "\""+os.environ['MATLAB_PATH']+"\\"+os.environ['MATLAB_VERSION']+"\\bin\\matlab.exe\" -c \""+os.environ['MATLAB_LICENSE']+"\" -wait -r \"disp('Starting the run....');addpath(genpath('"+os.environ['Sentinel_PATH']+"'));addpath ("+str(reference_model_path)+"); OutFolderPath = ("+str(
        out_folder_path)+");ReferenceModelPath = ("+str(reference_model_path)+");TargetModelPath = ("+str(target_model_path)+");TestScriptPath =("+str(test_script_path)+");Sentinel_MIL_SIL(ReferenceModelPath, TargetModelPath, TestScriptPath, OutFolderPath);exit\" -logfile \""+project_root+mil_sil_dir+"\\Sentinel_MIL_SIL"+"\\"+logFileName+"\""
    print(command)
    return execute_task(command)


def execute_sentinel_command_from_Json_config(project_root):

    jsonResults = parse_json_config_file(project_root)

    matlabVersions = jsonResults[0]
    sentinelVersion = jsonResults[1]
    milSilScriptName = jsonResults[2]
    
    logFilePath = project_root + "\\log.txt"

    for matlabVersion in matlabVersions:
        runMatlabCommand(sentinelVersion, matlabVersion, project_root, logFilePath, milSilScriptName)


def runMatlabCommand(sentinelVersion, matlabVersion, project_root, logFilePath, milSilScriptName):
    
    command = "\""+os.environ['MATLAB_PATH']+"\\"+matlabVersion+"\\bin\\matlab.exe\" -c \""+os.environ['MATLAB_LICENSE']+"\" -wait -automation -r \"disp('Starting the run....');addpath(genpath('"+os.environ['Sentinel_ROOT_PATH']+"\\"+sentinelVersion+"'));cd(\""+project_root+"\");startup;"+milSilScriptName+";exit\" -logfile \""+logFilePath+"\""
    
    print(command)
    
    return execute_task(command)


def parse_json_config_file(project_root):
    jsonFile = open(project_root + '\\' + JSON_CONFIG_FILE_NAME)
 
    jsonFileData = json.load(jsonFile)
    
    matlabVersions = jsonFileData['matlab_version']
    sentinelVersion = jsonFileData['sentinel_version']
    milSilScriptPath = jsonFileData['mil_sil_script_name']
    
    jsonFile.close()

    return matlabVersions, sentinelVersion, milSilScriptPath


def generateMultiComponentOutput(projectRoot, mbd_components, componentsDir, sentinelMilSilDir):
    global noError
    MIL_Test_Cases_Total_REGEX = 'Note: MIL Test Script comparison finished with \d+ total test scenario\(s\)'
    MIL_Test_Cases_Passed_REGEX = 'Note: MIL Test Script comparison finished with \d+ succeeded test scenario\(s\)'
    MIL_Test_Cases_Warnings_REGEX = 'Note: MIL Test Script comparison finished with \d+ warning test scenario\(s\)'
    MIL_Test_Cases_Failed_REGEX = 'Note: MIL Test Script comparison finished with \d+ failed test scenario\(s\)'
    MIL_Test_Cases_Not_Executed_REGEX = 'Note: MIL Test Script comparison finished with \d+ not simulated test scenario\(s\)'
    SIL_Test_Cases_Total_REGEX = 'Note: SIL_EC Test Script comparison finished with \d+ total test scenario\(s\)'
    SIL_Test_Cases_Passed_REGEX = 'Note: SIL_EC Test Script comparison finished with \d+ succeeded test scenario\(s\)'
    SIL_Test_Cases_Warnings_REGEX = 'Note: SIL_EC Test Script comparison finished with \d+ warning test scenario\(s\)'
    SIL_Test_Cases_Failed_REGEX = 'Note: SIL_EC Test Script comparison finished with \d+ failed test scenario\(s\)'
    SIL_Test_Cases_Not_Executed_REGEX = 'Note: SIL_EC Test Script comparison finished with \d+ not simulated test scenario\(s\)'
    MIL_Test_Cases_Total = 0
    MIL_Test_Cases_Not_Executed = 0
    MIL_Test_Cases_Passed = 0
    MIL_Test_Cases_Failed = 0
    MIL_Test_Cases_Warnings = 0
    SIL_Test_Cases_Total = 0
    SIL_Test_Cases_Not_Executed = 0
    SIL_Test_Cases_Passed = 0
    SIL_Test_Cases_Failed = 0
    SIL_Test_Cases_Warnings = 0
    os.makedirs(name=projectRoot+'\\MBD_OUTPUT', exist_ok=True)
    for mbd_com in mbd_components:
        execute_sentinel_command(
            projectRoot+componentsDir+mbd_com, sentinelMilSilDir)
        with open(projectRoot+componentsDir+mbd_com+sentinelMilSilDir+'\\Sentinel_MIL_SIL\\MatlabLog.txt', "r") as file:
            logFile = file.read()
        os.makedirs(name=projectRoot+'\\MBD_OUTPUT\\' +
                    mbd_com, exist_ok=True)
        os.makedirs(name=projectRoot+'\\MBD_OUTPUT\\' +
                    mbd_com+'\\Report', exist_ok=True)
        copy_tree(projectRoot+componentsDir+mbd_com +
                  sentinelMilSilDir+'\\Sentinel_MIL_SIL\\Report', projectRoot+'\\MBD_OUTPUT\\'+mbd_com+'\\Report')
        copy2(src=projectRoot+componentsDir+mbd_com + sentinelMilSilDir +
              '\\Sentinel_MIL_SIL\\MatlabLog.txt', dst=projectRoot+'\\MBD_OUTPUT\\'+mbd_com)
        MIL_Test_Cases_Total += int(getNumberOfTestCasesFromLog(
            MIL_Test_Cases_Total_REGEX, logFile))
        MIL_Test_Cases_Not_Executed += int(getNumberOfTestCasesFromLog(
            MIL_Test_Cases_Not_Executed_REGEX, logFile))
        MIL_Test_Cases_Passed += int(getNumberOfTestCasesFromLog(
            MIL_Test_Cases_Passed_REGEX, logFile))
        MIL_Test_Cases_Failed += int(getNumberOfTestCasesFromLog(
            MIL_Test_Cases_Failed_REGEX, logFile))
        MIL_Test_Cases_Warnings += int(getNumberOfTestCasesFromLog(
            MIL_Test_Cases_Warnings_REGEX, logFile))
        SIL_Test_Cases_Total += int(getNumberOfTestCasesFromLog(
            SIL_Test_Cases_Total_REGEX, logFile))
        SIL_Test_Cases_Not_Executed += int(getNumberOfTestCasesFromLog(
            SIL_Test_Cases_Not_Executed_REGEX, logFile))
        SIL_Test_Cases_Passed += int(getNumberOfTestCasesFromLog(
            SIL_Test_Cases_Passed_REGEX, logFile))
        SIL_Test_Cases_Failed += int(getNumberOfTestCasesFromLog(
            SIL_Test_Cases_Failed_REGEX, logFile))
        SIL_Test_Cases_Warnings += int(getNumberOfTestCasesFromLog(
            SIL_Test_Cases_Warnings_REGEX, logFile))

    if noError:
        with open(projectRoot+'\\MBD_OUTPUT\\MatlabLog.txt', 'w+') as outputLog:
            outputLog.write('Note: MIL Test Script comparison finished with ' +
                            str(MIL_Test_Cases_Total)+' total test scenario(s)\n' +
                            'Note: MIL Test Script comparison finished with ' +
                            str(MIL_Test_Cases_Passed)+' succeeded test scenario(s)\n' +
                            'Note: MIL Test Script comparison finished with ' +
                            str(MIL_Test_Cases_Warnings)+' warning test scenario(s)\n' +
                            'Note: MIL Test Script comparison finished with ' +
                            str(MIL_Test_Cases_Failed)+' failed test scenario(s)\n' +
                            'Note: MIL Test Script comparison finished with ' +
                            str(MIL_Test_Cases_Not_Executed)+' not simulated test scenario(s)\n' +
                            'Note: SIL_EC Test Script comparison finished with ' +
                            str(SIL_Test_Cases_Total)+' total test scenario(s)\n' +
                            'Note: SIL_EC Test Script comparison finished with ' +
                            str(SIL_Test_Cases_Passed)+' succeeded test scenario(s)\n' +
                            'Note: SIL_EC Test Script comparison finished with ' +
                            str(SIL_Test_Cases_Warnings)+' warning test scenario(s)\n' +
                            'Note: SIL_EC Test Script comparison finished with ' +
                            str(SIL_Test_Cases_Failed)+' failed test scenario(s)\n' +
                            'Note: SIL_EC Test Script comparison finished with ' +
                            str(SIL_Test_Cases_Not_Executed)+' not simulated test scenario(s)\n')
    else:
        open(project_root+'\\MBD_OUTPUT\\MatlabLog.txt', "w+").close()


if __name__ == "__main__":
    project_root = 'C:\\E\\WS\\3_MBSE\\2_P2_P1_Projects\\Dodeca\\proj4535_dodeca_p2_preprocessing'
    noError = True

    if os.path.isdir(project_root+'\.svn'):
        if os.path.isdir(os.path.join(os.path.join(project_root, '04-Software_Components'), '08-Model')):
            mbd_components = [dir for dir in os.listdir(
                os.path.join(os.path.join(project_root, '04-Software_Components'), '08-Model')) if dir.startswith('mbd_')]
            generateMultiComponentOutput(
                project_root, mbd_components, '\\04-Software_Components\\08-Model\\', '\\05-UTD\\03-MIL_SIL')
        elif os.path.isdir(os.path.join(project_root, '05-UTD')):
            execute_sentinel_command(project_root, '\\05-UTD\\03-MIL_SIL')
    elif os.path.isdir(project_root+'\.git'):
        print("GitFoldeer")
        if os.path.isfile(project_root + '\\' + JSON_CONFIG_FILE_NAME):
            execute_sentinel_command_from_Json_config(project_root)
        elif os.path.isdir(os.path.join(project_root, '04-Model')):
            mbd_components = [dir for dir in os.listdir(
                str(os.path.join(project_root, '04-Model'))) if dir.startswith('mbd_')]
            if (not isIntegrationBranch(project_root)):
                mbd_components = getChangedMbdComponents(
                    projectRoot=project_root, modelsPath='04-Model', components=mbd_components)
            generateMultiComponentOutput(
                project_root, mbd_components, '\\04-Model\\', '\\04-Unit_Test\\02-MIL_SIL')
        elif os.path.isdir(os.path.join(project_root, '03-Model')):
            execute_sentinel_command(project_root, '\\04-Unit_Test\\02-MIL_SIL')
