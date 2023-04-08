declare
    json clob;
begin
    json := '
    {
        "request": "select",
        "columns": [
            "id",
            "name"
        ],
        "tables": [
            "cars"
        ],
        "conditions": [
            "id < 3 and",
            "id = {
                "request": "select",
                "columns": "id",
                "tables": "cars",
                "conditions": [
                    "id = 2"
                ]
            }"
        ]
    }
    ';
    execute_request(json);
end;

create or replace procedure execute_request(json clob) is
    formatted_json clob;
    strings_count number;
    strings dbms_sql.varchar2a;
    cols clob;
    tabs clob;
    conditions clob;
begin
    dbms_output.put_line(parse_request(json));
end execute_request;

create or replace function parse_request(json clob) return clob is
    formatted_json clob;
    strings_count number;
    strings dbms_sql.varchar2a;
    cols clob;
    tabs clob;
    conditions clob;
begin
    formatted_json := replace(json, ' ', '');
    formatted_json := replace(formatted_json, chr(10) || '{', '{');
    formatted_json := replace(formatted_json, '}' || chr(10), '}');
    dbms_output.put_line(formatted_json);
    strings_count := regexp_count(formatted_json, '(\S*)' || chr(10));
    for i in 1..strings_count
    loop
        strings(i) := replace(regexp_substr(formatted_json, '(\S*)' || chr(10), 1, i), chr(10), '');
    end loop;
  
    for i in 1..strings.count
    loop
        dbms_output.put_line(strings(i));
    end loop;

    if regexp_substr(strings(2), '"(\S*)"', 10, 1) = '"select"' then
        cols := regexp_substr(strings(3), '"(\S*)"', 10, 1);
        cols := replace(cols, '"', '');
        cols := replace(cols, ',', ', ');
        dbms_output.put_line(cols);

        tabs := regexp_substr(strings(4), '"(\S*)"', 9, 1);
        tabs := replace(tabs, '"', '');
        tabs := replace(tabs, ',', ', ');
        dbms_output.put_line(tabs);

        conditions := regexp_substr(strings(5), '"(\S*)"', 13, 1);
        conditions := replace(conditions, '"', '');
        conditions := replace(conditions, ',', ', ');
        dbms_output.put_line(conditions);

        dbms_output.put_line('select ' || cols || ' from ' || tabs || ' where ' || conditions);
    end if;
end parse_request;
