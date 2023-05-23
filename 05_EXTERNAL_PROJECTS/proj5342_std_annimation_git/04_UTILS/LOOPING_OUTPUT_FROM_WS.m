%% lOOPING IN O_ALL_OUT TO_WORKSPACE BLOCK

counter=0;
GLOBAL_POSITION=1;
O_ALL_OUT1=struct2cell(O_ALL_OUT);
OUT_LEN=length(O_ALL_OUT1);

X(:,1)=O_ALL_OUT1{1}.Time;
Header{1}='Time';

for i=1:OUT_LEN
    if size(O_ALL_OUT1{i}.Data,2)>1
        compressed_sig_size=size(O_ALL_OUT1{i}.Data,2);
        TEMP=O_ALL_OUT1{i}.Data;
        F=1;
        for j=i:i+compressed_sig_size-1
        GLOBAL_POSITION=GLOBAL_POSITION+1;
        X(:,GLOBAL_POSITION)=TEMP(:,F);
        Header{GLOBAL_POSITION}=strcat(O_ALL_OUT1{i}.Name, "("+num2str(F)+")");
        F=F+1;
        end  
    else
        GLOBAL_POSITION=GLOBAL_POSITION+1;
        X(:,GLOBAL_POSITION)=O_ALL_OUT1{i}.Data; 
        Header{GLOBAL_POSITION}=O_ALL_OUT1{i}.Name;
        
    end
end
vars = who();
TF = contains(vars, '_i'); 
TF=vars(TF);
TimeDataTested=eval([TF{1},'.time']);
KK=ismember(round(X(:,1),10),round(TimeDataTested,10));
for i=1:size(X,1)
if true(KK(i))
    counter=counter+1;
    Out(i,:)=X(i,:);
end
end

FinalOut = [X(1,:);Out(~all(Out == 0, 2),:)];
ActualOutput = [Header;num2cell(FinalOut)];
ActualOutputTS = timeseries(FinalOut(:,2:end),FinalOut(:,1),'Name',Header);
