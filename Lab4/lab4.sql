create or replace procedure execute_request(json_text clob) is
    json json_object_t;
    temp_array json_array_t;
    temp_object json_object_t;

    request_type clob;
    cols clob;
    tabs clob;
    joins clob;
    conditions clob;
    condition_type clob;
    vals clob;
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

        for i in 0..temp_array.get_size() - 1
        loop
            temp_object := treat(temp_array.get(i) as json_object_t);

            joins := joins || temp_object.get_string('type') || ' join ' || temp_object.get_string('table') || ' on ' || temp_object.get_string('on');
        end loop;

        -- conditions
        temp_array := json.get_array('conditions');

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

        dbms_output.put_line('select ' || cols || ' from ' || tabs || ' ' || joins || ' where' || conditions);
    end if;

    if request_type = 'delete' then
        -- conditions
        temp_array := json.get_array('conditions');

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

        dbms_output.put_line('delete from ' || json.get_string('table') || ' where' || conditions);
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

        dbms_output.put_line('update ' || json.get_string('table') || ' set ' || cols || ' where' || conditions);
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
end execute_request;

create or replace function parse_request(json json_object_t) return clob is
    temp_array json_array_t;
    temp_object json_object_t;

    request_type clob;
    cols clob;
    tabs clob;
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

        -- conditions
        temp_array := json.get_array('conditions');

        for i in 0..temp_array.get_size() - 1
        loop
            temp_object := treat(temp_array.get(i) as json_object_t);

            condition_type := temp_object.get_string('type');

            if condition_type = 'default' then
                conditions := conditions || temp_object.get_string('condition');
            else
                conditions := conditions || parse_request(treat(temp_object.get('condition') as json_object_t));
            end if;
        end loop;

        return 'select ' || cols || ' from ' || tabs || ' where ' || conditions;
    end if;
end parse_request;
