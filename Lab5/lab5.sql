create sequence companies_logs_sequence start with 1;

create or replace trigger companies_logs
    before insert or update or delete
    on companies
    for each row
begin
    if inserting then
        insert into companies_logs values(companies_logs_sequence.nextval, 'insert', sysdate, :new.id, :new.name, :new.opening_date, :new.cars_amount);
        update_current_date_time(sysdate);
    elsif updating then
        insert into companies_logs values(companies_logs_sequence.nextval, 'update', sysdate, :new.id, :new.name, :new.opening_date, :new.cars_amount);
        update_current_date_time(sysdate);
    elsif deleting then
        insert into companies_logs values(companies_logs_sequence.nextval, 'delete', sysdate, :old.id, :old.name, :old.opening_date, :old.cars_amount);
        update_current_date_time(sysdate);
    end if;
end;

create sequence persons_logs_sequence start with 1;

create or replace trigger persons_logs
    before insert or update or delete
    on persons
    for each row
begin
    if inserting then
        insert into persons_logs values(persons_logs_sequence.nextval, 'insert', sysdate, :new.id, :new.name, :new.birthday, :new.cars_amount);
        update_current_date_time(sysdate);
    elsif updating then
        insert into persons_logs values(persons_logs_sequence.nextval, 'update', sysdate, :new.id, :new.name, :new.birthday, :new.cars_amount);
        update_current_date_time(sysdate);
    elsif deleting then
        insert into persons_logs values(persons_logs_sequence.nextval, 'delete', sysdate, :old.id, :old.name, :old.birthday, :old.cars_amount);
        update_current_date_time(sysdate);
    end if;
end;

create sequence cars_logs_sequence start with 1;

create or replace trigger cars_logs
    before insert or update or delete
    on cars
    for each row
begin
    if inserting then
        insert into cars_logs values(cars_logs_sequence.nextval, 'insert', sysdate, :new.id, :new.model_name, :new.manufacture_date, :new.company_id, :new.person_id);
        update_current_date_time(sysdate);
    elsif updating then
        insert into cars_logs values(cars_logs_sequence.nextval, 'update', sysdate, :new.id, :new.model_name, :new.manufacture_date, :new.company_id, :new.person_id);
        update_current_date_time(sysdate);
    elsif deleting then
        insert into cars_logs values(cars_logs_sequence.nextval, 'delete', sysdate, :old.id, :old.model_name, :old.manufacture_date, :old.company_id, :old.person_id);
        update_current_date_time(sysdate);
    end if;
end;

create or replace package restore_data is
    procedure restore_companies(date_time date);
    procedure restore_persons(date_time date);
    procedure restore_cars(date_time date);

    procedure restore_companies(mls number);
    procedure restore_persons(mls number);
    procedure restore_cars(mls number);

    procedure restore_data(date_time date);
    procedure restore_data(mls number);
end restore_data;

create or replace package body restore_data is
    procedure restore_companies(date_time date) is
        cursor records is
        select *
        from companies_logs
        where action_date <= date_time
        order by id;
        amount number;
    begin
        execute immediate 'alter trigger companies_logs disable';
        delete from companies;

        for record in records
        loop
            if record.action = 'insert' or record.action = 'update' then
                select count(*) into amount from companies where id = record.company_id;

                if amount = 0 then
                    insert into companies values(record.company_id, record.company_name, record.company_opening_date, record.company_cars_amount);
                else
                    update companies
                        set name = record.company_name,
                        opening_date = record.company_opening_date,
                        cars_amount = record.company_cars_amount
                        where id = record.company_id;    
                end if;
            end if;

            if record.action = 'delete' then
                delete from companies where id = record.company_id;
            end if;
        end loop;

        execute immediate 'alter trigger companies_logs enable';
        update_current_date_time(date_time);
    end;
    
    procedure restore_persons(date_time date) is
        cursor records is
            select *
            from persons_logs
            where action_date <= date_time
            order by id;
        amount number;
    begin
        execute immediate 'alter trigger persons_logs disable';
        delete from persons;

        for record in records
        loop
            if record.action = 'insert' or record.action = 'update' then
                select count(*) into amount from persons where id = record.person_id;

                if amount = 0 then
                    insert into persons values(record.person_id, record.person_name, record.person_birthday, record.person_cars_amount);
                else
                    update persons
                        set name = record.person_name,
                        birthday = record.person_birthday,
                        cars_amount = record.person_cars_amount
                        where id = record.person_id;    
                end if;
            end if;

            if record.action = 'delete' then
                delete from persons where id = record.person_id;
            end if;
        end loop;

        execute immediate 'alter trigger persons_logs enable';
        update_current_date_time(date_time);
    end;

    procedure restore_cars(date_time date) is
        cursor records is
        select *
        from cars_logs
        where action_date <= date_time
        order by id;
        amount number;
    begin
        execute immediate 'alter trigger cars_logs disable';
        delete from cars;

        for record in records
        loop
            if record.action = 'insert' or record.action = 'update' then
                select count(*) into amount from cars where id = record.car_id;

                if amount = 0 then
                    insert into cars values(record.car_id, record.car_model_name, record.car_manufacture_date, record.car_company_id, record.car_person_id);
                else
                    update cars
                        set model_name = record.car_model_name,
                        manufacture_date = record.car_manufacture_date,
                        company_id = record.car_company_id,
                        person_id = record.car_person_id
                        where id = record.car_id;    
                end if;
            end if;

            if record.action = 'delete' then
                delete from cars where id = record.car_id;
            end if;
        end loop;

        execute immediate 'alter trigger cars_logs enable';
        update_current_date_time(date_time);
    end;

    procedure restore_companies(mls number) is
        date_time date;
    begin
        select systimestamp - numtodsinterval(mls / 1000, 'second')
        into date_time
        from dual;

        restore_companies(date_time);
    end;

    procedure restore_persons(mls number) is
        date_time date;
    begin
        select systimestamp - numtodsinterval(mls / 1000, 'second')
        into date_time
        from dual;

        restore_persons(date_time);
    end;

    procedure restore_cars(mls number) is
        date_time date;
    begin
        select systimestamp - numtodsinterval(mls / 1000, 'second')
        into date_time
        from dual;

        restore_cars(date_time);
    end;

    procedure restore_data(date_time date) is
    begin
        restore_companies(date_time);
        restore_persons(date_time);
        restore_cars(date_time);
    end;

    procedure restore_data(mls number) is
    begin
        restore_companies(mls);
        restore_persons(mls);
        restore_cars(mls);
    end;
end restore_data;

create or replace procedure update_current_date_time(date_time date) is
    amount number;
begin
    select count(*) into amount from current_date_time;

    if amount = 0 then
        insert into current_date_time values(date_time);
    else
        update current_date_time set current_time = date_time;
    end if;
end;

create or replace procedure make_report(date_time_begin date) is
    cursor companies_records is
        select *
        from companies_logs
        where action_date between date_time_begin and (select current_time from current_date_time)
        order by id;

    cursor persons_records is
        select *
        from persons_logs
        where action_date between date_time_begin and (select current_time from current_date_time)
        order by id;

    cursor cars_records is
        select *
        from cars_logs
        where action_date between date_time_begin and (select current_time from current_date_time)
        order by id;
    result clob;
    file_handle UTL_FILE.FILE_TYPE;
begin
    result := '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Report</title>
</head>
<body>';

    -- companies
    result := result || '<h1>' || 'COMPANIES' || '</h1>';
    result := result || '<table>
        <tr>
            <th>action</ht>
            <th>action_date</th>
            <th>company_id</th>
            <th>company_name</th>
            <th>company_opening_date</th>
            <th>company_cars_amount</th>
        </tr>';

    for record in companies_records
    loop
        result := result || '<tr>
            <td>' || record.action || '</td>
            <td>' || record.action_date || '</td>
            <td>' || record.company_id || '</td>
            <td>' || record.company_name || '</td>
            <td>' || record.company_opening_date || '</td>
            <td>' || record.company_cars_amount || '</td>
        </tr>';
    end loop;

    result := result || '</table>';

    -- persons
    result := result || '<h1>' || 'PERSONS' || '</h1>';
    result := result || '<table>
        <tr>
            <th>action</ht>
            <th>action_date</th>
            <th>person_id</th>
            <th>person_name</th>
            <th>person_birthday</th>
            <th>person_cars_amount</th>
        </tr>';

    for record in persons_records
    loop
        result := result || '<tr>
            <td>' || record.action || '</td>
            <td>' || record.action_date || '</td>
            <td>' || record.person_id || '</td>
            <td>' || record.person_name || '</td>
            <td>' || record.person_birthday || '</td>
            <td>' || record.person_cars_amount || '</td>
        </tr>';
    end loop;

    result := result || '</table>';

    -- cars
    result := result || '<h1>' || 'CARS' || '</h1>';
    result := result || '<table>
        <tr>
            <th>action</ht>
            <th>action_date</th>
            <th>car_id</th>
            <th>car_model_name</th>
            <th>car_manufacture_date</th>
            <th>car_company_id</th>
            <th>car_person_id</th>
        </tr>';

    for record in cars_records
    loop
        result := result || '<tr>
            <th>' || record.action || '</ht>
            <th>' || record.action_date || '</th>
            <th>' || record.car_id || '</th>
            <th>' || record.car_model_name || '</th>
            <th>' || record.car_manufacture_date || '</th>
            <th>' || record.car_company_id || '</th>
            <th>' || record.car_person_id || '</th>
        </tr>';
    end loop;

    result := result || '</table>';

    result := result || '</body>
</html>';

    dbms_output.put_line(result);
    -- file_handle := UTL_FILE.FOPEN('D:\Labs\DB\Lab5', 'report.html', 'w');

    -- -- записываем текст в файл
    -- UTL_FILE.PUT_LINE(file_handle, result);

    -- -- закрываем файл
    -- UTL_FILE.FCLOSE(file_handle);
end;
