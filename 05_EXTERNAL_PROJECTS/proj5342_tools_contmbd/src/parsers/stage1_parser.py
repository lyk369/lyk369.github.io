import json

def parse_stage1_output(stage1_log_path, output_path):
    stage1_ident_flag = False
    stage1_ident_string = "Stage 1 - Compiling the Model:"
    stage_status = "Parsing Not Successful"

    with open(stage1_log_path, 'r') as f:
        for line in f:
            if stage1_ident_string in line:
                stage1_ident_flag = True
                break
        
        if stage1_ident_flag:
            for line in f:
                if "Stage Succeeded" in line:
                    stage_status = "Succeeded"
                    break
                elif "Stage Failed" in line:
                    stage_status = "Failed"
                    break
        
    out = {'stage1_status' : stage_status}

    with open(output_path, "w") as outfile:
        json.dump(out, outfile)

if __name__ == '__main__':
    parse_stage1_output("C:\\E\\WS\\4_Tools\\ContMBD\\logs\\proj3990_jlr_l560_hl\\21-08-2022-14-46-26\\stage1_log.txt", "C:\\E\\WS\\4_Tools\\ContMBD\\logs\\proj3990_jlr_l560_hl\\21-08-2022-14-46-26\\stage1_out.json")