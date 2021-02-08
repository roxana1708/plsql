--1
create table info_rg
(
	utilizator varchar2(50) not null,
	data date default (sysdate),
	comanda varchar2(100),
	nr_linii number(5),
	eroare varchar2(100)
);
/

--2
CREATE OR REPLACE FUNCTION f2_rg
	(v_nume employees.last_name%TYPE DEFAULT 'Bell')
RETURN NUMBER IS
	salariu employees.salary%type;
BEGIN
	begin
		SELECT salary INTO salariu
		FROM employees
		WHERE last_name = v_nume;
		RETURN salariu;
	  EXCEPTION
	    WHEN NO_DATA_FOUND THEN
			eroare := 'Nu exista angajati cu numele dat';
		WHEN TOO_MANY_ROWS THEN 
			eroare := 'Exista mai multi angajati cu numele dat';
	    WHEN OTHERS THEN
			eroare := 'Alta eroare!';
	end;

	begin 
		declare
		     eroare varchar2(100),
			utilizator varchar2 := USER,
			comanda varchar2(100) := 'f2_rg'
		begin
			insert into info_rg (utilizator, data, comanda, nr_linii, eroare)
			values (utilizator, sysdate, comanda, 25, eroare);
		end;
	end;

END f2_rg;
/


CREATE OR REPLACE PROCEDURE p4_rg
	(v_nume employees.last_name%TYPE)
IS
	salariu employees.salary%TYPE;

	eroare varchar2(100),
	utilizator varchar2 := USER,
	comanda varchar2(100) := 'p4_rg'
BEGIN
	begin
		SELECT salary INTO salariu
		FROM employees
		WHERE last_name = v_nume;
		DBMS_OUTPUT.PUT_LINE('Salariul este '|| salariu);
	  EXCEPTION
	    WHEN NO_DATA_FOUND THEN
			eroare := 'Nu exista angajati cu numele dat';
		WHEN TOO_MANY_ROWS THEN 
			eroare := 'Exista mai multi angajati cu numele dat';
	    WHEN OTHERS THEN
			eroare := 'Alta eroare!';
	end;
	insert into info_rg (utilizator, data, comanda, nr_linii, eroare)
		values (utilizator, sysdate, comanda, 25, eroare);
END p4_rg;
/


--3
create or replace FUNCTION ft3_rg
	(oras locations.city%TYPE default 'Seattle')
RETURN NUMBER IS
	nr_ang number(5);
begin
	
	begin
		select location_id
		from locations
		where city = oras;

	  EXCEPTION
	  	when NO_DATA_FOUND THEN
	  		eroare := 'Orasul nu exista in lista';
	end;

	begin
		select employee_id
		from employees e, departments d, locations l
		where e.employee_id = j.employee_id)
		and e.department_id = d.department_id
		and d.location_id = l.location_id
		and l.city = oras;

		EXCEPTION
	  	when NO_DATA_FOUND THEN
	  		eroare := 'Niciun angajat nu lucreaza in orasul selectat';
	end;

	select count(employee_id) into nr_ang
	from employees e, departments d, locations l
	where 2 <= (select count(job_id)
	            from job_history j
	            where e.employee_id = j.employee_id)
	            and e.department_id = d.department_id
	            and d.location_id = l.location_id
	            and l.city = oras);

	if nr_ang = 0 THEN
		eroare := 'Niciun angajat cu cel putin doua joburi nu lucreaza in orasul selectat'

	begin 
		declare
		     eroare varchar2(100),
			utilizator varchar2 := USER,
			comanda varchar2(100) := 'ft3_rg'
		begin
			insert into info_rg (utilizator, data, comanda, nr_linii, eroare)
			values (utilizator, sysdate, comanda, 27, eroare);
		end;
	end;

END ft3_rg;
/


--4
create or replace PROCEDURE pt4_rg
	(manager employees.manager_id%TYPE)
IS
	eroare varchar2(100),
	utilizator varchar2 := USER,
	comanda varchar2(100) := 'pt4_rg'
BEGIN
	begin
		select employee_id
		from emp_rg
		where emp_rg = manager;
		EXCEPTION
			when NO_DATA_FOUND then 
				eroare := 'Nu exista angajat cu codul respectiv';
	end;
	begin
		update emp_rg
			set salary = salary + salary * 10/100
			where manager_id = manager
	  EXCEPTION
	    WHEN NO_DATA_FOUND THEN
			eroare := 'Nu exista angajati care au managerul dat';
	end;
	insert into info_rg (utilizator, data, comanda, nr_linii, eroare)
		values (utilizator, sysdate, comanda, 25, eroare);
END pt4_rg;
/


--5
create or replace PROCEDURE pt5_rg
IS
	type tab_ind is table of number index by pls_integer;
	dept_id tab_ind;
begin
	select department_id into dept_id
	from departments;

	for i in dept_id.first..dept_id.last loop
		begin
			select department_id, to_char(HIRE_DATE,'DAY'), first_name, last_name, salary, trunc(MONTHS_BETWEEN(sysdate,hire_date)/12) as vechime 
			from employees
			where department_id = dept_id(i) and to_char(HIRE_DATE,'DAY') in (select TO_CHAR(HIRE_DATE,'DAY') DAY
																		from emp_rg
																		where department_id = dept_id(i)
																		group by TO_CHAR(hire_date,'DAY')
																		having COUNT (*)=(select MAX(COUNT(*))
			                    															from emp_rg
			                    															where department_id = dept_id(i)
			                    															group by TO_CHAR(hire_date,'DAY'))
					
																		);
			EXCEPTION
				when NO_DATA_FOUND then 
					DBMS_OUTPUT.PUT_LINE('Niciun angajat gasit in lista');
		end;													
	end loop;

end;

