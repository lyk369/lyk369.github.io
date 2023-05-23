classdef ValeoSimulinkLibrary

    
    % ValeoSimulinkLibrary is a Class used to handle masks of Valeo Simulink 
    %library blocks
    %       Version        Author                  Date             Modification
    %       -------------------------------------------------------------------------
    %         1.0       Karim Rostom            15-Jun-2015          Creation
    %         1.1       Bruno Montané          13-Oct-2015          Evolution for TargetLink use
    %         1.2       Sasidhar Duggireddy     10-jan-2019          Counter updates with respect to embedded coder
    %         1.3       Sasidhar Duggireddy     16-may-2019          Failure counter memoraisation added with respect to embedded coder
    %         1.4       Ahlem Askri             01-aug-2019          Sliding Average Filter and Decouncing Block are added 
    
    properties
    end
    
     methods
        
        function obj = ValeoSimulinkLibrary
        end
     
     end
     
    methods (Static)
        

        function DetectSat_ReversedPolarity(currentblock)
            
            % <BMO 20151013> <Library Used (Simulink or TargetLink)>
            if (strcmp(get_param(currentblock,'LibType'),'Simulink_Library'))
                MyLibraryUtilities = 'Valeo_Simulink_Library_EC/Utilities';
            elseif (strcmp(get_param(currentblock,'LibType'),'TargetLink_Library'))
                MyLibraryUtilities = 'Valeo_TargetLink_Library/Utilities';
            end

            % implement reversed polarity mode for the block
                BSatMaxFrom = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType', 'From','Name','SatMax_From2');
               
                % check if reversed polarity is allowed or not
                if  (isempty(BSatMaxFrom) && strcmpi(get_param(currentblock,'EnableRevThreshold'),'Yes'))
                    
                    delete_line(currentblock,'SatMin_From2/1','MinMax1/2')
                    delete_line(currentblock,'SatMax_From1/1','MinMax2/1')

                    MaxBlockPosition = get_param([currentblock,'/MinMax1'],'position');
                    factor1 = [325 105 325 105];

                    NewMaxPosition = MaxBlockPosition - factor1;
                    factor2 =[0 130 0 130];
                    NewMinPosition = NewMaxPosition + factor2;
                    
                    % add new Max and new Min blocks
                    % <BMO 20151013>
                    add_block(strcat(MyLibraryUtilities,'/Max'),[currentblock,'/Max'],'position',NewMaxPosition);
                    add_block(strcat(MyLibraryUtilities,'/Min'),[currentblock,'/Min'],'position',NewMinPosition);
%                     add_block('Valeo_Simulink_Library_EC/Utilities/Max',[currentblock,'/Max'],'position',NewMaxPosition);
%                     add_block('Valeo_Simulink_Library_EC/Utilities/Min',[currentblock,'/Min'],'position',NewMinPosition);

                    SatMaxPosition = get_param([currentblock,'/SatMax_From1'],'position');
                    factor3 = [0 25 0 25];%[1 0.959677419 1 0.9609375];
                    factor4 = [0 25 0 25];%[1 1.04032258 1 1.0390625]; 
                    NewSatMaxPosition1 = SatMaxPosition - factor3;%[1 0.959677 1 0.9609375]
                    NewSatMinPosition1 = SatMaxPosition + factor4;%[1 1.0403226 1 1.0390625] 

                    SatMinPosition = get_param([currentblock,'/SatMin_From2'],'position');
                    factor5 = [1 0.9666667 1 0.9675325];%[0 25 0 25];
                    factor6 = [1 1.0333333 1 1.0324675];
                    NewSatMaxPosition2 = SatMinPosition .* factor5;%[1 0.9666667 1 0.9675325]
                    NewSatMinPosition2 = SatMinPosition .* factor6;%[1 1.0333333 1 1.0324675]

                    set_param([currentblock,'/SatMax_From1'], 'Position',NewSatMaxPosition1);
                    set_param([currentblock,'/SatMin_From2'], 'Position',NewSatMinPosition2);
                    add_block('built-in/From',[currentblock,'/SatMax_From2'],'position',NewSatMaxPosition2,...
                            'ShowName','off','GotoTag','SatMax','BackgroundColor','lightBlue');
                    add_block('built-in/From',[currentblock,'/SatMin_From1'],'position',NewSatMinPosition1,...
                            'ShowName','off','GotoTag','SatMin','BackgroundColor','yellow');
                    
                    % connect inputs and outputs of the added Max and Min
                    % blocks
                    add_line(currentblock,'SatMax_From1/1','Max/1','autorouting','on');
                    add_line(currentblock,'SatMax_From2/1','Min/1','autorouting','on');

                    add_line(currentblock,'SatMin_From1/1','Max/2','autorouting','on');
                    add_line(currentblock,'SatMin_From2/1','Min/2','autorouting','on');

                    add_line(currentblock,'Min/1','MinMax1/2','autorouting','on');
                    add_line(currentblock,'Max/1','MinMax2/1','autorouting','on');

                    % connect low threshold relational operator with the
                    % minimal saturation value 
                    % connect high threshold relational operator with the
                    % maximal saturation value 
                    
                    delete_line(currentblock,'SatMax_From/1','RO3/2');
                    delete_line(currentblock,'SatMin_From/1','RO1/2');
                    delete_block([currentblock,'/SatMax_From']);
                    delete_block([currentblock,'/SatMin_From']);
                    
                    add_line(currentblock,'Max/1','RO3/2','autorouting','on');
                    add_line(currentblock,'Min/1','RO1/2','autorouting','on');
                    
                    % Enable Reversed Polarity Flag mask config
                    MaskParameters = Simulink.Mask.get(currentblock);
                    RevThrParameter = MaskParameters.Parameters(4);
                    RevThrParameter.Enabled='on';
                    
                end

                
                
        end
        
        function DetectSat_NormalMode(currentblock)
               
                BSatMaxFrom = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType', 'From','Name','SatMax_From2');
                % check if reversed polarity is allowed or not
                if (~isempty(BSatMaxFrom) && strcmpi(get_param(currentblock,'EnableRevThreshold'),'No'))
                    
                    % delete Min and Max blocks 
                    delete_line(currentblock,'SatMax_From1/1','Max/1');
                    delete_line(currentblock,'SatMax_From2/1','Min/1');
                    
                    delete_line(currentblock,'SatMin_From1/1','Max/2');
                    delete_line(currentblock,'SatMin_From2/1','Min/2');

                    delete_line(currentblock,'Max/1','MinMax2/1');
                    delete_line(currentblock,'Min/1','MinMax1/2');
                    
                    delete_line(currentblock,'Max/1','RO3/2');
                    delete_line(currentblock,'Min/1','RO1/2');

                    delete_block([currentblock,'/Max']);
                    delete_block([currentblock,'/Min']);

                    SatMaxPosition = get_param([currentblock,'/SatMax_From1'],'position');
                    factor3 = [0 25 0 25];%[1 1.04032258 1  1.0390625]
                    NewSatMaxPosition = SatMaxPosition + factor3;

                    SatMinPosition = get_param([currentblock,'/SatMin_From2'],'position');
                    factor4 = [1 0.967742 1 0.96855346];%[0 25 0 25]
                    NewSatMinPosition = SatMinPosition .* factor4;
                    
                    %connect SatMin and SatMax directly
                    set_param([currentblock,'/SatMax_From1'], 'Position',NewSatMaxPosition);
                    set_param([currentblock,'/SatMin_From2'], 'Position',NewSatMinPosition);

                    add_line(currentblock,'SatMax_From1/1','MinMax2/1','autorouting','on');
                    add_line(currentblock,'SatMin_From2/1','MinMax1/2','autorouting','on');

                    delete_block([currentblock,'/SatMin_From1']);
                    delete_block([currentblock,'/SatMax_From2']);
                    
                    SatMaxPosition1 = get_param([currentblock,'/Input_From2'],'position');
                    SatMinPosition1 = get_param([currentblock,'/Input_From3'],'position');
                    factor5 = [0 30 0 30];
                    NewSatMinPosition1 = SatMinPosition1 + factor5;
                    NewSatMaxPosition1 = SatMaxPosition1 + factor5;
                    
                    add_block('built-in/From',[currentblock,'/SatMax_From'],'position',NewSatMaxPosition1,...
                            'ShowName','off','GotoTag','SatMax','BackgroundColor','lightBlue');
                    add_block('built-in/From',[currentblock,'/SatMin_From'],'position',NewSatMinPosition1,...
                            'ShowName','off','GotoTag','SatMin','BackgroundColor','yellow');

                    add_line(currentblock,'SatMax_From/1','RO3/2','autorouting','on');
                    add_line(currentblock,'SatMin_From/1','RO1/2','autorouting','on');
                    
                    % terminate ReversedThr 
                    replace_block([currentblock,'/ReversedThr'],'Outport','Terminator','noprompt');
                    
                    % disable reversed polarity  flag mask config
                    MaskParameters = Simulink.Mask.get(currentblock);
                    RevThrParameter = MaskParameters.Parameters(4);
                    RevThrParameter.Enabled='off';
                    RevThrParameter.Value='off';
                    
                end
                

        end
        
        
        function DetectSat_View_Terminate(currentblock)
                
               
                BHitMax = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType', 'Outport','Name','HitMax');
                BHitMin = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType', 'Outport','Name','HitMin');
                BOut = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType', 'Outport','Name','Out');
                BRevThr = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType', 'Outport','Name','ReversedThr');

                BTHitMax = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType', 'Terminator','Name','HitMax');
                BTHitMin = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType', 'Terminator','Name','HitMin');
                BTOut = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType', 'Terminator','Name','Out');
                BTRevThr = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType', 'Terminator','Name','ReversedThr');

                %%Replacment of terminators by output ports and vice versa
                % depending on the options checked in the mask of the block

                % Case n1 : Hitmax is not checked and its outport exists
                if (~isempty(BHitMax) && strcmp(get_param(currentblock,'FlagHitMax'),'off'))
                        replace_block([currentblock,'/HitMax'],'Outport','Terminator','noprompt');
                end

                % Case n2 : Hitmax is checked and its outport doesn't exist
                if (~isempty(BTHitMax) && strcmp(get_param(currentblock,'FlagHitMax'),'on'))
                        replace_block([currentblock,'/HitMax'],'Terminator','Outport','noprompt');
                        set_param([currentblock,'/HitMax'],'BackgroundColor','orange'); %BL
                end

                % case n3 : Hitmin is not checked and its outport exists
                if (~isempty(BHitMin) && strcmp(get_param(currentblock,'FlagHitMin'),'off'))
                        replace_block([currentblock,'/HitMin'],'Outport','Terminator','noprompt');
                end

                % case n4 : HitMin is checked and its outport doesn't exist
                if (~isempty(BTHitMin) && strcmp(get_param(currentblock,'FlagHitMin'),'on'))
                        replace_block([currentblock,'/HitMin'],'Terminator','Outport','noprompt');
                        set_param([currentblock,'/HitMin'],'BackgroundColor','orange'); %BL
                end

                % case n5 : Out is not checked and its outport exists
                if (~isempty(BOut) && strcmp(get_param(currentblock,'FlagOut'),'off'))
                    replace_block([currentblock,'/Out'],'Outport','Terminator','noprompt');
                end

                % case n6 : Out is checked and its outport doesn't exist
                if (~isempty(BTOut) && strcmp(get_param(currentblock,'FlagOut'),'on'))
                    replace_block([currentblock,'/Out'],'Terminator','Outport','noprompt');
                    set_param([currentblock,'/Out'],'BackgroundColor','orange'); %BL
                end
                
                % case n7 : ReversedThr is not checked and its outport exists
                if (~isempty(BRevThr) && strcmp(get_param(currentblock,'FlagRevThr'),'off'))
                    replace_block([currentblock,'/ReversedThr'],'Outport','Terminator','noprompt');
                end

                % case n8 : ReversedThr is checked and its outport doesn't exist
                if (~isempty(BTRevThr) && strcmp(get_param(currentblock,'FlagRevThr'),'on'))
                    replace_block([currentblock,'/ReversedThr'],'Terminator','Outport','noprompt');
                    set_param([currentblock,'/ReversedThr'],'BackgroundColor','orange'); %BL
                end
                
        
        end
         
        function DetectSat_SortOutports(currentblock)
                 
                % sorting outports
 
                % case 1: HitMax flag is checked , HitMin is not checked ,Out is checked
                if  strcmp(get_param(currentblock,'FlagHitMin'),'off') && strcmp(get_param(currentblock,'FlagHitMax'),'on') && strcmp(get_param(currentblock,'FlagOut'),'on')
                    set_param([currentblock,'/HitMax'],'Port','1');
                    set_param([currentblock,'/Out'],'Port','2');

                % case 2: HitMin flag is checked , HitMax is not checked ,Out is checked
                elseif strcmp(get_param(currentblock,'FlagHitMin'),'on') && strcmp(get_param(currentblock,'FlagHitMax'),'off') && strcmp(get_param(currentblock,'FlagOut'),'on')
                    set_param([currentblock,'/HitMin'],'Port','2');
                    set_param([currentblock,'/Out'],'Port','1');

                % case 3: HitMax flag is checked , HitMin is checked ,Out is checked
                elseif strcmp(get_param(currentblock,'FlagHitMin'),'on') && strcmp(get_param(currentblock,'FlagHitMax'),'on') && strcmp(get_param(currentblock,'FlagOut'),'on')
                    set_param([currentblock,'/HitMax'],'Port','1');
                    set_param([currentblock,'/Out'],'Port','2');
                    set_param([currentblock,'/HitMin'],'Port','3');

                % case 4: HitMin flag is not checked , HitMax is not checked , Out is checked         
                elseif strcmp(get_param(currentblock,'FlagHitMin'),'off') && strcmp(get_param(currentblock,'FlagHitMax'),'off') && strcmp(get_param(currentblock,'FlagOut'),'on')
                    set_param([currentblock,'/Out'],'Port','1');

                % case 5:  HitMin flag is checked , HitMax is checked ,Out is not checked  
                elseif strcmp(get_param(currentblock,'FlagHitMin'),'on') && strcmp(get_param(currentblock,'FlagHitMax'),'on') && strcmp(get_param(currentblock,'FlagOut'),'off')
                    set_param([currentblock,'/HitMax'],'Port','1');
                    set_param([currentblock,'/HitMin'],'Port','2');
                end
        end
 %% functions for counter     
        
        function Counter_MaxFlag(currentblock)    % function for counter maximum flag out port (depend on the "view MaxFlag" checkbox )
                BHInc = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Outport','Name','MaxFlag');
                BTHInc = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Terminator','Name','MaxFlag');
                if (~isempty(BHInc) && strcmp(get_param(currentblock,'MaxFlag'),'off'))
                    replace_block([currentblock,'/MaxFlag'],'Outport','Terminator','noprompt');
                end
                if (~isempty(BTHInc) && strcmp(get_param(currentblock,'MaxFlag'),'on'))
                    replace_block([currentblock,'/MaxFlag'],'Terminator','Outport','noprompt');
                    set_param([currentblock,'/MaxFlag'],'BackgroundColor','orange');
                end
        end
        
        function Counter_reset(currentblock)      % function for counter reset input port (depend on the "View Rst" checkbox) 
                BHInc = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Inport','Name','Rst');
                BTHInc = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Ground','Name','Rst');
                if (~isempty(BHInc) && strcmp(get_param(currentblock,'Reset_flag'),'off'))
                    replace_block([currentblock,'/Rst'],'Inport','Ground','noprompt');
                end
                if (~isempty(BTHInc) && strcmp(get_param(currentblock,'Reset_flag'),'on'))
                    replace_block([currentblock,'/Rst'],'Ground','Inport','noprompt');
                    set_param([currentblock,'/Rst'],'BackgroundColor','green');
                end
        end
        
        function Counter_Inc(currentblock)         % function for counter increment inport (depend on the "View Inc" checkbox) 
                BHInc = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Inport','Name','Inc');
                BTHInc = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Constant','Name','Inc');
                if (~isempty(BHInc) && strcmp(get_param(currentblock,'Inc_parm'),'off'))
                    replace_block([currentblock,'/Inc'],'Inport','Constant','noprompt');
                    set_param([currentblock,'/Inc'],'value','1','OutDataTypeStr','Inherit: Inherit via back propagation'); %sahmed1:changed from uint32 to inherit
                    
                end
                if (~isempty(BTHInc) && strcmp(get_param(currentblock,'Inc_parm'),'on'))
                    replace_block([currentblock,'/Inc'],'Constant','Inport','noprompt');
                     set_param([currentblock,'/Inc'],'BackgroundColor','green');
                end
        end     
        
        function Counter_MaxCount(currentblock)     %function for counter maximum count input(depend on the "View MaxCount" checkbox) 
            
                BHInc = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Inport','Name','Count_Max');
                BTHInc = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Constant','Name','Count_Max');
                if ( strcmp(get_param(currentblock,'MaxCntFlag'),'off'))

                    MaskParameters = Simulink.Mask.get(currentblock);
                    MaskParameters.Parameters(5).Visible='on';
                    MaskParameters.Parameters(6).Visible='on';
                    MaskParameters.Parameters(6).Tunable='on';
                    MaskParameters.Parameters(6).Evaluate='on';        
                    replace_block([currentblock,'/Count_Max'],'Inport','Constant','noprompt');
                    Max =  str2num(MaskParameters.Parameters(6).Value);
                    if Max > 4294967295
%                        warning('Cnt_Max cannot exceed 4294967295 !');
                       errordlg('You can count maximum of (2^32)-1 or 4294967295 .                        Please enter the value with in the range','Value exceed! ');
                    end
                    Max = min(Max,4294967295); 
                   
                    set_param([currentblock,'/Count_Max'],'value',num2str(Max),'OutDataTypeStr','Inherit: Inherit via back propagation'); %sahmed1:changed from uint32 to inherit
                 end
                if (~isempty(BTHInc) && strcmp(get_param(currentblock,'MaxCntFlag'),'on'))
                    replace_block([currentblock,'/Count_Max'],'Constant','Inport','noprompt');
                     set_param([currentblock,'/Count_Max'],'BackgroundColor','green');
                     %disable conditions
                     
                   MaskParameters = Simulink.Mask.get(currentblock);
                   MaskParameters.Parameters(5).Visible='on';
                   MaskParameters.Parameters(6).Evaluate='off'; 
                   MaskParameters.Parameters(6).Visible='off';
                 
                end
        end
        
        function Counter_InitialVal(currentblock)      %function for counter initial value input (depend on the "View InitialVal" checkbox) 
                BHInc = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Inport','Name','InitialVal');
                BTHInc = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Ground','Name','InitialVal');
                if (~isempty(BHInc) && strcmp(get_param(currentblock,'InitialFlag'),'off'))
                    replace_block([currentblock,'/InitialVal'],'Inport','Ground','noprompt');
                  
                    
                end
                if (~isempty(BTHInc) && strcmp(get_param(currentblock,'InitialFlag'),'on'))
                    replace_block([currentblock,'/InitialVal'],'Ground','Inport','noprompt');
                     set_param([currentblock,'/InitialVal'],'BackgroundColor','green');
                end
        end      
        
%% Failur counter memorisation  
        function Failure_counter_with_memory(currentblock)
            
            OR2handler = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Logic','Name','OR2');
            DatectSatHandler=find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','SubSystem','Name','DetectSat');
            DataSatConnection=get_param(DatectSatHandler,'PortConnectivity');
            DataBlkName = get_param(DataSatConnection{1,1}(4).DstBlock,'Name');
            BothFlag = 0;
            BothFlag1 = 0;
            if(length(DataBlkName)== 2)
                if((strcmp(DataBlkName(1), 'Failure_Flag')||strcmp(DataBlkName(1), 'Goto'))&&isempty(OR2handler)) % checking Failure_Flag is present in Hit max or not 
                    BothFlag = 1;      % if  Failure_Flag connected to Hit max then Both flag will set 
                    BothFlag1 = 0;
                else
                    if(isempty(OR2handler))
                        BothFlag = 0;
                        BothFlag1 = 1;
                    end
                end
            else    
                if(strcmp(DataBlkName, 'Failure_Flag')&&isempty(OR2handler)) % checking Failure_Flag is present in Hit max or not 
                    BothFlag = 1;      % if  Failure_Flag connected to Hit max then Both flag will set 
                    BothFlag1 = 0;
                else
                    if(isempty(OR2handler))
                        BothFlag = 0;
                        BothFlag1 = 1;
                    end
                end
            end
            
           
%% max value to minimum 
           if((strcmp(get_param(currentblock,'Parameter'),'Minvalue'))&&(isempty(OR2handler))&&BothFlag)
                delete_line(currentblock,'DetectSat/1','Failure_Flag/1');
                delete_line(currentblock,'DetectSat/3','Terminator/1');
                if(strcmp(get_param(currentblock,'FCM'),'on'))
                   delete_line(currentblock,'DetectSat/1','Goto/1');
                   delete_block([currentblock,'/Goto']); 
                end
                delete_block([currentblock,'/Terminator']);
                Terminator_Handle = add_block('simulink/Commonly Used Blocks/Terminator',[currentblock,'/Terminator']);
                set_param(Terminator_Handle,'Position',[920 210 940 230],'ShowName','off');
                add_line(currentblock,'DetectSat/1','Terminator/1','autorouting','on');
                add_line(currentblock,'DetectSat/3','Failure_Flag/1','autorouting','on');

            end
%% both to max val
            if((strcmp(get_param(currentblock,'Parameter'),'Maxvalue'))&&~isempty(OR2handler))
               delete_line(currentblock,'DetectSat/1','OR2/1'); 
               delete_line(currentblock,'DetectSat/3','OR2/2');
               delete_line(currentblock,'OR2/1','And/1');
               delete_line(currentblock,'OR3/1','And/2');
               delete_line(currentblock,'From2/1','OR3/1');
               delete_line(currentblock,'From3/1','OR3/2');
               delete_line(currentblock,'And/1','Failure_Flag/1');              
               if(strcmp(get_param(currentblock,'FCM'),'on'))
                  delete_line(currentblock,'And/1','Goto/1'); 
                  delete_block([currentblock,'/Goto']);
               end
               delete_block([currentblock,'/OR3']);
               delete_block([currentblock,'/And']);
               delete_block([currentblock,'/From2']);
               delete_block([currentblock,'/From3']);
               delete_block([currentblock,'/OR2']);
               add_line(currentblock,'DetectSat/1','Failure_Flag/1','autorouting','on');
               Terminator_Handle = add_block('simulink/Commonly Used Blocks/Terminator',[currentblock,'/Terminator']);
               set_param(Terminator_Handle,'Position',[915 300 935 320],'ShowName','off'); 
               add_line(currentblock,'DetectSat/3','Terminator/1','autorouting','on');
     
            end
%% max to both      
             if((strcmp(get_param(currentblock,'Parameter'),'Both Min Max'))&& BothFlag)
                 delete_line(currentblock,'DetectSat/1','Failure_Flag/1'); 
                 delete_line(currentblock,'DetectSat/3','Terminator/1');
                 if(strcmp(get_param(currentblock,'FCM'),'on'))
                        delete_line(currentblock,'DetectSat/1','Goto/1');
                        delete_block([currentblock,'/Goto']);
                 end
                 delete_block([currentblock,'/Terminator']);
                 Orhandler_Handle = add_block('simulink/Logic and Bit Operations/Logical Operator',[currentblock,'/OR2']);
                 From2HandlerVal =add_block('simulink/Signal Routing/From',[currentblock,'/From2']);
                 From3HandlerVal =add_block('simulink/Signal Routing/From',[currentblock,'/From3']);
                 OR3HandlerVal =add_block('simulink/Logic and Bit Operations/Logical Operator',[currentblock,'/OR3']);
                 AndHandlerVal =add_block('simulink/Logic and Bit Operations/Logical Operator',[currentblock,'/And']);
                 set_param(From2HandlerVal,'Position',[1245 328 1295 342],'GotoTag','En_inc','BackgroundColor','Magenta','ShowName','off');
                 set_param(From3HandlerVal,'Position',[1245 403 1295 417],'GotoTag','En_Dec','BackgroundColor','Magenta','ShowName','off');
                 set_param(OR3HandlerVal,'Position',[1365 357 1395 388],'Operator','OR');
                 set_param(AndHandlerVal,'Position',[1485 247 1515 278],'Operator','AND');
                 add_line(currentblock,'From2/1','OR3/1','autorouting','on');
                 add_line(currentblock,'From3/1','OR3/2','autorouting','on');
                 add_line(currentblock,'OR3/1','And/2','autorouting','on');
                 add_line(currentblock,'OR2/1','And/1','autorouting','on');
                 add_line(currentblock,'And/1','Failure_Flag/1','autorouting','on');
                 %
                 set_param(Orhandler_Handle,'Position',[1195 214 1220 316],'Operator','OR','ShowName','off'); 
                 add_line(currentblock,'DetectSat/1','OR2/1','autorouting','on');
                 add_line(currentblock,'DetectSat/3','OR2/2','autorouting','on');
             end
            
 %% min val to max val 
              if((strcmp(get_param(currentblock,'Parameter'),'Maxvalue'))&&isempty(OR2handler)&& BothFlag1)
                 delete_line(currentblock,'DetectSat/1','Terminator/1');
                 delete_line(currentblock,'DetectSat/3','Failure_Flag/1');
                 if(strcmp(get_param(currentblock,'FCM'),'on'))
                     delete_line(currentblock,'DetectSat/3','Goto/1');
                     delete_block([currentblock,'/Goto'])
                 end
                 delete_block([currentblock,'/Terminator']);
                 Terminator_Handle = add_block('simulink/Commonly Used Blocks/Terminator',[currentblock,'/Terminator']);
                 set_param(Terminator_Handle,'Position',[915 300 935 320],'ShowName','off');
                 add_line(currentblock,'DetectSat/3','Terminator/1','autorouting','on');
                 add_line(currentblock,'DetectSat/1','Failure_Flag/1','autorouting','on');

              end
%%    both to min
              if((strcmp(get_param(currentblock,'Parameter'),'Minvalue'))&&(~isempty(OR2handler)))
                 delete_line(currentblock,'DetectSat/1','OR2/1'); 
                 delete_line(currentblock,'DetectSat/3','OR2/2'); 
                 delete_line(currentblock,'And/1','Failure_Flag/1');
                 if(strcmp(get_param(currentblock,'FCM'),'on'))
                  delete_line(currentblock,'And/1','Goto/1'); 
                  delete_block([currentblock,'/Goto']);
                 end
                 delete_line(currentblock,'OR2/1','And/1');
                 delete_line(currentblock,'OR3/1','And/2');
                 delete_line(currentblock,'From2/1','OR3/1');
                 delete_line(currentblock,'From3/1','OR3/2');
                 delete_block([currentblock,'/OR2']);
                 delete_block([currentblock,'/OR3']);
                 delete_block([currentblock,'/And']);
                 delete_block([currentblock,'/From2']);
                 delete_block([currentblock,'/From3']);
                 Terminator_Handle = add_block('simulink/Commonly Used Blocks/Terminator',[currentblock,'/Terminator']);
                 set_param(Terminator_Handle,'Position',[920 210 940 230],'ShowName','off');
                 add_line(currentblock,'DetectSat/1','Terminator/1','autorouting','on');
                 add_line(currentblock,'DetectSat/3','Failure_Flag/1','autorouting','on');
              end
              
              if((strcmp(get_param(currentblock,'Parameter'),'Both Min Max'))&& BothFlag1 && isempty(OR2handler))
                  delete_line(currentblock,'DetectSat/1','Terminator/1');
                  delete_line(currentblock,'DetectSat/3','Failure_Flag/1');
                  
                  if(strcmp(get_param(currentblock,'FCM'),'on'))
                      delete_line(currentblock,'DetectSat/3','Goto/1');
                      delete_block([currentblock,'/Goto']);
                  end
                  delete_block([currentblock,'/Terminator']);
                  Orhandler_Handle = add_block('simulink/Logic and Bit Operations/Logical Operator',[currentblock,'/OR2']);
                  %
                  From2HandlerVal =add_block('simulink/Signal Routing/From',[currentblock,'/From2']);
                  From3HandlerVal =add_block('simulink/Signal Routing/From',[currentblock,'/From3']);
                  OR3HandlerVal =add_block('simulink/Logic and Bit Operations/Logical Operator',[currentblock,'/OR3']);
                  AndHandlerVal =add_block('simulink/Logic and Bit Operations/Logical Operator',[currentblock,'/And']);
                  set_param(From2HandlerVal,'Position',[1245 328 1295 342],'GotoTag','En_inc','BackgroundColor','Magenta','ShowName','off');
                  set_param(From3HandlerVal,'Position',[1245 403 1295 417],'GotoTag','En_Dec','BackgroundColor','Magenta','ShowName','off');
                  set_param(OR3HandlerVal,'Position',[1365 357 1395 388],'Operator','OR','ShowName','off');
                  set_param(AndHandlerVal,'Position',[1485 247 1515 278],'Operator','AND','ShowName','off');
                  add_line(currentblock,'From2/1','OR3/1','autorouting','on');
                  add_line(currentblock,'From3/1','OR3/2','autorouting','on');
                  add_line(currentblock,'OR3/1','And/2','autorouting','on');
                  add_line(currentblock,'OR2/1','And/1','autorouting','on');
                  add_line(currentblock,'And/1','Failure_Flag/1','autorouting','on');
                  %
                  set_param(Orhandler_Handle,'Position',[1195 214 1220 316],'Operator','OR','ShowName','off'); 
                  add_line(currentblock,'DetectSat/1','OR2/1','autorouting','on');
                  add_line(currentblock,'DetectSat/3','OR2/2','autorouting','on');
              end
             
              Switch2Hand = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Switch','Name','Switch2');
             
              if (isempty(Switch2Hand)&&strcmp(get_param(currentblock,'FCM'),'on'))   
                    ResetBlkHandle = add_block('simulink/Sources/In1',[currentblock,'/Reset_FailureMem']);
                    Failure_Memorisation_Handle = add_block('simulink/Sinks/Out1',[currentblock,'/Failure_Memorisation']);
                    DelayBlkHandle = add_block('simulink/Discrete/Unit Delay',[currentblock,'/Unit_dealy3']);
                    OR_BlkHandle = add_block('simulink/Logic and Bit Operations/Logical Operator',[currentblock,'/OR1']);
                    SwitchBlkHandle = add_block('simulink/Signal Routing/Switch',[currentblock,'/Switch2']);
                    FromHandle = add_block('simulink/Signal Routing/From',[currentblock,'/From']);
                    From1Handle = add_block('simulink/Signal Routing/From',[currentblock,'/From1']);
                    set_param(OR_BlkHandle,'Operator','OR');
                    set_param(SwitchBlkHandle,'Position',[1350 476 1380 694],'Criteria','u2 ~= 0','ShowName','off');
                    set_param(Failure_Memorisation_Handle,'Position',[1780 578 1810 592],'BackgroundColor','Orange','OutDataTypeStr','boolean');
                    set_param(DelayBlkHandle,'Position',[1455 703 1490 737],'Orientation','left','ShowName','off');
                    set_param(ResetBlkHandle,'Position',[5 593 35 607],'BackgroundColor','Green','OutDataTypeStr','boolean');
                    set_param(OR_BlkHandle,'Position',[1195 545 1215 620],'ShowName','off');
                    set_param(From1Handle,'Position',[950 502 1100 528],'GotoTag','Failure_Flag','BackgroundColor','Magenta','ShowName','off');
                    set_param(FromHandle,'Position',[950 552 1100 578],'GotoTag','Failure_Flag','BackgroundColor','Magenta','ShowName','off'); 
                    add_line(currentblock,'Reset_FailureMem/1','OR1/2','autorouting','on');
                    add_line(currentblock,'Switch2/1','Failure_Memorisation/1','autorouting','on');
                    add_line(currentblock,'OR1/1','Switch2/2','autorouting','on');
                    add_line(currentblock,'Unit_dealy3/1','Switch2/3','autorouting','on');
                    add_line(currentblock,'Switch2/1','Unit_dealy3/1','autorouting','on');
                    add_line(currentblock,'From1/1','Switch2/1','autorouting','on');
                    add_line(currentblock,'From/1','OR1/1','autorouting','on');
              end
            
                 if (~isempty(Switch2Hand)&&strcmp(get_param(currentblock,'FCM'),'off'))
                     delete_line(currentblock,'Reset_FailureMem/1','OR1/2');
                     delete_line(currentblock,'Switch2/1','Failure_Memorisation/1');
                     delete_line(currentblock,'OR1/1','Switch2/2');
                     delete_line(currentblock,'Unit_dealy3/1','Switch2/3');
                     delete_line(currentblock,'Switch2/1','Unit_dealy3/1');
                     delete_line(currentblock,'From1/1','Switch2/1');
                     delete_line(currentblock,'From/1','OR1/1');
                     delete_block([currentblock,'/Reset_FailureMem']);
                     delete_block([currentblock,'/Failure_Memorisation']);
                     delete_block([currentblock,'/Unit_dealy3']);
                     delete_block([currentblock,'/Switch2']);
                     delete_block([currentblock,'/From']);
                     delete_block([currentblock,'/From1']);
                     delete_block([currentblock,'/OR1']);
                 end   
                 
  OR2handler = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Logic','Name','OR2');  
  GotoHandler = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Goto','Name','Goto');
  DatectSatHandler=find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','SubSystem','Name','DetectSat');
            DataSatConnection=get_param(DatectSatHandler,'PortConnectivity');
            DataBlkName = get_param(DataSatConnection{1,1}(4).DstBlock,'Name');
            if(length(DataBlkName)== 2)
                if(strcmp(DataBlkName(1), 'Failure_Flag')||strcmp(DataBlkName(1), 'Goto')&&isempty(OR2handler)) % checking Failure_Flag is present in Hit max or not 
                    BothFlag = 1;      % if  Failure_Flag connected to Hit max then Both flag will set 
                    BothFlag1 = 0;
                else
                    if(isempty(OR2handler))
                        BothFlag = 0;
                        BothFlag1 = 1;
                    end
                end
            else    
                if((strcmp(DataBlkName, 'Failure_Flag'))&&isempty(OR2handler)) % checking Failure_Flag is present in Hit max or not 
                    BothFlag = 1;      % if  Failure_Flag connected to Hit max then Both flag will set 
                    BothFlag1 = 0;
                else
                    if(isempty(OR2handler))
                        BothFlag = 0;
                        BothFlag1 = 1;
                    end
                end
            end
             
              if(strcmp(get_param(currentblock,'FCM'),'on')&&isempty(GotoHandler))
                    GotoHandle = add_block('simulink/Signal Routing/Goto',[currentblock,'/Goto']);
                    set_param(GotoHandle,'Position',[1365 152 1515 178],'GotoTag','Failure_Flag','BackgroundColor','Cyan');
                    if(~isempty(OR2handler))
                    add_line(currentblock,'And/1','Goto/1','autorouting','on');
                    end
                    if(isempty(OR2handler)&&BothFlag)
                    add_line(currentblock,'DetectSat/1','Goto/1','autorouting','on');
                    end
                    if(isempty(OR2handler)&&BothFlag1)
                    add_line(currentblock,'DetectSat/3','Goto/1','autorouting','on');
                    end
              end
              if(strcmp(get_param(currentblock,'FCM'),'off')&&~isempty(GotoHandler))
                    if(~isempty(OR2handler))
                        delete_line(currentblock,'And/1','Goto/1');
                        delete_block([currentblock,'/Goto']);
                    end
                    if(isempty(OR2handler)&& BothFlag)
                        delete_line(currentblock,'DetectSat/1','Goto/1');
                        delete_block([currentblock,'/Goto']);
                    end
                    if(isempty(OR2handler)&&BothFlag1)
                        delete_line(currentblock,'DetectSat/3','Goto/1');
                        delete_block([currentblock,'/Goto']);
                    end
                  
              end
             
        end 
        
        function FailureCounterM_Inc_Dec_blk_Rvm(currentblock)
            Switch1Handler = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Switch','Name','Switch1');
            AddHandler = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Sum','Name','Add');
            SubHandler = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Sum','Name','Sub');
            ConstantHandler2 = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Constant','Name','Constant2');
            if((strcmp(get_param(currentblock,'Parameter'),'Maxvalue'))&&~isempty(Switch1Handler))
                delete_line(currentblock,'DEC_Value/1','MinMax1/2');
                delete_line(currentblock,'Constant6/1','MinMax1/1');
                delete_line(currentblock,'MinMax1/1','Switch1/1');
                delete_line(currentblock,'En_DecCounter/1','Switch1/2');
                delete_line(currentblock,'En_DecCounter/1','Goto2/1');
                delete_line(currentblock,'Constant/1','Switch1/3');
                delete_line(currentblock,'Switch1/1','Add1/1');
                delete_line(currentblock,'Add1/1','Switch/3');
                delete_line(currentblock,'Unit_Delay/1','Add1/2');
                delete_line(currentblock,'En_IncCounter/1','Goto1/1'); 
                delete_block([currentblock,'/Add1']);
                delete_block([currentblock,'/Switch1']);
                delete_block([currentblock,'/En_DecCounter']);
                delete_block([currentblock,'/DEC_Value']);
                delete_block([currentblock,'/Constant']);
                delete_block([currentblock,'/Constant6']);
                delete_block([currentblock,'/MinMax1']);
                delete_block([currentblock,'/Goto1']);
                delete_block([currentblock,'/Goto2']);
                
                ConstantHandler =add_block('simulink/Sources/Constant',[currentblock,'/Constant']);
                set_param(ConstantHandler,'Position',[310 370 340 400],'OutDataTypeStr','Inherit: Inherit via back propagation','Value','0','ShowName','off');
                add_line(currentblock,'Constant/1','Switch/3','autorouting','on');
                MaskParameters = Simulink.Mask.get(currentblock);
                MaskParameters.Parameters(2).Visible='off';
                replace_block([currentblock,'/Constant2'],'Constant','Ground','noprompt');
                set_param([currentblock,'/Constant2'],'BackgroundColor','darkGreen','ShowName','off');
                MaskParameters.Parameters(1).Visible='on';
            end
            
            if((strcmp(get_param(currentblock,'Parameter'),'Minvalue'))&&~isempty(AddHandler)&&isempty(Switch1Handler))
                delete_line(currentblock,'En_IncCounter/1','Switch/2');
                delete_line(currentblock,'INC_Value/1','MinMax/2'); 
                delete_line(currentblock,'Constant5/1','MinMax/1'); 
                delete_line(currentblock,'MinMax/1','Add/2'); 
                delete_line(currentblock,'Add/1','Switch/1');
                delete_line(currentblock,'Unit_Delay/1','Add/1');
                delete_block([currentblock,'/Add']);
                delete_block([currentblock,'/En_IncCounter']);
                delete_block([currentblock,'/INC_Value']);
                delete_block([currentblock,'/MinMax']); 
                delete_block([currentblock,'/Constant5']);  
                DecHandlerVal =add_block('simulink/Sources/In1',[currentblock,'/DEC_Value']);
                DEC_CounterHandler =add_block('simulink/Sources/In1',[currentblock,'/En_DecCounter']);
                SubHandler =add_block('simulink/Math Operations/Add',[currentblock,'/Sub']);
                MinMaxHandler =add_block('simulink/Math Operations/MinMax',[currentblock,'/MinMax']); 
                Constant5Handler =add_block('simulink/Sources/Constant',[currentblock,'/Constant5']); 
                set_param(DEC_CounterHandler,'Position',[25 258 55 272],'BackgroundColor','Green','OutDataTypeStr','boolean');
                set_param(DecHandlerVal,'Position',[25 158 55 172],'BackgroundColor','Green');
                set_param(SubHandler,'Position',[400 99 430 186],'Inputs','+-','ShowName','off');
                set_param(MinMaxHandler,'Position',[210 147 240 178],'Function','max','Inputs','2','ShowName','off'); 
                set_param(Constant5Handler,'Position',[110 105 140 135],'OutDataTypeStr','Inherit: Inherit via back propagation','Value','0','ShowName','off'); 
                add_line(currentblock,'Sub/1','Switch/1','autorouting','on');
                add_line(currentblock,'DEC_Value/1','MinMax/2','autorouting','on');
                add_line(currentblock,'Constant5/1','MinMax/1','autorouting','on'); 
                add_line(currentblock,'MinMax/1','Sub/2','autorouting','on'); 
                add_line(currentblock,'En_DecCounter/1','Switch/2','autorouting','on');
                add_line(currentblock,'Unit_Delay/1','Sub/1','autorouting','on');                
                %mask edit
                MaskParameters = Simulink.Mask.get(currentblock);
                MaskParameters.Parameters(1).Visible='off';
                replace_block([currentblock,'/Constant1'],'Constant','Ground','noprompt');
                replace_block([currentblock,'/Constant2'],'Ground','Constant','noprompt');
                set_param([currentblock,'/Constant2'],'BackgroundColor','darkGreen','Value','MIN_CountVal','ShowName','off');
                set_param([currentblock,'/Constant1'],'BackgroundColor','darkGreen','ShowName','off');
                MaskParameters.Parameters(2).Visible='on';
            end
            
            if((strcmp(get_param(currentblock,'Parameter'),'Maxvalue'))&&~isempty(SubHandler))
                delete_line(currentblock,'En_DecCounter/1','Switch/2');
                delete_line(currentblock,'DEC_Value/1','MinMax/2'); 
                delete_line(currentblock,'MinMax/1','Sub/2'); 
                delete_line(currentblock,'Sub/1','Switch/1');
                delete_line(currentblock,'Unit_Delay/1','Sub/1');
                delete_block([currentblock,'/Sub']);
                delete_block([currentblock,'/En_DecCounter']);
                delete_block([currentblock,'/DEC_Value']);
                IncHandlerVal =add_block('simulink/Sources/In1',[currentblock,'/INC_Value']);
                Inc_CounterHandler =add_block('simulink/Sources/In1',[currentblock,'/En_IncCounter']);
                Add1Handler =add_block('simulink/Math Operations/Add',[currentblock,'/Add']);
                set_param(Inc_CounterHandler,'Position',[25 258 55 272],'BackgroundColor','Green','OutDataTypeStr','boolean');
                set_param(IncHandlerVal,'Position',[25 158 55 172],'BackgroundColor','Green');
                set_param(Add1Handler,'Position',[400 99 430 186],'ShowName','off');
                add_line(currentblock,'Add/1','Switch/1','autorouting','on');
                add_line(currentblock,'INC_Value/1','MinMax/2','autorouting','on'); 
                add_line(currentblock,'MinMax/1','Add/2','autorouting','on'); 
                add_line(currentblock,'En_IncCounter/1','Switch/2','autorouting','on');
                add_line(currentblock,'Unit_Delay/1','Add/1','autorouting','on');
                %mask edit
                MaskParameters = Simulink.Mask.get(currentblock);
                MaskParameters.Parameters(2).Visible='off';
                replace_block([currentblock,'/Constant2'],'Constant','Ground','noprompt');
                replace_block([currentblock,'/Constant1'],'Ground','Constant','noprompt');
                set_param([currentblock,'/Constant1'],'BackgroundColor','darkGreen','Value','MAX_CountVal','ShowName','off');
                MaskParameters.Parameters(1).Visible='on';
            end
 
             if((strcmp(get_param(currentblock,'Parameter'),'Both Min Max'))&&isempty(AddHandler)) 
                 delete_line(currentblock,'DEC_Value/1','MinMax/2');
                 delete_line(currentblock,'MinMax/1','Sub/2'); 
                 delete_line(currentblock,'En_DecCounter/1','Switch/2');
                 delete_line(currentblock,'Unit_Delay/1','Sub/1');
                 delete_line(currentblock,'Sub/1','Switch/1');
                 delete_line(currentblock,'Constant/1','Switch/3');
                 delete_block([currentblock,'/DEC_Value']);
                 delete_block([currentblock,'/En_DecCounter']);
                 delete_block([currentblock,'/Sub']);
                 delete_block([currentblock,'/Constant']);
                 DecHandlerVal =add_block('simulink/Sources/In1',[currentblock,'/DEC_Value']);
                 DEC_CounterHandler =add_block('simulink/Sources/In1',[currentblock,'/En_DecCounter']);
                 Switch1Handler =add_block('simulink/Commonly Used Blocks/Switch',[currentblock,'/Switch1']);
                 ConstantHandler =add_block('simulink/Commonly Used Blocks/Constant',[currentblock,'/Constant']);
                 Add1Handler =add_block('simulink/Math Operations/Add',[currentblock,'/Add1']);
                 MinMax1Handler =add_block('simulink/Math Operations/MinMax',[currentblock,'/MinMax1']); 
                 Constant6Handler =add_block('simulink/Sources/Constant',[currentblock,'/Constant6']);    
                 set_param(MinMax1Handler,'Position',[115 308 150 332],'Function','max','Inputs','2','ShowName','off'); 
                 set_param(Constant6Handler,'Position',[50 292 85 308],'OutDataTypeStr','Inherit: Inherit via back propagation','Value','0','ShowName','off'); 
                 set_param(DecHandlerVal,'Position',[25 318 55 332],'BackgroundColor','Green');
                 set_param(DEC_CounterHandler,'Position',[25 378 55 392],'BackgroundColor','Green','OutDataTypeStr','boolean');
                 set_param(ConstantHandler,'Position',[90 430 120 460],'OutDataTypeStr','Inherit: Inherit via back propagation','Value','0','ShowName','off');
                 set_param(Switch1Handler,'Position',[200 292 230 478],'ShowName','off');
                 set_param(Add1Handler,'Position',[400 339 430 426],'Inputs','-+','ShowName','off');
                 add_line(currentblock,'Add1/1','Switch/3','autorouting','on');
                 add_line(currentblock,'DEC_Value/1','MinMax1/2','autorouting','on');
                 add_line(currentblock,'Constant6/1','MinMax1/1','autorouting','on');
                 add_line(currentblock,'MinMax1/1','Switch1/1','autorouting','on');
                 add_line(currentblock,'En_DecCounter/1','Switch1/2','autorouting','on');
                 add_line(currentblock,'Constant/1','Switch1/3','autorouting','on');
                 add_line(currentblock,'Switch1/1','Add1/1','autorouting','on');
                 add_line(currentblock,'Unit_Delay/1','Add1/2','autorouting','on');
                 IncHandlerVal =add_block('simulink/Sources/In1',[currentblock,'/INC_Value']);
                 Inc_CounterHandler =add_block('simulink/Sources/In1',[currentblock,'/En_IncCounter']);
                 Add1Handler =add_block('simulink/Math Operations/Add',[currentblock,'/Add']);
                 set_param(Inc_CounterHandler,'Position',[25 258 55 272],'BackgroundColor','Green','OutDataTypeStr','boolean');
                 set_param(IncHandlerVal,'Position',[25 158 55 172],'BackgroundColor','Green');
                 set_param(Add1Handler,'Position',[400 99 430 186],'ShowName','off');
                 add_line(currentblock,'Add/1','Switch/1','autorouting','on');
                 add_line(currentblock,'INC_Value/1','MinMax/2','autorouting','on'); 
                 add_line(currentblock,'MinMax/1','Add/2','autorouting','on'); 
                 %adding goto
                 Goto1HandlerVal =add_block('simulink/Signal Routing/Goto',[currentblock,'/Goto1']);
                 Goto2HandlerVal =add_block('simulink/Signal Routing/Goto',[currentblock,'/Goto2']);
                 set_param(Goto1HandlerVal,'Position',[200 217 250 233],'GotoTag','En_inc','BackgroundColor','cyan','ShowName','off');
                 set_param(Goto2HandlerVal,'Position',[115 357 165 373],'GotoTag','En_Dec','BackgroundColor','cyan','ShowName','off');
                 add_line(currentblock,'En_IncCounter/1','Goto1/1','autorouting','on');
                 add_line(currentblock,'En_DecCounter/1','Goto2/1','autorouting','on');
                 add_line(currentblock,'En_IncCounter/1','Switch/2','autorouting','on');
                 add_line(currentblock,'Unit_Delay/1','Add/1','autorouting','on'); 
                 %mask edit
                 MaskParameters = Simulink.Mask.get(currentblock);
                 MaskParameters.Parameters(2).Visible='on';
                 replace_block([currentblock,'/Constant1'],'Ground','Constant','noprompt');
                 set_param([currentblock,'/Constant1'],'BackgroundColor','darkGreen','Value','MAX_CountVal','ShowName','off');
                 MaskParameters.Parameters(1).Visible='on';
             end
          
             if((strcmp(get_param(currentblock,'Parameter'),'Both Min Max'))&&~isempty(AddHandler)&&isempty(SubHandler)&&isempty(ConstantHandler2))
                   delete_line(currentblock,'Constant/1','Switch/3');
                   delete_block([currentblock,'/Constant']);
                   DecHandlerVal =add_block('simulink/Sources/In1',[currentblock,'/DEC_Value']);
                   DEC_CounterHandler =add_block('simulink/Sources/In1',[currentblock,'/En_DecCounter']);
                   Switch1Handler =add_block('simulink/Commonly Used Blocks/Switch',[currentblock,'/Switch1']);
                   ConstantHandler =add_block('simulink/Commonly Used Blocks/Constant',[currentblock,'/Constant']);
                   Add1Handler =add_block('simulink/Math Operations/Add',[currentblock,'/Add1']);
                   set_param(DecHandlerVal,'Position',[25 318 55 332],'BackgroundColor','Green');
                   set_param(DEC_CounterHandler,'Position',[25 378 55 392],'BackgroundColor','Green','OutDataTypeStr','boolean');
                   set_param(ConstantHandler,'Position',[90 430 120 460],'OutDataTypeStr','Inherit: Inherit via back propagation','Value','0','ShowName','off');
                   set_param(Switch1Handler,'Position',[200 292 230 478],'ShowName','off');
                   set_param(Add1Handler,'Position',[400 339 430 426],'Inputs','-+','ShowName','off');
                   MinMax1Handler =add_block('simulink/Math Operations/MinMax',[currentblock,'/MinMax1']); 
                   Constant6Handler =add_block('simulink/Sources/Constant',[currentblock,'/Constant6']);    
                   set_param(MinMax1Handler,'Position',[115 308 150 332],'Function','max','Inputs','2','ShowName','off'); 
                   set_param(Constant6Handler,'Position',[50 292 85 308],'OutDataTypeStr','Inherit: Inherit via back propagation','Value','0','ShowName','off');
                   add_line(currentblock,'Add1/1','Switch/3','autorouting','on');
                   add_line(currentblock,'DEC_Value/1','MinMax1/2','autorouting','on');
                   add_line(currentblock,'Constant6/1','MinMax1/1','autorouting','on');
                   add_line(currentblock,'MinMax1/1','Switch1/1','autorouting','on');
                   add_line(currentblock,'En_DecCounter/1','Switch1/2','autorouting','on');
                   add_line(currentblock,'Constant/1','Switch1/3','autorouting','on');
                   add_line(currentblock,'Switch1/1','Add1/1','autorouting','on');
                   add_line(currentblock,'Unit_Delay/1','Add1/2','autorouting','on');
                   Goto1HandlerVal =add_block('simulink/Signal Routing/Goto',[currentblock,'/Goto1']);
                   Goto2HandlerVal =add_block('simulink/Signal Routing/Goto',[currentblock,'/Goto2']);
                   set_param(Goto1HandlerVal,'Position',[200 217 250 233],'GotoTag','En_inc','BackgroundColor','cyan','ShowName','off');
                   set_param(Goto2HandlerVal,'Position',[115 357 165 373],'GotoTag','En_Dec','BackgroundColor','cyan','ShowName','off');
                   add_line(currentblock,'En_IncCounter/1','Goto1/1','autorouting','on');
                   add_line(currentblock,'En_DecCounter/1','Goto2/1','autorouting','on');
                   %mask edit
                   MaskParameters = Simulink.Mask.get(currentblock);
                   MaskParameters.Parameters(2).Visible='on';
                   MaskParameters.Parameters(1).Visible='on';
                   replace_block([currentblock,'/Constant2'],'Ground','Constant','noprompt');
                   set_param([currentblock,'/Constant2'],'BackgroundColor','darkGreen','Value','MIN_CountVal','ShowName','off');   
             end        
             if((strcmp(get_param(currentblock,'Parameter'),'Minvalue'))&&~isempty(Switch1Handler))
                    delete_line(currentblock,'DEC_Value/1','MinMax1/2');
                    delete_line(currentblock,'Constant6/1','MinMax1/1');
                    delete_line(currentblock,'MinMax1/1','Switch1/1'); 
                    delete_line(currentblock,'En_DecCounter/1','Switch1/2');
                    delete_line(currentblock,'En_DecCounter/1','Goto2/1'); 
                    delete_line(currentblock,'Constant/1','Switch1/3');
                    delete_line(currentblock,'Switch1/1','Add1/1');
                    delete_line(currentblock,'Add1/1','Switch/3');
                    delete_line(currentblock,'Unit_Delay/1','Add1/2');
                    delete_block([currentblock,'/Add1']);
                    delete_block([currentblock,'/Switch1']);
                    delete_block([currentblock,'/En_DecCounter']);
                    delete_block([currentblock,'/DEC_Value']);
                    delete_block([currentblock,'/Constant']); 
                    delete_block([currentblock,'/Goto2']);
                    delete_block([currentblock,'/Constant6']);
                    delete_block([currentblock,'/MinMax1']);
                    delete_line(currentblock,'En_IncCounter/1','Switch/2');
                    delete_line(currentblock,'En_IncCounter/1','Goto1/1');
                    delete_line(currentblock,'INC_Value/1','MinMax/2');
                    delete_line(currentblock,'MinMax/1','Add/2');
                    delete_line(currentblock,'Add/1','Switch/1');
                    delete_line(currentblock,'Unit_Delay/1','Add/1');
                    delete_block([currentblock,'/Add']);
                    delete_block([currentblock,'/En_IncCounter']);
                    delete_block([currentblock,'/INC_Value']);
                    delete_block([currentblock,'/Goto1']);
                    DecHandlerVal =add_block('simulink/Sources/In1',[currentblock,'/DEC_Value']);
                    DEC_CounterHandler =add_block('simulink/Sources/In1',[currentblock,'/En_DecCounter']);
                    SubHandler =add_block('simulink/Math Operations/Add',[currentblock,'/Sub']);
                    ConstantHandler =add_block('simulink/Commonly Used Blocks/Constant',[currentblock,'/Constant']);
                    set_param(DEC_CounterHandler,'Position',[25 258 55 272],'BackgroundColor','Green','OutDataTypeStr','boolean');
                    set_param(DecHandlerVal,'Position',[25 158 55 172],'BackgroundColor','Green');
                    set_param(SubHandler,'Position',[400 99 430 186],'Inputs','+-','ShowName','off');
                    set_param(ConstantHandler,'Position',[310 370 340 400],'OutDataTypeStr','Inherit: Inherit via back propagation','Value','0','ShowName','off');
                    add_line(currentblock,'Sub/1','Switch/1','autorouting','on');
                    add_line(currentblock,'DEC_Value/1','MinMax/2','autorouting','on');
                    add_line(currentblock,'MinMax/1','Sub/2','autorouting','on');
                    add_line(currentblock,'En_DecCounter/1','Switch/2','autorouting','on');
                    add_line(currentblock,'Unit_Delay/1','Sub/1','autorouting','on');
                    add_line(currentblock,'Constant/1','Switch/3','autorouting','on');
                    %mask edit
                    MaskParameters1 = Simulink.Mask.get(currentblock);
                    MaskParameters1.Parameters(1).Visible='off';
                    replace_block([currentblock,'/Constant1'],'Constant','Ground','noprompt');
                    set_param([currentblock,'/Constant1'],'BackgroundColor','darkGreen','ShowName','off');
             end
        end  

        %Sliding Average Filter    
        function SAF_TypeProp(currentblock) 

            maskStr = get_param(currentblock,'InputTypeFlag');

            %Searching for Blocks 'From' and 'Ground for Subsystem 'DPropagation_32Bits'
            BRefFrom32b = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','From','Name','Ref1_32bits');
            BRefGround32b = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Ground','Name','Ref1_32bits');
            BDataFrom32b = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','From','Name','DataProp_32bits');
            BDataGround32b = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Ground','Name','DataProp_32bits');

            %Searching for Blocks 'From' and 'Ground for Subsystem 'DPropagation_Others'
            BDataFromOthers = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','From','Name','DataProp_Others');
            BDataGroundOthers = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Ground','Name','DataProp_Others');
            BRefFromOthers = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','From','Name','Ref1_Others');
            BRefGroundOthers = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Ground','Name','Ref1_Others');

            %Path Subsystem 'DPropagation_32Bits'
            Data32BitsPath = [currentblock,'/DataProp_32bits'];
            Ref132BitsPath = [currentblock,'/Ref1_32bits'];

            %Path Subsystem 'DPropagation_Others'
            DataOthersPath = [currentblock,'/DataProp_Others'];
            Ref1OthersPath = [currentblock,'/Ref1_Others'];

            %Activate propagation for 32 bits using Subsystem 'DPropagation_32Bits'
            if (~isempty(BRefGround32b) && ~isempty(BDataGround32b)&& strcmp(maskStr,'on'))
                %Activate propagation for 32bits type
                replace_block(Ref132BitsPath,'Ground','From','noprompt');
                set_param(Ref132BitsPath,  'GotoTag', 'Ref1');
                set_param(Ref132BitsPath,'BackgroundColor','magenta');

                replace_block(Data32BitsPath,'Ground','From','noprompt');
                set_param(Data32BitsPath,  'GotoTag', 'DataProp');
                set_param(Data32BitsPath,'BackgroundColor','cyan');
            end

            if (~isempty(BDataFromOthers) && ~isempty(BRefFromOthers)&& strcmp(maskStr,'on'))
                %disactivate propagation for other types
                replace_block(Ref1OthersPath,'From','Ground','noprompt');
                replace_block(DataOthersPath,'From','Ground','noprompt');
            end

            %Activate propagation for type other than 32bits using Subsystem 'DPropagation_Others'
            if (~isempty(BDataGroundOthers) && ~isempty(BRefGroundOthers) && strcmp(maskStr,'off'))
                %Activate propagation for type other than 32bits
                replace_block(Ref1OthersPath,'Ground','From','noprompt');
                set_param(Ref1OthersPath,  'GotoTag', 'Ref1');
                set_param(Ref1OthersPath,'BackgroundColor','magenta');

                replace_block(DataOthersPath,'Ground','From','noprompt');
                set_param(DataOthersPath,  'GotoTag', 'DataProp');
                set_param(DataOthersPath,'BackgroundColor','cyan');
            end

            if (~isempty(BRefFrom32b) && ~isempty(BDataFrom32b)&& strcmp(maskStr,'off'))
                %disactivate propagation for 32 bits types
                replace_block(Ref132BitsPath,'From','Ground','noprompt');
                replace_block(Data32BitsPath,'From','Ground','noprompt');
            end
        end
        
        %Decouncing Block
        function Debouncing_ConfigRst_Cnt (currentblock) 
      %Identify Inport Rst and Init if exist
            BkRst = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Inport','Name','Rst');
            BkInit = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Inport','Name','Init');
            BkCnt = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Outport','Name','Counter');


            %Identify Constant Rst and Init if exist
            BkCstRst= find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Constant','Name','Rst');
            BkCstInit = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Constant','Name','Init');
            BkGrdCnt = find_system(currentblock,'FollowLinks','on','SearchDepth',1,'LookUnderMasks','all','BlockType','Terminator','Name','Counter');

            %Path of Blocks with name Rst and Init
            RstPath= [currentblock,'/Rst'];
            InitPath= [currentblock,'/Init'];
            CntPath= [currentblock,'/Counter'];

            %Enable Reset 
            if (~isempty(BkRst) && ~isempty(BkInit) && strcmp(get_param(currentblock,'Rst_Flag'),'off'))
                replace_block(RstPath,'Inport','Constant','noprompt');
                set_param(RstPath, 'Value','0');
                set_param(RstPath, 'OutDataTypeStr', 'boolean');
                set_param(RstPath, 'SampleTime','-1');
                replace_block(InitPath,'Inport','Constant','noprompt');
                set_param(InitPath, 'Value','0');
                set_param(InitPath, 'OutDataTypeStr', 'boolean');
                set_param(InitPath, 'SampleTime','-1');
            end

            %Disable Reset
            if (~isempty(BkCstRst) && ~isempty(BkCstInit) && strcmp(get_param(currentblock,'Rst_Flag'),'on'))
                replace_block(RstPath,'Constant','Inport','noprompt');
                replace_block(InitPath,'Constant','Inport','noprompt');
                set_param(RstPath,'BackgroundColor','green');
                set_param(InitPath,'BackgroundColor','green');
            end

            %Enable Counter calculation
            if (~isempty(BkGrdCnt) && strcmp(get_param(currentblock,'Cnt_Flag'),'on'))
                replace_block(CntPath,'Terminator','Outport','noprompt');
                set_param(CntPath,'BackgroundColor','red');
            end
            %Disable Counter calculation
            if (~isempty(BkCnt) && strcmp(get_param(currentblock,'Cnt_Flag'),'off'))
                replace_block(CntPath,'Outport','Terminator','noprompt');
            end	
        end 
        
    end
end

