from datetime import datetime
import os
import json
import scripts_r2017b
import scripts_r2020b
from parsers import stage1_parser, stage2_parser, stage3_parser, stage5_parser, stage6_parser, stage8_parser
import timeit


def pipeline_executor(matlab_path, sentinel_path, log_file_dir, project_abs_path):
    config_file_path = project_abs_path + "\\CI_Config.json"

    log_file_dir = log_file_dir + "proj3990_jlr_l560_hl\\" + \
        datetime.now().strftime("%d-%m-%Y-%H-%M-%S")

    if not os.path.exists(log_file_dir):
        os.makedirs(log_file_dir)

    with open(config_file_path, 'r') as f:
        data = json.load(f)

    if data['matlab_version'].strip().lower() == 'r2017b':
        lastStageResult = True
        if data['stage1_compile_model'] == True:
            stage1_log_file = log_file_dir + "\\stage1_log.txt"
            lastStageResult = scripts_r2017b.compile_model(
                matlab_path=matlab_path, log_file_path=stage1_log_file, project_abs_path=project_abs_path, model_name=data['model_name'])
            stage1_parser.parse_stage1_output("{}\\stage1_log.txt".format(
                log_file_dir), "{}\\stage1_out.json".format(log_file_dir))

        if data['stage2_run_model_advisor'] == True and lastStageResult == True:
            default_config_path = os.getcwd() + "\\default_model_advisor_config_r2017b.mat"
            stage2_log_file = log_file_dir + "\\stage2_log.txt"
            lastStageResult = scripts_r2017b.run_model_advisor(
                matlab_path=matlab_path, log_file_path=stage2_log_file, project_abs_path=project_abs_path, model_name=data['model_name'], default_config_path=default_config_path)
            stage2_parser.parse_stage2_output("{}\\stage2_log.txt".format(
                log_file_dir), "{}\\stage2_out.json".format(log_file_dir), project_abs_path, data['model_name'])

        if data['stage3_run_mil_sil'] == True and lastStageResult == True:
            active_sentinel_path = sentinel_path + \
                "\\Sentinel_{}".format(data['sentinel_version'])
            stage3_log_file = log_file_dir + "\\stage3_log.txt"
            lastStageResult = scripts_r2017b.run_mil_sil(
                matlab_path=matlab_path, log_file_path=stage3_log_file, project_abs_path=project_abs_path, model_name=data['model_name'], sentinel_path=active_sentinel_path)
            stage3_parser.parse_stage3_output("{}\\stage3_log.txt".format(
                log_file_dir), "{}\\stage3_out.json".format(log_file_dir))

        if data['stage4_run_pil'] == True and lastStageResult == True:
            pass

        if data['stage5_generate_code'] == True and lastStageResult == True:
            stage5_log_file = log_file_dir + "\\stage5_log.txt"
            lastStageResult = scripts_r2017b.generate_code(
                matlab_path=matlab_path, log_file_path=stage5_log_file, project_abs_path=project_abs_path, model_name=data['model_name'])
            stage5_parser.parse_stage5_output("{}\\stage5_log.txt".format(
                log_file_dir), "{}\\stage5_out.json".format(log_file_dir))

        if data['stage6_build_code'] == True and lastStageResult == True:
            stage6_log_file = log_file_dir + "\\stage6_log.txt"
            lastStageResult = scripts_r2017b.build_code(
                log_file_path=stage6_log_file, project_abs_path=project_abs_path, model_name=data['model_name'])
            stage6_parser.parse_stage6_output("{}\\stage6_log.txt".format(
                log_file_dir), "{}\\stage6_out.json".format(log_file_dir))

        if data['stage7_run_klocwork'] == True and lastStageResult == True:
            pass

        if data['stage8_prepare_delivery_package'] == True and lastStageResult == True:
            stage8_log_file = log_file_dir + "\\stage8_log.txt"
            scripts_r2017b.prepare_delivery_package(
                matlab_path=matlab_path, log_file_path=stage8_log_file, project_abs_path=project_abs_path, model_name=data['model_name'])
            stage8_parser.parse_stage8_output("{}\\stage8_log.txt".format(
                log_file_dir), "{}\\stage8_out.json".format(log_file_dir))

    elif data['matlab_version'].strip().lower() == 'r2020b':
        lastStageResult = True
        if data['stage1_compile_model'] == True:
            stage1_log_file = log_file_dir + "\\stage1_log.txt"
            lastStageResult = scripts_r2017b.compile_model(
                matlab_path=matlab_path, log_file_path=stage1_log_file, project_abs_path=project_abs_path, model_name=data['model_name'])
            stage1_parser.parse_stage1_output("{}\\stage1_log.txt".format(
                log_file_dir), "{}\\stage1_out.json".format(log_file_dir))

        if data['stage2_run_model_advisor'] == True and lastStageResult == True:
            default_config_path = os.getcwd() + "\\default_model_advisor_config_r2020b.json"
            stage2_log_file = log_file_dir + "\\stage2_log.txt"
            lastStageResult = scripts_r2017b.run_model_advisor(
                matlab_path=matlab_path, log_file_path=stage2_log_file, project_abs_path=project_abs_path, model_name=data['model_name'], default_config_path=default_config_path)
            stage2_parser.parse_stage2_output("{}\\stage2_log.txt".format(
                log_file_dir), "{}\\stage2_out.json".format(log_file_dir), project_abs_path, data['model_name'])

        if data['stage3_run_mil_sil'] == True and lastStageResult == True:
            active_sentinel_path = sentinel_path + \
                "\\Sentinel_{}".format(data['sentinel_version'])
            stage3_log_file = log_file_dir + "\\stage3_log.txt"
            lastStageResult = scripts_r2017b.run_mil_sil(
                matlab_path=matlab_path, log_file_path=stage3_log_file, project_abs_path=project_abs_path, model_name=data['model_name'], sentinel_path=active_sentinel_path)
            stage3_parser.parse_stage3_output("{}\\stage3_log.txt".format(
                log_file_dir), "{}\\stage3_out.json".format(log_file_dir))

        if data['stage4_run_pil'] == True and lastStageResult == True:
            pass

        if data['stage5_generate_code'] == True and lastStageResult == True:
            stage5_log_file = log_file_dir + "\\stage5_log.txt"
            lastStageResult = scripts_r2020b.generate_code(
                matlab_path=matlab_path, log_file_path=stage5_log_file, project_abs_path=project_abs_path, model_name=data['model_name'])
            stage5_parser.parse_stage5_output("{}\\stage5_log.txt".format(
                log_file_dir), "{}\\stage5_out.json".format(log_file_dir))

        if data['stage6_build_code'] == True and lastStageResult == True:
            stage6_log_file = log_file_dir + "\\stage6_log.txt"
            lastStageResult = scripts_r2017b.build_code(
                log_file_path=stage6_log_file, project_abs_path=project_abs_path, model_name=data['model_name'])
            stage6_parser.parse_stage6_output("{}\\stage6_log.txt".format(
                log_file_dir), "{}\\stage6_out.json".format(log_file_dir))

        if data['stage7_run_klocwork'] == True and lastStageResult == True:
            pass

        if data['stage8_prepare_delivery_package'] == True and lastStageResult == True:
            stage8_log_file = log_file_dir + "\\stage8_log.txt"
            scripts_r2017b.prepare_delivery_package(
                matlab_path=matlab_path, log_file_path=stage8_log_file, project_abs_path=project_abs_path, model_name=data['model_name'])
            stage8_parser.parse_stage8_output("{}\\stage8_log.txt".format(
                log_file_dir), "{}\\stage8_out.json".format(log_file_dir))

    else:
        print('Specified Matlab Version Not Supported')

    return


if __name__ == '__main__':
    matlab_path = "\"C:\\Program Files\\MATLAB\\R2020b\\bin\\matlab.exe\""
    sentinel_path = "C:\\E\\Programs\\MBSE"
    log_file_dir = os.getcwd() + "\\logs\\"
    project_abs_path = "C:\\WS_VLS\\proj5250_dodeca_r8mv_integrated_model\\"
    start_time = timeit.default_timer()
    pipeline_executor(matlab_path, sentinel_path,
                      log_file_dir, project_abs_path)
    end_time = timeit.default_timer()
    print("The time difference is :{}".format((end_time - start_time)/60))
