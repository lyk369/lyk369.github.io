% Remove Needed Paths
rmpath(genpath('.\01_SRC\01_SLDD\'));
rmpath(genpath('.\01_SRC\02_LIB\'));
rmpath(genpath('.\01_SRC\03_MDL\'));
rmpath(genpath('.\01_SRC\04_CACHE\'));

Internal_Components_List = dir('.\01_SRC\05_COMPONENTS\');
dirFlags = [Internal_Components_List.isdir];
Internal_Components_List = Internal_Components_List(dirFlags);
if length(Internal_Components_List) > 2
    for i = 3:length(Internal_Components_List)
        rmpath(genpath(char(strcat('.\01_SRC\05_COMPONENTS\'+string(Internal_Components_List(i).name)+'\01_SLDD\'))));
        rmpath(genpath(char(strcat('.\01_SRC\05_COMPONENTS\'+string(Internal_Components_List(i).name)+'\02_LIB\'))));
        rmpath(genpath(char(strcat('.\01_SRC\05_COMPONENTS\'+string(Internal_Components_List(i).name)+'\03_MDL\'))));
    end 
end

External_Components_List = dir('.\05_EXTERNAL_PROJECTS\');
dirFlags = [External_Components_List.isdir];
External_Components_List = External_Components_List(dirFlags);
if length(External_Components_List) > 2
    for i = 3:length(External_Components_List)
        rmpath(genpath(char(strcat('.\05_EXTERNAL_PROJECTS\'+string(External_Components_List(i).name)+'\01_SRC\01_SLDD\'))));
        rmpath(genpath(char(strcat('.\05_EXTERNAL_PROJECTS\'+string(External_Components_List(i).name)+'\01_SRC\02_LIB\'))));
        rmpath(genpath(char(strcat('.\05_EXTERNAL_PROJECTS\'+string(External_Components_List(i).name)+'\01_SRC\03_MDL\'))));
    end
end

rmpath(genpath('.\04_UTILS\'));
rmpath(genpath('.\06_CODE_GEN\01_STUBS'));

% Reset Cache and CodeGen Folders
Simulink.fileGenControl('reset')

clear
