function [return_origs, return_fakes, L2] = get_data(origs, fakes, test)

fields = fieldnames(origs);
cells = struct2cell(origs);
sz = size(cells);
cells = reshape(cells, sz(1), []);
cells = cells';
% Sort by field "date"
cells = sortrows(cells, 3);
cells = reshape(cells', sz);
return_origs = cell2struct(cells, fields, 1);

fields = fieldnames(fakes);
cells = struct2cell(fakes);
sz = size(cells);
cells = reshape(cells, sz(1), []);
cells = cells';
% Sort by field "date"
cells = sortrows(cells, 3);
cells = reshape(cells', sz);
return_fakes = cell2struct(cells, fields, 1);

L1 = length(return_origs)
L2 = length(return_fakes);

if test
    if mod(L2,L1) ~= 0
        disp('Not correct length ratio between directories');
        disp('Terminating script');
        return
    end
    %check for errors
    for fake_i = 1:L2
        fake_i
        orig_i = mod(fake_i-1,L1)+1; %getting correct original index
        orig_name = return_origs(orig_i).name;
        fake_name = return_fakes(fake_i).name;
        fake_name = strsplit(fake_name,'_');
        fake_name = strcat(fake_name{2},'_', fake_name{3},'_', fake_name{4});
        if ~strcmp(orig_name,fake_name)
            disp('Not same image!!!');
            return
        end
    end
else
    if L1 ~= L2
        disp('Not same length of directories');
        disp('Terminating script');
        return
    end
    %check for errors
    for i = 1:L1
        i
        orig_name = return_origs(i).name;
        orig_name = strsplit(orig_name,'_');
        n1 = orig_name{4};
        fake_name = return_fakes(i).name;
        fake_name = strsplit(fake_name,'_');
        n2 = fake_name{4};
        if ~strcmp(n1,n2)
            disp('Not same image!!!');
            return
        end
    end
end