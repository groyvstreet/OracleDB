-- 1.
create table students(
    id number,
    name varchar2(100),
    group_id number
);

create table groups(
    id number,
    name varchar2(100),
    c_val number
);

-- 2.
create or replace trigger students_insert
    before insert
    on students
    for each row
declare
    amount number;
    last_id number;
begin
    select count(*) into amount from students;
    if amount = 0 then
        :new.id := 1;
    else
        select max(id) into last_id from students;
        if :new.id > last_id then
            :new.id := last_id + 1;
        elsif :new.id > 0 then
            select count(*) into amount from students where id = :new.id;
            if amount > 0 then
                :new.id := last_id + 1;
            end if;
        else
            :new.id := last_id + 1;
        end if;
    end if;
end students_insert;

create or replace trigger students_update
    before update
    on students
    for each row
begin
    if :old.id != :new.id then
        RAISE_APPLICATION_ERROR(-20001, 'Student id cannot be changed.');
    end if;
end students_update;

create or replace trigger groups_insert
    before insert
    on groups
    for each row
declare
    amount number;
    last_id number;
begin
    select count(*) into amount from groups where name = :new.name;
    if amount = 0 then
        select count(*) into amount from groups;
        if amount = 0 then
            :new.id := 1;
        else
            select max(id) into last_id from groups;
            if :new.id > last_id then
                :new.id := last_id + 1;
            elsif :new.id > 0 then
                select count(*) into amount from groups where id = :new.id;
                if amount > 0 then
                    :new.id := last_id + 1;
                end if;
            else
                :new.id := last_id + 1;
            end if;
        end if;
    else
        RAISE_APPLICATION_ERROR(-20001, 'This group name is already exists.');
    end if;
end groups_insert;

create or replace trigger groups_update
    before update
    on groups
    for each row
begin
    if :old.id != :new.id then
        RAISE_APPLICATION_ERROR(-20001, 'Group id cannot be changed.');
    end if;

    if :old.name != :new.name then
        RAISE_APPLICATION_ERROR(-20001, 'Group name cannot be changed.');
    end if;
end groups_update;

-- 3.
create or replace trigger groups_delete
    after delete
    on groups
    for each row
begin
    delete from students where group_id = :old.id;
end groups_delete;

-- 4.
create table students_logs(
    student_id number,
    old_name varchar2(100),
    new_name varchar2(100),
    old_group_id number,
    new_group_id number,
    action varchar2(6),
    time date
);

create or replace trigger students_logs
    after insert or update or delete
    on students
    for each row
begin
    if inserting then
        insert into students_logs values(:new.id, null, :new.name, null, :new.group_id, 'insert', sysdate);
    elsif updating then
        insert into students_logs values(:old.id, :old.name, :new.name, :old.group_id, :new.group_id, 'update', sysdate);
    elsif deleting then
        insert into students_logs values(:old.id, :old.name, null, :old.group_id, null, 'delete', sysdate);
    end if;
end students_logs;
