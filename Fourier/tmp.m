load('C:\Users\DanilaPRO\MATLAB_PROJECTS\Fourier\patterns\1.mat')
LENGTH = length(pattern{1}) - 1;
fileID = fopen('patterns/train.csv', 'w');
format_spec = '%f';
for i = 1:(LENGTH-1)
    format_spec = strcat(format_spec, ',%f');
end
format_spec = strcat(format_spec, ',%i\n');
fprintf(fileID, '%i %i\n', [LENGTH, length(pattern)]);
for i = 1:length(pattern)
    fprintf(fileID, format_spec, pattern{i});
end
fclose(fileID);