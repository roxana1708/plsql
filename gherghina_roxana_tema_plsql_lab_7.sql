--1
create table error_rg (
    cod number,
    mesaj varchar2(100)
);


declare
    nr number := -16;
    v_cod number;
    v_mesaj varchar2(100);
    exceptie_1 exception;
begin
    if(nr < 0) then
        raise exceptie_1;
    end if;
    
    dbms_output.put_line(sqrt(nr));
    
exception
    when exceptie_1 then
        v_cod := -20001;
        v_mesaj := 'Numarul ales este negativ';
        insert into error_rg
        values (v_cod, v_mesaj);
end;
/

select * from error_rg;


--2
select * from emp_rg;

declare
    v_nume emp_rg.first_name%type;
    v_salariu emp_rg.salary%type := &salariu;
begin
    select first_name
    into v_nume
    from emp_rg
    where salary = v_salariu;
    
    dbms_output.put_line(v_nume || ' castiga salariul de ' || v_salariu);
exception
    when no_data_found then
        dbms_output.put_line('Nu exista salariati care sa castige acest salariu');
    when too_many_rows then
        dbms_output.put_line('Exista mai multi salariati care castiga acest salariu');
end;
/

--4
select * from emp_rg;

declare
    v_int_a number := &margine_inferioara_interval;
    v_int_b number := &margine_superioara_interval;
    v_dept departments.department_name%type;
    v_nr_ang number;
    exceptie_4 exception;
begin
    select count(*)
    into v_nr_ang
    from emp_rg 
    where department_id = 10;
    
    if(v_nr_ang > v_int_a and v_nr_ang < v_int_b) then
        select department_name
        into v_dept
        from departments
        where department_id = 10;
        
        DBMS_OUTPUT.put_line('Departamentul ' || v_dept || ' are ' || v_nr_ang || ' angajat/angajati');
    else
        raise exceptie_4;
    end if;
    
exception
    when exceptie_4 then
        dbms_output.put_line('Departamentul 10 are un numar de angajari care nu se incadreaza in intervalul specificat');
end;
/


--5
select * from dept_rg;

declare
    v_dept_cod dept_rg.department_id%type := &dept_id;
begin
    update dept_rg
    set department_name = 'New dept name'
    where department_id = v_dept_cod;
    
    if sql%notfound then
        RAISE_APPLICATION_ERROR(-20009, 'Nu exista departament cu acest id');
    end if;
end;
/

--6
--varianta 1
declare
    v_locatie dept_rg.location_id%type := 2500;
    v_cod dept_rg.department_id%type := 70;
    v_nume_1 dept_rg.department_name%type;
    v_nume_2 dept_rg.department_name%type;
begin
    begin
        select department_name
        into v_nume_1
        from dept_rg
        where location_id = v_locatie;
    exception
        when no_data_found then
            dbms_output.put_line('Nu exista niciun departament in aceasta locatie');
            dbms_output.put_line('Select 1');
    end;
    
    begin
        select department_name
        into v_nume_2
        from dept_rg
        where department_id = v_cod;
    exception
        when no_data_found then
            dbms_output.put_line('Nu exista niciun departament cu acest cod');
            dbms_output.put_line('Select 2');
    end;
    
end;
/

--varianta 2
declare
    v_locatie dept_rg.location_id%type := 2500;
    v_cod dept_rg.department_id%type := 3;
    v_nume_1 dept_rg.department_name%type;
    v_nume_2 dept_rg.department_name%type;
    v_nr_1 number;
    v_nr_2 number;
begin

    select count(*)
    into v_nr_1 
    from dept_rg
    where location_id = v_locatie;
    
    if(v_nr_1 = 0) then
        RAISE_APPLICATION_ERROR(-20010, 'Select 1 nu intoarce nicio linie');
    else
        select department_name
        into v_nume_1 
        from dept_rg
        where location_id = v_locatie;
    end if;
    
    select count(*)
    into v_nr_2 
    from dept_rg
    where department_id = v_cod;
    
    if(v_nr_2 = 0) then
        RAISE_APPLICATION_ERROR(-20010, 'Select 2 nu intoarce nicio linie');
    else
        select department_name
        into v_nume_2
        from dept_rg
        where department_id = v_cod;
    end if; 
end;
/