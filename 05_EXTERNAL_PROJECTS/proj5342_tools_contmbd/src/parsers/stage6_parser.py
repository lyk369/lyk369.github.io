import json

def parse_stage6_output(stage6_log_path, output_path):
    stage_status = "Parsing Not Successful"

    with open(stage6_log_path, 'r') as f:
        stage_status = "Succeeded"
        
        for line in f:
            if "The make command returned an error of" in line:
                stage_status = "Failed"
                break
        
    out = {'stage6_status' : stage_status}

    with open(output_path, "w") as outfile:
        json.dump(out, outfile)

if __name__ == '__main__':
    parse_stage6_output("C:\\E\\WS\\4_Tools\\ContMBD\\logs\\proj3990_jlr_l560_hl\\21-08-2022-15-16-06\\stage6_log.txt", "C:\\E\\WS\\4_Tools\\ContMBD\\logs\\proj3990_jlr_l560_hl\\21-08-2022-15-16-06\\stage6_out.json")