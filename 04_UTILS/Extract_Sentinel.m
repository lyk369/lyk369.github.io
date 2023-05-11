size = length(V_PL_OUT.time);

needed_time = [0:0.5:31.5];
result = [];

for x = 1:size
    if ismember(V_PL_OUT.time(x), needed_time)
        disp(V_PL_OUT.time(x));
        result = [result; V_PL_OUT.signals.values(x,:)];
    end
end

disp(result);