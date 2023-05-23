import os
import json
from bs4 import BeautifulSoup


def parse_stage2_output(stage2_log_path, output_path, project_abs_path, model_name):
    stage2_ident_flag = False
    stage2_ident_string = "Stage 2 - Run Model Advisor:"
    stage_status = "Parsing Not Successful"
    comp_results = []

    with open(stage2_log_path, 'r') as f:
        for line in f:
            if stage2_ident_string in line:
                stage2_ident_flag = True
                break

        if stage2_ident_flag:
            for line in f:
                if "Stage Succeeded" in line:
                    report_out_path = project_abs_path + \
                        "\\02_TEST\\01_STATIC\\01_VMAAC\\{}\\report.html".format(
                            model_name)
                    report_found_flag = False
                    if os.path.exists(report_out_path):
                        stage_status = "Succeeded"
                        report_found_flag = True
                    else:
                        stage_status = "Failed"

                    if report_found_flag:
                        with open(report_out_path, 'r') as f:
                            soup = BeautifulSoup(f, 'html.parser')
                            tables = soup.find_all('table')
                            rows = tables[1].find_all('tr')
                            current_comp = ""
                            current_comp_passed = ""
                            current_comp_failed = ""
                            current_comp_warnings = ""
                            current_comp_notrun = ""
                            for x in rows:
                                columns = x.find_all('td')
                                current_comp = ""
                                current_comp_passed = ""
                                current_comp_failed = ""
                                current_comp_warnings = ""
                                current_comp_notrun = ""
                                for y in columns:
                                    if current_comp == "":
                                        current_comp = y.get_text().strip()
                                    elif current_comp_passed == "":
                                        current_comp_passed = y.get_text().strip()
                                    elif current_comp_failed == "":
                                        current_comp_failed = y.get_text().strip()
                                    elif current_comp_warnings == "":
                                        current_comp_warnings = y.get_text().strip()
                                    elif current_comp_notrun == "":
                                        current_comp_notrun = y.get_text().strip()
                                        current_comp = {
                                            "Component Name": current_comp,
                                            "Passed": current_comp_passed,
                                            "Failed": current_comp_failed,
                                            "Warnings": current_comp_warnings,
                                            "Not Run": current_comp_notrun
                                        }
                                        comp_results.append(current_comp)
                                    else:
                                        pass

                    break
                elif "Stage Failed" in line:
                    stage_status = "Failed"
                    break

    out = {
        'stage2_status' : stage_status,
        'results' : comp_results
    }

    with open(output_path, "w") as outfile:
        json.dump(out, outfile)


if __name__ == '__main__':
    parse_stage2_output("C:\\E\\WS\\4_Tools\\proj5342_tools_contmbd\\logs\\proj3990_jlr_l560_hl\\16-10-2022-17-57-18\\stage2_log.txt",
                        "C:\\E\\WS\\4_Tools\\proj5342_tools_contmbd\\logs\\proj3990_jlr_l560_hl\\16-10-2022-17-57-18\\stage2_out.json", "C:\\E\\WS\\3_MBSE\\2_P2_P1_Projects\\proj3990_jlr_l560_hl", "JLR_L560_HL")
