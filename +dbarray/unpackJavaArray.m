function [mArr, hasDataMask] = unpackJavaArray(jArr, varargin)
%dbarray.unpackJavaArray Unpacks a java array into its MATLAB counterpart
%   mArr = dbarray.unpackJavaArray( jArr ) takes a java array (simple or
%   nested) and produces an equivalently sized and populated MATLAB array.
%
%   mArr = dbarray.unpackJavaArray( jArr, 'emptyvalue', VAL ) allows
%   "empty" elements of the input java array to be assigned a particular
%   value such as NaN, rather than the default (0 for numeric output and []
%   for cell output).
%
%   [mArr,hasDataMask] = dbarray.unpackJavaArray( ... ) also returns a mask
%   into mArr showing which elements had real data. This is useful if the
%   chosen output type is integer or boolean which may have empty elements
%   (but they cannot be assigned as NaN because integers cannot be NaN).

IP = inputParser;
IP.addParameter('emptyvalue',[])
IP.parse(varargin{:})

unwrapFcn = @double; % Only "double(jArr)" gets data into MATLAB for most classes
packUpElement = @(el)el; % By default just putting a double into a typed array will convert it
emptyVal = 0;

% Map Java class to appropriate MATLAB variables
baseDataClass = regexprep(class(jArr),'\[\]','');
firstLen = length(jArr);
switch baseDataClass
    case {'java.lang.Double','java.lang.Number','java.math.BigDecimal'}
        mArr = zeros(firstLen,1,'double');
    case 'java.lang.Float'
        mArr = zeros(firstLen,1,'single');
    case 'java.lang.Boolean'
        mArr = false(firstLen,1);
    case {'java.lang.Integer','java.lang.Long','java.lang.Short','java.math.BigInteger'}
        mArr = zeros(firstLen,1,'uint32'); % Currently just map all integers to uint32
    case {'java.lang.String','java.lang.Character','java.sql.Date','java.sql.Time','java.sql.Timestamp'}
        unwrapFcn = @char;
        mArr = cell(firstLen,1);
        packUpElement = @(el){el};
        emptyVal = [];
    otherwise
        error('dbarray:unknownJavaType','Java class %s is not currently implemented. Leave a file exchange comment to request implementation.',baseDataClass)
end

% Allow particular empty value to be given
if ~isequal(IP.Results.emptyvalue,[])
    emptyVal = IP.Results.emptyvalue;
end

% Map which elements came from data and which came from empty input.
hasDataMask = true(size(mArr));
recurseUnwrapJavaArray(jArr,{})

% Recursively walk through each element in a java array, and fill mArr with
% its contents.
    function recurseUnwrapJavaArray(innerElement, subs)
        inElFullClass = class(innerElement);
        if any(inElFullClass=='[') % The element is a nested array
            nEls = length(innerElement);
            nextSubs = [subs {0}];            
            for i = 1:nEls
                nextSubs{end} = i;
                recurseUnwrapJavaArray(innerElement(i), nextSubs)
            end
        else % The element is either empty or populated with scalar data
            if isempty(innerElement)
                hasDataMask(subs{:}) = false;
                mArr(subs{:}) = packUpElement(emptyVal);
            else
                mArr(subs{:}) = packUpElement(unwrapFcn(innerElement));
                hasDataMask(subs{:}) = true;
            end
        end
    end
end