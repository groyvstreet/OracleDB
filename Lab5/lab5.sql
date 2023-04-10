create sequence companies_logs_sequence start with 1;

create or replace trigger companies_logs
    before insert or update or delete
    on companies
    for each row
begin
    if inserting then
        insert into companies_logs values(companies_logs_sequence.nextval, 'insert', sysdate, :new.id, :new.name, :new.opening_date, :new.cars_amount);
    elsif updating then
        insert into companies_logs values(companies_logs_sequence.nextval, 'update', sysdate, :new.id, :new.name, :new.opening_date, :new.cars_amount);
    elsif deleting then
        insert into companies_logs values(companies_logs_sequence.nextval, 'delete', sysdate, :old.id, :old.name, :old.opening_date, :old.cars_amount);
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
    elsif updating then
        insert into persons_logs values(persons_logs_sequence.nextval, 'update', sysdate, :new.id, :new.name, :new.birthday, :new.cars_amount);
    elsif deleting then
        insert into persons_logs values(persons_logs_sequence.nextval, 'delete', sysdate, :old.id, :old.name, :old.birthday, :old.cars_amount);
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
    elsif updating then
        insert into cars_logs values(cars_logs_sequence.nextval, 'update', sysdate, :new.id, :new.model_name, :new.manufacture_date, :new.company_id, :new.person_id);
    elsif deleting then
        insert into cars_logs values(cars_logs_sequence.nextval, 'delete', sysdate, :old.id, :old.model_name, :old.manufacture_date, :old.company_id, :old.person_id);
    end if;
end;
