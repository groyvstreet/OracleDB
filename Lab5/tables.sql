create table companies
(
    id number,
    name varchar2(100),
    opening_date date,
    cars_amount number,

    constraint company_id primary key (id)
);

create table persons
(
    id number,
    name varchar2(100),
    birthday date,
    cars_amount number,

    constraint person_id primary key (id)
);

create table cars
(
    id number,
    model_name varchar2(100),
    manufacture_date date,
    company_id number,
    person_id number,

    constraint car_id primary key (id),
    constraint fk_company foreign key (id) references companies(id),
    constraint fk_person foreign key (id) references persons(id)
);

create table companies_logs
(
    id number,
    action varchar2(6),
    action_date date,

    company_id number,
    company_name varchar2(100),
    company_opening_date date,
    company_cars_amount number
);

create table persons_logs
(
    id number,
    action varchar2(6),
    action_date date,

    person_id number,
    person_name varchar2(100),
    person_birthday date,
    person_cars_amount number
);

create table cars_logs
(
    id number,
    action varchar2(6),
    action_date date,

    car_id number,
    car_model_name varchar2(100),
    car_manufacture_date date,
    car_company_id number,
    car_person_id number
);
