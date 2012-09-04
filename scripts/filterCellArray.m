% function out = filterCellArray (in, array, value)
% 	index = find (strcmp(array ,value));
%     out = cell(size(in));
%     for i = 1:length(in)
%         out{i} = in{i}(index);
%     end
% end

function out = filterCellArray (varargin)
    in = varargin{1};
    out = in;
    for i = 2:2:nargin
        array = varargin{i};
        value = varargin{i+1};
%         index = find (strcmp(array ,value));
        match = regexp(array, ['\<', value, '\>'], 'once');
        index = find(~cellfun('isempty',match));
        for i = 1:length(out)
            out{i} = out{i}(index);
        end
        for i = 2:2:nargin
            varargin{i} = varargin{i}(index);
        end
    end
end