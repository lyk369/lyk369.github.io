% Script Version : 1.3.0
if exist('packageName','var') == 0
    packageName = 'Hepta_V2.0.0';
end

packageDir = strcat('./',packageName);
if exist(packageDir, 'dir')
    rmdir(packageDir,'s');
end

mkdir(packageDir);

% Handle Doc Folder
copyfile('./03_DOC/03_TRACEBILITY',strcat(packageDir,'/01_DOC/03_TRACEBILITY'),'f');
copyfile('./03_DOC/04_SMI',strcat(packageDir,'/01_DOC/01_SMI'),'f');
copyfile('./03_DOC/05_MDF',strcat(packageDir,'/01_DOC/02_MDF'),'f');

% Handle Test Folder

% Handle static tests
copyfile('./02_TEST/01_STATIC/01_VMAAC',strcat(packageDir,'/02_TEST/01_STATIC/01_VMAAC'),'f');
copyfile('./02_TEST/01_STATIC/02_KLOCWORK',strcat(packageDir,'/02_TEST/01_STATIC/02_KLOCWORK'),'f');

% Handle unit tests
copyfile('./02_TEST/02_UNIT_TESTS/01_TEST_CASES',strcat(packageDir,'/02_TEST/01_UNIT_TESTS/01_TEST_CASES'),'f');

filelist = dir(fullfile('./02_TEST/02_UNIT_TESTS/02_MIL/Sentinel_Output', '**\*.*'));
numel = size(filelist,1);
for x = 1:numel
    if(strcmp(filelist(x).name, 'Report') && (filelist(x).isdir == 1))
        tempPath = extractAfter(filelist(x).folder, '02_MIL\');
        copyfile(filelist(x).folder,strcat(packageDir,'/02_TEST/02_UNIT_TESTS/02_MIL/',tempPath),'f');
    end
end

filelist = dir(fullfile('./02_TEST/02_UNIT_TESTS/03_SIL/Sentinel_Output', '**\*.*'));
numel = size(filelist,1);
for x = 1:numel
    if(strcmp(filelist(x).name, 'Report') && (filelist(x).isdir == 1))
        tempPath = extractAfter(strcat(filelist(x).folder,'/',filelist(x).name), '03_SIL\');
        copyfile(strcat(filelist(x).folder,'/',filelist(x).name),strcat(packageDir,'/02_TEST/02_UNIT_TESTS/03_SIL/',tempPath),'f');
    end
end

filelist = dir(fullfile('./02_TEST/02_UNIT_TESTS/04_PIL/Sentinel_Output', '**\*.*'));
numel = size(filelist,1);
for x = 1:numel
    if(strcmp(filelist(x).name, 'Report') && (filelist(x).isdir == 1))
        tempPath = extractAfter(strcat(filelist(x).folder,'/',filelist(x).name), '04_PIL\');
        copyfile(strcat(filelist(x).folder,'/',filelist(x).name),strcat(packageDir,'/02_TEST/02_UNIT_TESTS/04_PIL/',tempPath),'f');
    end
end

% Handle integration tests
copyfile('./02_TEST/03_INTEGRATION_TESTS/01_TEST_CASES',strcat(packageDir,'/02_TEST/03_INTEGRATION_TESTS/01_TEST_CASES'),'f');

filelist = dir(fullfile('./02_TEST/03_INTEGRATION_TESTS/02_MIL/Sentinel_Output', '**\*.*'));
numel = size(filelist,1);
for x = 1:numel
    if(strcmp(filelist(x).name, 'Report') && (filelist(x).isdir == 1))
        tempPath = extractAfter(filelist(x).folder, '02_MIL\');
        copyfile(filelist(x).folder,strcat(packageDir,'/02_TEST/03_INTEGRATION_TESTS/02_MIL/',tempPath),'f');
    end
end

filelist = dir(fullfile('./02_TEST/03_INTEGRATION_TESTS/03_SIL/Sentinel_Output', '**\*.*'));
numel = size(filelist,1);
for x = 1:numel
    if(strcmp(filelist(x).name, 'Report') && (filelist(x).isdir == 1))
        tempPath = extractAfter(strcat(filelist(x).folder,'/',filelist(x).name), '03_SIL\');
        copyfile(strcat(filelist(x).folder,'/',filelist(x).name),strcat(packageDir,'/02_TEST/03_INTEGRATION_TESTS/03_SIL/',tempPath),'f');
    end
end

filelist = dir(fullfile('./02_TEST/03_INTEGRATION_TESTS/04_PIL/Sentinel_Output', '**\*.*'));
numel = size(filelist,1);
for x = 1:numel
    if(strcmp(filelist(x).name, 'Report') && (filelist(x).isdir == 1))
        tempPath = extractAfter(strcat(filelist(x).folder,'/',filelist(x).name), '04_PIL\');
        copyfile(strcat(filelist(x).folder,'/',filelist(x).name),strcat(packageDir,'/02_TEST/03_INTEGRATION_TESTS/04_PIL/',tempPath),'f');
    end
end

% Handle CodeGen Folder
copyfile('./06_CODE_GEN/01_STUBS',strcat(packageDir,'/03_CODE_GEN/01_STUBS'),'f');
copyfile('./06_CODE_GEN/02_CODE',strcat(packageDir,'/03_CODE_GEN/02_CODE'),'f');
copyfile('./06_CODE_GEN/03_SHARED_UTILS',strcat(packageDir,'/03_CODE_GEN/03_SHARED_UTILS'),'f');
copyfile('./06_CODE_GEN/04_REPORT',strcat(packageDir,'/03_CODE_GEN/04_REPORT'),'f');
copyfile('./06_CODE_GEN/05_DLL',strcat(packageDir,'/03_CODE_GEN/05_DLL'),'f');
copyfile('./06_CODE_GEN/06_A2L',strcat(packageDir,'/03_CODE_GEN/06_A2L'),'f');

% Remove all .gitkeep and .gitignore
filelist = dir(fullfile(packageDir, '**\*.*'));
numel = size(filelist,1);
for x = 1:numel
    if((filelist(x).isdir == 0) && (strcmp(filelist(x).name, '.gitkeep') || strcmp(filelist(x).name, '.gitignore')))
        delete(strcat(filelist(x).folder,'\',filelist(x).name));
    end
end

zip(strcat(packageName,'.zip'), packageDir);
rmdir(packageDir,'s');
