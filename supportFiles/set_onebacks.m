function [t] = set_onebacks(nTrials,nOneBacks)

% Randomly assigns one-backs to a series of numbers.

if nOneBacks ~= 2
    error('Sorry, set_onebacks only supports nOneBacks=2 at this time');
end

% Set randomization of one-backs.
t = randperm(nTrials);
r = randi(length(t), 1, nOneBacks);

% If r(1) is the last entry, then change r to include a random selection from earlier in the series.  
    if r(1) == length(t)
        
        r = [randi(length(t)-1, 1, 1) r(1)];
        
    end
    
% If r(2) is the last entry, then change r to include a random selection from earlier in the series.  
    if r(2) == length(t)
        
        r = [randi(length(t)-1, 1, 1) r(1)];
        
    end

if abs(r(1)-r(2)) == 1
    
    r(2) = r(2) + 1;    % make sure that the one-backs are not adjacent
   
    % If the new r(2) is outside the bounds of t, then change r to include
    % a random selection from earlier in the series.
    if r(2) > length(t)
        
        r = [randi(length(t)-2, 1, 1) r(1)];
        
    end
    
end

for p = 1:length(r)
    idx = find(t == r(p));
    t(idx+1) = t(idx);
end

end

