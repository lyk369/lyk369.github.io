import json


def parse_stage3_output(stage3_log_path, output_path):
    stage3_ident_flag = False
    stage3_ident_string = "Stage 3 - Running MIL/SIL Tests:"
    stage_status = "Parsing Not Successful"
    total_number_of_testcases = 0
    total_number_of_not_executed_testcases = 0
    total_number_of_passed_testcases = 0
    total_number_of_failed_testcases = 0
    total_number_of_warning_testcases = 0
    inside_run_summary = False

    with open(stage3_log_path, 'r') as f:
        for line in f:
            if stage3_ident_string in line:
                stage3_ident_flag = True
                break

        if stage3_ident_flag:
            for line in f:
                if not inside_run_summary and "Run Summary:" in line:
                    inside_run_summary = True
                elif inside_run_summary and "Total Number of TestCases:" in line:
                    total_number_of_testcases += int(
                        line.split(":")[1].strip())
                elif inside_run_summary and "Total Number of Not Executed TestCases:" in line:
                    total_number_of_not_executed_testcases += int(
                        line.split(":")[1].strip())
                elif inside_run_summary and "Total Number of Passed TestCases:" in line:
                    total_number_of_passed_testcases += int(
                        line.split(":")[1].strip())
                elif inside_run_summary and "Total Number of Failed TestCases:" in line:
                    total_number_of_failed_testcases += int(
                        line.split(":")[1].strip())
                elif inside_run_summary and "Total Number of Warning TestCases:" in line:
                    total_number_of_warning_testcases += int(
                        line.split(":")[1].strip())
                    inside_run_summary = False
                
            stage_status = "Succeeded"

    # if total_number_of_testcases != 0 and total_number_of_passed_testcases == total_number_of_testcases:
        
    # else:
    #     stage_status = "Failed"

    out = {
        'stage3_status': stage_status,
        'Total Number of TestCases': total_number_of_testcases,
        'Total Number of Not Executed TestCases': total_number_of_not_executed_testcases,
        'Total Number of Passed TestCases': total_number_of_passed_testcases,
        'Total Number of Failed TestCases': total_number_of_failed_testcases,
        'Total Number of Warning TestCases': total_number_of_warning_testcases
    }

    with open(output_path, "w") as outfile:
        json.dump(out, outfile)


if __name__ == '__main__':
    parse_stage3_output("C:\\E\\WS\\4_Tools\\proj5342_tools_contmbd\\logs\\proj3990_jlr_l560_hl\\17-10-2022-23-20-52\\stage3_log.txt",
                        "C:\\E\\WS\\4_Tools\\proj5342_tools_contmbd\\logs\\proj3990_jlr_l560_hl\\17-10-2022-23-20-52\\stage3_out.json")
