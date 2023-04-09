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
                "conditions": {
                    "type": "default",
                    "condition": "1 = 1"
                }
            }
        ],
        "conditions": {
            "type": "binary",
            "operator": "and",
            "left": {
                "type": "default",
                "condition": "id < 3"
            },
            "right": {
                "type": "unary",
                "operator": "exists",
                "operand": {
                    "type": "request",
                    "condition": {
                        "request": "select",
                        "columns": [
                            "id"
                        ],
                        "tables": [
                            "cars"
                        ],
                        "joins": [

                        ],
                        "conditions": {
                            "type": "default",
                            "condition": "id = 2"
                        }
                    }
                }
            }
        }
    }
    ';
    execute_request(json_text);
end;

declare
    json_text clob;
begin
    json_text := '
    {
        "request": "delete",
        "table": "cars",
        "conditions": {
            "type": "binary",
            "operator": "and",
            "left": {
                "type": "default",
                "condition": "id < 3"
            },
            "right": {
                "type": "unary",
                "operator": "exists",
                "operand": {
                    "type": "request",
                    "condition": {
                        "request": "select",
                        "columns": [
                            "id"
                        ],
                        "tables": [
                            "cars"
                        ],
                        "joins": [

                        ],
                        "conditions": {
                            "type": "default",
                            "condition": "id = 2"
                        }
                    }
                }
            }
        }
    }
    ';
    execute_request(json_text);
end;

declare
    json_text clob;
begin
    json_text := '
    {
        "request": "update",
        "table": "cars",
        "columns": [
            {
                "key": "id",
                "value": "1"
            }
        ],
        "conditions": {
            "type": "binary",
            "operator": "and",
            "left": {
                "type": "default",
                "condition": "id < 3"
            },
            "right": {
                "type": "unary",
                "operator": "exists",
                "operand": {
                    "type": "request",
                    "condition": {
                        "request": "select",
                        "columns": [
                            "id"
                        ],
                        "tables": [
                            "cars"
                        ],
                        "joins": [

                        ],
                        "conditions": {
                            "type": "default",
                            "condition": "id = 2"
                        }
                    }
                }
            }
        }
    }
    ';
    execute_request(json_text);
end;

declare
    json_text clob;
begin
    json_text := '
    {
        "request": "insert",
        "table": "cars",
        "columns": [
            {
                "key": "id",
                "value": "1"
            },
            {
                "key": "name",
                "value": "Tesla"
            }
        ]
    }
    ';
    execute_request(json_text);
end;

declare
    json_text clob;
begin
    json_text := '
    {
        "request": "create",
        "table": "cars",
        "columns": [
            {
                "key": "id",
                "value": "number"
            },
            {
                "key": "name",
                "value": "varchar2(100)"
            }
        ],
        "primary": [
            {
                "name": "test",
                "columns": [
                    "id"
                ]
            }
        ]
    }
    ';
    execute_request(json_text);
end;

declare
    json_text clob;
begin
    json_text := '
    {
        "request": "drop",
        "table": "cars"
    }
    ';
    execute_request(json_text);
end;
