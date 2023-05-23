import os
import shutil
import glob
from datetime import datetime
from utils import clean_cache, wrap_in_try_catch, execute_task


def compile_model(matlab_path, log_file_path, project_abs_path, model_name):
    clean_cache(project_abs_path)

    start_command = "{} -automation -logfile {} -wait -sd {} -r " \
        "\"disp('Stage 1 - Compiling the Model:');" \
        "startup;".format(matlab_path, log_file_path, project_abs_path)

    command = "Simulink.data.dictionary.closeAll('-discard');"\
        "{}([],[],[],'compile');"\
        "{}([],[],[],'term');".format(model_name, model_name)

    end_command = "\""

    wrapped_command = wrap_in_try_catch(command)

    full_command = start_command + wrapped_command + end_command

    # print(full_command)
    result = execute_task(command=full_command, log=True,
                          log_file_path=log_file_path)
    return result


def run_model_advisor(matlab_path, log_file_path, project_abs_path, model_name, default_config_path):
    clean_cache(project_abs_path)

    report_out_path = project_abs_path + "\\02_TEST\\01_STATIC\\01_VMAAC"

    if os.path.exists(report_out_path):
        start_command = "{} -automation -logfile {} -wait -sd {} -r " \
            "\"disp('Stage 2 - Run Model Advisor:');" \
            "startup;".format(matlab_path, log_file_path, project_abs_path)

        command = "Simulink.data.dictionary.closeAll('-discard');"\
            "app = Advisor.Manager.createApplication('UseTempDir', true);"\
            "setAnalysisRoot(app, 'Root', '{}');"\
            "loadConfiguration(app, '{}');"\
            "run(app);"\
            "getResults(app);"\
            "report = generateReport(app, 'Location', '{}');".format(
                model_name, default_config_path, report_out_path)

        end_command = "\""

        wrapped_command = wrap_in_try_catch(command)

        full_command = start_command + wrapped_command + end_command

        # print(full_command)
        result = execute_task(command=full_command,
                              log=True, log_file_path=log_file_path)
    else:
        result = False

    return result


def run_mil_sil(matlab_path, log_file_path, project_abs_path, model_name, sentinel_path):
    clean_cache(project_abs_path)

    # Clean old Sentinel API Files
    files = glob.glob(sentinel_path + "\\Sentinel_APIs\\*")
    for f in files:
        os.remove(f)

    # Check MIL Sentinel projects if exists
    mil_unit_dir = project_abs_path + "\\02_TEST\\03_UNIT_TESTS\\02_MIL\\**\\*.Sprj"
    sentinel_project_mil_unit_files = glob.glob(mil_unit_dir, recursive=True)

    mil_integration_dir = project_abs_path + \
        "\\02_TEST\\03_INTEGRATION_TESTS\\02_MIL\\**\\*.Sprj"
    sentinel_project_mil_integration_files = glob.glob(
        mil_integration_dir, recursive=True)

    # Check SIL Sentinel projects if exists
    sil_unit_dir = project_abs_path + "\\02_TEST\\03_UNIT_TESTS\\03_SIL\\**\\*.Sprj"
    sentinel_project_sil_unit_files = glob.glob(sil_unit_dir, recursive=True)

    sil_integration_dir = project_abs_path + \
        "\\02_TEST\\03_INTEGRATION_TESTS\\03_SIL\\**\\*.Sprj"
    sentinel_project_sil_integration_files = glob.glob(
        sil_integration_dir, recursive=True)

    sentinel_projects = sentinel_project_mil_unit_files + sentinel_project_mil_integration_files + \
        sentinel_project_sil_unit_files + sentinel_project_sil_integration_files

    first_sentinel_project = True

    for x in sentinel_projects:
        sentinel_project_name = os.path.basename(x).split('.')[0]

        if first_sentinel_project:
            start_command = "{} -automation -logfile {} -wait -sd {} -r " \
                "\"disp('Stage 3 - Running MIL/SIL Tests:');" \
                "startup;".format(matlab_path, log_file_path, project_abs_path)

            first_sentinel_project = False
        else:
            start_command = "{} -automation -logfile {} -wait -sd {} -r " \
                "\"disp('Stage 3 - Continue Running MIL/SIL Tests:');" \
                "startup;".format(matlab_path, log_file_path, project_abs_path)

        command = "Simulink.data.dictionary.closeAll('-discard');" \
            "addpath(genpath('{}'));" \
            "Sentinel.GenerateSentinelAPIFile('{}');" \
            "run('{}\\Sentinel_APIs\\{}.m');".format(
                sentinel_path, x, sentinel_path, sentinel_project_name)

        end_command = "\""

        wrapped_command = wrap_in_try_catch(command)

        full_command = start_command + wrapped_command + end_command

        # print(full_command)
        result = execute_task(command=full_command, log=True,
                              log_file_path=log_file_path)

    return result


def generate_code(matlab_path, log_file_path, project_abs_path, model_name):
    clean_cache(project_abs_path)

    start_command = "{} -automation -logfile {} -wait -sd {} -r " \
        "\"disp('Stage 5 - Generating Code from the Model:');" \
        "startup;".format(matlab_path, log_file_path, project_abs_path)

    command = "Simulink.data.dictionary.closeAll('-discard');"\
        "slbuild('{}', 'StandaloneRTWTarget');".format(model_name)

    end_command = "\""

    wrapped_command = wrap_in_try_catch(command)

    full_command = start_command + wrapped_command + end_command

    # print(full_command)
    result = execute_task(command=full_command, log=True,
                          log_file_path=log_file_path)
    return result


def build_code(log_file_path, project_abs_path, model_name):
    code_gen_folder = project_abs_path + "\\06_CODE_GEN\\"

    main_build_dir = code_gen_folder + model_name + "_ert_rtw"
    sub_components_dir = code_gen_folder + "slprj\\ert\\"

    klcowork_build_spec_file = code_gen_folder + "kwinject.out"

    result = False

    if os.path.exists(main_build_dir):
        clean_cmd = main_build_dir + "\\" + model_name + ".bat clean"
        result = execute_task(clean_cmd, cwd=main_build_dir,
                              log=True, log_file_path=log_file_path)
    else:
        return False

    if os.path.exists(sub_components_dir):
        for x in os.listdir(sub_components_dir):
            for y in os.listdir(sub_components_dir + x):
                if ".bat" in y:
                    current_dir = sub_components_dir + x
                    clean_cmd = current_dir + "\\" + y + " clean"
                    result = execute_task(
                        clean_cmd, cwd=current_dir, log=True, log_file_path=log_file_path)
                    if result:
                        build_cmd = "kwinject --update --output {} cmd /c ".format(
                            klcowork_build_spec_file) + current_dir + "\\" + y + " all"
                        result = execute_task(
                            build_cmd, cwd=current_dir, log=True, log_file_path=log_file_path)

                        if result:
                            for z in os.listdir(current_dir):
                                if ".obj" in z or ".lib" in z:
                                    shutil.copy(
                                        current_dir + "\\" + z, main_build_dir)
                        else:
                            return False
                    else:
                        return False

    build_cmd = "kwinject --update --output {} cmd /c ".format(
        klcowork_build_spec_file) + main_build_dir + "\\" + model_name + ".bat all"
    result = execute_task(build_cmd, cwd=main_build_dir,
                          log=True, log_file_path=log_file_path)

    return result


def run_klocwork():
    pass


def prepare_delivery_package(matlab_path, log_file_path, project_abs_path, model_name):
    package_prep_time = datetime.now().strftime("%d-%m-%Y-%H-%M-%S")
    start_command = "{} -automation -logfile {} -wait -sd {} -r " \
        "\"disp('Stage 8 - Prepare Delivery Package:');" \
        "startup;".format(matlab_path, log_file_path, project_abs_path)

    command = "Simulink.data.dictionary.closeAll('-discard');" \
        "PostBuildScript;" \
        "packageName = '{}_{}';" \
        "PrepareDeliveryPackage;".format(model_name, package_prep_time)

    end_command = "\""

    wrapped_command = wrap_in_try_catch(command)

    full_command = start_command + wrapped_command + end_command

    # print(full_command)
    result = execute_task(command=full_command, log=True,
                          log_file_path=log_file_path)
    return result
