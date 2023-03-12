-- 1.
alter session set "_ORACLE_SCRIPT"=true;
create user dev_schema identified by 1;
create user prod_schema identified by 1;

--
grant create session to dev_schema;
grant create table to dev_schema;
grant create procedure to dev_schema;
grant create trigger to dev_schema;
grant create view to dev_schema;
grant create sequence to dev_schema;
grant alter any table to dev_schema;
grant alter any procedure to dev_schema;
grant alter any trigger to dev_schema;
grant alter profile to dev_schema;
grant delete any table to dev_schema;
grant drop any table to dev_schema;
grant drop any procedure to dev_schema;
grant drop any trigger to dev_schema;
grant drop any view to dev_schema;
grant drop profile to dev_schema;

grant select on sys.v_$session to dev_schema;
grant select on sys.v_$sesstat to dev_schema;
grant select on sys.v_$statname to dev_schema;
grant SELECT ANY DICTIONARY to dev_schema;

--
grant create session to prod_schema;
grant create table to prod_schema;
grant create procedure to prod_schema;
grant create trigger to prod_schema;
grant create view to prod_schema;
grant create sequence to prod_schema;
grant alter any table to prod_schema;
grant alter any procedure to prod_schema;
grant alter any trigger to prod_schema;
grant alter profile to prod_schema;
grant delete any table to prod_schema;
grant drop any table to prod_schema;
grant drop any procedure to prod_schema;
grant drop any trigger to prod_schema;
grant drop any view to prod_schema;
grant drop profile to prod_schema;

grant select on sys.v_$session to prod_schema;
grant select on sys.v_$sesstat to prod_schema;
grant select on sys.v_$statname to prod_schema;
grant SELECT ANY DICTIONARY to prod_schema;

create or replace procedure get_tables(dev_schema_name varchar2, prod_schema_name varchar2) is
    cursor dev_schema_tables is
        select *
        from all_tables
        where owner = dev_schema_name;
    cursor dev_table_columns(tab_name varchar2) is
        select *
        from all_tab_columns
        where owner = dev_schema_name
            and table_name = tab_name
        order by column_name;
    amount number;
    columns_amount1 number;
    columns_amount2 number;
begin
    for dev_schema_table in dev_schema_tables
    loop
        select count(*) into amount from all_tables where owner = prod_schema_name and table_name = dev_schema_table.table_name;
        if amount = 0 then
            dbms_output.put_line(dev_schema_table.table_name);
        else
            select count(*) into columns_amount1 from all_tab_columns where owner = dev_schema_name and table_name = dev_schema_table.table_name;
            select count(*) into columns_amount2 from all_tab_columns where owner = prod_schema_name and table_name = dev_schema_table.table_name;
            if columns_amount1 = columns_amount2 then
                for record in dev_table_columns(dev_schema_table.table_name)
                loop
                    select count(*) into amount from all_tab_columns where owner = prod_schema_name and table_name = dev_schema_table.table_name and
                        column_name = record.column_name and data_type = record.data_type and data_length = record.data_length and
                        nullable = record.nullable;
                    if amount = 0 then
                        dbms_output.put_line(dev_schema_table.table_name);
                        exit;
                    end if;
                end loop;
            else
                dbms_output.put_line(dev_schema_table.table_name);
            end if;
        end if;
    end loop;
end get_tables;

begin
    get_tables('DEV_SCHEMA', 'PROD_SCHEMA');
end;

create table dev_schema.mytable(
    id number,
    val number
);

create table prod_schema.mytable(
    id number,
    val number
);

select * from all_tab_columns where owner = 'DEV_SCHEMA' or owner = 'PROD_SCHEMA';
