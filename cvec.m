function cvec(varargin)
%
% cvec(rowwise_matrix)
% cvec(rowwise_matrix, Fs)
% cvec(data_struct)
% data_struct.y, data_struct.x, data_struct.Fs. If y is a matrix: row-wise channels.
%
% Thomas E. Gladwin, 2007.

global data params
if length(varargin) == 0,
    % make pretty sim data
    data.Fs = 100;
    data.x = 0:(1/data.Fs):60;
    A = sin(2 * pi * (1 / 6) * data.x);
    upwards = (1:length(data.x)) / length(data.x);
    downwards = 1 - upwards;
    sin_part = upwards .* A .* sin(2 * pi * 1 * data.x);
    block_part = downwards .* round(mod(data.x, 1));
    data.y = sin_part + block_part;
    data.y = [data.y; sin_part];
else,
    if isstruct(varargin{1}),
        data = varargin{1};
    elseif length(varargin) == 1,
        data.y = varargin{1};
        [r, c] = size(data.y);
        if r > 20 * c,
            data.y = data.y';
            [r, c] = size(data.y);
        end;
        data.x = 1:c;
        data.Fs = 1;
    elseif length(varargin) == 2,
        data.y = varargin{1};
        data.Fs = varargin{2};
        [r, c] = size(data.y);
        data.x = (0:(c-1)) / data.Fs;
    end;
end;
%
data.y = data.y';
%
%params.sample_range = 1 + [0 min([4 * data.Fs, -1 + length(data.y(:, 1))])];
params.sample_range = [1 length(data.y(:, 1))];
params.d_shift_prop = 4;
params.d_shift = ceil(abs(diff(params.sample_range)) / 4) ;
params.d_stretch = params.d_shift;
%
params.fig_index = figure;
clf reset;
set(gcf, 'KeyPressFcn', @scrollKeyHandler);
set(gcf, 'WindowButtonDownFcn', @mouseButtonHandler);
%
replot;


function replot
%
%
global data params
figure(params.fig_index);
plot_samples = params.sample_range(1):params.sample_range(end);
[r, c] = size(data.y(plot_samples, :));
d_sep = sqrt(var(data.y(plot_samples, :)))/sqrt(r);
sep_mat = ones(r, c) * (1:c)' * d_sep;
plot(data.x(plot_samples), data.y(plot_samples, :) + sep_mat);
xlim(data.x(params.sample_range));


function scrollKeyHandler(whoGotPressed, keyData)
%
%
global data params
key = get(gcf, 'CurrentCharacter');
if strcmp(key, 's') == 1,
    params.sample_range(1) = max(1, params.sample_range(1) - params.d_stretch);
elseif strcmp(key, 'f') == 1,
    params.sample_range(1) = min(params.sample_range(2) - 1, params.sample_range(1) + params.d_stretch);
elseif strcmp(key, 'd') == 1,
    width0 = abs(diff(params.sample_range));
    params.sample_range(1) = max(1, params.sample_range(1) - params.d_shift);
    params.sample_range(2) = min(params.sample_range(1) + width0, length(data.x));
elseif strcmp(key, 'k') == 1,
    width0 = abs(diff(params.sample_range));
    params.sample_range(2) = min(params.sample_range(2) + params.d_shift, length(data.x));
    params.sample_range(1) = max(1, params.sample_range(2) - width0);
elseif strcmp(key, 'j') == 1,
    params.sample_range(2) = max(params.sample_range(1) + 1, params.sample_range(2) - params.d_stretch);
elseif strcmp(key, 'l') == 1,
    params.sample_range(2) = min(length(data.x), params.sample_range(2) + params.d_stretch);
elseif ~isempty(findstr(key, '12345678')),
    params.d_shift_prop = str2num(key);
end;
params.d_shift = ceil(diff(params.sample_range) / params.d_shift_prop);
params.d_stretch = params.d_shift;
replot;


function mouseButtonHandler(whoGotPressed, buttData)
%
%
global params
P = get(gca, 'CurrentPoint');
sample = P(1, 1);
fprintf(['You clicked at time point ' num2str(sample) '.\n']);