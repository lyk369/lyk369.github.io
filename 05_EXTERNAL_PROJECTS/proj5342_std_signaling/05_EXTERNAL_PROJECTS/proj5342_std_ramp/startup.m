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

% Configure Cache and CodeGen Output Paths
Simulink.fileGenControl('set', 'CacheFolder', '.\01_SRC\04_CACHE', 'CodeGenFolder', '.\06_CODE_GEN')

clear
