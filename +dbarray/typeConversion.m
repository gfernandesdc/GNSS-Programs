function outType = typeConversion( inType, fromMATLAB )
%TYPECONVERSION Looks up given MATLAB/JAVA type to find it JAVA/MATLAB pair
%
% OUT = dbarray.typeConversion( 'double', true )
% (results in OUT='java.lang.Double')
%
% OUT = dbarray.typeConversion( 'java.lang.Float', false )
% (results in OUT='single')

if nargin<2, fromMATLAB = true; end

if fromMATLAB % Convert from a MATLAB type to its closes java type
    % http://www.mathworks.com/help/matlab/matlab_external/passing-data-to-a-java-method.html
    switch inType
        case 'logical'
            %boolean	byte	short	int	long	float	double
            outType = 'java.lang.Boolean';
        case 'double'
            %double	float	long	int	short	byte	boolean
            outType = 'java.lang.Double';
        case 'single'
            %float	double
            outType = 'java.lang.Float';
        case 'char'
            % char (1-by-1scalar)	String	char
            % char (1-by-n orn-by-1, n>1)	String	char[]
            % char(m-by-n,m,n>1)	String[]
            outType = 'java.lang.String';
        case {'uint8','int8'}
            %byte	short	int	long	float	double
            outType = 'java.lang.Byte';
        case {'uint16','int16'}
            %short	int	long	float	double
            outType = 'java.lang.Short';
        case {'uint32','int32'}
            %int	long	float	double
            outType = 'java.lang.Integer';
        case {'uint64','int64'}
            %long	float	double
            outType = 'java.lang.Long';
        case 'cell'
            % Allow cell array of strings
            outType = 'java.lang.String';
        otherwise
            error('dbarray:unknownJavaType','MATLAB class %s has no direct Java type implemented. Leave a file exchange comment to request implementation.',inType)
            
            % cell array ofstrings	String[]
            % Java object	Object
            % cell array ofobject	Object[]
    end
    
else % Convert from a java type to a valid MATLAB type
    switch inType
        case {'java.lang.Double','java.lang.Number','java.math.BigDecimal'}
            outType = 'double';
        case 'java.lang.Float'
            outType = 'single';
        case 'java.lang.Boolean'
            outType = 'logical';
        case 'java.lang.Byte'
            outType = 'int8';
        case 'java.lang.Short'
            outType = 'int16';
        case {'java.lang.Integer','java.lang.Long','java.math.BigInteger'}
            outType = 'uint32';
        case {'java.lang.String','java.lang.Character','java.sql.Date','java.sql.Time','java.sql.Timestamp'}
            outType = 'char';
        otherwise
            error('dbarray:unknownJavaType','Java class %s is not currently implemented. Leave a file exchange comment to request implementation.',inType)
    end
    
end