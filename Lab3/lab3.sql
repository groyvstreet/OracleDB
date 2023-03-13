alter session set "_ORACLE_SCRIPT"=true;
create user dev_schema identified by 1;
create user prod_schema identified by 1;

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

create or replace procedure get_differences(dev_schema_name varchar2, prod_schema_name varchar2) is
begin
    get_tables(dev_schema_name, prod_schema_name);
    get_procedures(dev_schema_name, prod_schema_name);
    get_functions(dev_schema_name, prod_schema_name);
    get_indexes(dev_schema_name, prod_schema_name);
    get_packages(dev_schema_name, prod_schema_name);
end get_differences;

create or replace procedure ddl_create_table(dev_schema_name varchar2, tab_name varchar2, prod_schema_name varchar2) is
    cursor table_columns is
        select column_name, data_type, data_length, nullable
        from all_tab_columns
        where owner = dev_schema_name
            and table_name = tab_name
        order by column_name;
    cursor table_constraints is
        select all_constraints.constraint_name, all_constraints.constraint_type, all_constraints.search_condition, all_ind_columns.column_name
        from all_constraints
        inner join all_ind_columns
        on all_constraints.constraint_name = all_ind_columns.index_name
        where owner = dev_schema_name
            and all_constraints.table_name = tab_name
        order by all_constraints.constraint_name;
begin
    dbms_output.put_line('DROP TABLE ' || prod_schema_name || '.' || UPPER(tab_name) || ';');
    dbms_output.put_line('CREATE TABLE ' || prod_schema_name || '.' || UPPER(tab_name) || '(');
    for table_column in table_columns
    loop
        dbms_output.put(table_column.column_name || ' ' || table_column.data_type || '(' || table_column.data_length || ')');
        if table_column.nullable = 'N' then
            dbms_output.put(' NOT NULL');
        end if;
        dbms_output.put_line(',');
    end loop;
    for table_constraint in table_constraints
    loop
        dbms_output.put('CONSTRAINT ' || table_constraint.constraint_name || ' ');
        if table_constraint.constraint_type = 'U' then
            dbms_output.put('UNIQUE ');
        end if;
        dbms_output.put_line('(' || table_constraint.column_name || ' ' || table_constraint.search_condition || ')');
    end loop;
    dbms_output.put_line(')');
end ddl_create_table;

create or replace procedure ddl_create_procedure(dev_schema_name varchar2, procedure_name varchar2, prod_schema_name varchar2) is
    cursor procedure_text is
        select text
        from all_source
        where owner = dev_schema_name
            and name = procedure_name
            and type = 'PROCEDURE'
            and line <> 1;
    cursor procedure_args is
        select argument_name, data_type
        from all_arguments
        where owner = dev_schema_name
            and object_name = procedure_name
            and position <> 0;
begin
    dbms_output.put('CREATE OR REPLACE PROCEDURE ' || prod_schema_name || '.' || procedure_name);
    dbms_output.put('(');
    for arg in procedure_args
    loop
        dbms_output.put(arg.argument_name || ' ' || arg.data_type || ', ');
    end loop;
    dbms_output.put_line(') IS');

    for line in procedure_text
    loop
        dbms_output.put(line.text);
    end loop;
    dbms_output.put_line('');
end ddl_create_procedure;

create or replace procedure ddl_create_function(dev_schema_name varchar2, function_name varchar2, prod_schema_name varchar2) is
    cursor procedure_text is
        select text
        from all_source
        where owner = dev_schema_name
            and name = function_name
            and type = 'FUNCTION'
            and line <> 1;
    cursor procedure_args is
        select argument_name, data_type
        from all_arguments
        where owner = dev_schema_name
            and object_name = function_name
            and position <> 0;
    arg_type all_arguments.data_type%TYPE;
begin
    dbms_output.put('CREATE OR REPLACE FUNCTION ' || prod_schema_name || '.' || function_name);
    dbms_output.put('(');
    for arg in procedure_args
    loop
        dbms_output.put(arg.argument_name || ' ' || arg.data_type || ', ');
    end loop;
    select data_type into arg_type from all_arguments where owner = dev_schema_name and object_name = function_name and position = 0;
    dbms_output.put_line(') RETURN ' || arg_type || ' IS');

    for line in procedure_text
    loop
        dbms_output.put(line.text);
    end loop;
    dbms_output.put_line('');
end ddl_create_function;

create or replace procedure ddl_create_index(dev_schema_name varchar2, ind_name varchar2, prod_schema_name varchar2) is
    tab_name all_indexes.table_name%TYPE;

    cursor index_columns is
        select column_name
        from all_ind_columns
        inner join all_indexes
        on all_ind_columns.index_name = all_indexes.index_name
            and all_ind_columns.index_owner = all_indexes.owner
        where index_owner = dev_schema_name
            and all_indexes.index_name = ind_name;
begin
    select table_name into tab_name from all_indexes where owner = dev_schema_name and index_name = ind_name;
    dbms_output.put_line('DROP INDEX ' || prod_schema_name || '.' || ind_name || ';');
    dbms_output.put('CREATE INDEX ' || prod_schema_name || '.' || ind_name || ' ON ' || prod_schema_name || '.' || tab_name || '(');
    for index_column in index_columns
    loop
        dbms_output.put(index_column.column_name || ', ');
    end loop;
    dbms_output.put_line(');');
end ddl_create_index;

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
            ddl_create_table(dev_schema_name, dev_schema_table.table_name, prod_schema_name);
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
                        ddl_create_table(dev_schema_name, dev_schema_table.table_name, prod_schema_name);
                        exit;
                    end if;

                    exit when dev_table_columns%NOTFOUND and prod_table_columns%NOTFOUND;
                end loop;

                close dev_table_columns;
                close prod_table_columns;
            else
                dbms_output.put_line(dev_schema_table.table_name);
                ddl_create_table(dev_schema_name, dev_schema_table.table_name, prod_schema_name);
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
                        ddl_create_table(dev_schema_name, dev_schema_table.table_name, prod_schema_name);
                        exit;
                    end if;

                    exit when dev_table_constraints%NOTFOUND and prod_table_constraints%NOTFOUND;
                end loop;

                close dev_table_constraints;
                close prod_table_constraints;
            else
                dbms_output.put_line(dev_schema_table.table_name);
                ddl_create_table(dev_schema_name, dev_schema_table.table_name, prod_schema_name);
            end if;
        end if;
    end loop;
end get_tables;

create or replace procedure get_procedures(dev_schema_name varchar2, prod_schema_name varchar2) is
    cursor dev_schema_procedures is
        select distinct name
        from all_source
        where owner = dev_schema_name
            and type = 'PROCEDURE';

    dev_procedure_text SYS_REFCURSOR;
    prod_procedure_text SYS_REFCURSOR;

    dev_procedure_args SYS_REFCURSOR;
    prod_procedure_args SYS_REFCURSOR;

    amount number;

    args_amount1 number;
    args_amount2 number;

    arg1 all_arguments.argument_name%TYPE;
    type1 all_arguments.data_type%TYPE;

    arg2 all_arguments.argument_name%TYPE;
    type2 all_arguments.data_type%TYPE;

    lines_amount1 number;
    lines_amount2 number;

    line1 all_source.text%TYPE;
    line2 all_source.text%TYPE;
begin
    for dev_schema_procedure in dev_schema_procedures
    loop
        select count(*) into amount from all_source where owner = prod_schema_name and type = 'PROCEDURE' and name = dev_schema_procedure.name;
        if amount = 0 then
            dbms_output.put_line(dev_schema_procedure.name);
            ddl_create_procedure(dev_schema_name, dev_schema_procedure.name, prod_schema_name);
        else
            select count(*) into args_amount1 from all_arguments where owner = dev_schema_name and object_name = dev_schema_procedure.name;
            select count(*) into args_amount2 from all_arguments where owner = prod_schema_name and object_name = dev_schema_procedure.name;
            if args_amount1 = args_amount2 then
                open dev_procedure_args for
                    select argument_name, data_type
                    from all_arguments
                    where owner = dev_schema_name
                        and object_name = dev_schema_procedure.name
                    order by position;
                open prod_procedure_args for
                    select argument_name, data_type
                    from all_arguments
                    where owner = prod_schema_name
                        and object_name = dev_schema_procedure.name
                    order by position;

                loop
                    fetch dev_procedure_args into arg1, type1;
                    fetch prod_procedure_args into arg2, type2;
                    
                    if arg1 <> arg2 or type1 <> type2 then
                        dbms_output.put_line(dev_schema_procedure.name);
                        ddl_create_procedure(dev_schema_name, dev_schema_procedure.name, prod_schema_name);
                        exit;
                    end if;

                    exit when dev_procedure_args%NOTFOUND and prod_procedure_args%NOTFOUND;
                end loop;

                close dev_procedure_args;
                close prod_procedure_args;
            else
                dbms_output.put_line(dev_schema_procedure.name);
                ddl_create_procedure(dev_schema_name, dev_schema_procedure.name, prod_schema_name);
            end if;

            select count(*) into lines_amount1 from all_source where owner = dev_schema_name and type = 'PROCEDURE' and name = dev_schema_procedure.name;
            select count(*) into lines_amount2 from all_source where owner = prod_schema_name and type = 'PROCEDURE' and name = dev_schema_procedure.name;
            if lines_amount1 = lines_amount2 then
                open dev_procedure_text for
                    select text
                    from all_source
                    where owner = dev_schema_name
                        and name = dev_schema_procedure.name
                        and line <> 1
                    order by line;
                open prod_procedure_text for
                    select text
                    from all_source
                    where owner = prod_schema_name
                        and name = dev_schema_procedure.name
                        and line <> 1
                    order by line;

                loop
                    fetch dev_procedure_text into line1;
                    fetch prod_procedure_text into line2;
                    
                    if line1 <> line2 then
                        dbms_output.put_line(dev_schema_procedure.name);
                        ddl_create_procedure(dev_schema_name, dev_schema_procedure.name, prod_schema_name);
                        exit;
                    end if;

                    exit when dev_procedure_text%NOTFOUND and prod_procedure_text%NOTFOUND;
                end loop;

                close dev_procedure_text;
                close prod_procedure_text;
            else
                dbms_output.put_line(dev_schema_procedure.name);
                ddl_create_procedure(dev_schema_name, dev_schema_procedure.name, prod_schema_name);
            end if;
        end if;
    end loop;
end get_procedures;

create or replace procedure get_functions(dev_schema_name varchar2, prod_schema_name varchar2) is
    cursor dev_schema_functions is
        select distinct name
        from all_source
        where owner = dev_schema_name
            and type = 'FUNCTION';

    dev_function_text SYS_REFCURSOR;
    prod_function_text SYS_REFCURSOR;

    dev_function_args SYS_REFCURSOR;
    prod_function_args SYS_REFCURSOR;

    amount number;

    args_amount1 number;
    args_amount2 number;

    arg1 all_arguments.argument_name%TYPE;
    type1 all_arguments.data_type%TYPE;

    arg2 all_arguments.argument_name%TYPE;
    type2 all_arguments.data_type%TYPE;

    lines_amount1 number;
    lines_amount2 number;

    line1 all_source.text%TYPE;
    line2 all_source.text%TYPE;
begin
    for dev_schema_function in dev_schema_functions
    loop
        select count(*) into amount from all_source where owner = prod_schema_name and type = 'FUNCTION' and name = dev_schema_function.name;
        if amount = 0 then
            dbms_output.put_line(dev_schema_function.name);
            ddl_create_function(dev_schema_name, dev_schema_function.name, prod_schema_name);
        else
            select count(*) into args_amount1 from all_arguments where owner = dev_schema_name and object_name = dev_schema_function.name;
            select count(*) into args_amount2 from all_arguments where owner = prod_schema_name and object_name = dev_schema_function.name;
            if args_amount1 = args_amount2 then
                open dev_function_args for
                    select argument_name, data_type
                    from all_arguments
                    where owner = dev_schema_name
                        and object_name = dev_schema_function.name
                    order by position;
                open prod_function_args for
                    select argument_name, data_type
                    from all_arguments
                    where owner = prod_schema_name
                        and object_name = dev_schema_function.name
                    order by position;

                loop
                    fetch dev_function_args into arg1, type1;
                    fetch prod_function_args into arg2, type2;
                    
                    if arg1 <> arg2 or type1 <> type2 then
                        dbms_output.put_line(dev_schema_function.name);
                        ddl_create_function(dev_schema_name, dev_schema_function.name, prod_schema_name);
                        exit;
                    end if;

                    exit when dev_function_args%NOTFOUND and prod_function_args%NOTFOUND;
                end loop;

                close dev_function_args;
                close prod_function_args;
            else
                dbms_output.put_line(dev_schema_function.name);
                ddl_create_function(dev_schema_name, dev_schema_function.name, prod_schema_name);
            end if;

            select count(*) into lines_amount1 from all_source where owner = dev_schema_name and type = 'FUNCTION' and name = dev_schema_function.name;
            select count(*) into lines_amount2 from all_source where owner = prod_schema_name and type = 'FUNCTION' and name = dev_schema_function.name;
            if lines_amount1 = lines_amount2 then
                open dev_function_text for
                    select text
                    from all_source
                    where owner = dev_schema_name
                        and name = dev_schema_function.name
                        and line <> 1
                    order by line;
                open prod_function_text for
                    select text
                    from all_source
                    where owner = prod_schema_name
                        and name = dev_schema_function.name
                        and line <> 1
                    order by line;

                loop
                    fetch dev_function_text into line1;
                    fetch prod_function_text into line2;
                    
                    if line1 <> line2 then
                        dbms_output.put_line(dev_schema_function.name);
                        ddl_create_function(dev_schema_name, dev_schema_function.name, prod_schema_name);
                        exit;
                    end if;

                    exit when dev_function_text%NOTFOUND and prod_function_text%NOTFOUND;
                end loop;

                close dev_function_text;
                close prod_function_text;
            else
                dbms_output.put_line(dev_schema_function.name);
                ddl_create_function(dev_schema_name, dev_schema_function.name, prod_schema_name);
            end if;
        end if;
    end loop;
end get_functions;

create or replace procedure get_indexes(dev_schema_name varchar2, prod_schema_name varchar2) is
    cursor dev_schema_indexes is
        select index_name
        from all_indexes
        where owner = dev_schema_name;

    amount number;

    index1_columns SYS_REFCURSOR;
    index2_columns SYS_REFCURSOR;

    columns_amount1 number;
    columns_amount2 number;

    index_type1 all_indexes.index_type%TYPE;
    table_name1 all_indexes.table_name%TYPE;
    uniqueness1 all_indexes.uniqueness%TYPE;
    column_name1 all_ind_columns.column_name%TYPE;

    index_type2 all_indexes.index_type%TYPE;
    table_name2 all_indexes.table_name%TYPE;
    uniqueness2 all_indexes.uniqueness%TYPE;
    column_name2 all_ind_columns.column_name%TYPE;
begin
    for dev_schema_index in dev_schema_indexes
    loop
        select count(*) into amount from all_indexes where owner = prod_schema_name and index_name = dev_schema_index.index_name;
        if amount = 0 then
            dbms_output.put_line(dev_schema_index.index_name);
            ddl_create_index(dev_schema_name, dev_schema_index.index_name, prod_schema_name);
        else
            select index_type, table_name, uniqueness
            into index_type1, table_name1, uniqueness1
            from all_indexes
            where owner = dev_schema_name
                and index_name = dev_schema_index.index_name;

            select index_type, table_name, uniqueness
            into index_type2, table_name2, uniqueness2
            from all_indexes
            where owner = prod_schema_name
                and index_name = dev_schema_index.index_name;

            if index_type1 = index_type2 and table_name1 = table_name2 and uniqueness1 = uniqueness2 then
                select count(*)
                into columns_amount1
                from all_indexes
                inner join all_ind_columns
                on all_indexes.index_name = all_ind_columns.index_name and all_indexes.owner = all_ind_columns.index_owner
                where all_indexes.owner = dev_schema_name
                    and all_indexes.index_name = dev_schema_index.index_name;

                select count(*)
                into columns_amount2
                from all_indexes
                inner join all_ind_columns
                on all_indexes.index_name = all_ind_columns.index_name and all_indexes.owner = all_ind_columns.index_owner
                where all_indexes.owner = prod_schema_name
                    and all_indexes.index_name = dev_schema_index.index_name;

                if columns_amount1 = columns_amount2 then
                    open index1_columns for
                        select column_name
                        from all_ind_columns
                        where index_owner = dev_schema_name
                            and index_name = dev_schema_index.index_name
                        group by column_name;
                    
                    open index2_columns for
                        select column_name
                        from all_ind_columns
                        where index_owner = prod_schema_name
                            and index_name = dev_schema_index.index_name
                        group by column_name;

                    loop
                        fetch index1_columns into column_name1;
                        fetch index2_columns into column_name2;

                        if column_name1 <> column_name2 then
                            dbms_output.put_line(dev_schema_index.index_name);
                            ddl_create_index(dev_schema_name, dev_schema_index.index_name, prod_schema_name);
                            exit;
                        end if;

                        exit when index1_columns%NOTFOUND and index2_columns%NOTFOUND;
                    end loop;

                    close index1_columns;
                    close index2_columns;
                else
                    dbms_output.put_line(dev_schema_index.index_name);
                    ddl_create_index(dev_schema_name, dev_schema_index.index_name, prod_schema_name);
                end if;
            else
                dbms_output.put_line(dev_schema_index.index_name);
                ddl_create_index(dev_schema_name, dev_schema_index.index_name, prod_schema_name);
            end if;
        end if;
    end loop;
end get_indexes;

create or replace procedure get_packages(dev_schema_name varchar2, prod_schema_name varchar2) is
    cursor dev_schema_packages is
        select distinct name
        from all_source
        where owner = dev_schema_name
            and type = 'PACKAGE';

    dev_package_text SYS_REFCURSOR;
    prod_package_text SYS_REFCURSOR;

    amount number;

    lines_amount1 number;
    lines_amount2 number;

    line1 all_source.text%TYPE;
    line2 all_source.text%TYPE;
begin
    for dev_schema_package in dev_schema_packages
    loop
        select count(*) into amount from all_source where owner = prod_schema_name and type = 'PACKAGE' and name = dev_schema_package.name;
        if amount = 0 then
            dbms_output.put_line(dev_schema_package.name);
        else
            select count(*) into lines_amount1 from all_source where owner = dev_schema_name and type = 'PACKAGE' and name = dev_schema_package.name;
            select count(*) into lines_amount2 from all_source where owner = prod_schema_name and type = 'PACKAGE' and name = dev_schema_package.name;
            if lines_amount1 = lines_amount2 then
                open dev_package_text for
                    select text
                    from all_source
                    where owner = dev_schema_name
                        and name = dev_schema_package.name
                        and line <> 1
                    order by line;
                open prod_package_text for
                    select text
                    from all_source
                    where owner = prod_schema_name
                        and name = dev_schema_package.name
                        and line <> 1
                    order by line;

                loop
                    fetch dev_package_text into line1;
                    fetch prod_package_text into line2;
                    
                    if line1 <> line2 then
                        dbms_output.put_line(dev_schema_package.name);
                        exit;
                    end if;

                    exit when dev_package_text%NOTFOUND and prod_package_text%NOTFOUND;
                end loop;

                close dev_package_text;
                close prod_package_text;
            else
                dbms_output.put_line(dev_schema_package.name);
            end if;
        end if;
    end loop;
end get_packages;

begin
    get_tables('DEV_SCHEMA', 'PROD_SCHEMA');
end;

begin
    get_procedures('DEV_SCHEMA', 'PROD_SCHEMA');
end;

begin
    get_functions('DEV_SCHEMA', 'PROD_SCHEMA');
end;

begin
    get_indexes('DEV_SCHEMA', 'PROD_SCHEMA');
end;

create table dev_schema.mytable(
    id number,
    val number,
    constraint id_unique unique (id)
);

create table prod_schema.mytable(
    id number,
    val number
);

create or replace procedure dev_schema.test_proc1 is
begin
    dbms_output.put_line('HELLO');
end;

create or replace function dev_schema.test_func1(arg1 number, arg2 number) return number is
begin
    return 1;
end;

create index dev_schema.test_index1 on dev_schema.mytable(id);
create index prod_schema.test_index1 on prod_schema.mytable(id);

select * from all_tab_columns where owner = 'DEV_SCHEMA' or owner = 'PROD_SCHEMA';
select * from all_source where name = 'TEST_PROC1';
