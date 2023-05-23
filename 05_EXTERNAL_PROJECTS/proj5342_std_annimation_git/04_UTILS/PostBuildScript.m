CodeGenFolder = './06_CODE_GEN';

files = dir(CodeGenFolder);
dirFlags = [files.isdir];
subFolders = files(dirFlags);
subFolderNames = {subFolders(3:end).name};

for k = 1 : length(subFolderNames)
    if contains(subFolderNames{k}, '_ert_rtw')
        modelName = extractBetween(subFolderNames{k}, '', '_ert_rtw');
        
        ModelReportFolder = strcat(CodeGenFolder,'/04_REPORT/',modelName{1},'/html');
        if exist(ModelReportFolder, 'dir')
            rmdir(ModelReportFolder,'s');
        end
        mkdir(ModelReportFolder);
        copyfile(strcat(CodeGenFolder,'/',subFolderNames{k},'/html'), ModelReportFolder);
        
        ModelSrcFolder = strcat(CodeGenFolder,'/02_CODE/');
        f=dir(ModelSrcFolder);
        f={f.name};
        n=find(strcmp(f,'.gitignore'));
        if(~isempty(n))
            f{n}=[];
        end
        for l=1:numel(f)
            delete([ModelSrcFolder f{l}]);
        end
        
        c_filelist = dir(strcat(CodeGenFolder,'/',subFolderNames{k},'/*.c'));
        for i = 1 : length(c_filelist)
            if(strcmp(c_filelist(i).name,'ert_main.c'))
                copyfile(strcat(c_filelist(i).folder,'/',c_filelist(i).name), strcat(CodeGenFolder,'/01_STUBS/'), 'f');
            else
                copyfile(strcat(c_filelist(i).folder,'/',c_filelist(i).name), strcat(CodeGenFolder,'/02_CODE/'));
            end
        end
        
        h_filelist = dir(strcat(CodeGenFolder,'/',subFolderNames{k},'/*.h'));
        for i = 1 : length(h_filelist)
            copyfile(strcat(h_filelist(i).folder,'/',h_filelist(i).name), strcat(CodeGenFolder,'/02_CODE/'));
        end
        
        a2l_filelist = dir(strcat(CodeGenFolder,'/',subFolderNames{k},'/*.a2l'));
        for i = 1 : length(a2l_filelist)
            copyfile(strcat(a2l_filelist(i).folder,'/',a2l_filelist(i).name), strcat(CodeGenFolder,'/06_A2L/'));
        end
        
    elseif strcmp(subFolderNames{k}, 'slprj')
        % Handle _sharedutils Folder %
        SharedUtilsReportFolder = strcat(CodeGenFolder,'/04_REPORT/slprj/ert/_sharedutils/html');
        if exist(SharedUtilsReportFolder, 'dir')
            rmdir(SharedUtilsReportFolder,'s');
        end
        mkdir(SharedUtilsReportFolder);
        copyfile(strcat(CodeGenFolder,'/slprj/ert/_sharedutils/html'), SharedUtilsReportFolder);
        
        SharedUtilsSrcFolder = strcat(CodeGenFolder,'/03_SHARED_UTILS/');
        f=dir(SharedUtilsSrcFolder);
        f={f.name};
        n=find(strcmp(f,'.gitignore'));
        if(~isempty(n))
            f{n}=[];
        end
        for l=1:numel(f)
            delete([SharedUtilsSrcFolder f{l}]);
        end
        
        c_filelist = dir(strcat(CodeGenFolder,'/slprj/ert/_sharedutils/*.c'));
        for i = 1 : length(c_filelist)
            copyfile(strcat(c_filelist(i).folder,'/',c_filelist(i).name), strcat(CodeGenFolder,'/03_SHARED_UTILS/'));
        end
        
        h_filelist = dir(strcat(CodeGenFolder,'/slprj/ert/_sharedutils/*.h'));
        for i = 1 : length(h_filelist)
            copyfile(strcat(h_filelist(i).folder,'/',h_filelist(i).name), strcat(CodeGenFolder,'/03_SHARED_UTILS/'));
        end
        
        a2l_filelist = dir(strcat(CodeGenFolder,'/slprj/ert/_sharedutils/*.a2l'));
        for i = 1 : length(a2l_filelist)
            copyfile(strcat(a2l_filelist(i).folder,'/',a2l_filelist(i).name), strcat(CodeGenFolder,'/06_A2L/'));
        end
        
        % Handle components folders if it exists %
        filesInSlprj = dir(strcat(CodeGenFolder,'/slprj/ert'));
        slprjDirFlags = [filesInSlprj.isdir];
        slprjSubFolders = filesInSlprj(slprjDirFlags);
        slprjSubFolderNames = {slprjSubFolders(3:end).name};
        
        for i = 1 : length(slprjSubFolderNames)
            compName = slprjSubFolderNames{i};
            
            if (~strcmp(compName,modelName{1})) && (~strcmp(compName,'_sharedutils'))
                
                compReportFolder = strcat(CodeGenFolder,'/04_REPORT/slprj/ert/',compName,'/html');
                if exist(compReportFolder, 'dir')
                    rmdir(compReportFolder,'s');
                end
                mkdir(compReportFolder);
                copyfile(strcat(CodeGenFolder,'/slprj/ert/',compName,'/html'), compReportFolder);
                
                compSrcFolder = strcat(CodeGenFolder,'/02_CODE/',compName);
                if exist(compSrcFolder, 'dir')
                    rmdir(compSrcFolder,'s');
                end
                mkdir(compSrcFolder);
                
                c_filelist = dir(strcat(CodeGenFolder,'/slprj/ert/',compName,'/*.c'));
                for j = 1 : length(c_filelist)
                    copyfile(strcat(c_filelist(j).folder,'/',c_filelist(j).name), strcat(compSrcFolder,'/'));
                end
                
                h_filelist = dir(strcat(CodeGenFolder,'/slprj/ert/',compName,'/*.h'));
                for j = 1 : length(h_filelist)
                    copyfile(strcat(h_filelist(j).folder,'/',h_filelist(j).name), strcat(compSrcFolder,'/'));
                end
                
                a2l_filelist = dir(strcat(CodeGenFolder,'/slprj/ert/',compName,'/*.a2l'));
                for j = 1 : length(a2l_filelist)
                    copyfile(strcat(a2l_filelist(j).folder,'/',a2l_filelist(j).name), strcat(CodeGenFolder,'/06_A2L/'));
                end
            end
        end
    end
end
clear