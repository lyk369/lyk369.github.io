disp('Select Model File');
modelFile = uigetfile();
modelFile = modelFile(1:end-4);
handle = load_system(modelFile);

disp('Select SLDD File');
slddFile = uigetfile();

unusedVars = Simulink.findVars(modelFile,'FindUsedVars','off','SourceType','data dictionary');

myDictionaryObj = Simulink.data.dictionary.open(slddFile);
dDataSectObj = getSection(myDictionaryObj,'Design Data');

for i = 1:size(unusedVars)
    disp(unusedVars(i).Name)
    try
        deleteEntry(dDataSectObj, unusedVars(i).Name);
    catch
        disp('Not in Design Data')
    end
end

close_system(modelFile);
