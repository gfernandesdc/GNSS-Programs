function objOut = pack( dataIn, dbConn, dataType )
%dbarray.pack Transforms a MATLAB array into an insertable database array
%
%   OBJOUT = DBARRAY.PACK(DATAIN, DBCONN) takes a array DATAIN and converts
%   it to the database array type required by DBCONN, which is an open
%   connection to the target database.
%
%   For PostgreSQL databases, MATLAB data types are mapped as follows:
%    {'single','double'}    -> "numeric"
%    {'intX','uintX',...}   -> "int"
%    {'logical'}            -> "bool"
%    {'char','cell'}        -> "char"
%   In some cases, a particular destination class is desired. This may be
%   set by supplying an additional DATATYPE argument specifying the class
%   string for the created PostgreSQL array:
%   OBJOUT = DBARRAY.PACK(DATAIN, DBCONN, POSTGRESQLTYPE)
%
%   For Oracle databases, the array "TYPE" must be known in advance and
%   declared as an object in the target schema. Therefore the following
%   syntax must be used specifying which array type is to be used.
%   OBJOUT = DBARRAY.PACK(DATAIN, DBCONN, ORCLTYPE) Here, ORCLTYPE is a 
%   string name of the declared Oracle array type.
%

dbStr = dbName(dbConn);
switch dbStr
    case 'postgresql'
        if nargin>=3
            % Explicit dataType provided
            pgDataClass = dataType;
        else
            % Use default mapping of numeric to numeric, etc.
            switch class(dataIn)
                case {'single','double'}
                    pgDataClass = 'numeric';
                case {'int8','uint8','int16','uint16','int32','uint32','int64','uint64'}
                    pgDataClass = 'int';
                case 'logical'
                    pgDataClass = 'bool';
                case {'char','cell'}
                    % TODO: Add ability to hold varying dim numeric cells
                    if iscell(dataIn) && ~iscellstr(dataIn)
                        error('dbarray:pack:unsupportedClass', 'Cells must be cell arrays of strings. Numeric variable arrays not currently supported.')
                    end
                    pgDataClass = 'char';
                otherwise
                    error('dbarray:pack:unsupportedClass', '%s data are not currently supported.', class(dataIn))
            end
        end
        bestJavaType = dbarray.typeConversion(class(dataIn), true);
        javaObjectArray = dbarray.packJavaArray(dataIn, bestJavaType);
        objOut = createArrayOf(dbConn.Handle, pgDataClass, javaObjectArray);
        
    case 'oracle'
        % Oracle requires a specific "TYPE" to be declared in advance. The
        % array description should therefore be able to convert the native
        % MATLAB data to the required array type data
        arrDescObj = javaObject('oracle.sql.ArrayDescriptor',dataType,dbConn.Handle);
        objOut = javaObject('oracle.sql.ARRAY',arrDescObj,dbConn.Handle,dataIn);
        
    otherwise
        error('dbarray:pack:unsupportedDb', '%s databases are not currently supported.', dbStr)
end

function dbStr = dbName(connOrStr)
%dbName converts a db conn object to lowercase db name string
%
% Usage:
% dbcompat.dbName(pgSqlConn)
%     ans = 'postgresql'
%
% dbcompat.sequenceSelect(oracleConn)
%     ans = 'oracle'

if isa(connOrStr,'database')
    dMetaData = dmd(connOrStr);
    sDbName = get(dMetaData,'DatabaseProductName');
elseif ischar(connOrStr)
    sDbName = connOrStr;
else
    error('Unknown database object type: %s.',class(connOrStr))
end
dbStr = lower(sDbName);