create or replace PACKAGE pachet_tema_rg as
	--a
	PROCEDURE a_adaugare_angajat (v_nume emp_rg.last_name%TYPE,
									v_prenume emp_rg.first_name%TYPE,
									v_telefon emp_rg.phone%TYPE,
									v_email emp_rg.email%TYPE,
									v_nume_dept dept_rg.department_name%TYPE,
									v_nume_job jobs.job_title,
									v_nume_manager emp_rg.last_name%TYPE,
									v_prenume_manager emp_rg.first_name%TYPE);
	FUNCTION a_get_salariu;
	FUNCTION a_get_cod_manager;
	FUNCTION a_get_cod_dept (v_nume_dept dept_rg.department_name%TYPE);
	FUNCTION a_get_cod_job (v_nume_job jobs.job_title);

	--b
	PROCEDURE b_update_dept_angajat (v_nume emp_rg.last_name%TYPE,
									v_prenume emp_rg.first_name%TYPE,
									v_nume_dept dept_rg.department_name%TYPE,
									v_nume_job jobs.job_title,
									v_nume_manager emp_rg.last_name%TYPE,
									v_prenume_manager emp_rg.first_name%TYPE);

	--c
	FUNCTION c_get_nr_subalterni (v_nume_manager emp_rg.last_name%TYPE,
									v_prenume_manager emp_rg.first_name%TYPE);

	--e
	PROCEDURE e_update_salariu (v_nume emp_rg.last_name%TYPE,
								v_salariu emp_rg.salary%TYPE);

	--f
	CURSOR f_crs_angajati (cod_job number) RETURN emp_rg%rowtype;

	--g
	CURSOR g_crs_joburi RETURN jobs%rowtype;

end pachet_tema_rg;
/

create or replace PACKAGE BODY pachet_tema_rg as

	FUNCTION a_get_cod_job (v_nume_job jobs.job_title%TYPE)
	RETURN emp_rg.job_id%TYPE is
		cod_job emp_rg.job_id%TYPE;

	begin
		select job_id into cod_job
		from jobs
		where job_title = v_nume_job;
	end;

	RETURN cod_job;
	end;

	--------

	FUNCTION a_get_cod_dept (v_nume_dept dept_rg.department_name%TYPE)
	RETURN dept_rg.department_id%TYPE is
		cod_dept dept_rg.department_name%TYPE;

	begin
		select department_id into cod_dept
		from dept_rg
		where department_name = v_nume_dept;
	end;

	RETURN cod_dept;
	end;

	--------

	FUNCTION a_get_salariu (v_nume_dept dept_rg.department_name%TYPE,
							v_nume_job jobs.job_title%TYPE)
	RETURN number is
		salariu emp_rg.salary%TYPE;
	begin
		select min(salary) into salariu
		from emp_rg e, dept_rg d
		where e.department_id = a_get_cod_dept
		and e.job_id = a_get_cod_job;

	RETURN salariu;
	end;

	---------

	FUNCTION a_get_cod_manager (v_nume_manager emp_rg.last_name%TYPE,
								v_prenume_manager emp_rg.first_name%TYPE)
	RETURN emp_rg.manager_id%TYPE is
		cod_manager dept_rg.manager_id%TYPE;

	begin
		select employee_id into cod_manager
		from emp_rg
		where first_name = v_prenume_manager and last_name = v_nume_manager;
	end;

	RETURN cod_manager;
	end;

	---------

	PROCEDURE a_adaugare_angajat (v_nume emp_rg.last_name%TYPE,
									v_prenume emp_rg.first_name%TYPE,
									v_telefon emp_rg.phone_number%TYPE,
									v_email emp_rg.email%TYPE,
									v_nume_dept dept_rg.department_name%TYPE,
									v_nume_job jobs.job_title,
									v_nume_manager emp_rg.last_name%TYPE,
									v_prenume_manager emp_rg.first_name%TYPE)

	begin
		insert into emp_rg (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id)
			values (empseq_rg.nextval, v_prenume, v_nume, v_email, v_telefon, sysdate, a_get_cod_job(v_nume_job), a_get_salariu(v_nume_dept, v_nume_job), 0, a_get_cod_manager(v_nume_manager, v_prenume_manager), a_get_cod_dept(v_nume_dept));
	end;

	end cod_manager;

	---------

	PROCEDURE b_update_dept_angajat (v_nume emp_rg.last_name%TYPE,
									v_prenume emp_rg.first_name%TYPE,
									v_nume_dept dept_rg.department_name%TYPE,
									v_nume_job jobs.job_title,
									v_nume_manager emp_rg.last_name%TYPE,
									v_prenume_manager emp_rg.first_name%TYPE)

	begin
		update emp_rg
			set department_id = a_get_cod_dept(v_nume_dept),
				job_id = a_get_cod_job(v_nume_job),
				manager_id = a_get_cod_manager(v_nume_manager, v_prenume_manager),
				salary = case 
							when a_get_salariu(v_nume_dept, v_nume_job) <= salary then
									a_get_salariu(v_nume_dept, v_nume_job)
							else
								salary
							end,
				commission_pct = 0,
				hire_date = sysdate
			where first_name = v_prenume and last_name = v_nume;
	end;

	end b_update_dept_angajat;

	---------

	FUNCTION c_get_nr_subalterni (v_nume_manager emp_rg.last_name%TYPE,
									v_prenume_manager emp_rg.first_name%TYPE)
	RETURN number is
		nr_subalterni number := 0;
		cod_manager = a_get_cod_manager(v_nume_manager, v_prenume_manager);

	begin
		select count(employee_id) into nr_subalterni
		from emp_rg
		where manager_id = cod_manager;
	end;

	RETURN nr_subalterni;
	end;

	---------

	PROCEDURE e_update_salariu (v_nume emp_rg.last_name%TYPE,
								v_salariu emp_rg.salary%TYPE)
	IS 
		cod_job = emp_rg.job_id%TYPE;
		salariu = emp_rg.salary%TYPE;
		salariu_min = emp_rg.salary%TYPE;
		salariu_max = emp_rg.salary%TYPE;

	begin
		begin
			select job_id into cod_job
			from emp_rg
			where last_name = v_nume;
		exception
			when no_data_found then
				DBMS_OUTPUT.PUT_LINE('nu este niciun angajat care sa aiba numele respectiv');
			when too_many_rows_found then
				DBMS_OUTPUT.PUT_LINE('exista mai multi angajati cu acest nume');
		end;

		select min_salary, max_salary
		into salariu_min. salariu_max
		from jobs
		where job_id = cod_job;

		if v_salariu < salariu_min then 
			DBMS_OUTPUT.PUT_LINE('salariu introdus este prea mic');
		elsif v_salariu > salariu_max then
			DBMS_OUTPUT.PUT_LINE('salariu introdus este prea mare');
		end if;


		update emp_rg
			set salary = v_salariu
			where last_name = v_nume;

	end;

	end e_update_salariu;

	---------

	CURSOR f_crs_angajati (cod_job number) RETURN emp_rg%rowtype
		IS
		select *
		from emp_rg
		where job_id = cod_job;

	---------

	CURSOR g_crs_joburi RETURN jobs%rowtype
		IS
		select *
		from jobs


end pachet_tema_rg;
/