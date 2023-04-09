-- select

declare
    json_text clob;
begin
    json_text := '
    {
        "request": "select",
        "columns": [
            "cars.id",
            "cars.name",
            "cars.person_id"
        ],
        "tables": [
            "persons"
        ],
        "joins": [
            {
                "type": "left",
                "table": "cars",
                "conditions": {
                    "type": "binary",
                    "operator": "=",
                    "left": {
                        "type": "default",
                        "condition": "cars.person_id"
                    },
                    "right": {
                        "type": "default",
                        "condition": "persons.id"
                    }
                }
            }
        ]
    }
    ';
    execute_request(json_text);
end;

-- delete

declare
    json_text clob;
begin
    json_text := '
    {
        "request": "delete",
        "table": "persons",
        "conditions": {
            "type": "binary",
            "operator": "and",
            "left": {
                "type": "binary",
                "operator": "=",
                "left": {
                    "type": "default",
                    "condition": "id"
                },
                "right": {
                    "type": "request",
                    "condition": {
                        "request": "select",
                        "columns": [
                            "person_id"
                        ],
                        "tables": [
                            "cars"
                        ],
                        "conditions": {
                            "type": "default",
                            "condition": "id = 2"
                        }
                    }
                }
            },
            "right": {
                "type": "unary",
                "operator": "exists",
                "operand": {
                    "type": "request",
                    "condition": {
                        "request": "select",
                        "columns": [
                            "*"
                        ],
                        "tables": [
                            "persons"
                        ]
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
                "type": "binary",
                "operator": "=",
                "left": {
                    "type": "default",
                    "condition": "id"
                },
                "right": {
                    "type": "request",
                    "condition": {
                        "request": "select",
                        "columns": [
                            "id"
                        ],
                        "tables": [
                            "cars"
                        ],
                        "conditions": {
                            "type": "default",
                            "condition": "id = 2"
                        }
                    }
                }
            },
            "right": {
                "type": "unary",
                "operator": "not exists",
                "operand": {
                    "type": "request",
                    "condition": {
                        "request": "select",
                        "columns": [
                            "*"
                        ],
                        "tables": [
                            "persons"
                        ]
                    }
                }
            }
        }
    }
    ';
    execute_request(json_text);
end;

-- update

declare
    json_text clob;
begin
    json_text := '
    {
        "request": "update",
        "table": "persons",
        "columns": [
            {
                "key": "id",
                "value": "2"
            },
            {
                "key": "name",
                "value": "''krakenoid''"
            }
        ],
        "conditions": {
            "type": "binary",
            "operator": "and",
            "left": {
                "type": "binary",
                "operator": "=",
                "left": {
                    "type": "default",
                    "condition": "id"
                },
                "right": {
                    "type": "default",
                    "condition": "1"
                }
            },
            "right": {
                "type": "binary",
                "operator": "=",
                "left": {
                    "type": "default",
                    "condition": "name"
                },
                "right": {
                    "type": "default",
                    "condition": "''kraken''"
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
                "value": "2"
            },
            {
                "key": "name",
                "value": "''nissan''"
            },
            {
                "key": "person_id",
                "value": "2"
            }
        ],
        "conditions": {
            "type": "binary",
            "operator": "and",
            "left": {
                "type": "binary",
                "operator": "=",
                "left": {
                    "type": "default",
                    "condition": "id"
                },
                "right": {
                    "type": "default",
                    "condition": "1"
                }
            },
            "right": {
                "type": "binary",
                "operator": "and",
                "left": {
                    "type": "binary",
                    "operator": "=",
                    "left": {
                        "type": "default",
                        "condition": "person_id"
                    },
                    "right": {
                        "type": "default",
                        "condition": "1"
                    }
                },
                "right": {
                    "type": "binary",
                    "operator": "=",
                    "left": {
                        "type": "default",
                        "condition": "name"
                    },
                    "right": {
                        "type": "default",
                        "condition": "''tesla''"
                    }
                }
            }
        }
    }
    ';
    execute_request(json_text);
end;

-- insert

declare
    json_text clob;
begin
    json_text := '
    {
        "request": "insert",
        "table": "persons",
        "columns": [
            {
                "key": "id",
                "value": "1"
            },
            {
                "key": "name",
                "value": "''kraken''"
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
                "value": "''tesla''"
            },
            {
                "key": "person_id",
                "value": "1"
            }
        ]
    }
    ';
    execute_request(json_text);
end;

-- create

declare
    json_text clob;
begin
    json_text := '
    {
        "request": "create",
        "table": "persons",
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
                "name": "person_id",
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
            },
            {
                "key": "person_id",
                "value": "varchar2(100)"
            }
        ],
        "primary": [
            {
                "name": "car_id",
                "columns": [
                    "id"
                ]
            }
        ]
    }
    ';
    execute_request(json_text);
end;

-- drop

declare
    json_text clob;
begin
    json_text := '
    {
        "request": "drop",
        "table": "persons"
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
