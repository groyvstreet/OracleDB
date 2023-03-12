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

    dev_table_columns SYS_REFCURSOR;
    prod_table_columns SYS_REFCURSOR;

    dev_table_constraints SYS_REFCURSOR;
    prod_table_constraints SYS_REFCURSOR;

    amount number;

    columns_amount1 number;
    columns_amount2 number;

    column_name1 all_tab_columns.column_name%TYPE;
    data_type1 all_tab_columns.data_type%TYPE;
    data_length1 all_tab_columns.data_length%TYPE;
    nullable1 all_tab_columns.nullable%TYPE;

    column_name2 all_tab_columns.column_name%TYPE;
    data_type2 all_tab_columns.data_type%TYPE;
    data_length2 all_tab_columns.data_length%TYPE;
    nullable2 all_tab_columns.nullable%TYPE;

    constraints_amount1 number;
    constraints_amount2 number;

    constraint_name1 all_constraints.constraint_name%TYPE;
    constraint_type1 all_constraints.constraint_type%TYPE;
    search_condition1 all_constraints.search_condition%TYPE;

    constraint_name2 all_constraints.constraint_name%TYPE;
    constraint_type2 all_constraints.constraint_type%TYPE;
    search_condition2 all_constraints.search_condition%TYPE;
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
                open dev_table_columns for
                    select column_name, data_type, data_length, nullable
                    from all_tab_columns
                    where owner = dev_schema_name
                        and table_name = dev_schema_table.table_name
                    order by column_name;
                open prod_table_columns for
                    select column_name, data_type, data_length, nullable
                    from all_tab_columns
                    where owner = prod_schema_name
                        and table_name = dev_schema_table.table_name
                    order by column_name;

                loop
                    fetch dev_table_columns into column_name1, data_type1, data_length1, nullable1;
                    fetch prod_table_columns into column_name2, data_type2, data_length2, nullable2;
                    
                    if column_name1 <> column_name2 or data_type1 <> data_type2 or data_length1 <> data_length2 or nullable1 <> nullable2 then
                        dbms_output.put_line(dev_schema_table.table_name);
                        exit;
                    end if;

                    exit when dev_table_columns%NOTFOUND and prod_table_columns%NOTFOUND;
                end loop;

                close dev_table_columns;
                close prod_table_columns;
            else
                dbms_output.put_line(dev_schema_table.table_name);
            end if;

            select count(*) into constraints_amount1 from all_constraints where owner = dev_schema_name and table_name = dev_schema_table.table_name;
            select count(*) into constraints_amount2 from all_constraints where owner = prod_schema_name and table_name = dev_schema_table.table_name;
            if constraints_amount1 = constraints_amount2 then
                open dev_table_constraints for
                    select constraint_name, constraint_type, search_condition
                    from all_constraints
                    where owner = dev_schema_name
                        and table_name = dev_schema_table.table_name
                    order by constraint_name;
                open prod_table_constraints for
                    select constraint_name, constraint_type, search_condition
                    from all_constraints
                    where owner = prod_schema_name
                        and table_name = dev_schema_table.table_name
                    order by constraint_name;

                loop
                    fetch dev_table_constraints into constraint_name1, constraint_type1, search_condition1;
                    fetch prod_table_constraints into constraint_name2, constraint_type2, search_condition2;
                    
                    if constraint_name1 <> constraint_name2 or constraint_type1 <> constraint_type2 or search_condition1 <> search_condition2 then
                        dbms_output.put_line(dev_schema_table.table_name);
                        exit;
                    end if;

                    exit when dev_table_constraints%NOTFOUND and prod_table_constraints%NOTFOUND;
                end loop;

                close dev_table_constraints;
                close prod_table_constraints;
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
