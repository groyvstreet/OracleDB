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

declare
    json_text clob;
begin
    json_text := '
    {
        "request": "delete",
        "table": "cars",
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
