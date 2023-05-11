disp(['#### start test vector result update form Sentinel result']);
clear
clc
%%
SheetVarsRowIdx = 7;
SheetResultRowIdx = 13;
%%
ResFolder = uigetdir('..\02_TEST\03_INTEGRATION_TESTS\03_SIL\Sentinel_Output');
disp(['Sentinel result folder: ',ResFolder]);
ResFolderFiles = cellstr(ls(ResFolder));

[filename,pathname]=uigetfile('..\02_TEST\03_INTEGRATION_TESTS\01_TEST_CASES\*.xlsx');
filefullname=[pathname,filename];
disp(['Test vector file: ',filefullname]);

sheets = cellstr(sheetnames(filefullname));
disp(['Imported sheets: ',int2str(length(sheets))]);
disp(['Variables line: ',int2str(SheetVarsRowIdx),' | Result line index: ',int2str(SheetResultRowIdx)]);
%%
for ii_sheet=1:length(sheets)
    sheetname = sheets{ii_sheet};
    disp(['Sheet (#',int2str(ii_sheet),') :',sheetname])
    
    ResFileName = ['o_',sheetname,'.mat'];
    IndexC = strfind(ResFolderFiles,ResFileName);
    Index = find(not(cellfun('isempty',IndexC)));
    
    if ~isempty(Index)
        [~,~,SheetRaw] = xlsread(filefullname,sheetname);
        disp(['The sheet ',sheetname,' is imported']);
        
        ResFileNameFull = [ResFolder,'\',ResFileName];
        ResStruct = load(ResFileNameFull);
        ResFields = fields(ResStruct);
        disp(['Matlab result file ',ResFileName,' is imported']);
        
        for ii_fields=1:length(ResFields)
            FieldName = ResFields{ii_fields};
            %disp(['Result variable ',FieldName]);
            
            IndexCol=[];
            for ii_col=1:size(SheetRaw,2)
                if ~isnan(SheetRaw{SheetVarsRowIdx,ii_col})
                    if strfind(SheetRaw{SheetVarsRowIdx,ii_col},FieldName)
                        IndexCol = [IndexCol;ii_col];
                    end
                end
            end %end column loop
            
            if length(IndexCol) ~= eval(['ResStruct.',FieldName,'.signals.dimensions'])
                error(['ERROR: variable ',FieldName,': wrong size or not found in the line ',int2str(SheetVarsRowIdx),' of the sheet ',sheetname]);
                %fprintf(2,['ERROR: variable ',FieldName,': wrong size or not found in the line ',int2str(SheetVarsRowIdx),' of the sheet ',sheetname,'\n'])
            else           
                FieldVal = eval(['ResStruct.',FieldName,'.signals.values']);
                VarValuesStartIdx = size(FieldVal,1)+ SheetResultRowIdx - 1;
                SheetRaw(SheetResultRowIdx:VarValuesStartIdx,IndexCol) = num2cell(FieldVal);
                %disp([FieldName,' ready to be saved in the test vector sheet']);
            end

        end % end mat fields
        disp(['Matlab result file ',ResFileName,' treatement is finished'])
        
        xlswrite(filefullname,SheetRaw,sheetname);
        disp(['The sheet ',sheetname,' is updated']);
        
        clear ResFileNameFull
        clear SheetRaw
        clear ResStruct
        clear ResFields
        clear FieldName
        
    else
        disp(['no Matlab file is found for the sheet ',sheetname]);
    end %end mat file found
           
           
end %end sheets loop
disp(['#### Test Vector file ',filename,' is updated']);