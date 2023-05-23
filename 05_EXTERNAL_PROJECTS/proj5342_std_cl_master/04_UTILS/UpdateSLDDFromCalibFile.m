% Compatible with Template V1.0.1

% SMI Path Relative to Project Root
CalibPath = "./03_DOC/04_SMI/Calibration.xlsx";

% SLDD Folder Path Relative to Project Root
SlddPath = './01_SRC/01_SLDD/Dodeca_PowerControl_DD.sldd';

% Load Tables from SMI file
table = readtable(CalibPath, 'Sheet', 'Global', 'TextType', 'String');

try
    myDictionaryObj = Simulink.data.dictionary.open(SlddPath);
catch ME
    disp(ME);
end

dDataSectObj = getSection(myDictionaryObj,'Design Data');

% Loop on Table
num_rows = height(table);
for row = 1:num_rows
    paramName = convertStringsToChars(string(table{row,1}));
    
    if (~isempty(paramName))
        paramValue = convertStringsToChars(string(table{row,2}));
        evalin('base',['tempValue = ',paramValue,';']);
        
        tempObj = getEntry(dDataSectObj,paramName);
        
        tempObjValue = getValue(tempObj);
        tempObjValue.Value = tempValue;
        
        setValue(tempObj, tempObjValue);
    end
end
