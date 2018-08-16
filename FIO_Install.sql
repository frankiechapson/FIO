/********************************************************************************************************************

    FILE IO Manager. This solution can manage input and output interface files.

    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.05 |  1.0    | Ferenc Toth    | Created 
    2018.08.16 |  1.1    | Ferenc Toth    | The 1.1 was a modified version of a working one, but during the upgrade I made a lot of bug.

********************************************************************************************************************/



/*
drop table FIO_FILE_BLOBS;
drop table FIO_FILE_LINES;
drop table FIO_FILE_HEADERS;
drop table FIO_FILE_TYPES;
drop table FIO_FILE_STATUSES;
drop table FIO_FILE_ERRORS;
drop table FIO_LINE_ERRORS;
drop sequence FIO_SEQ_ID;
*/

Prompt *****************************************************************
Prompt **      I N S T A L L I N G   F I L E   I O   M G R            **
Prompt *****************************************************************


/*============================================================================================*/
CREATE SEQUENCE FIO_SEQ_ID
/*============================================================================================*/
    INCREMENT BY        1
    MINVALUE            1
    MAXVALUE   9999999999
    START WITH       1000
    CYCLE
    NOCACHE;




Prompt *****************************************************************
Prompt **                        T A B L E S                          **
Prompt *****************************************************************

/*============================================================================================*/
CREATE TABLE FIO_FILE_TYPES (
/*============================================================================================*/
    ID                      NUMBER                  NOT NULL,
    NAME                    VARCHAR2 ( 1000 )       NOT NULL,
    MASK                    VARCHAR2 ( 1000 ),  
    TEXT_FILE_FLAG          NUMBER   ( 1, 0 )       NOT NULL,
    DIRECTION               CHAR     (    1 )       NOT NULL,      
    ORACLE_DIRECTORY        VARCHAR2 (  200 ),
    OS_DIRECTORY            VARCHAR2 ( 4000 ),
    IDENTIFY_PROCEDURE      VARCHAR2 ( 1000 ),
    CHECK_PROCEDURE         VARCHAR2 ( 1000 ),
    PROCESS_PROCEDURE       VARCHAR2 ( 1000 ),
    CREATE_PROCEDURE        VARCHAR2 ( 1000 ),
    DELETE_PROCEDURE        VARCHAR2 ( 1000 ),
    REMARK                  VARCHAR2 ( 1000 ),
    CONSTRAINT              PK_FIO_FILE_TYPES            PRIMARY KEY ( ID ),
    CONSTRAINT              CH1_FIO_FILE_TYPES           CHECK       ( DIRECTION IN ( 'I', 'O' ) )
  );


CREATE OR REPLACE TRIGGER TR_FIO_FILE_TYPES_BIUR
    BEFORE INSERT OR UPDATE ON FIO_FILE_TYPES FOR EACH ROW
BEGIN
    :NEW.ID             := NVL  ( :NEW.ID, FIO_SEQ_ID.NEXTVAL );
    :NEW.DIRECTION      := UPPER( :NEW.DIRECTION    );
END;
/



/*============================================================================================*/
CREATE TABLE FIO_FILE_STATUSES (
/*============================================================================================*/
    ID              NUMBER                  NOT NULL,
    TEXT            VARCHAR2 ( 2000 )       NOT NULL,
    DIRECTION       CHAR     (    1 )       NOT NULL,      
    CONSTRAINT      PK_FIO_FILE_STATUSES    PRIMARY KEY ( ID ),
    CONSTRAINT      CH1_FIO_FILE_STATUSES   CHECK       ( DIRECTION IN ( 'I', 'O', 'B' ) )
    );

-- Input files
INSERT INTO FIO_FILE_STATUSES ( ID, TEXT , DIRECTION ) VALUES ( 11, 'Waiting for read'      ,'I' );
INSERT INTO FIO_FILE_STATUSES ( ID, TEXT , DIRECTION ) VALUES ( 12, 'Reading'               ,'I' );
INSERT INTO FIO_FILE_STATUSES ( ID, TEXT , DIRECTION ) VALUES ( 13, 'Waiting for identify'  ,'I' );
INSERT INTO FIO_FILE_STATUSES ( ID, TEXT , DIRECTION ) VALUES ( 14, 'Identifing'            ,'I' );
INSERT INTO FIO_FILE_STATUSES ( ID, TEXT , DIRECTION ) VALUES ( 15, 'Waiting for check'     ,'I' );
INSERT INTO FIO_FILE_STATUSES ( ID, TEXT , DIRECTION ) VALUES ( 16, 'Checking'              ,'I' );
INSERT INTO FIO_FILE_STATUSES ( ID, TEXT , DIRECTION ) VALUES ( 17, 'Waiting for process'   ,'I' );
INSERT INTO FIO_FILE_STATUSES ( ID, TEXT , DIRECTION ) VALUES ( 18, 'Processing'            ,'I' );
INSERT INTO FIO_FILE_STATUSES ( ID, TEXT , DIRECTION ) VALUES ( 19, 'Processed'             ,'I' );
-- Output files                         
INSERT INTO FIO_FILE_STATUSES ( ID, TEXT , DIRECTION ) VALUES ( 21, 'Waiting for create'    ,'O' );
INSERT INTO FIO_FILE_STATUSES ( ID, TEXT , DIRECTION ) VALUES ( 22, 'Creating'              ,'O' );
INSERT INTO FIO_FILE_STATUSES ( ID, TEXT , DIRECTION ) VALUES ( 24, 'Waiting for write'     ,'O' );
INSERT INTO FIO_FILE_STATUSES ( ID, TEXT , DIRECTION ) VALUES ( 25, 'Writing'               ,'O' );
INSERT INTO FIO_FILE_STATUSES ( ID, TEXT , DIRECTION ) VALUES ( 26, 'Wrote'                 ,'O' );
INSERT INTO FIO_FILE_STATUSES ( ID, TEXT , DIRECTION ) VALUES ( 27, 'Acknowledged'          ,'O' );
-- Common                                
INSERT INTO FIO_FILE_STATUSES ( ID, TEXT , DIRECTION ) VALUES ( 30, 'External process'      ,'B' );
INSERT INTO FIO_FILE_STATUSES ( ID, TEXT , DIRECTION ) VALUES ( 31, 'Failed'                ,'B' );
INSERT INTO FIO_FILE_STATUSES ( ID, TEXT , DIRECTION ) VALUES ( 32, 'Waiting for delete'    ,'B' );
INSERT INTO FIO_FILE_STATUSES ( ID, TEXT , DIRECTION ) VALUES ( 33, 'Deleting'              ,'B' );
INSERT INTO FIO_FILE_STATUSES ( ID, TEXT , DIRECTION ) VALUES ( 34, 'Deleted (data)'        ,'B' );
COMMIT;




/*============================================================================================*/
CREATE TABLE FIO_FILE_ERRORS (
/*============================================================================================*/
    ID              NUMBER                  NOT NULL,
    TEXT            VARCHAR2 ( 2000 )       NOT NULL,
    DIRECTION       CHAR     (    1 )       NOT NULL,      
    CONSTRAINT      PK_FIO_FILE_ERRORS      PRIMARY KEY ( ID ),
    CONSTRAINT      CH1_FIO_FILE_ERRORS     CHECK       ( DIRECTION IN ( 'I', 'O', 'B' ) )
    );
-- Fix codes
INSERT INTO FIO_FILE_ERRORS ( ID, TEXT, DIRECTION ) VALUES (  1, 'Open'     , 'B' );
INSERT INTO FIO_FILE_ERRORS ( ID, TEXT, DIRECTION ) VALUES (  2, 'Read'     , 'I' );
INSERT INTO FIO_FILE_ERRORS ( ID, TEXT, DIRECTION ) VALUES (  3, 'Write'    , 'O' );
INSERT INTO FIO_FILE_ERRORS ( ID, TEXT, DIRECTION ) VALUES (  4, 'Rename'   , 'B' );
INSERT INTO FIO_FILE_ERRORS ( ID, TEXT, DIRECTION ) VALUES (  5, 'Unknown'  , 'B' );
INSERT INTO FIO_FILE_ERRORS ( ID, TEXT, DIRECTION ) VALUES (  6, 'Identify' , 'I' );
INSERT INTO FIO_FILE_ERRORS ( ID, TEXT, DIRECTION ) VALUES (  7, 'Check'    , 'I' );
INSERT INTO FIO_FILE_ERRORS ( ID, TEXT, DIRECTION ) VALUES (  8, 'Process'  , 'I' );
INSERT INTO FIO_FILE_ERRORS ( ID, TEXT, DIRECTION ) VALUES (  9, 'Delete'   , 'B' );
INSERT INTO FIO_FILE_ERRORS ( ID, TEXT, DIRECTION ) VALUES ( 10, 'Create'   , 'O' );
COMMIT;


/*============================================================================================*/
CREATE TABLE FIO_FILE_HEADERS (
/*============================================================================================*/
    ID                      NUMBER                  NOT NULL,
    NAME                    VARCHAR2 (  500 )       NOT NULL,
    FILE_TYPE_ID            NUMBER,
    FILE_STATUS_ID          NUMBER                  NOT NULL,
    TEXT_FILE_FLAG          NUMBER   ( 1, 0 )       NOT NULL,
    DIRECTION               CHAR     (    1 )       NOT NULL,      
    ORACLE_DIRECTORY        VARCHAR2 (  200 ),
    OS_DIRECTORY            VARCHAR2 ( 4000 ),
    CREATED                 DATE,
    MODIFIED                DATE,
    IO_DATE                 DATE,
    CONFIRM_DATE            DATE,
    LAST_STAT_CHNG_DATE     DATE,
    ERROR_ID                NUMBER,
    ERROR_TEXT              VARCHAR2 ( 2000 ),
    REMARK                  VARCHAR2 ( 2000 ),
    CONSTRAINT              PK_FIO_FILE_HEADERS          PRIMARY KEY ( ID ),
    CONSTRAINT              CH1_FIO_FILE_HEADERS         CHECK       ( DIRECTION IN ( 'I', 'O' ) ),
    CONSTRAINT              FK1_FIO_FILE_HEADERS         FOREIGN KEY ( FILE_TYPE_ID    ) REFERENCES FIO_FILE_TYPES    ( ID ),
    CONSTRAINT              FK2_FIO_FILE_HEADERS         FOREIGN KEY ( FILE_STATUS_ID  ) REFERENCES FIO_FILE_STATUSES ( ID ),
    CONSTRAINT              FK3_FIO_FILE_HEADERS         FOREIGN KEY ( ERROR_ID        ) REFERENCES FIO_FILE_ERRORS   ( ID )
  );


CREATE BITMAP INDEX IDX1_FIO_FILE_HEADERS     ON FIO_FILE_HEADERS ( TEXT_FILE_FLAG );
CREATE BITMAP INDEX IDX2_FIO_FILE_HEADERS     ON FIO_FILE_HEADERS ( DIRECTION      );
CREATE        INDEX IDX3_FIO_FILE_HEADERS     ON FIO_FILE_HEADERS ( FILE_TYPE_ID   );
CREATE        INDEX IDX4_FIO_FILE_HEADERS     ON FIO_FILE_HEADERS ( FILE_STATUS_ID );


CREATE OR REPLACE TRIGGER TR_FIO_FILE_HEADERS_BIR
    BEFORE INSERT ON FIO_FILE_HEADERS FOR EACH ROW
BEGIN
    :NEW.ID             := NVL( :NEW.ID, FIO_SEQ_ID.NEXTVAL ); 
    :NEW.DIRECTION      := UPPER( :NEW.DIRECTION       );
    :NEW.CREATED        := NVL( :NEW.CREATED , SYSDATE );
    :NEW.MODIFIED       := NVL( :NEW.MODIFIED, SYSDATE );
END;
/


CREATE OR REPLACE TRIGGER TR_FIO_FILE_HEADERS_BUR
    BEFORE UPDATE ON FIO_FILE_HEADERS FOR EACH ROW
BEGIN
    IF :OLD.FILE_STATUS_ID != :NEW.FILE_STATUS_ID THEN
        :NEW.LAST_STAT_CHNG_DATE := SYSDATE;
    END IF;
    :NEW.DIRECTION      := UPPER( :NEW.DIRECTION       );
    :NEW.MODIFIED       := NVL( :NEW.MODIFIED, SYSDATE );
    if :OLD.FILE_TYPE_ID is null and :NEW.FILE_TYPE_ID is not null then
        :NEW.FILE_STATUS_ID := 15;
    end if;
    if :OLD.FILE_STATUS_ID != :NEW.FILE_STATUS_ID then
        :NEW.LAST_STAT_CHNG_DATE := sysdate;
    end if;
END;
/


/*============================================================================================*/
CREATE TABLE FIO_FILE_BLOBS (
/*============================================================================================*/
    ID                      NUMBER                  NOT NULL,
    FILE_HEADER_ID          NUMBER                  NOT NULL,
    FILE_DATA               BLOB,
    CONSTRAINT              PK_FIO_FILE_BLOBS            PRIMARY KEY ( ID ),
    CONSTRAINT              FK1_FIO_FILE_BLOBS           FOREIGN KEY ( FILE_HEADER_ID ) REFERENCES FIO_FILE_HEADERS ( ID )
  );

CREATE        INDEX IDX1_FIO_FILE_BLOBS     ON FIO_FILE_BLOBS ( FILE_HEADER_ID );


CREATE OR REPLACE TRIGGER TR_FIO_FILE_BLOBS_BIR
    BEFORE INSERT ON FIO_FILE_BLOBS FOR EACH ROW
BEGIN
    :NEW.ID := NVL( :NEW.ID, FIO_SEQ_ID.NEXTVAL ); 
END;
/



/*============================================================================================*/
CREATE TABLE FIO_LINE_ERRORS (
/*============================================================================================*/
    ID              NUMBER                  NOT NULL,
    TEXT            VARCHAR2 ( 2000 )       NOT NULL,
    CONSTRAINT      PK_FIO_LINE_ERRORS      PRIMARY KEY ( ID )
    );
-- some typical error
INSERT INTO FIO_LINE_ERRORS ( ID, TEXT ) VALUES (  0, 'Unknown Error'     );
INSERT INTO FIO_LINE_ERRORS ( ID, TEXT ) VALUES (  1, 'Invalid number'    );
INSERT INTO FIO_LINE_ERRORS ( ID, TEXT ) VALUES (  2, 'Invalid date'      );
INSERT INTO FIO_LINE_ERRORS ( ID, TEXT ) VALUES (  3, 'Invalid time'      );
INSERT INTO FIO_LINE_ERRORS ( ID, TEXT ) VALUES (  4, 'String too long'   );
INSERT INTO FIO_LINE_ERRORS ( ID, TEXT ) VALUES (  5, 'Too many data'     );
INSERT INTO FIO_LINE_ERRORS ( ID, TEXT ) VALUES (  6, 'Not enough data'   );
INSERT INTO FIO_LINE_ERRORS ( ID, TEXT ) VALUES (  7, 'It is not Header Line'   );
INSERT INTO FIO_LINE_ERRORS ( ID, TEXT ) VALUES (  8, 'It is not Trailer Line'   );
INSERT INTO FIO_LINE_ERRORS ( ID, TEXT ) VALUES (  9, 'Wrong number of rows'   );
INSERT INTO FIO_LINE_ERRORS ( ID, TEXT ) VALUES ( 10, 'Wrong checksum'   );
COMMIT;




/*============================================================================================*/
CREATE TABLE FIO_FILE_LINES (
/*============================================================================================*/
    ID                      NUMBER                  NOT NULL,
    FILE_HEADER_ID          NUMBER                  NOT NULL,
    LINE_NO                 NUMBER                  NOT NULL,
    LINE                    VARCHAR2 ( 4000 ),
    ERROR_ID                NUMBER,
    CONSTRAINT              PK_FIO_FILE_LINES          PRIMARY KEY ( ID ),
    CONSTRAINT              FK1_FIO_FILE_LINES         FOREIGN KEY ( FILE_HEADER_ID ) REFERENCES FIO_FILE_HEADERS ( ID ),
    CONSTRAINT              FK2_FIO_FILE_LINES         FOREIGN KEY ( ERROR_ID       ) REFERENCES FIO_LINE_ERRORS  ( ID )
  );

CREATE        INDEX IDX1_FIO_FILE_LINES     ON FIO_FILE_LINES ( FILE_HEADER_ID );
CREATE        INDEX IDX2_FIO_FILE_LINES     ON FIO_FILE_LINES ( LINE_NO        );


CREATE OR REPLACE TRIGGER TR_FIO_FILE_LINES_BIR
    BEFORE INSERT ON FIO_FILE_LINES FOR EACH ROW
BEGIN
    :NEW.ID := NVL( :NEW.ID, FIO_SEQ_ID.NEXTVAL ); 
END;
/




Prompt *****************************************************************
Prompt **                         V I E W S                           **
Prompt *****************************************************************

CREATE OR REPLACE VIEW FIO_WAIT_FOR_READ_VW AS
SELECT *
  FROM FIO_FILE_HEADERS
 WHERE FILE_STATUS_ID = 11
 ORDER BY IO_DATE, CREATED
;

CREATE OR REPLACE VIEW FIO_WAIT_FOR_IDENTIFY_VW AS
SELECT *
  FROM FIO_FILE_HEADERS
 WHERE FILE_STATUS_ID = 13
 ORDER BY IO_DATE, CREATED
;

CREATE OR REPLACE VIEW FIO_WAIT_FOR_CHECK_VW AS
SELECT *
  FROM FIO_FILE_HEADERS
 WHERE FILE_STATUS_ID = 15
 ORDER BY IO_DATE, CREATED
;

CREATE OR REPLACE VIEW FIO_WAIT_FOR_PROCESS_VW AS
SELECT *
  FROM FIO_FILE_HEADERS
 WHERE FILE_STATUS_ID = 17
 ORDER BY IO_DATE, CREATED
;

CREATE OR REPLACE VIEW FIO_WAIT_FOR_CREATE_VW AS
SELECT *
  FROM FIO_FILE_HEADERS
 WHERE FILE_STATUS_ID = 21
 ORDER BY IO_DATE, CREATED
;

CREATE OR REPLACE VIEW FIO_WAIT_FOR_WRITE_VW AS
SELECT *
  FROM FIO_FILE_HEADERS
 WHERE FILE_STATUS_ID = 24
 ORDER BY IO_DATE, CREATED
;


CREATE OR REPLACE VIEW FIO_WAIT_FOR_DELETE_VW AS
SELECT *
  FROM FIO_FILE_HEADERS
 WHERE FILE_STATUS_ID = 32
 ORDER BY IO_DATE, CREATED
;


CREATE OR REPLACE VIEW FIO_FAILED_VW AS
SELECT *
  FROM FIO_FILE_HEADERS
 WHERE FILE_STATUS_ID = 31
;



Prompt *****************************************************************
Prompt **               P A C K A G E   H E A D E R                   **
Prompt *****************************************************************

/*============================================================================================*/
create or replace package PKG_FIO is
/*============================================================================================*/

/*  
    History of changes
    yyyy.mm.dd | Version | Author   | Changes
    -----------+---------+----------+-------------------------
    2016.01.12 |  1.0    | Tothf    | Created
*/

    C_ERROR_OPEN                CONSTANT number  := 1;
    C_ERROR_READ                CONSTANT number  := 2;
    C_ERROR_WRITE               CONSTANT number  := 3;
    C_ERROR_RENAME              CONSTANT number  := 4;
    C_ERROR_OTHER               CONSTANT number  := 5;
    C_ERROR_IDENTIFY            CONSTANT number  := 6;
    C_ERROR_CHECK               CONSTANT number  := 7;
    C_ERROR_PROCESS             CONSTANT number  := 8;
    C_ERROR_DELETE              CONSTANT number  := 9;
    C_ERROR_CREATE              CONSTANT number  := 10;

    C_STATUS_EXTRENAL           CONSTANT number  := 30;    
    C_STATUS_4_READ             CONSTANT number  := 11;
    C_STATUS_READING            CONSTANT number  := 12;
    C_STATUS_4_IDENTIFY         CONSTANT number  := 13;
    C_STATUS_IDENTIFING         CONSTANT number  := 14;
    C_STATUS_4_CHECK            CONSTANT number  := 15;
    C_STATUS_CHECKING           CONSTANT number  := 16;
    C_STATUS_4_PROCESS          CONSTANT number  := 17;
    C_STATUS_PROCESSING         CONSTANT number  := 18;
    C_STATUS_PROCESSED          CONSTANT number  := 19;
    C_STATUS_FAILED             CONSTANT number  := 31;  
    C_STATUS_4_DELETE           CONSTANT number  := 32;   
    C_STATUS_DELETING           CONSTANT number  := 33;  
    C_STATUS_DELETED            CONSTANT number  := 34;  
    C_STATUS_4_CREATE           CONSTANT number  := 21;
    C_STATUS_CREATING           CONSTANT number  := 22;
    C_STATUS_4_WRITE            CONSTANT number  := 24;
    C_STATUS_WRITING            CONSTANT number  := 25;
    C_STATUS_WROTE              CONSTANT number  := 26;


    ------------------------------------------------------------------------------------
    function   FILE_EXISTS ( I_ORA_DIR       in varchar2
                           , I_FILE_NAME     in varchar2
                           ) return char;
    ------------------------------------------------------------------------------------
    function   GET_FILE_EXTENTION ( I_FILE_NAME      in varchar2 ) return varchar2;
    ------------------------------------------------------------------------------------
    function   GET_ORA_DIRECTORY  ( I_OS_DIRECTORY   in varchar2 ) return varchar2;
    ------------------------------------------------------------------------------------
    function   GET_OS_DIRECTORY   ( I_ORA_DIRECTORY  in varchar2 ) return varchar2;
    ------------------------------------------------------------------------------------
    function   MASK_MATCH( I_MASK        in varchar2
                         , I_FILE_NAME   in varchar2 
                         ) return number;
    ------------------------------------------------------------------------------------
    procedure  BLOB_TO_LINES  ( I_FILE_HEADER_ID    in number );
    ------------------------------------------------------------------------------------


    ------------------------------------------------------------------------------------
    procedure  READ_TEXT_FILE  ( I_FILE_HEADER_ID   in number );
    ------------------------------------------------------------------------------------
    procedure  READ_BLOB_FILE  ( I_FILE_HEADER_ID   in number );
    ------------------------------------------------------------------------------------
    procedure  READ_FILES;
    ------------------------------------------------------------------------------------
    function   UPLOAD_FILE ( I_OS_DIRECTORY            in varchar2
                           , I_FILE_NAME               in varchar2
                           , I_CREATION_DATE           in date     := null
                           , I_MODIFICATION_DATE       in date     := null
                           , I_IS_TEXT_FILE            in number   := 0
                           , I_DO_NOT_READ             in char     := 'N'     -- N=read by Oracle, Y=read by external program
                           ) return number;
    ------------------------------------------------------------------------------------
    procedure  IDENTIFY_FILES;
    ------------------------------------------------------------------------------------
    procedure  CHECK_FILES;
    ------------------------------------------------------------------------------------
    procedure  PROCESS_FILES;
    ------------------------------------------------------------------------------------


    ------------------------------------------------------------------------------------
    procedure  CREATE_FILES;
    ------------------------------------------------------------------------------------
    procedure  WRITE_TEXT_FILE ( I_FILE_HEADER_ID   in number );
    ------------------------------------------------------------------------------------
    procedure  WRITE_BLOB_FILE ( I_FILE_HEADER_ID   in number );
    ------------------------------------------------------------------------------------
    procedure  WRITE_FILES;
    ------------------------------------------------------------------------------------

    ------------------------------------------------------------------------------------
    procedure  DELETE_FILE_DATA ( I_FILE_HEADER_ID   in number );
    ------------------------------------------------------------------------------------
    procedure  DELETE_FILES;
    ------------------------------------------------------------------------------------

    ------------------------------------------------------------------------------------
    procedure  INP_JOB_PROC;
    ------------------------------------------------------------------------------------
    procedure  OUT_JOB_PROC;
    ------------------------------------------------------------------------------------
    procedure  CLEAN_JOB_PROC;
    ------------------------------------------------------------------------------------

end;
/


Prompt *****************************************************************
Prompt **                  P A C K A G E   B O D Y                    **
Prompt *****************************************************************

/*============================================================================================*/
create or replace package body PKG_FIO is
/*============================================================================================*/
/*  
    History of changes
    yyyy.mm.dd | Version | Author   | Changes
    -----------+---------+----------+-------------------------
    2016.01.12 |  1.0    | Tothf    | Created
*/


    ------------------------------------------------------------------------------------
    function  FILE_EXISTS ( I_ORA_DIR       in varchar2
                          , I_FILE_NAME     in varchar2
                          ) return char is
    ------------------------------------------------------------------------------------
        V_FEXISTS   boolean;
        V_FLEN      number;
        V_BSIZE     number;
        V_RES       CHAR ( 1 ) := 'N';
    begin
        utl_file.fgetattr( upper( I_ORA_DIR ), I_FILE_NAME, V_FEXISTS, V_FLEN, V_BSIZE );
        if V_FEXISTS then
            V_RES := 'Y';
        end if;
        return V_RES;
    end;


    ------------------------------------------------------------------------------------
    function  GET_FILE_EXTENTION ( I_FILE_NAME  in varchar2 ) return varchar2 is
    ------------------------------------------------------------------------------------
    begin
        if instr( I_FILE_NAME, '.', -1 ) = 0 then
            return null;
        end if;
        return substr( I_FILE_NAME, instr( I_FILE_NAME, '.', -1 ) + 1, length( I_FILE_NAME )- instr( I_FILE_NAME, '.', -1 ) );
    end;


    ------------------------------------------------------------------------------------
    function  GET_ORA_DIRECTORY ( I_OS_DIRECTORY in varchar2 ) return varchar2 is
    ------------------------------------------------------------------------------------
        V_ORA_DIRECTORY     varchar( 100 );
    begin
        select min( directory_name ) into V_ORA_DIRECTORY from all_directories where directory_path = I_OS_DIRECTORY;
        if V_ORA_DIRECTORY is null then
            select min( directory_name ) into V_ORA_DIRECTORY from all_directories where upper( directory_path ) = upper( I_OS_DIRECTORY );
        end if;
        return V_ORA_DIRECTORY;
    end;


    ------------------------------------------------------------------------------------
    function  GET_OS_DIRECTORY ( I_ORA_DIRECTORY in varchar2 ) return varchar2 is
    ------------------------------------------------------------------------------------
        V_OS_DIRECTORY     varchar( 1000 );
    begin
        select min( directory_path ) into V_OS_DIRECTORY from all_directories where  upper( directory_name ) = upper( I_ORA_DIRECTORY );
        return V_OS_DIRECTORY;
    end;


    ------------------------------------------------------------------------------------
    function  MASK_MATCH( I_MASK        in varchar2
                        , I_FILE_NAME   in varchar2 
                        ) return number is
    ------------------------------------------------------------------------------------
        V_MATCH     number           := 0;    -- the file name does not match the mask
        V_MASK      varchar2( 1000 ) := I_MASK;
    begin
        if I_MASK is not null and I_FILE_NAME is not null then
            V_MASK := replace( V_MASK, '*', '%' );
            V_MASK := replace( V_MASK, '?', '_' );
            select count(*) into V_MATCH from dual where I_FILE_NAME like V_MASK;
        end if;
        return V_MATCH;
    end;


    ------------------------------------------------------------------------------------
    procedure  BLOB_TO_LINES  ( I_FILE_HEADER_ID    in number ) is
    ------------------------------------------------------------------------------------
        type T_STRING_LIST is table of varchar2( 4000 ); 
        V_FILE_LINE     FIO_FILE_LINES%rowtype;
        V_FILE_BLOB     FIO_FILE_BLOBS%rowtype;
        V_OFFSET        number  :=     1;
        V_AMOUNT        number  :=  4000;
        V_LENGTH        number;
        V_BUFFER        varchar2( 32000 );
        V_STRING_LIST   T_STRING_LIST := T_STRING_LIST();


        function CSV_TO_LIST ( I_CSV_STRING in varchar2, I_SEPARATOR in varchar2 ) return T_STRING_LIST is
            L_CSV           varchar2( 32000 ) := I_CSV_STRING;
            L_FIELD         varchar2( 32000 );
            L_STRING_LIST   T_STRING_LIST := T_STRING_LIST();
        begin
            loop
                if L_CSV is not null then
                    -- did we reach a separator outside?
                    if substr( L_CSV , 1 , length( I_SEPARATOR ) ) = I_SEPARATOR  then
                        L_CSV    := substr( L_CSV, length( I_SEPARATOR ) + 1 );
                        L_STRING_LIST.extend;
                        L_STRING_LIST( L_STRING_LIST.count ) := L_FIELD;
                        L_FIELD  := '';      
                    else  -- inside
                        L_FIELD  := L_FIELD || substr( L_CSV, 1 , 1 );
                        L_CSV    := substr( L_CSV, 2 );
                    end if;
                else
                    if L_FIELD is not null then
                        L_STRING_LIST.extend;
                        L_STRING_LIST( L_STRING_LIST.count ) := L_FIELD;
                    end if;
                    exit;
                end if;
            end loop;
            return L_STRING_LIST;        
        end;



    begin
        select * into V_FILE_BLOB from FIO_FILE_BLOBS where FILE_HEADER_ID = I_FILE_HEADER_ID;
        V_FILE_LINE.FILE_HEADER_ID  := I_FILE_HEADER_ID;
        V_FILE_LINE.LINE_NO         := 0;
        V_LENGTH  := dbms_lob.getlength( V_FILE_BLOB.FILE_DATA );      
        if V_LENGTH > 0 then
       
            delete FIO_FILE_LINES where FILE_HEADER_ID = I_FILE_HEADER_ID;

            while V_OFFSET < V_LENGTH loop
       
                -- get the next part of blob
                V_BUFFER := utl_raw.cast_to_varchar2( dbms_lob.substr( V_FILE_BLOB.FILE_DATA, V_AMOUNT, V_OFFSET ) );
                V_BUFFER := replace( V_BUFFER, chr( 13 ), null );
       
                -- crate a list from it
                V_STRING_LIST := CSV_TO_LIST( V_BUFFER, chr( 10 ) );
       
                -- go through the list elements
                for L_I in 1..V_STRING_LIST.count 
                loop
                    V_FILE_LINE.LINE := V_FILE_LINE.LINE || V_STRING_LIST( L_I );
                    if L_I < V_STRING_LIST.count then  -- the last row should be truncated
                        V_FILE_LINE.ID      := FIO_SEQ_ID.nextval;
                        V_FILE_LINE.LINE_NO := V_FILE_LINE.LINE_NO + 1;
                        insert into FIO_FILE_LINES values V_FILE_LINE;
                        V_FILE_LINE.LINE := '';
                    end if;
                end loop;
       
                V_OFFSET := V_OFFSET + V_AMOUNT;
       
            end loop;
       
            -- put out the last one as well    
            if V_FILE_LINE.LINE is not null then
                V_FILE_LINE.ID      := FIO_SEQ_ID.nextval;
                V_FILE_LINE.LINE_NO := V_FILE_LINE.LINE_NO + 1;
                insert into FIO_FILE_LINES values V_FILE_LINE;
            end if;
       
            update FIO_FILE_HEADERS
               set TEXT_FILE_FLAG  = 1 
             where ID              = I_FILE_HEADER_ID 
               and TEXT_FILE_FLAG != 1;
       
            delete FIO_FILE_BLOBS where FILE_HEADER_ID = I_FILE_HEADER_ID;
            commit;

        end if;
    end;

    ------------------------------------------------------------------------------------
    function  UPLOAD_FILE ( I_OS_DIRECTORY            in varchar2
                          , I_FILE_NAME               in varchar2
                          , I_CREATION_DATE           in date     := null
                          , I_MODIFICATION_DATE       in date     := null
                          , I_IS_TEXT_FILE            in number   := 0
                          , I_DO_NOT_READ             in char     := 'N'     -- N=read by Oracle, Y=read by external program
                          ) return number is
    ------------------------------------------------------------------------------------
    -- Just creates the file header row and returns with its ID
    -- This usually called by an external shell script which is polling a folder and 
    -- if found a file to upload then calls this procedure with the paramters what it has 
        V_FILE_REC      FIO_FILE_HEADERS%rowtype;
    begin
        V_FILE_REC.ID                     := FIO_SEQ_ID.nextval;
        V_FILE_REC.FILE_TYPE_ID           := null;
        if I_DO_NOT_READ = 'Y' then
            V_FILE_REC.FILE_STATUS_ID     := C_STATUS_EXTRENAL;    -- out of scope for Oracle
        else
            V_FILE_REC.FILE_STATUS_ID     := C_STATUS_4_READ;      -- waiting for read
        end if;
        V_FILE_REC.TEXT_FILE_FLAG         := I_IS_TEXT_FILE;
        V_FILE_REC.DIRECTION              := 'I';
        V_FILE_REC.NAME                   := I_FILE_NAME;
        V_FILE_REC.ORACLE_DIRECTORY       := GET_ORA_DIRECTORY( I_OS_DIRECTORY );
        V_FILE_REC.OS_DIRECTORY           := I_OS_DIRECTORY;
        V_FILE_REC.CREATED                := I_CREATION_DATE;
        V_FILE_REC.MODIFIED               := I_MODIFICATION_DATE;
        V_FILE_REC.IO_DATE                := null;
        V_FILE_REC.CONFIRM_DATE           := null;
        V_FILE_REC.LAST_STAT_CHNG_DATE    := sysdate;
        V_FILE_REC.ERROR_ID               := null;
        V_FILE_REC.ERROR_TEXT             := null;

        insert into FIO_FILE_HEADERS values V_FILE_REC;       
        commit;

        return V_FILE_REC.ID;

    end;


    ------------------------------------------------------------------------------------
    procedure  READ_TEXT_FILE  ( I_FILE_HEADER_ID      in number ) is
    ------------------------------------------------------------------------------------
        V_FILE_HEADER   FIO_FILE_HEADERS%rowtype;
        V_FILE_LINE     FIO_FILE_LINES%rowtype;
        V_FILE          utl_file.file_type;
        V_HAS_ERROR     boolean  := false;
        V_NUMBER        number;
        V_STRING        varchar2( 4000 );
    begin
        V_FILE_LINE.FILE_HEADER_ID  := I_FILE_HEADER_ID;
        V_FILE_LINE.LINE_NO         := 0;

        select * into V_FILE_HEADER from FIO_FILE_HEADERS where ID = I_FILE_HEADER_ID;

        begin
            utl_file.frename( V_FILE_HEADER.ORACLE_DIRECTORY, V_FILE_HEADER.NAME, V_FILE_HEADER.ORACLE_DIRECTORY, V_FILE_HEADER.NAME||'.tmp', true );
        exception when others then
            V_NUMBER := sqlcode;
            V_STRING := sqlerrm;
            update FIO_FILE_HEADERS
               set FILE_STATUS_ID = C_STATUS_FAILED
                 , ERROR_ID       = C_ERROR_RENAME
                 , ERROR_TEXT     = V_NUMBER||' '||V_STRING 
             where ID = I_FILE_HEADER_ID;
            commit;
            return;
        end;

        begin
            V_FILE := utl_file.fopen( V_FILE_HEADER.ORACLE_DIRECTORY, V_FILE_HEADER.NAME||'.tmp', 'R');
        exception when others then
            V_NUMBER := sqlcode;
            V_STRING := sqlerrm;
            update FIO_FILE_HEADERS
               set FILE_STATUS_ID = C_STATUS_FAILED
                 , ERROR_ID       = C_ERROR_OPEN
                 , ERROR_TEXT     = V_NUMBER||' '||V_STRING 
             where ID = I_FILE_HEADER_ID;
            commit;
            return;
        end;

        -- delete the lines from a previous read
        delete FIO_FILE_LINES where FILE_HEADER_ID = I_FILE_HEADER_ID;

        update FIO_FILE_HEADERS 
           set FILE_STATUS_ID = C_STATUS_READING
             , ERROR_ID       = null 
             , ERROR_TEXT     = null 
         where ID = I_FILE_HEADER_ID;     
        commit;

        loop

            begin
                utl_file.get_line( V_FILE , V_FILE_LINE.LINE );
--                V_FILE_LINE.LINE    := convert( V_FILE_LINE.LINE , 'UTF8', 'EE8MSWIN1250' );
                V_FILE_LINE.ID      := FIO_SEQ_ID.nextval;
                V_FILE_LINE.LINE_NO := V_FILE_LINE.LINE_NO + 1;
                insert into FIO_FILE_LINES values V_FILE_LINE;
                commit;
            exception 
                when no_data_found then
                    exit;
                when others then
                    V_NUMBER := sqlcode;
                    V_STRING := sqlerrm;
                    update FIO_FILE_HEADERS
                       set FILE_STATUS_ID = C_STATUS_FAILED
                         , ERROR_ID       = C_ERROR_READ
                         , ERROR_TEXT     = V_NUMBER||' '||V_STRING
                     where ID = I_FILE_HEADER_ID;
                    commit;
                    V_HAS_ERROR := true;
                    exit;
            end;

        end loop;

        utl_file.fclose ( V_FILE );

        begin
            if V_HAS_ERROR then
                utl_file.frename( V_FILE_HEADER.ORACLE_DIRECTORY, V_FILE_HEADER.NAME||'.tmp', V_FILE_HEADER.ORACLE_DIRECTORY, V_FILE_HEADER.NAME||'.failed', true );
            else
                utl_file.frename( V_FILE_HEADER.ORACLE_DIRECTORY, V_FILE_HEADER.NAME||'.tmp', V_FILE_HEADER.ORACLE_DIRECTORY, V_FILE_HEADER.NAME||'.done'  , true );
            end if;
        exception when others then
            V_NUMBER := sqlcode;
            V_STRING := sqlerrm;
            update FIO_FILE_HEADERS
               set FILE_STATUS_ID = C_STATUS_FAILED
                 , ERROR_ID       = C_ERROR_RENAME
                 , ERROR_TEXT     = V_NUMBER||' '||V_STRING
             where ID = I_FILE_HEADER_ID;
            commit;
        end;

        update FIO_FILE_HEADERS 
           set FILE_STATUS_ID = C_STATUS_4_IDENTIFY
             , IO_DATE        = sysdate 
         where ID = I_FILE_HEADER_ID;     
        commit;

    exception when others then

        V_NUMBER := sqlcode;
        V_STRING := sqlerrm;
        update FIO_FILE_HEADERS
           set FILE_STATUS_ID = C_STATUS_FAILED
             , ERROR_ID       = C_ERROR_OTHER
             , ERROR_TEXT     = V_NUMBER||' '||V_STRING
         where ID = I_FILE_HEADER_ID;
        commit;

        if utl_file.is_open( V_FILE ) then
            utl_file.fclose( V_FILE );
        end if;

        utl_file.frename( V_FILE_HEADER.ORACLE_DIRECTORY, V_FILE_HEADER.NAME||'.tmp', V_FILE_HEADER.ORACLE_DIRECTORY, V_FILE_HEADER.NAME||'.failed', true );

    end READ_TEXT_FILE;



    ------------------------------------------------------------------------------------
    procedure  READ_BLOB_FILE  ( I_FILE_HEADER_ID      in number ) is
    ------------------------------------------------------------------------------------
        V_FILE_REC      FIO_FILE_HEADERS%rowtype;
        V_FILE_BLOB     FIO_FILE_BLOBS%rowtype;
        V_FILE          bfile;
        V_NUMBER        number;
        V_STRING        varchar2( 4000 );
    begin

        select * into V_FILE_REC from FIO_FILE_HEADERS where ID = I_FILE_HEADER_ID;

        begin
            utl_file.frename( V_FILE_REC.ORACLE_DIRECTORY, V_FILE_REC.NAME, V_FILE_REC.ORACLE_DIRECTORY, V_FILE_REC.NAME||'.tmp', true );
        exception when others then
            V_NUMBER := sqlcode;
            V_STRING := sqlerrm;
            update FIO_FILE_HEADERS
               set FILE_STATUS_ID = C_STATUS_FAILED    -- FAILED
                 , ERROR_ID       = C_ERROR_RENAME
                 , ERROR_TEXT     = V_NUMBER||' '||V_STRING 
             where ID = I_FILE_HEADER_ID;
            commit;
            return;
        end;

        begin
            V_FILE := bfilename( V_FILE_REC.ORACLE_DIRECTORY, V_FILE_REC.NAME||'.tmp' );
            dbms_lob.open( V_FILE, dbms_lob.lob_readonly );
        exception when others then
            V_NUMBER := sqlcode;
            V_STRING := sqlerrm;
            update FIO_FILE_HEADERS
               set FILE_STATUS_ID = C_STATUS_FAILED    -- FAILED
                 , ERROR_ID       = C_ERROR_OPEN
                 , ERROR_TEXT     = V_NUMBER||' '||V_STRING 
             where ID = I_FILE_HEADER_ID;
            commit;
            return;
        end;

        -- delete the lines from a previous read
        delete FIO_FILE_BLOBS where FILE_HEADER_ID = I_FILE_HEADER_ID;

        update FIO_FILE_HEADERS 
           set FILE_STATUS_ID = C_STATUS_READING
             , ERROR_ID       = null 
             , ERROR_TEXT     = null 
         where ID = I_FILE_HEADER_ID;     
        commit;

        dbms_lob.createtemporary( V_FILE_BLOB.FILE_DATA, true );

        dbms_lob.open( V_FILE_BLOB.FILE_DATA, dbms_lob.lob_readwrite);

        dbms_lob.loadfromfile( dest_lob => V_FILE_BLOB.FILE_DATA, src_lob  => V_FILE, amount => dbms_lob.getlength( V_FILE ) );

        dbms_lob.close( V_FILE_BLOB.FILE_DATA );
        dbms_lob.fileclose( V_FILE );

        begin
            utl_file.frename( V_FILE_REC.ORACLE_DIRECTORY, V_FILE_REC.NAME||'.tmp', V_FILE_REC.ORACLE_DIRECTORY, V_FILE_REC.NAME||'.done'  , true );
        exception when others then
            V_NUMBER := sqlcode;
            V_STRING := sqlerrm;
            update FIO_FILE_HEADERS
               set FILE_STATUS_ID = C_STATUS_FAILED    -- FAILED
                 , ERROR_ID       = C_ERROR_RENAME
                 , ERROR_TEXT     = V_NUMBER||' '||V_STRING 
             where ID = I_FILE_HEADER_ID;
            commit;
        end;

        V_FILE_BLOB.FILE_HEADER_ID := I_FILE_HEADER_ID;
        V_FILE_BLOB.ID             := FIO_SEQ_ID.nextval;
        insert into FIO_FILE_BLOBS values V_FILE_BLOB;
        commit;

        update FIO_FILE_HEADERS 
           set FILE_STATUS_ID = C_STATUS_4_IDENTIFY
             , IO_DATE        = sysdate 
         where ID = I_FILE_HEADER_ID;     
        commit;

    exception when others then

        V_NUMBER := sqlcode;
        V_STRING := sqlerrm;
        update FIO_FILE_HEADERS
           set FILE_STATUS_ID = C_STATUS_FAILED    -- FAILED
             , ERROR_ID       = C_ERROR_OTHER
             , ERROR_TEXT     = V_NUMBER||' '||V_STRING
         where ID = I_FILE_HEADER_ID;
        commit;

        if dbms_lob.fileisopen( V_FILE ) = 1 then
            dbms_lob.fileclose( V_FILE );
        end if;

        utl_file.frename( V_FILE_REC.ORACLE_DIRECTORY, V_FILE_REC.NAME||'.tmp', V_FILE_REC.ORACLE_DIRECTORY, V_FILE_REC.NAME||'.failed', true );

    end READ_BLOB_FILE;



    ------------------------------------------------------------------------------------
    procedure READ_FILES is
    ------------------------------------------------------------------------------------
    begin
        for L_FILES in ( select * from FIO_WAIT_FOR_READ_VW )
        loop
            if L_FILES.TEXT_FILE_FLAG = 1 then
                READ_TEXT_FILE( L_FILES.ID );
            else
                READ_BLOB_FILE( L_FILES.ID );
            end if;
        end loop;
    end;




    ------------------------------------------------------------------------------------
    procedure IDENTIFY_FILES is
    ------------------------------------------------------------------------------------
        V_MIN_ID            number (  10 );
        V_MAX_ID            number (  10 );
        V_FILE_TYPE_ID      number (  10 );
        V_FILE_HEADER_ID    number;
        V_NUMBER            number;
        V_STRING            varchar2( 4000 );
        V_FIO_FILE_TYPES    FIO_FILE_TYPES%rowtype;
        V_TEXT_FILE_FLAG    number;
    begin
        for L_FILES in ( select * from FIO_WAIT_FOR_IDENTIFY_VW )
        loop

            V_FILE_HEADER_ID := L_FILES.ID;

            update FIO_FILE_HEADERS 
               set FILE_STATUS_ID = C_STATUS_IDENTIFING
                 , ERROR_ID       = null 
                 , ERROR_TEXT     = null 
             where ID = V_FILE_HEADER_ID;    
            commit;

            -- first try with folder names and mask
            select min(ID) , max(ID)
              into V_MIN_ID, V_MAX_ID
              from FIO_FILE_TYPES
             where L_FILES.DIRECTION                    = DIRECTION
               and upper( nvl( L_FILES.OS_DIRECTORY    , 'X' ) ) = upper( nvl( OS_DIRECTORY    , nvl( L_FILES.OS_DIRECTORY    , 'X' ) ) )
             /*  and upper( nvl( L_FILES.ORACLE_DIRECTORY, 'X' ) ) = upper( nvl( ORACLE_DIRECTORY, nvl( L_FILES.ORACLE_DIRECTORY, 'X' ) ) ) */
               and MASK_MATCH( MASK, L_FILES.NAME )     = 1;

            if V_MIN_ID is null or V_MIN_ID != V_MAX_ID then   

                -- try to find using identify procedures
                for L_TYPES in ( select * from FIO_FILE_TYPES where DIRECTION = 'I' and IDENTIFY_PROCEDURE is not null )
                loop    
                    V_MIN_ID := null;
                    begin
                        execute immediate L_TYPES.IDENTIFY_PROCEDURE using V_FILE_HEADER_ID;
                        select FILE_TYPE_ID into V_MIN_ID from FIO_FILE_HEADERS where ID = V_FILE_HEADER_ID;
                        exit when V_MIN_ID is not null;
                    exception when others then
                        null;
                    end;
                end loop;
    
            end if;

            if V_MIN_ID is not null then 

                select TEXT_FILE_FLAG into V_TEXT_FILE_FLAG from FIO_FILE_HEADERS where ID = V_FILE_HEADER_ID;    
                select * into V_FIO_FILE_TYPES from FIO_FILE_TYPES where ID = V_MIN_ID;    

                update FIO_FILE_HEADERS 
                   set FILE_STATUS_ID = C_STATUS_4_CHECK
                     , ERROR_ID       = null 
                     , ERROR_TEXT     = null 
                     , FILE_TYPE_ID   = V_MIN_ID
                 where ID = V_FILE_HEADER_ID;    

                if V_TEXT_FILE_FLAG = 0 and V_FIO_FILE_TYPES.TEXT_FILE_FLAG = 1 then
                    BLOB_TO_LINES ( V_FILE_HEADER_ID );                      
                end if;

                commit;
            else
                update FIO_FILE_HEADERS 
                   set FILE_STATUS_ID = C_STATUS_FAILED
                     , ERROR_ID       = C_ERROR_IDENTIFY 
                     , ERROR_TEXT     = 'Unknown file type'
                     , FILE_TYPE_ID   = null
                 where ID = V_FILE_HEADER_ID;    
                commit;
            end if;

        end loop;

    exception when others then

        V_NUMBER := sqlcode;
        V_STRING := sqlerrm;
        update FIO_FILE_HEADERS
           set FILE_STATUS_ID = C_STATUS_FAILED    
             , ERROR_ID       = C_ERROR_IDENTIFY
             , ERROR_TEXT     = V_NUMBER||' '||V_STRING
         where ID = V_FILE_HEADER_ID;
        commit;

    end;



    ------------------------------------------------------------------------------------
    procedure CHECK_FILES is
    ------------------------------------------------------------------------------------
        V_FILE_HEADER_ID    number;
        V_NUMBER            number;
        V_STRING            varchar2( 4000 );
    begin
        for L_FILES in ( select * from FIO_WAIT_FOR_CHECK_VW )
        loop

            V_FILE_HEADER_ID := L_FILES.ID;

            for L_TYPES in ( select * from FIO_FILE_TYPES where ID = L_FILES.FILE_TYPE_ID )
            loop    

                update FIO_FILE_HEADERS 
                   set FILE_STATUS_ID = C_STATUS_CHECKING
                     , ERROR_ID       = null 
                     , ERROR_TEXT     = null 
                 where ID = V_FILE_HEADER_ID
                   and L_TYPES.CHECK_PROCEDURE is not null;    
                commit;

                begin
                    execute immediate L_TYPES.CHECK_PROCEDURE using V_FILE_HEADER_ID;
                exception when others then
                    null;
                end;
            end loop;
    
        end loop;

    exception when others then

        V_NUMBER := sqlcode;
        V_STRING := sqlerrm;
        update FIO_FILE_HEADERS
           set FILE_STATUS_ID = C_STATUS_FAILED    
             , ERROR_ID       = C_ERROR_CHECK
             , ERROR_TEXT     = V_NUMBER||' '||V_STRING
         where ID = V_FILE_HEADER_ID;
        commit;

    end;



    ------------------------------------------------------------------------------------
    procedure PROCESS_FILES is
    ------------------------------------------------------------------------------------
        V_FILE_HEADER_ID    number;
        V_NUMBER            number;
        V_STRING            varchar2( 4000 );
    begin
        for L_FILES in ( select * from FIO_WAIT_FOR_PROCESS_VW )
        loop

            V_FILE_HEADER_ID := L_FILES.ID;

            for L_TYPES in ( select * from FIO_FILE_TYPES where ID = L_FILES.FILE_TYPE_ID )
            loop    
                update FIO_FILE_HEADERS 
                   set FILE_STATUS_ID = C_STATUS_PROCESSING
                     , ERROR_ID       = null 
                     , ERROR_TEXT     = null 
                 where ID = V_FILE_HEADER_ID    
                   and L_TYPES.PROCESS_PROCEDURE is not null;    
                commit;

                begin
                    execute immediate L_TYPES.PROCESS_PROCEDURE using V_FILE_HEADER_ID;
                exception when others then
                    null;
                end;
            end loop;
    
        end loop;

    exception when others then

        V_NUMBER := sqlcode;
        V_STRING := sqlerrm;
        update FIO_FILE_HEADERS
           set FILE_STATUS_ID = C_STATUS_FAILED    
             , ERROR_ID       = C_ERROR_PROCESS
             , ERROR_TEXT     = V_NUMBER||' '||V_STRING
         where ID = V_FILE_HEADER_ID;
        commit;

    end;


    ------------------------------------------------------------------------------------
    procedure CREATE_FILES is
    ------------------------------------------------------------------------------------
        V_FILE_HEADER_ID    number;
        V_NUMBER            number;
        V_STRING            varchar2( 4000 );
    begin
        for L_FILES in ( select * from FIO_WAIT_FOR_CREATE_VW )
        loop

            V_FILE_HEADER_ID := L_FILES.ID;


            for L_TYPES in ( select * from FIO_FILE_TYPES where ID = L_FILES.FILE_TYPE_ID )
            loop    
                update FIO_FILE_HEADERS 
                   set FILE_STATUS_ID = C_STATUS_CREATING
                     , ERROR_ID       = null 
                     , ERROR_TEXT     = null 
                 where ID = V_FILE_HEADER_ID  
                   and L_TYPES.CREATE_PROCEDURE is not null;    
                commit;

                begin
                    execute immediate L_TYPES.CREATE_PROCEDURE using V_FILE_HEADER_ID;
                exception when others then
                    null;
                end;
            end loop;
    
        end loop;

    exception when others then

        V_NUMBER := sqlcode;
        V_STRING := sqlerrm;
        update FIO_FILE_HEADERS
           set FILE_STATUS_ID = C_STATUS_FAILED    
             , ERROR_ID       = C_ERROR_CREATE
             , ERROR_TEXT     = V_NUMBER||' '||V_STRING
         where ID = V_FILE_HEADER_ID;
        commit;

    end;


    ------------------------------------------------------------------------------------
    procedure  DELETE_FILE_DATA ( I_FILE_HEADER_ID   in number ) is
    ------------------------------------------------------------------------------------
    begin
        delete FIO_FILE_BLOBS where FILE_HEADER_ID = I_FILE_HEADER_ID;
        delete FIO_FILE_LINES where FILE_HEADER_ID = I_FILE_HEADER_ID;
        update FIO_FILE_HEADERS 
           set FILE_STATUS_ID = C_STATUS_DELETED
         where ID = I_FILE_HEADER_ID;    
        commit;
    end;

    ------------------------------------------------------------------------------------
    procedure DELETE_FILES is
    ------------------------------------------------------------------------------------
        V_FILE_HEADER_ID    number;
        V_NUMBER            number;
        V_STRING            varchar2( 4000 );
    begin
        for L_FILES in ( select * from FIO_WAIT_FOR_DELETE_VW )
        loop

            V_FILE_HEADER_ID := L_FILES.ID;


            if L_FILES.FILE_TYPE_ID is null then

                update FIO_FILE_HEADERS 
                   set FILE_STATUS_ID = C_STATUS_DELETING
                     , ERROR_ID       = null 
                     , ERROR_TEXT     = null 
                 where ID = V_FILE_HEADER_ID;    
                commit;
                DELETE_FILE_DATA ( V_FILE_HEADER_ID );

            else

                for L_TYPES in ( select * from FIO_FILE_TYPES where ID = L_FILES.FILE_TYPE_ID )
                loop    
                    update FIO_FILE_HEADERS 
                       set FILE_STATUS_ID = C_STATUS_DELETING
                         , ERROR_ID       = null 
                         , ERROR_TEXT     = null 
                     where ID = V_FILE_HEADER_ID;    
                    commit;
                    begin
                        execute immediate L_TYPES.DELETE_PROCEDURE using V_FILE_HEADER_ID;
                    exception when others then
                        null;
                    end;
                end loop;

            end if;

        end loop;

    exception when others then

        V_NUMBER := sqlcode;
        V_STRING := sqlerrm;
        update FIO_FILE_HEADERS
           set FILE_STATUS_ID = C_STATUS_FAILED    
             , ERROR_ID       = C_ERROR_DELETE
             , ERROR_TEXT     = V_NUMBER||' '||V_STRING
         where ID = V_FILE_HEADER_ID;
        commit;

    end;


    ------------------------------------------------------------------------------------
    procedure  WRITE_TEXT_FILE ( I_FILE_HEADER_ID      in number ) is
    ------------------------------------------------------------------------------------
        V_FILE_HEADER   FIO_FILE_HEADERS%rowtype;
        V_FILE_LINE     FIO_FILE_LINES%rowtype;
        V_FILE          utl_file.file_type;
        V_HAS_ERROR     boolean  := false;
        V_NUMBER        number;
        V_STRING        varchar2( 4000 );
    begin
        V_FILE_LINE.FILE_HEADER_ID  := I_FILE_HEADER_ID;
        V_FILE_LINE.LINE_NO         := 0;

        select * into V_FILE_HEADER from FIO_FILE_HEADERS where ID = I_FILE_HEADER_ID;

        begin
            V_FILE := utl_file.fopen_nchar( V_FILE_HEADER.ORACLE_DIRECTORY, V_FILE_HEADER.NAME||'.tmp', 'W');
        exception when others then
            V_NUMBER := sqlcode;
            V_STRING := sqlerrm;
            update FIO_FILE_HEADERS
               set FILE_STATUS_ID = C_STATUS_FAILED    -- FAILED
                 , ERROR_ID       = C_ERROR_OPEN
                 , ERROR_TEXT     = null
             where ID = I_FILE_HEADER_ID;
            commit;
            return;
        end;

        update FIO_FILE_HEADERS 
           set FILE_STATUS_ID = C_STATUS_WRITING
             , ERROR_ID       = null 
             , ERROR_TEXT     = null
         where ID = I_FILE_HEADER_ID;     -- under writing out
        commit;

        for L_REC in ( select * from FIO_FILE_LINES where FILE_HEADER_ID = I_FILE_HEADER_ID order by LINE_NO asc )
        loop
            begin
                utl_file.put_line_nchar( V_FILE, L_REC.LINE);
            exception when others then
                V_NUMBER := sqlcode;
                V_STRING := sqlerrm;
                update FIO_FILE_HEADERS
                   set FILE_STATUS_ID = C_STATUS_FAILED    -- FAILED
                     , ERROR_ID       = C_ERROR_WRITE       
                     , ERROR_TEXT     = V_NUMBER||' '||V_STRING
                 where ID = I_FILE_HEADER_ID;
                commit;
                V_HAS_ERROR := true;
                exit;
            end;
        end loop;

        utl_file.fclose ( V_FILE );

        begin
            if V_HAS_ERROR then
                utl_file.frename( V_FILE_HEADER.ORACLE_DIRECTORY, V_FILE_HEADER.NAME||'.tmp', V_FILE_HEADER.ORACLE_DIRECTORY, V_FILE_HEADER.NAME||'.failed', true );
            else
                utl_file.frename( V_FILE_HEADER.ORACLE_DIRECTORY, V_FILE_HEADER.NAME||'.tmp', V_FILE_HEADER.ORACLE_DIRECTORY, V_FILE_HEADER.NAME, true );
            end if;
        exception when others then
            V_NUMBER := sqlcode;
            V_STRING := sqlerrm;
            update FIO_FILE_HEADERS
               set FILE_STATUS_ID = C_STATUS_FAILED    -- FAILED
                 , ERROR_ID       = C_ERROR_RENAME
                 , ERROR_TEXT     = V_NUMBER||' '||V_STRING
             where ID = I_FILE_HEADER_ID;
            commit;
            return;
        end;

        update FIO_FILE_HEADERS 
           set FILE_STATUS_ID = C_STATUS_WROTE      -- WRITTEN OUT
             , IO_DATE        = sysdate 
             , CREATED        = sysdate
             , MODIFIED       = sysdate
         where ID = I_FILE_HEADER_ID;     
        commit;

    exception when others then

        V_NUMBER := sqlcode;
        V_STRING := sqlerrm;
        update FIO_FILE_HEADERS
           set FILE_STATUS_ID = C_STATUS_FAILED    -- FAILED
             , ERROR_ID       = C_ERROR_OTHER
             , ERROR_TEXT     = V_NUMBER||' '||V_STRING
         where ID = I_FILE_HEADER_ID;
        commit;

        if utl_file.is_open( V_FILE ) then
            utl_file.fclose( V_FILE );
        end if;

        utl_file.frename( V_FILE_HEADER.ORACLE_DIRECTORY, V_FILE_HEADER.NAME||'.tmp', V_FILE_HEADER.ORACLE_DIRECTORY, V_FILE_HEADER.NAME||'.failed', true );

    end;


    ------------------------------------------------------------------------------------
    procedure  WRITE_BLOB_FILE  ( I_FILE_HEADER_ID      in number ) is
    ------------------------------------------------------------------------------------
        V_FILE_REC      FIO_FILE_HEADERS%rowtype;
        V_FILE_BLOB     FIO_FILE_BLOBS%rowtype;
        V_FILE          utl_file.file_type;
        V_BUFFER        raw(32767);
        V_BUFFER_SIZE   binary_integer;
        V_AMOUNT        binary_integer;
        V_OFFSET        number(38) := 1;
        V_CHUNKSIZE     integer;
        V_HAS_ERROR     boolean  := false;
        V_NUMBER        number;
        V_STRING        varchar2( 4000 );
    begin

        select * into V_FILE_REC  from FIO_FILE_HEADERS  where ID             = I_FILE_HEADER_ID;
        select * into V_FILE_BLOB from FIO_FILE_BLOBS    where FILE_HEADER_ID = I_FILE_HEADER_ID;

        V_CHUNKSIZE := dbms_lob.getchunksize( V_FILE_BLOB.FILE_DATA );

        if ( V_CHUNKSIZE < 32767 ) then
            V_BUFFER_SIZE := V_CHUNKSIZE;
        else
            V_BUFFER_SIZE := 32767;
        end if;

        V_AMOUNT := V_BUFFER_SIZE;

        dbms_lob.open( V_FILE_BLOB.FILE_DATA, dbms_lob.lob_readonly);

        begin
            V_FILE := utl_file.fopen( location => V_FILE_REC.ORACLE_DIRECTORY, filename => V_FILE_REC.NAME || '.tmp', open_mode => 'WB', max_linesize  => 32767 );
        exception when others then
            V_NUMBER := sqlcode;
            V_STRING := sqlerrm;
            update FIO_FILE_HEADERS
               set FILE_STATUS_ID = C_STATUS_FAILED    -- FAILED
                 , ERROR_ID       = C_ERROR_OPEN
                 , ERROR_TEXT     = V_NUMBER||' '||V_STRING
             where ID = I_FILE_HEADER_ID;
            commit;
            return;
        end;

        update FIO_FILE_HEADERS 
           set FILE_STATUS_ID = C_STATUS_WRITING
             , ERROR_ID       = null 
             , ERROR_TEXT     = null
         where ID = I_FILE_HEADER_ID;     -- under writing out
        commit;

        while V_AMOUNT >= V_BUFFER_SIZE
        loop

            begin
                dbms_lob.read( lob_loc => V_FILE_BLOB.FILE_DATA, amount => V_AMOUNT, offset => V_OFFSET, buffer => V_BUFFER );
                V_OFFSET := V_OFFSET + V_AMOUNT;
                utl_file.put_raw ( file => V_FILE, buffer => V_BUFFER, autoflush => true );
                utl_file.fflush( file => V_FILE );
            exception when others then
                V_NUMBER := sqlcode;
                V_STRING := sqlerrm;
                update FIO_FILE_HEADERS
                   set FILE_STATUS_ID = C_STATUS_FAILED    -- FAILED
                     , ERROR_ID       = C_ERROR_WRITE      
                     , ERROR_TEXT     = V_NUMBER||' '||V_STRING
                 where ID = I_FILE_HEADER_ID;
                commit;
                V_HAS_ERROR := true;
                exit;
            end;

        end loop;

        utl_file.fflush( file => V_FILE );
        utl_file.fclose( V_FILE );
        dbms_lob.close ( V_FILE_BLOB.FILE_DATA );

        begin
            if V_HAS_ERROR then
                utl_file.frename( V_FILE_REC.ORACLE_DIRECTORY, V_FILE_REC.NAME||'.tmp', V_FILE_REC.ORACLE_DIRECTORY, V_FILE_REC.NAME||'.failed', true );
            else
                utl_file.frename( V_FILE_REC.ORACLE_DIRECTORY, V_FILE_REC.NAME||'.tmp', V_FILE_REC.ORACLE_DIRECTORY, V_FILE_REC.NAME, true );
            end if;
        exception when others then
            V_NUMBER := sqlcode;
            V_STRING := sqlerrm;
            update FIO_FILE_HEADERS
               set FILE_STATUS_ID = C_STATUS_FAILED    -- FAILED
                 , ERROR_ID       = C_ERROR_RENAME
                 , ERROR_TEXT     = V_NUMBER||' '||V_STRING
             where ID = I_FILE_HEADER_ID;
            commit;
            return;
        end;

        update FIO_FILE_HEADERS 
           set FILE_STATUS_ID = C_STATUS_WROTE       -- WRITTEN OUT
             , IO_DATE        = sysdate 
             , CREATED        = sysdate
             , MODIFIED       = sysdate
         where ID = I_FILE_HEADER_ID;     
        commit;

    exception when others then

        V_NUMBER := sqlcode;
        V_STRING := sqlerrm;
        update FIO_FILE_HEADERS
           set FILE_STATUS_ID = C_STATUS_FAILED    -- FAILED
             , ERROR_ID       = C_ERROR_OTHER
             , ERROR_TEXT     = V_NUMBER||' '||V_STRING
         where ID = I_FILE_HEADER_ID;
        commit;

        if utl_file.is_open( V_FILE ) then
            utl_file.fclose( V_FILE );
        end if;

        utl_file.frename( V_FILE_REC.ORACLE_DIRECTORY, V_FILE_REC.NAME||'.tmp', V_FILE_REC.ORACLE_DIRECTORY, V_FILE_REC.NAME||'.failed', true );

    end WRITE_BLOB_FILE;



    ------------------------------------------------------------------------------------
    procedure WRITE_FILES is
    ------------------------------------------------------------------------------------
    begin
        for L_FILES in ( select * from FIO_WAIT_FOR_WRITE_VW )
        loop
            if L_FILES.TEXT_FILE_FLAG = 1 then
                WRITE_TEXT_FILE( L_FILES.ID );
            else
                WRITE_BLOB_FILE( L_FILES.ID );
            end if;
        end loop;
    end;



    ------------------------------------------------------------------------------------
    procedure  INP_JOB_PROC is
    ------------------------------------------------------------------------------------
    begin
        READ_FILES;
        IDENTIFY_FILES;
        CHECK_FILES;
        PROCESS_FILES;
    end;


    ------------------------------------------------------------------------------------
    procedure  OUT_JOB_PROC is
    ------------------------------------------------------------------------------------
    begin
        CREATE_FILES;
        WRITE_FILES; 
    end;

    ------------------------------------------------------------------------------------
    procedure  CLEAN_JOB_PROC is
    ------------------------------------------------------------------------------------
    begin
        DELETE_FILES;
    end;




end;
/





/*************************************/
Prompt   J O B S
/*************************************/

DECLARE
  X NUMBER;
BEGIN
  SYS.DBMS_JOB.SUBMIT
    ( job       => X
     ,what      => 'PKG_FIO.INP_JOB_PROC;'
     ,next_date => SYSDATE+5/1440
     ,interval  => 'SYSDATE+5/1440'
     ,no_parse  => TRUE
    );
END;
/


DECLARE
  X NUMBER;
BEGIN
  SYS.DBMS_JOB.SUBMIT
    ( job       => X
     ,what      => 'PKG_FIO.OUT_JOB_PROC;'
     ,next_date => SYSDATE+5/1440
     ,interval  => 'SYSDATE+5/1440'
     ,no_parse  => TRUE
    );
END;
/

DECLARE
  X NUMBER;
BEGIN
  SYS.DBMS_JOB.SUBMIT
    ( job       => X
     ,what      => 'PKG_FIO.CLEAN_JOB_PROC;'
     ,next_date => SYSDATE+5/1440
     ,interval  => 'SYSDATE+5/1440'
     ,no_parse  => TRUE
    );
END;
/
COMMIT;




