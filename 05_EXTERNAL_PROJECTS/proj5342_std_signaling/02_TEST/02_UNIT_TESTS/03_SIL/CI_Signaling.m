ModelName = 'Signaling_Model_Run';
DDName = 'Signaling_Sldd_Test.sldd';
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
     if(i <= length(blocks))
         Simulink.ModelReference.refresh(blocks{i});
     end

    close_system(RefModels{i});
end 