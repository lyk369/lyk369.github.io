%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor : Omar Ashraf
% Modified by: -
% Version : 1
% Description : Creating an SMI from the SLDD.
% Inputs :
%           * SLDD to be described in FileName
%           * Model name in Model
%           * Header to be described in HeaderFile
%           * Output .xlsx file name
%
% Outputs :
%           * SMI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FileName = 'StdAnimation_DD.sldd';
Model='StdAnimation';
HeaderFile = 'ANIM_cfg.h';
Output = 'SLDD_Parameters.xlsx';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Scanning Model I/O's %%
load_system(Model);
System=find_system(Model);
sysIns = find_system(Model,'SearchDepth',1,'BlockType','Inport');
sysOuts = find_system(Model,'SearchDepth',1,'BlockType','Outport');
InportNames  = get_param(sysIns, 'Name');
OutportNames  = get_param(sysOuts, 'Name');
for i=1:length(sysIns)
    if strcmp(InportNames{i,1}(1:3),'ANI')
        Runnables{i,1}=InportNames{i,1};
        InportNames{i,1}=[];
        continue
    else
       Gets{i,1}=strcat('get_',InportNames{i,1},'('); 
    end 
end
for i=1:length(sysOuts)
Sets{i,1}=strcat('set_',OutportNames{i,1},'(');
end
InportNames=InportNames(~cellfun('isempty',InportNames));
Gets=Gets(~cellfun('isempty',Gets));
Runnables=Runnables(~cellfun('isempty',Runnables));
myDictionaryObj = Simulink.data.dictionary.open(FileName);
dDataSectObj = getSection(myDictionaryObj,'Design Data');
exportToFile(dDataSectObj,'temp.mat');
load('temp.mat');
ParamName = who('-file','temp.mat');
isv_idx=1;osv_idx=1;psv_idx=1;con_idx=1;pv_idx=1;runnable_idx=1;


for i = 1:length(ParamName)
    v_name=char(ParamName(i));
    if(strcmp(class(eval([v_name])),'Simulink.Signal'))
        if(strcmp(eval([v_name]).CoderInfo.CustomStorageClass,'GetSet'))
            if any(strcmp(InportNames,v_name))
                Index = find(strcmp(InportNames,v_name));
%% Input Signals %%                
                isv_name{isv_idx}=v_name;
                isv_datatype{isv_idx}=eval([v_name,'.DataType']);
                isv_dimensions{isv_idx}=mat2str(eval([v_name,'.Dimensions']));
                isv_init{isv_idx} = eval([v_name,'.InitialValue']);
                isv_min{isv_idx} = eval([v_name,'.Min']);
                isv_max{isv_idx} = eval([v_name,'.Max']);
                isv_units{isv_idx} = eval([v_name,'.DocUnits']);
                isv_description{isv_idx}=eval([v_name,'.Description']);
                isv_stclass{isv_idx}='GetSet';
                isv_header{isv_idx}=HeaderFile;
                if str2num(isv_dimensions{isv_idx})>1
                    if contains(isv_datatype{isv_idx},'fixdt')
                        isv_getfun{isv_idx}=strcat('uint',isv_datatype{isv_idx}(9:10),'_T'," ",Gets{Index,1},'uint8_T index)');
                    else
                        isv_getfun{isv_idx}=strcat(isv_datatype{isv_idx},'_T '," ",Gets{Index,1},'uint8_T index)');
                    end
                else
                    if contains(isv_datatype{isv_idx},'fixdt')
                        isv_getfun{isv_idx}=strcat('uint',osv_datatype{osv_idx}(9:10),'_T'," ",Gets{Index,1},')');
                    elseif contains(isv_datatype{isv_idx},'Bus:')
                        isv_getfun{isv_idx}=strcat(strip(erase(isv_datatype{isv_idx},'Bus:'))," ",Gets{Index,1},')');
                    else
                        isv_getfun{isv_idx}=strcat(isv_datatype{isv_idx},'_T '," ",Gets{Index,1},')');
                    end
                end
                isv_idx=isv_idx+1;
            else    
%% Output Signals%%
                Index = find(strcmp(OutportNames,v_name));
                osv_name{osv_idx}=v_name;
                osv_datatype{osv_idx}=eval([v_name,'.DataType']);
                osv_dimensions{osv_idx}=mat2str(eval([v_name,'.Dimensions']));
                osv_init{osv_idx} = eval([v_name,'.InitialValue']);
                osv_min{osv_idx} = eval([v_name,'.Min']);
                osv_max{osv_idx} = eval([v_name,'.Max']);
                osv_units{osv_idx} = eval([v_name,'.DocUnits']);
                osv_description{osv_idx}=eval([v_name,'.Description']);
                osv_stclass{osv_idx}='GetSet';
                osv_header{osv_idx}=HeaderFile;
                if str2num(osv_dimensions{osv_idx})>1
                    if contains(osv_datatype{osv_idx},'fixdt')
                    osv_setfun{osv_idx}=strcat('void '," ",Sets{Index,1},'uint8_T index'," ",',uint',osv_datatype{osv_idx}(9:10),'_T value)');
                    else
                    osv_setfun{osv_idx}=strcat('void '," ",Sets{Index,1},'uint8_T index'," ",',',osv_datatype{osv_idx},'_T'," ",'value)');
                    end
                    
                else
                    if contains(osv_datatype{osv_idx},'fixdt')
                    osv_setfun{osv_idx}=strcat('void '," ",Sets{Index,1},',uint',osv_datatype{osv_idx}(9:10),'_T value)');
                    else
                    osv_setfun{osv_idx}=strcat('void '," ",Sets{Index,1},osv_datatype{osv_idx},'_T'," ",'value)');
                    end
                end
                osv_idx=osv_idx+1;
 
            end
            
           
            
        else
            
%% Private Signals %%
            psv_name{psv_idx}=v_name;
            psv_datatype{psv_idx}=eval([v_name,'.DataType']);
            psv_dimensions{psv_idx}=mat2str(eval([v_name,'.Dimensions']));
            psv_init{psv_idx} = eval([v_name,'.InitialValue']);
            psv_min{psv_idx} = eval([v_name,'.Min']);
            psv_max{psv_idx} = eval([v_name,'.Max']);
            psv_units{psv_idx} = eval([v_name,'.Unit']);
            psv_description{psv_idx}=eval([v_name,'.Description']);
            psv_idx=psv_idx+1;
        end
    end 
    
%% Constants %%    
    if(strcmp(class(eval([v_name])),'Simulink.Parameter'))
        if(strcmp(eval([v_name]).CoderInfo.StorageClass,'Custom'))
            con_name{con_idx}=v_name;
            con_value{con_idx}=mat2str(eval([v_name,'.Value']));
            con_dimensions{con_idx}=mat2str(eval([v_name,'.Dimensions']));
            con_datatype{con_idx}=eval([v_name,'.DataType']);
            con_min{con_idx} = eval([v_name,'.Min']);
            con_max{con_idx} = eval([v_name,'.Max']);
            con_units{con_idx} = eval([v_name,'.DocUnits']);
            con_description{con_idx}=eval([v_name,'.Description']);
            con_stclass{con_idx}=eval([v_name,'.CoderInfo.CustomStorageClass']);
            con_header{con_idx}=eval([v_name,'.CoderInfo.CustomAttributes.HeaderFile']);
            con_idx=con_idx+1;
        else
            
%% Configuration Parameters %%
            pv_name{pv_idx}=v_name;
            pv_value{pv_idx}=mat2str(eval([v_name,'.Value']));
            pv_dimensions{pv_idx}=mat2str(eval([v_name,'.Dimensions']));
            pv_datatype{pv_idx}=eval([v_name,'.DataType']);
            pv_min{pv_idx} = eval([v_name,'.Min']);
            pv_max{pv_idx} = eval([v_name,'.Max']);
            pv_units{pv_idx} = eval([v_name,'.DocUnits']);
            pv_description{pv_idx}=eval([v_name,'.Description']);
            pv_stclass{pv_idx}=eval([v_name,'.CoderInfo.StorageClass']);
            pv_header{pv_idx}=HeaderFile;
            pv_idx=pv_idx+1;
        end
    end
end

%% BUS %%
entries_bus=find(dDataSectObj, '-value', '-class', 'Simulink.Bus');
% produce cell array of Simulink.Bus objects:
buses = arrayfun(@(x) getValue(x), entries_bus, 'UniformOutput', false);
buses_names = arrayfun(@(x) x.Name, entries_bus, 'UniformOutput', false);
% produce a cell array of cell arrays of Simulink.BusElement objects:
elements = cellfun(@(x) x.Elements, buses,  'UniformOutput', false); 
% produce a cell array of cell arrays of element names:
element_names = getElementNames(elements);
element_types = getElementTypes(elements);
out_index=1;
for i=1:length(buses_names)
    Bus_name{out_index}=buses_names{i};
    Bus_dim{out_index}=length(element_names{i});
    for inner_index=1:length(element_names{i})
    Bus_elem_name{out_index}=element_names{i}{inner_index};
    Bus_elem_type{out_index}=element_types{i}{inner_index};
    out_index=out_index+1;
    end
end
%     Bus_name{out_index-1}='';
%     Bus_dim{out_index-1}='';
    

%% Transposing cell arrays and assigning them to the table columns %%

ISignal_Name=isv_name';
ISignal_DataType=isv_datatype';
ISignal_Dimensions=isv_dimensions';
ISignal_Initial=isv_init';
ISignal_Min=isv_min';
ISignal_Max=isv_max';
ISignal_Units=isv_units';
ISignal_Description=isv_description';
ISignal_StClass=isv_stclass';
ISignal_Header=isv_header';
ISignal_GetFunction=isv_getfun';

OSignal_Name=osv_name';
OSignal_DataType=osv_datatype';
OSignal_Dimensions=osv_dimensions';
OSignal_Initial=osv_init';
OSignal_Min=osv_min';
OSignal_Max=osv_max';
OSignal_Units=osv_units';
OSignal_Description=osv_description';
OSignal_StClass=osv_stclass';
OSignal_Header=osv_header';
OSignal_SetFunction=osv_setfun';

% PrivateSignal_Name=psv_name';
% PrivateSignal_DataType=psv_datatype';
% PrivateSignal_Dimensions=psv_dimensions';
% PrivateSignal_Initial=psv_init';
% PrivateSignal_Min=psv_min';
% PrivateSignal_Max=psv_max';
% PrivateSignal_Units=psv_units';
% PrivateSignal_Description=psv_description';

Constant_Name=con_name';
Constant_Value=con_value';
Constant_DataType=con_datatype';
Constant_Dimensions=con_dimensions';
Constant_Min=con_min';
Constant_Max=con_max';
Constant_Units=con_units';
Constant_Description=con_description';
Constant_StorageClass=con_stclass';
Constant_Header=con_header';

Parameter_Name=pv_name';
Parameter_Value=pv_value';
Parameter_DataType=pv_datatype';
Parameter_Dimensions=pv_dimensions';
Parameter_Min=pv_min';
Parameter_Max=pv_max';
Parameter_Units=pv_units';
Parameter_Description=pv_description';
Parameter_StorageClass=pv_stclass';
Parameter_Header=pv_header';

% Bus_Name=Bus_name';
% Bus_Element_Name=Bus_elem_name';
% Bus_Element_Type=Bus_elem_type';
% Bus_Dimensions=Bus_dim';


%% Sheets & Table creation %%

isv_table=table(ISignal_Name,ISignal_DataType,ISignal_Dimensions,ISignal_Initial,ISignal_Min,ISignal_Max,ISignal_Units,ISignal_Description,ISignal_StClass,ISignal_Header,ISignal_GetFunction);
osv_table=table(OSignal_Name,OSignal_DataType,OSignal_Dimensions,OSignal_Initial,OSignal_Min,OSignal_Max,OSignal_Units,OSignal_Description,OSignal_StClass,OSignal_Header,OSignal_SetFunction);
% psv_table=table(PrivateSignal_Name,PrivateSignal_DataType,PrivateSignal_Dimensions,PrivateSignal_Initial,PrivateSignal_Min,PrivateSignal_Max,PrivateSignal_Units,PrivateSignal_Description);
con_table=table(Constant_Name,Constant_Value,Constant_Dimensions,Constant_DataType,Constant_Min,Constant_Max,Constant_Units,Constant_Description,Constant_StorageClass,Constant_Header);
pv_table=table(Parameter_Name,Parameter_Value,Parameter_Dimensions,Parameter_DataType,Parameter_Min,Parameter_Max,Parameter_Units,Parameter_Description,Parameter_StorageClass,Parameter_Header);
run_table=table(Runnables);
% bus_table=table(Bus_Name,Bus_Element_Name,Bus_Element_Type,Bus_Dimensions);

writetable(isv_table,Output,'Sheet','Inputs');
writetable(osv_table,Output,'Sheet','Outputs');
writetable(run_table,Output,'Sheet','Runnables');
% writetable(psv_table,Output,'Sheet','PrivateSignals');
writetable(pv_table,Output,'Sheet','Parameters');
writetable(con_table,Output,'Sheet','Constants');
% writetable(bus_table,Output,'Sheet','Bus');


%% Functions returning a cell array of bus element properties

function names = getElementNames(arrayOfElements)
    function names = busElementNames(busElement)
      if (length(busElement)<1)
        errordlg('There is a bus with zero elements.')
      elseif (length(busElement)==1)
        names{1}{1} = busElement;
      else
        names = arrayfun(@(x) x.Name, busElement, 'UniformOutput', false);
      end
    end
  names = cellfun(@busElementNames, arrayOfElements, 'UniformOutput', false);
end

function types = getElementTypes(arrayOfElements)
    function types = busElementTypes(busElement)
      if (length(busElement)<1)
        errordlg('There is a bus with zero elements.')
      elseif (length(busElement)==1)
        types{1}{1} = busElement.Name;
      else
        types = arrayfun(@(x) x.DataType, busElement, 'UniformOutput', false);
      end
    end
  types = cellfun(@busElementTypes, arrayOfElements, 'UniformOutput', false);
end