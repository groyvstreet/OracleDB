-- 1.
create table MyTable(
    id number,
    val number
)

-- 2.
declare
    val number;
begin
    for id in 1..10000
    loop
        select dbms_random.random() into val from dual;
        insert into MyTable values (id, val);
    end loop;
end;

-- 3.
create or replace function check_vals return varchar2 is
    checksum number;
    cursor records is
        select val
        from MyTable;
begin
    checksum := 0;
    for record in records
    loop
        if mod(record.val, 2) = 0 then
            checksum := checksum + 1;
        else
            checksum := checksum - 1;
        end if;
    end loop;

    if checksum = 0 then
        return 'EQUAL';
    elsif checksum > 0 then
        return 'TRUE';
    else
        return 'FALSE';
    end if;
end check_vals;

begin
    dbms_output.put_line(check_vals());
end;

-- 4.
create or replace function text_insert(id_i number) return varchar2 is
    val_i number;
begin
    select val into val_i from MyTable where id = id_i;
    return 'insert into MyTable values (' || id_i || ', ' || val_i || ')';
exception
    when no_data_found then
    return 'The record with the specified id is not in the table. You can add record as: insert into MyTable values (' || id_i || ', dbms_random.random())';
end text_insert;

begin
    dbms_output.put_line(text_insert(1));
end;

-- 5.
create or replace procedure mytable_insert(id_i number) is
    amount number;
begin
    select count(*) into amount from MyTable where id = id_i;
    if amount > 0 then
        update MyTable set val = dbms_random.random() where id = id_i;
    else
        insert into MyTable values (id_i, dbms_random.random());
    end if;
end mytable_insert;

begin
    mytable_insert(1);
end;

create or replace procedure mytable_update(id_i number, val_i number) is
    amount number;
begin
    select count(*) into amount from MyTable where id = id_i;
    if amount > 0 then
        update MyTable set val = val_i where id = id_i;
    else
        dbms_output.put_line('The specified id is not in the table.');
    end if;
end mytable_insert;

begin
    mytable_update(1, 1111);
end;

create or replace procedure mytable_delete(id_i number) is
begin
    delete from MyTable where id = id_i;
end mytable_delete;

begin
    mytable_delete(1);
end;

-- 6.
create or replace function get_reward(salary_text varchar2, percent_text varchar2) return float is
    salary float;
    percent float;
    result float;
begin
    if instr(salary_text, '.') > 0 then
        salary := replace(salary_text, '.', ',');
    else
        salary := salary_text;
    end if;

    if instr(percent_text, '.') > 0 then
        percent := replace(percent_text, '.', ',');
    else
        percent := percent_text;
    end if;

    if salary <= 0.0 then
        dbms_output.put_line('The salary must be positive.');
        return 0.0;
    end if;

    if percent <= 1.0 then
        dbms_output.put_line('Min value for the percent is 1.');
        return 0.0;
    end if;

    if mod(percent, 1) > 0 then
        dbms_output.put_line('The percent must be an integer.');
        return 0.0;
    end if;

    result := (1.0 + percent / 100.0) * 12.0 * salary;
    return result;
exception
    when value_error then
    dbms_output.put_line('Invalid input.');
    return 0.0;
end get_reward;

begin
    dbms_output.put_line(get_reward('1200,54', '5'));
end;
