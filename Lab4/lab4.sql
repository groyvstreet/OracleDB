declare
    json_text clob;
begin
    json_text := '
    {
        "request": "select",
        "columns": [
            "id",
            "name"
        ],
        "tables": [
            "cars"
        ],
        "joins": [
            {
                "type": "inner",
                "table": "person",
                "on": "1=1"
            }
        ],
        "conditions": [
            {
                "type": "default",
                "condition": "id < 3 and id ="
            },
            {
                "type": "request",
                "condition": {
                    "request": "select",
                    "columns": [
                        "id"
                    ],
                    "tables": [
                        "cars"
                    ],
                    "conditions": [
                        {
                            "type": "default",
                            "condition": "id = 2"
                        }
                    ]
                }
            }
        ]
    }
    ';
    execute_request(json_text);
end;

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
