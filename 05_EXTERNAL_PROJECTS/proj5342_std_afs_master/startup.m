% Set Needed Paths
addpath(genpath('.\01_SRC\01_SLDD\'));
addpath(genpath('.\01_SRC\02_LIB\'));
addpath(genpath('.\01_SRC\03_MDL\'));
addpath(genpath('.\01_SRC\04_CACHE\'));

Internal_Components_List = dir('.\01_SRC\05_COMPONENTS\');
dirFlags = [Internal_Components_List.isdir];
Internal_Components_List = Internal_Components_List(dirFlags);
if length(Internal_Components_List) > 2
    for i = 3:length(Internal_Components_List)
        addpath(genpath(char(strcat('.\01_SRC\05_COMPONENTS\'+string(Internal_Components_List(i).name)+'\01_SLDD\'))));
        addpath(genpath(char(strcat('.\01_SRC\05_COMPONENTS\'+string(Internal_Components_List(i).name)+'\02_LIB\'))));
        addpath(genpath(char(strcat('.\01_SRC\05_COMPONENTS\'+string(Internal_Components_List(i).name)+'\03_MDL\'))));
    end 
end

External_Components_List = dir('.\05_EXTERNAL_PROJECTS\');
dirFlags = [External_Components_List.isdir];
External_Components_List = External_Components_List(dirFlags);
if length(External_Components_List) > 2
    for i = 3:length(External_Components_List)
        addpath(genpath(char(strcat('.\05_EXTERNAL_PROJECTS\'+string(External_Components_List(i).name)+'\01_SRC\01_SLDD\'))));
        addpath(genpath(char(strcat('.\05_EXTERNAL_PROJECTS\'+string(External_Components_List(i).name)+'\01_SRC\02_LIB\'))));
        addpath(genpath(char(strcat('.\05_EXTERNAL_PROJECTS\'+string(External_Components_List(i).name)+'\01_SRC\03_MDL\'))));
    end 
end

addpath(genpath('.\04_UTILS\'));
addpath(genpath('.\06_CODE_GEN\01_STUBS'));
addpath('.\06_CODE_GEN');

addpath(genpath('.\05_EXTERNAL_PROJECTS\proj5342_transversal_utilities_git\R2020b\'));

% Configure Cache and CodeGen Output Paths
Simulink.fileGenControl('set', 'CacheFolder', '.\01_SRC\04_CACHE', 'CodeGenFolder', '.\06_CODE_GEN')
% Link Model to the sldd that allows code generation and build
ModelName = 'AFS_Master';
DDName = 'AFS_Master_Model.sldd';
load_system(ModelName);
[RefModels,blocks] = find_mdlrefs(ModelName);
myDictionaryObj = Simulink.data.dictionary.open(DDName);
dDataSectObj = getSection(myDictionaryObj,'Configurations');
entryObj = getEntry(dDataSectObj,'Reference');
ConfigSetRef = getValue(entryObj);
ConfigName = get_param(ConfigSetRef,"SourceName");
Simulink.data.dictionary.closeAll(DDName,'-discard');

for i = 1:length(RefModels)
    AvailableRefConfSet = 0;
    load_system(RefModels{i});
    set_param(RefModels{i}, 'DataDictionary', DDName);
    activeConfigObj = getActiveConfigSet(RefModels{i});
    if(isequal(activeConfigObj.class,'Simulink.ConfigSetRef'))
        set_param(activeConfigObj,"SourceName",ConfigName);
    else
        ConfigSets = getConfigSets(RefModels{i});
        for j = 1:length(ConfigSets)
            ConfigObject = getConfigSet(RefModels{i},ConfigSets{j});
            if(isequal(ConfigObject.class,'Simulink.ConfigSetRef'))
                set_param(ConfigObject,"SourceName",ConfigName);
                ActiveConfigSetName = get_param(ConfigObject,"Name");
                setActiveConfigSet(RefModels{i},ActiveConfigSetName);
                AvailableRefConfSet = 1;
                break;
            end
        end
        if(~AvailableRefConfSet)
            NewRefConfigSet = Simulink.ConfigSetRef;
            attachConfigSet(RefModels{i}, NewRefConfigSet , true);
            set_param(NewRefConfigSet,"SourceName",ConfigName);
            setActiveConfigSet(RefModels{i}, NewRefConfigSet.Name);
        end
    end
    try 
        save_system(RefModels{i});
    catch
        save_system(RefModels{i},RefModels{i},'SaveDirtyReferencedModels',true);
    end
    close_system(RefModels{i});
end 