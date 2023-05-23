from utils import wrap_in_try_catch, execute_task


def generate_code(matlab_path, log_file_path, project_abs_path, model_name):

    start_command = "{} -automation -logfile {} -wait -sd {} -r " \
        "\"disp('Stage 5 - Generating Code from the Model:');" \
        "startup;".format(matlab_path, log_file_path, project_abs_path)

    command = "Simulink.data.dictionary.closeAll('-discard');"\
        "slbuild('{}', 'StandaloneCoderTarget', 'GenCodeOnly', true);".format(
            model_name)

    end_command = "\""

    wrapped_command = wrap_in_try_catch(command)

    full_command = start_command + wrapped_command + end_command

    # print(full_command)
    result = execute_task(command=full_command)
    return result
