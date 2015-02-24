matlabpool OPEN 4

%%
cmd = dir('*.sh');

parfor ii = 1: length(cmd)
    system(sprintf('./%s',cmd(ii).name))
end