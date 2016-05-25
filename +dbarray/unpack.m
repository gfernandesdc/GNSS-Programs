function [mArr, hasDataMask] = unpack( objIn )
%spatialdb.unpack Transforms a database SQL array to MATLAB array
%
%   ARROUT = DBARRAY.UNPACK(OBJIN) takes a fetched OBJIN database array and
%   converts it to its equivalent native MATLAB array.
%
%   CELLARRAYOUT = DBARRAY.UNPACK(OBJCELLIN) takes a cell array of fetched
%   database objects to unpack and returns an equivalently sized cell
%   output of the unpacked contents of each cell.
%
%   PostgreSQL example:
%    Dpg = fetch(conn,'select ARRAY[1,2,3,4], ARRAY[[10,20], [30,40]], ARRAY[[''a'',''b''], [''c'',''d'']]')
%    dbarray.unpack(Dpg{1})
%         ans = [1 ; 2 ; 3 ; 4]
%    dbarray.unpack(Dpg{2})
%         ans =
%            10   20
%            30   40
%    dbarray.unpack(Dpg{3})
%         ans = 
%             'a'
%             'c'
%             'b'
%             'd'
%
%   For Oracle databases, the array "TYPE" must be known in advance and
%   declared in the target schema.
%

%% Handle cell of inputs
if iscell(objIn)
    [mArr, hasDataMask] = deal(cell(size(objIn)));
    for i = 1:numel(objIn)
        [mArr{i}, hasDataMask{i}] = dbarray.unpack(objIn{i});
    end
    return;
end

%% Handle scalar input

if isempty(objIn) % Empty case
    [mArr, hasDataMask] = deal([]);
    return;
end

objClass = class(objIn);
switch objClass
    case {'org.postgresql.jdbc4.Jdbc4Array', 'oracle.sql.ARRAY'}
        [mArr, hasDataMask] = dbarray.unpackJavaArray(objIn.getArray);
    otherwise
        error('dbarray:unpack:unsupportedArray', '%s database objects are not yet supported.', objClass)
end