function [r_origs, r_fakes, L1] = get_data(origs, fakes)

fields = fieldnames(origs);
cells = struct2cell(origs);
sz = size(cells);
cells = reshape(cells, sz(1), []);
cells = cells';
% Sort by field "date"
cells = sortrows(cells, 3);
cells = reshape(cells', sz);
r_origs = cell2struct(cells, fields, 1);

fields = fieldnames(fakes);
cells = struct2cell(fakes);
sz = size(cells);
cells = reshape(cells, sz(1), []);
cells = cells';
% Sort by field "date"
cells = sortrows(cells, 3);
cells = reshape(cells', sz);
r_fakes = cell2struct(cells, fields, 1);

L1 = length(r_origs);
L2 = length(r_fakes);

if L1 ~= L2
    disp('Not same length of directories');
    disp('Terminating script');
    return
end

%check for errors
for i = 1:L1
    i
    orig = r_origs(i).name;
    orig = strsplit(orig,'_');
    n1 = orig{4};
    fak = r_fakes(i).name;
    fak = strsplit(fak,'_');
    n2 = fak{4};
    if ~strcmp(n1,n2)
        disp('Not same image!!!');
        return
    end
end