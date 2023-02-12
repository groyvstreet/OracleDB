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
    FOR EACH ROW
declare
    amount number;
    last_id number;
begin
    select count(*) into amount from students;
    if amount = 0 then
        :new.id := 1;
    else
        select max(id) into last_id from students;
        :new.id := last_id + 1;
    end if;
end students_insert;

create or replace trigger groups_insert
    before insert
    on groups
    FOR EACH ROW
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
            :new.id := last_id + 1;
        end if;
    else
        RAISE_APPLICATION_ERROR(-20001, 'This group name is already exists.');
    end if;
end groups_insert;
