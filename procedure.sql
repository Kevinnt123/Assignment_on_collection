**# Assignment_on_collection**

This SQL/PLSQL script creates a small health-check system for citizens.
It stores citizens, their health status, and diseases, and then uses a procedure to decide whether a citizen is allowed to drink alcohol.

**The query is below**

set serveroutput on;

-- Drop types/tables if already exist (for re-runnability)
begin
    execute immediate 'drop table citizens';
exception when others then null;
end;
/

begin
    execute immediate 'drop type c_diseases force';
exception when others then null;
end;
/

-- Create collection type
create or replace type c_diseases as table of varchar2(40);
/

-- Create citizens table
create table citizens (
    citizens_id number primary key,
    names_s varchar2(50),
    health varchar2(20),
    diseases c_diseases
) nested table diseases store as cs_diseases;
/

-- Insert data (UPDATED NAMES)
insert into citizens values(01,'kevin','good',c_diseases());
insert into citizens values(02,'amina','bad',c_diseases('liver','lungs','stomach'));
insert into citizens values(03,'patrick','good',c_diseases());
insert into citizens values(04,'claire','bad',c_diseases('kidney','heart'));
insert into citizens values(05,'john','bad',c_diseases('liver'));
/

-- Show data
select * from citizens;

-- Create procedure
create or replace procedure alcohol_test(
    p_citizens_id in citizens.citizens_id%type,
    p_age in number
) is
    each_citizens citizens%rowtype;
begin
    -- Fetch citizen
    select * into each_citizens
    from citizens
    where citizens_id = p_citizens_id;

    -- Check conditions
    if p_age < 18 then
        dbms_output.put_line(each_citizens.names_s || ' you are too young to take beer');
        return; -- Exit early
    end if;

    if each_citizens.health = 'bad' then
        dbms_output.put_line(each_citizens.names_s || ' you are suffering from diseases, health is bad');
        -- List diseases if any exist
        if each_citizens.diseases is not null and each_citizens.diseases.count > 0 then
            dbms_output.put_line('Diseases:');
            for i in 1..each_citizens.diseases.count loop
                dbms_output.put_line(' - ' || each_citizens.diseases(i));
            end loop;
        else
            dbms_output.put_line('No specific diseases recorded.');
        end if;
        return;
    else
        dbms_output.put_line(each_citizens.names_s || ' take beer');
    end if;

exception
    when no_data_found then
        dbms_output.put_line('Error: Citizen with ID ' || p_citizens_id || ' not found.');
    when others then
        dbms_output.put_line('Error: ' || sqlerrm);
end alcohol_test;
/

-- CALL THE PROCEDURE
begin
    alcohol_test(01, 3);
end;
/

