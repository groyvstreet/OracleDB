create or replace procedure execute_request(json_text clob) is
    json json_object_t;
    temp_array json_array_t;
    temp_array2 json_array_t;
    temp_object json_object_t;

    request_type clob;
    cols clob;
    tabs clob;
    joins clob;
    conditions clob;
    condition_type clob;
    vals clob;
    prim clob;
begin
    json := json_object_t.parse(json_text);

    request_type := json.get_string('request');

    if request_type = 'select' then
        -- columns
        temp_array := json.get_array('columns');

        for i in 0..temp_array.get_size() - 1
        loop
            if i = temp_array.get_size() - 1 then
                cols := cols || temp_array.get_string(i);
            else
                cols := cols || temp_array.get_string(i) || ', ';
            end if;
        end loop;

        -- tables
        temp_array := json.get_array('tables');

        for i in 0..temp_array.get_size() - 1
        loop
            if i = temp_array.get_size() - 1 then
                tabs := tabs || temp_array.get_string(i);
            else
                tabs := tabs || temp_array.get_string(i) || ', ';
            end if;
        end loop;

        -- joins
        temp_array := json.get_array('joins');

        if temp_array.get_size() <> 0 then
            for i in 0..temp_array.get_size() - 1
            loop
                temp_object := treat(temp_array.get(i) as json_object_t);

                joins := joins || ' ' || temp_object.get_string('type') || ' join ' || temp_object.get_string('table') || ' on ' || temp_object.get_string('on');
            end loop;
        end if;

        -- conditions
        temp_array := json.get_array('conditions');

        if temp_array.get_size() <> 0 then
            conditions := ' where';

            for i in 0..temp_array.get_size() - 1
            loop
                temp_object := treat(temp_array.get(i) as json_object_t);

                condition_type := temp_object.get_string('type');

                if condition_type = 'default' then
                    conditions := conditions || ' ' || temp_object.get_string('condition');
                else
                    conditions := conditions || ' (' || parse_request(treat(temp_object.get('condition') as json_object_t)) || ')';
                end if;
            end loop;
        end if;

        dbms_output.put_line('select ' || cols || ' from ' || tabs || joins || conditions);
    end if;

    if request_type = 'delete' then
        -- conditions
        temp_array := json.get_array('conditions');

        if temp_array.get_size() <> 0 then
            conditions := ' where';

            for i in 0..temp_array.get_size() - 1
            loop
                temp_object := treat(temp_array.get(i) as json_object_t);

                condition_type := temp_object.get_string('type');

                if condition_type = 'default' then
                    conditions := conditions || ' ' || temp_object.get_string('condition');
                else
                    conditions := conditions || ' (' || parse_request(treat(temp_object.get('condition') as json_object_t)) || ')';
                end if;
            end loop;
        end if;

        dbms_output.put_line('delete from ' || json.get_string('table') || conditions);
    end if;

    if request_type = 'update' then
        -- columns
        temp_array := json.get_array('columns');

        for i in 0..temp_array.get_size() - 1
        loop
            temp_object := treat(temp_array.get(i) as json_object_t);

            if i = temp_array.get_size() - 1 then
                cols := cols || temp_object.get_string('key') || ' = ' || temp_object.get_string('value');
            else
                cols := cols || temp_object.get_string('key') || ' = ' || temp_object.get_string('value') || ', ';
            end if;
        end loop;

        -- conditions
        temp_array := json.get_array('conditions');

        if temp_array.get_size() <> 0 then
            conditions := ' where';

            for i in 0..temp_array.get_size() - 1
            loop
                temp_object := treat(temp_array.get(i) as json_object_t);

                condition_type := temp_object.get_string('type');

                if condition_type = 'default' then
                    conditions := conditions || ' ' || temp_object.get_string('condition');
                else
                    conditions := conditions || ' (' || parse_request(treat(temp_object.get('condition') as json_object_t)) || ')';
                end if;
            end loop;
        end if;

        dbms_output.put_line('update ' || json.get_string('table') || ' set ' || cols || conditions);
    end if;

    if request_type = 'insert' then
        -- columns
        temp_array := json.get_array('columns');

        for i in 0..temp_array.get_size() - 1
        loop
            temp_object := treat(temp_array.get(i) as json_object_t);

            if i = temp_array.get_size() - 1 then
                cols := cols || temp_object.get_string('key');
                vals := vals || '''' || temp_object.get_string('value') || '''';
            else
                cols := cols || temp_object.get_string('key') || ', ';
                vals := vals || '''' || temp_object.get_string('value') || '''' || ', ';
            end if;
        end loop;

        dbms_output.put_line('insert into ' || json.get_string('table') || '(' || cols || ') values(' || vals || ')');
    end if;

    if request_type = 'create' then
        -- columns
        temp_array := json.get_array('columns');

        for i in 0..temp_array.get_size() - 1
        loop
            temp_object := treat(temp_array.get(i) as json_object_t);

            if i = temp_array.get_size() - 1 then
                cols := cols || temp_object.get_string('key') || ' ' || temp_object.get_string('value');
            else
                cols := cols || temp_object.get_string('key') || ' ' || temp_object.get_string('value') || ', ';
            end if;
        end loop;

        -- primary
        temp_array := json.get_array('primary');

        if temp_array.get_size() = 0 then
            dbms_output.put_line('create table ' || json.get_string('table') || ' (' || cols || ')');
        else
            for i in 0..temp_array.get_size() - 1
            loop
                temp_object := treat(temp_array.get(i) as json_object_t);

                prim := prim || ' constraint ' || temp_object.get_string('name') || ' primary key (';

                temp_array2 := temp_object.get_array('columns');

                for j in 0..temp_array2.get_size() - 1
                loop
                    if j = temp_array2.get_size() - 1 then
                        prim := prim || temp_array2.get_string(j) || ')';
                    else
                        prim := prim || temp_array2.get_string(j) || ', ';
                    end if;
                end loop;

                if i = temp_array.get_size() - 1 then
                    null;
                else
                    prim := prim || ', ';
                end if;
            end loop;

            dbms_output.put_line('create table ' || json.get_string('table') || ' (' || cols || ',' || prim || ')');
        end if;
    end if;

    if request_type = 'drop' then
        dbms_output.put_line('drop table ' || json.get_string('table'));
    end if;
end execute_request;

create or replace function parse_request(json json_object_t) return clob is
    temp_array json_array_t;
    temp_object json_object_t;

    request_type clob;
    cols clob;
    tabs clob;
    joins clob;
    conditions clob;
    condition_type clob;
begin
    request_type := json.get_string('request');

    if request_type = 'select' then
        -- columns
        temp_array := json.get_array('columns');

        for i in 0..temp_array.get_size() - 1
        loop
            if i = temp_array.get_size() - 1 then
                cols := cols || temp_array.get_string(i);
            else
                cols := cols || temp_array.get_string(i) || ', ';
            end if;
        end loop;

        -- tables
        temp_array := json.get_array('tables');

        for i in 0..temp_array.get_size() - 1
        loop
            if i = temp_array.get_size() - 1 then
                tabs := tabs || temp_array.get_string(i);
            else
                tabs := tabs || temp_array.get_string(i) || ', ';
            end if;
        end loop;

        -- joins
        temp_array := json.get_array('joins');

        if temp_array.get_size() <> 0 then
            for i in 0..temp_array.get_size() - 1
            loop
                temp_object := treat(temp_array.get(i) as json_object_t);

                joins := joins || ' ' || temp_object.get_string('type') || ' join ' || temp_object.get_string('table') || ' on ' || temp_object.get_string('on');
            end loop;
        end if;

        -- conditions
        temp_array := json.get_array('conditions');

        if temp_array.get_size() <> 0 then
            conditions := ' where';

            for i in 0..temp_array.get_size() - 1
            loop
                temp_object := treat(temp_array.get(i) as json_object_t);

                condition_type := temp_object.get_string('type');

                if condition_type = 'default' then
                    conditions := conditions || ' ' || temp_object.get_string('condition');
                else
                    conditions := conditions || ' ' || parse_request(treat(temp_object.get('condition') as json_object_t));
                end if;
            end loop;
        end if;

        return 'select ' || cols || ' from ' || tabs || joins || conditions;
    end if;
end parse_request;
