% Compatible with Template V1.0.1

% SMI Path Relative to Project Root
SMIPath = "./03_DOC/04_SMI/Signaling_Sldd_test.xlsx";

% SLDD Folder Path Relative to Project Root
SlddFolderPath = "./01_SRC/01_SLDD/";
p
% Load Tables from SMI file
HeaderTable = readtable(SMIPath, 'Sheet', 'Header', 'ReadVariableNames', false, 'TextType', 'String');
InputsTable = readtable(SMIPath, 'Sheet', 'Inputs', 'Format', 'auto', 'TextType', 'String');
OutputsTable = readtable(SMIPath, 'Sheet', 'Outputs', 'Format', 'auto', 'TextType', 'String');
RunnablesTable = readtable(SMIPath, 'Sheet', 'Runnables', 'TextType', 'String');
PublicDataTable = readtable(SMIPath, 'Sheet', 'PublicData', 'Format', 'auto', 'TextType', 'String');
PrivateDataTable = readtable(SMIPath, 'Sheet', 'PrivateData', 'TextType', 'String');
PrivateSignalsTable = readtable(SMIPath, 'Sheet', 'PrivateSignals', 'TextType', 'String');
NumericTypesTable = readtable(SMIPath, 'Sheet', 'NumericTypes', 'TextType', 'String');
BusTable = readtable(SMIPath, 'Sheet', 'Bus', 'TextType', 'String');
EnumTable = readtable(SMIPath, 'Sheet', 'Enum', 'TextType', 'String');

SlddName = HeaderTable{3,2} + ".sldd";
SlddFilePath = SlddFolderPath + SlddName;

try
    myDictionaryObj = Simulink.data.dictionary.create(SlddFilePath);
catch ME
    if strcmp(ME.identifier,'SLDD:sldd:DictionaryAlreadyExists')
        myDictionaryObj = Simulink.data.dictionary.open(SlddFilePath);
    else
        rethrow(ME);
    end
end

dDataSectObj = getSection(myDictionaryObj,'Design Data');

% Loop on Inputs
num_rows = height(InputsTable);
for row = 1:num_rows
    signalName = convertStringsToChars(string(InputsTable{row,1}));
    
    if (~isempty(signalName))
        signalDataType = convertStringsToChars(string(InputsTable{row,2}));
        signalDimensions = convertStringsToChars(string(InputsTable{row,3}));
        signalInitialValue = convertStringsToChars(string(InputsTable{row,4}));
        signalMin = double(InputsTable{row,5});
        signalMax = double(InputsTable{row,6});
        signalUnit = convertStringsToChars(string(InputsTable{row,7}));
        signalDescription = convertStringsToChars(string(InputsTable{row,8}));
        signalStorageClass = convertStringsToChars(string(InputsTable{row,9}));
        signalHeaderFile = convertStringsToChars(string(InputsTable{row,10}));
        signalGetFunction = convertStringsToChars(string(InputsTable{row,11}));
        
        evalin('base',[signalName,' = Simulink.Signal;']);
        
        evalin('base',[signalName,'.DataType = signalDataType;']);
        
        evalin('base',[signalName,'.Dimensions = signalDimensions;']);
        
        if(~isempty(signalInitialValue))
            evalin('base',[signalName,'.InitialValue = signalInitialValue;']);
        end
        
        if(~contains(signalDataType,'Enum:'))
            evalin('base',[signalName,'.Min = signalMin;']);
        end
        
        if(~contains(signalDataType,'Enum:'))
            evalin('base',[signalName,'.Max = signalMax;']);
        end
        
        if(~isempty(signalUnit))
            evalin('base',[signalName,'.Unit = signalUnit;']);
        end
        
        if(~isempty(signalDescription))
            evalin('base',[signalName,'.Description = signalDescription;']);
        end
        
        
        if(strcmp(signalStorageClass, 'GetSet'))
            evalin('base',[signalName,'.CoderInfo.StorageClass = ''Custom'';']);
            
            evalin('base',[signalName,'.CoderInfo.CustomStorageClass = signalStorageClass;']);
            
            if(~isempty(signalHeaderFile))
                evalin('base',[signalName,'.CoderInfo.CustomAttributes.HeaderFile = signalHeaderFile;']);
            end
            
            if(~isempty(signalGetFunction))
                evalin('base',[signalName,'.CoderInfo.CustomAttributes.GetFunction = signalGetFunction;']);
            end
        else
            evalin('base',[signalName,'.CoderInfo.StorageClass = signalStorageClass;']);
        end
        
        importFromBaseWorkspace(myDictionaryObj, 'varList', {signalName}, ...
            'existingVarsAction', 'overwrite', 'clearWorkspaceVars', true);
    end
end

% Loop on Outputs
num_rows = height(OutputsTable);
for row = 1:num_rows
    signalName = convertStringsToChars(string(OutputsTable{row,1}));
    
    if (~isempty(signalName))
        signalDataType = convertStringsToChars(string(OutputsTable{row,2}));
        signalDimensions = convertStringsToChars(string(OutputsTable{row,3}));
        signalInitialValue = convertStringsToChars(string(OutputsTable{row,4}));
        signalMin = double(OutputsTable{row,5});
        signalMax = double(OutputsTable{row,6});
        signalUnit = convertStringsToChars(string(OutputsTable{row,7}));
        signalDescription = convertStringsToChars(string(OutputsTable{row,8}));
        signalStorageClass = convertStringsToChars(string(OutputsTable{row,9}));
        signalHeaderFile = convertStringsToChars(string(OutputsTable{row,10}));
        signalSetFunction = convertStringsToChars(string(OutputsTable{row,11}));
        
        evalin('base',[signalName,' = Simulink.Signal;']);
        
        evalin('base',[signalName,'.DataType = signalDataType;']);
        
        evalin('base',[signalName,'.Dimensions = signalDimensions;']);
        
        if(~isempty(signalInitialValue))
            evalin('base',[signalName,'.InitialValue = signalInitialValue;']);
        end
        
        if(~contains(signalDataType,'Enum:'))
            evalin('base',[signalName,'.Min = signalMin;']);
        end
        
        if(~contains(signalDataType,'Enum:'))
            evalin('base',[signalName,'.Max = signalMax;']);
        end
        
        if(~isempty(signalUnit))
            evalin('base',[signalName,'.Unit = signalUnit;']);
        end
        
        if(~isempty(signalDescription))
            evalin('base',[signalName,'.Description = signalDescription;']);
        end
        
        if(strcmp(signalStorageClass, 'GetSet'))
            evalin('base',[signalName,'.CoderInfo.StorageClass = ''Custom'';']);
            
            evalin('base',[signalName,'.CoderInfo.CustomStorageClass = signalStorageClass;']);
            
            if(~isempty(signalHeaderFile))
                evalin('base',[signalName,'.CoderInfo.CustomAttributes.HeaderFile = signalHeaderFile;']);
            end
            
            if(~isempty(signalSetFunction))
                evalin('base',[signalName,'.CoderInfo.CustomAttributes.SetFunction = signalSetFunction;']);
            end
        else
            evalin('base',[signalName,'.CoderInfo.StorageClass = signalStorageClass;']);
        end
        
        importFromBaseWorkspace(myDictionaryObj, 'varList', {signalName}, ...
            'existingVarsAction', 'overwrite', 'clearWorkspaceVars', true);
    end
end

% Loop on PrivateSignals
num_rows = height(PrivateSignalsTable);
for row = 1:num_rows
    signalName = convertStringsToChars(string(PrivateSignalsTable{row,1}));
    
    if(~isempty(signalName))
        signalDataType = convertStringsToChars(string(PrivateSignalsTable{row,2}));
        signalDimensions = convertStringsToChars(string(PrivateSignalsTable{row,3}));
        signalInitialValue = convertStringsToChars(string(PrivateSignalsTable{row,4}));
        signalMin = double(PrivateSignalsTable{row,5});
        signalMax = double(PrivateSignalsTable{row,6});
        signalUnit = convertStringsToChars(string(PrivateSignalsTable{row,7}));
        signalDescription = convertStringsToChars(string(PrivateSignalsTable{row,8}));
        
        evalin('base',[signalName,' = Simulink.Signal;']);
        
        evalin('base',[signalName,'.DataType = signalDataType;']);
        
        evalin('base',[signalName,'.Dimensions = signalDimensions;']);
        
        if(~isempty(signalInitialValue))
            evalin('base',[signalName,'.InitialValue = signalInitialValue;']);
        end
        
        if(~contains(signalDataType,'Enum:'))
            evalin('base',[signalName,'.Min = signalMin;']);
        end
        
        if(~contains(signalDataType,'Enum:'))
            evalin('base',[signalName,'.Max = signalMax;']);
        end
        
        if(~isempty(signalUnit))
            evalin('base',[signalName,'.Unit = signalUnit;']);
        end
        
        if(~isempty(signalDescription))
            evalin('base',[signalName,'.Description = signalDescription;']);
        end
        
        importFromBaseWorkspace(myDictionaryObj, 'varList', {signalName}, ...
            'existingVarsAction', 'overwrite', 'clearWorkspaceVars', true);
    end
end

% Loop on PublicData
num_rows = height(PublicDataTable);
for row = 1:num_rows
    paramName = convertStringsToChars(string(PublicDataTable{row,1}));
    
    if (~isempty(paramName))
        paramValue = convertStringsToChars(string(PublicDataTable{row,2}));
        paramDimensions = convertStringsToChars(string(PublicDataTable{row,3}));
        paramDataType = convertStringsToChars(string(PublicDataTable{row,4}));
        paramMin = double(PublicDataTable{row,5});
        paramMax = double(PublicDataTable{row,6});
        paramUnit = convertStringsToChars(string(PublicDataTable{row,7}));
        paramDescription = convertStringsToChars(string(PublicDataTable{row,8}));
        paramStorageClass = convertStringsToChars(string(PublicDataTable{row,9}));
        paramHeaderFile = convertStringsToChars(string(PublicDataTable{row,10}));
        paramDefinitionFile = convertStringsToChars(string(PublicDataTable{row,11}));
        
        evalin('base',[paramName,' = Simulink.Parameter;']);
        
        evalin('base',[paramName,'.Value = ',paramValue,';']);
        
        evalin('base',[paramName,'.Dimensions = paramDimensions;']);
        
        evalin('base',[paramName,'.DataType = paramDataType;']);
        
        if(~contains(paramDataType,'Enum:'))
            evalin('base',[paramName,'.Min = paramMin;']);
        end
        
        if(~contains(paramDataType,'Enum:'))
            evalin('base',[paramName,'.Max = paramMax;']);
        end
        
        if(~isempty(paramUnit))
            evalin('base',[paramName,'.Unit = paramUnit;']);
        end
        
        if(~isempty(paramDescription))
            evalin('base',[paramName,'.Description = paramDescription;']);
        end
        if strcmp(paramStorageClass, 'Auto')
            % Do Nothing
        elseif strcmp(paramStorageClass, 'ImportedExtern')
            evalin('base',[paramName,'.CoderInfo.StorageClass = paramStorageClass;']);
            
        elseif strcmp(paramStorageClass, 'ImportedExternPointer')
            evalin('base',[paramName,'.CoderInfo.StorageClass = paramStorageClass;']);
            
        elseif strcmp(paramStorageClass, 'Const')
            evalin('base',[paramName,'.CoderInfo.StorageClass = ''Custom'';']);
            
            evalin('base',[paramName,'.CoderInfo.CustomStorageClass = paramStorageClass;']);
            
            evalin('base',[paramName,'.CoderInfo.CustomAttributes.HeaderFile = paramHeaderFile;']);
            
            evalin('base',[paramName,'.CoderInfo.CustomAttributes.DefinitionFile = paramDefinitionFile;']);
            
        elseif strcmp(paramStorageClass, 'ImportedDefine')
            evalin('base',[paramName,'.CoderInfo.StorageClass = ''Custom'';']);
            
            evalin('base',[paramName,'.CoderInfo.CustomStorageClass = paramStorageClass;']);
            
            evalin('base',[paramName,'.CoderInfo.CustomAttributes.HeaderFile = paramHeaderFile;']);
            
        elseif strcmp(paramStorageClass, 'Define')
            evalin('base',[paramName,'.CoderInfo.StorageClass = ''Custom'';']);
            
            evalin('base',[paramName,'.CoderInfo.CustomStorageClass = paramStorageClass;']);
            
            evalin('base',[paramName,'.CoderInfo.CustomAttributes.HeaderFile = paramHeaderFile;']);
            
        elseif strcmp(paramStorageClass, 'FileScope')
            evalin('base',[paramName,'.CoderInfo.StorageClass = ''Custom'';']);
            
            evalin('base',[paramName,'.CoderInfo.CustomStorageClass = paramStorageClass;']);
        end
        
        importFromBaseWorkspace(myDictionaryObj, 'varList', {paramName}, ...
            'existingVarsAction', 'overwrite', 'clearWorkspaceVars', true);
    end
end

% Loop on PrivateData
num_rows = height(PrivateDataTable);
for row = 1:num_rows
    paramName = convertStringsToChars(string(PrivateDataTable{row,1}));
    
    if (~isempty(paramName))
        paramValue = convertStringsToChars(string(PrivateDataTable{row,2}));
        paramDimensions = convertStringsToChars(string(PrivateDataTable{row,3}));
        paramDataType = convertStringsToChars(string(PrivateDataTable{row,4}));
        paramMin = double(PrivateDataTable{row,5});
        paramMax = double(PrivateDataTable{row,6});
        paramUnit = convertStringsToChars(string(PrivateDataTable{row,7}));
        paramDescription = convertStringsToChars(string(PrivateDataTable{row,8}));
        paramStorageClass = convertStringsToChars(string(PrivateDataTable{row,9}));
        paramHeaderFile = convertStringsToChars(string(PrivateDataTable{row,10}));
        paramDefinitionFile = convertStringsToChars(string(PrivateDataTable{row,11}));
        
        evalin('base',[paramName,' = Simulink.Parameter;']);
        
        evalin('base',[paramName,'.Value = ',paramValue,';']);
        
        evalin('base',[paramName,'.Dimensions = paramDimensions;']);
        
        evalin('base',[paramName,'.DataType = paramDataType;']);
        
        
        if(~contains(paramDataType,'Enum:'))
            evalin('base',[paramName,'.Min = paramMin;']);
        end
        
        if(~contains(paramDataType,'Enum:'))
            evalin('base',[paramName,'.Max = paramMax;']);
        end
        
        if(~isempty(paramUnit))
            evalin('base',[paramName,'.Unit = paramUnit;']);
        end
        
        if(~isempty(paramDescription))
            evalin('base',[paramName,'.Description = paramDescription;']);
        end
        
        if strcmp(paramStorageClass, 'Auto')
            % Do Nothing
        elseif strcmp(paramStorageClass, 'ImportedExtern')
            evalin('base',[paramName,'.CoderInfo.StorageClass = paramStorageClass;']);
            
        elseif strcmp(paramStorageClass, 'ImportedExternPointer')
            evalin('base',[paramName,'.CoderInfo.StorageClass = paramStorageClass;']);
            
        elseif strcmp(paramStorageClass, 'Const')
            evalin('base',[paramName,'.CoderInfo.StorageClass = ''Custom'';']);
            
            evalin('base',[paramName,'.CoderInfo.CustomStorageClass = paramStorageClass;']);
            
            evalin('base',[paramName,'.CoderInfo.CustomAttributes.HeaderFile = paramHeaderFile;']);
            
            evalin('base',[paramName,'.CoderInfo.CustomAttributes.DefinitionFile = paramDefinitionFile;']);
            
        elseif strcmp(paramStorageClass, 'ImportedDefine')
            evalin('base',[paramName,'.CoderInfo.StorageClass = ''Custom'';']);
            
            evalin('base',[paramName,'.CoderInfo.CustomStorageClass = paramStorageClass;']);
            
            evalin('base',[paramName,'.CoderInfo.CustomAttributes.HeaderFile = paramHeaderFile;']);
            
        elseif strcmp(paramStorageClass, 'Define')
            evalin('base',[paramName,'.CoderInfo.StorageClass = ''Custom'';']);
            
            evalin('base',[paramName,'.CoderInfo.CustomStorageClass = paramStorageClass;']);
            
            evalin('base',[paramName,'.CoderInfo.CustomAttributes.HeaderFile = paramHeaderFile;']);
            
        elseif strcmp(paramStorageClass, 'FileScope')
            evalin('base',[paramName,'.CoderInfo.StorageClass = ''Custom'';']);
            
            evalin('base',[paramName,'.CoderInfo.CustomStorageClass = paramStorageClass;']);
        end
        
        importFromBaseWorkspace(myDictionaryObj, 'varList', {paramName}, ...
            'existingVarsAction', 'overwrite', 'clearWorkspaceVars', true);
    end
end

% Loop on NumericTypes
num_rows = height(NumericTypesTable);
for row = 1:num_rows
    numericTypeName = convertStringsToChars(string(NumericTypesTable{row,1}));
    
    if (~isempty(numericTypeName))
        numericTypeDataTypeMode = convertStringsToChars(string(NumericTypesTable{row,2}));
        
        if strcmp(numericTypeDataTypeMode, 'SlopeBias')
            dataTypeMode = 'Fixed-point: slope and bias scaling';
        elseif strcmp(numericTypeDataTypeMode, 'BinaryPoint')
            dataTypeMode = 'Fixed-point: binary point scaling';
        end
        
        numericTypeSignedness = convertStringsToChars(string(NumericTypesTable{row,3}));
        numericTypeWordLength = double(NumericTypesTable{row,4});
        numericTypeSlope = double(NumericTypesTable{row,5});
        numericTypeBias = double(NumericTypesTable{row,6});
        numericTypeFractionLength = double(NumericTypesTable{row,7});
        numericTypeDataScope = convertStringsToChars(string(NumericTypesTable{row,8}));
        numericTypeHeaderFile = convertStringsToChars(string(NumericTypesTable{row,9}));
        numericTypeDescription = convertStringsToChars(string(NumericTypesTable{row,10}));
        
        evalin('base',[numericTypeName,' = Simulink.NumericType;']);
        
        evalin('base',[numericTypeName,'.DataTypeMode = dataTypeMode;']);
        
        evalin('base',[numericTypeName,'.Signedness = numericTypeSignedness;']);
        
        evalin('base',[numericTypeName,'.WordLength = numericTypeWordLength;']);
        
        if strcmp(numericTypeDataTypeMode, 'SlopeBias')
            evalin('base',[numericTypeName,'.Slope = numericTypeSlope;']);
            evalin('base',[numericTypeName,'.Bias = numericTypeBias;']);
            
        elseif strcmp(numericTypeDataTypeMode, 'BinaryPoint')
            evalin('base',[numericTypeName,'.FractionLength = numericTypeFractionLength;']);
        end
        
        
        if(~isempty(numericTypeDataScope))
            evalin('base',[numericTypeName,'.DataScope = numericTypeDataScope;']);
        end
        
        if(~isempty(numericTypeHeaderFile))
            evalin('base',[numericTypeName,'.HeaderFile = numericTypeHeaderFile;']);
        end
        
        if(~isempty(numericTypeDescription))
            evalin('base',[numericTypeName,'.Description = numericTypeDescription;']);
        end
        
        importFromBaseWorkspace(myDictionaryObj, 'varList', {numericTypeName}, ...
            'existingVarsAction', 'overwrite', 'clearWorkspaceVars', true);
    end
end

% Loop on Enum
row = 1;
num_rows = height(EnumTable);
while row <= num_rows
    enumName = convertStringsToChars(string(EnumTable{row,1}));
    
    if (~isempty(enumName))
        enumDescription = convertStringsToChars(string(EnumTable{row,2}));
        numEnumElements = double(EnumTable{row,3});
        enumDefaultValue = convertStringsToChars(string(EnumTable{row,7}));
        enumStorageType = convertStringsToChars(string(EnumTable{row,8}));
        enumDataScope = convertStringsToChars(string(EnumTable{row,9}));
        enumHeaderFile = convertStringsToChars(string(EnumTable{row,10}));
        
        evalin('base',[enumName,'= Simulink.data.dictionary.EnumTypeDefinition;']);
        
        for element = 1:numEnumElements
            elementName = convertStringsToChars(string(EnumTable{row + element - 1,4}));
            enumValue = convertStringsToChars(string(EnumTable{row + element - 1,5}));
            elementDescription = convertStringsToChars(string(EnumTable{row + element - 1,6}));
            evalin('base',['appendEnumeral(' enumName ', ''' elementName ''' ,' enumValue ',''' elementDescription ''');']);
        end
        evalin('base',['removeEnumeral(',enumName,', 1);']);
        
        if(~isempty(enumDescription))
            evalin('base',[enumName,'.Description = enumDescription;']);
        end
        
        if(~isempty(enumStorageType))
            evalin('base',[enumName,'.StorageType = enumStorageType;']);
        end
        
        if(~isempty(enumDataScope))
            evalin('base',[enumName,'.DataScope  = enumDataScope;']);
        end
        
        if(~isempty(enumHeaderFile))
            evalin('base',[enumName,'.HeaderFile  = enumHeaderFile;']);
        end
        
        importFromBaseWorkspace(myDictionaryObj, 'varList', {enumName}, ...
            'existingVarsAction', 'overwrite', 'clearWorkspaceVars', true);
        
        row = row + numEnumElements;
        
    end
end
