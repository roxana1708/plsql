--1
CREATE OR REPLACE TRIGGER trig1_tema_rg
	BEFORE DELETE ON dept_rg
DECLARE
	v_user := USER;
BEGIN
	IF(v_user = 'SCOTT')
	THEN
		RAISE_APPLICATION_ERROR(-20010, 'Nu aveti drepturi de stergere');
	END IF;
END;
/

--2
CREATE OR REPLACE TRIGGER trig2_tema_rg
	BEFORE UPDATE OF commission_pct ON emp_rg
	FOR EACH ROW
BEGIN
	IF(:NEW.commission_pct > :OLD.salary * 5 / 10)
	THEN
		RAISE_APPLICATION_ERROR(-20011, 'Comision prea mare');
	END IF;
END;
/

--3.a
ALTER TABLE info_dept_rg
ADD numar number(10);

DECLARE
	TYPE tablou_imbricat IS TABLE OF NUMBER;
	t tablou_imbricat := tablou_imbricat();
BEGIN
	select id_dept
	into t
	from info_dept_rg

	for j in t.first..t.last loop
		UPDATE info_dept_rg
		SET numar = (select count(*)
					from info_emp_rg
					group by t(j));
	END loop;
END;
/

--3.b
CREATE OR REPLACE TRIGGER trig3_tema_rg
	INSTEAD OF INSERT ON info_emp_rg
BEGIN
	INSERT into info_emp_rg
	VALUES (:NEW.id, :NEW.nume, :NEW.prenume, :NEW.salariu,
:NEW.id_dept);

	UPDATE info_dept_rg
	SET numar = numar + 1
	WHERE id = :NEW.id_dept;
END;
/


--4
CREATE OR REPLACE TRIGGER trig4_tema_rg
	BEFORE INSERT ON emp_rg
DECLARE
	nr := 0;
BEGIN
	select count(*)
	into nr
	from emp_rg
	where department_id = :NEW.department_id;

	IF(nr > 45)
	THEN
		RAISE_APPLICATION_ERROR(-20012, 'Prea multi angajati in departament');
	END IF;
END;
/


--5
CREATE OR REPLACE TRIGGER trig5_tema_rg
	INSTEAD OF DELETE OR UPDATE ON dept_test_rg
BEGIN
	IF DELETING THEN
		DELETE from emp_test_rg
		WHERE department_id = :OLD.department_id;

		DELETE from dept_test_rg
		WHERE department_id = :OLD.department_id;

	ELSIF UPDATING THEN
		UPDATE emp_test_rg
		SET department_id = :NEW.department_id
		WHERE department_id = :OLD.department_id;

		UPDATE dept_test_rg
		SET department_id = :NEW.department_id
		WHERE department_id = :OLD.department_id;
	END IF;

END;
/	