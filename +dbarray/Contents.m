% +DBARRAY
%
% The dbarray package handles conversion between native MATLAB arrays of
% data (or strings) and their equivalent database representation.
%
% Usually databases contain only scalar values in each field. In some
% (rare) cases it is advantageous to allow arrays of data in a given field.
% This is usually when that data exists as a collection and there is no
% intention to use individual elements (for searching, sorting, etc).
%
% For instance, given the task to store colour names and their associated
% RGB values, it may be more convenient to store the RGB values in an array
% rather than separate fields:
%
% __ Colour __|______RGB______
%  Red        | {255,  0,  0}
%  Pink       | {255,192,203}
%  ...        | ...
%
% MATLAB holds this data naturally in 1-by-3 arrays, and some databases
% (PostgreSQL, Oracle) have ARRAY type fields suitable for storing such
% array directly. While it is possible to insert MATLAB data into such
% databases using SQL strings:
%  "INSERT into Colours (Colour, RGB) VALUES ('Red',{255,0,0})"
% , it is far more efficient to instead use MATLAB's fastinsert() and
% update() functions.
%
% fastinsert() and update() don't natively handle these array inserts, but
% the dbarray package provide a convenient interface to meet this need.
%
% Example 1 - PostgreSQL:
%  -- PostgreSQL table creation --
% "CREATE TABLE Colours (Colour text, RGB numeric ARRAY[3])"
%  -- Insert packed array using MATLAB --
% conn = database(... your PostgreSQL connection ...)
% redDb  = dbarray.pack([255,   0,   0], conn);
% pinkDb = dbarray.pack([255, 192, 203], conn);
% fastinsert(conn,'Colours',{'Colour','RGB'},{'Pink',pinkDb; 'Red',redDb})
%  -- Select and unpack using MATLAB --
% D = fetch(conn,'SELECT RGB FROM Colours WHERE Colour = ''Pink''');
% pink = dbarray.unpack(D{1})
%      = [ 255   192   203 ]
%
% Note that in the above example the RGB data inserted was actually a
% nested array (a 1-by-1 array containing a 3-by-1 array) rather than a
% more straightforward 3-by-1 array. In order to insert an N-by-1 array,
% you should make sure that your data being packed is an N-by-1 array
% (rather than the 1-by-3 of our RGB example).
%
% Example 2 - Oracle:
%  -- Oracle type and table creation --
% CREATE TYPE RGB_SET AS VARRAY(3) OF NUMBER;
% CREATE TABLE Colours (Colour VARCHAR2(64), RGB RGB_set);
%  -- Insert packed array using MATLAB --
% conn = database(... your Oracle connection ...)
% % Oracle RGB_SET object is 1-dim array even if 1-by-3 input is given:
% redDb  = dbarray.pack([255   0   0], conn, 'RGB_SET');
% pinkDb = dbarray.pack([255 192 203], conn, 'RGB_SET');
% fastinsert(conn,'Colours',{'Colour','RGB'},{'Pink',pinkDb; 'Red',redDb})
%  -- Select and unpack using MATLAB --
% D = fetch(conn,'SELECT RGB FROM Colours WHERE Colour = ''Pink''');
% pink = dbarray.unpack(D{1})
%      = [ 255;   192;   203 ] % 1-dim array types always return as N-by-1
%
% The dbarray package was tested for PostgreSQL and Oracle (the two primary
% databases supporting ARRAY[] type objects). Other databases (such as
% MySQL) don't support native ARRAY[] data types and instead suggest you
% serialise/unserialise strings to simulate arrays.
%
% Files
%   pack     - Transforms a MATLAB array into an insertable database array
%   unpack   - Transforms a fetched database array to MATLAB array
%   packJavaArray - Creates java array, same size/contents as MATLAB array
%   unpackJavaArray - Transforms java array to MATLAB array

%   Written by Sven Holcombe.