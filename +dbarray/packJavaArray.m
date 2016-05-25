function jArr = packJavaArray( dataIn, jClass )
%dbarray.packJavaArray Packs a MATLAB array into a same sized java array
%   jArr = packJavaArray( dataIn, jClass ) takes DATAIN and produces an
%   equivalently sized java array.
%
%   Note that java arrays are just nested 1-d arrays. For instance: A
%   5-by-1 MATLAB array results in one 5-length java array, whereas a
%   1-by-5 MATLAB array results in a 1-length java array with the first
%   element containing a 5-length java array.
%
%   Example:
%     dbarray.packJavaArray((1:3)','java.lang.Double')
%     ans = java.lang.Double[]:
%         [1]
%         [2]
%         [3]
%
%     dbarray.packJavaArray((1:3),'java.lang.Double')
%     ans = java.lang.Double[][]:
%         [1]    [2]    [3]

% No conversion type was specified, use default type lookup
if nargin<2
    jClass = dbarray.typeConversion(class(dataIn),true);
end

sz = size(dataIn);
nl = numel(dataIn);
if numel(sz)==2 && sz(2)==1
    % Special case for single dimension vector arrays
    sz(2) = [];
    subsCell = num2cell(1:sz(1))';
else
    % Regular case for any dimensioned array
    subs = cell(1,ndims(dataIn));
    [subs{:}] = ind2sub(sz, (1:nl)');
    subsCell = num2cell([subs{:}]);
end

jArr = javaArray(jClass,sz);
for i = 1:nl
    jArr(subsCell{i,:}) = javaObject(jClass, dataIn(i));
end