--TEMA
--1
/*
a) Valoarea variabilei numar în subbloc este: 2
b) Valoarea variabilei mesaj1 în subbloc este: text 2
c) Valoarea variabilei mesaj2 în subbloc este: text 3 adaugat in sub-bloc
d) Valoarea variabilei numar în bloc este: 101
e) Valoarea variabilei mesaj1 în bloc este: text 1 adaugat in blocul principal
f) Valoarea variabilei mesaj2 în bloc este: text 2 adaugat in blocul principal
*/
DECLARE
    numar number(3):=100;
    mesaj1 varchar2(255):='text 1'; 
    mesaj2 varchar2(255):='text 2';
BEGIN
    DECLARE
        numar number(3):=1;
        mesaj1 varchar2(255):='text 2'; 
        mesaj2 varchar2(255):='text 3';
    BEGIN
        numar:=numar+1;
        mesaj2:=mesaj2||' adaugat in sub-bloc';
    END;
    numar:=numar+1;
    mesaj1:=mesaj1||' adaugat un blocul principal'; 
    mesaj2:=mesaj2||' adaugat in blocul principal';
END;


--2

--select * from rental;
select day_of_month, coalesce (cnt, 0)
from    (SELECT TO_DATE ('01-OCT-2020', 'DD-MON-YYYY') + LEVEL - 1 as day_of_month
        FROM DUAL
        CONNECT BY LEVEL <= 31
        AND TO_CHAR ( TO_DATE ('01-OCT-2020', 'DD-MON-YYYY') + LEVEL - 1, 'MON') = 'OCT') d
left join     (SELECT  trunc(book_date) as b_d, count(book_date) as cnt
            FROM     rental
            group by trunc(book_date)) r
on d.day_of_month = r.b_d
order by day_of_month;


--b
create table octombrie_rg
(id number,
data date);

DECLARE
    nr_zi number(2) := 1;
BEGIN
    loop
        insert into octombrie_rg
        values (nr_zi, TO_DATE(nr_zi||'.10.2020', 'dd.mm.yy'));
        nr_zi := nr_zi + 1;
        exit when nr_zi >= 32;
    end loop;
END;
--select * from octombrie_rg
    
--3
declare
    v_name varchar2(50) := '&p_name';
    v_nr number := 0;
    v_id number := 0;
begin
    --v_name := &p_name;
    select m.member_id
    into v_id
    from member m
    where m.last_name || ' ' || m.first_name = v_name;
    
    select count(distinct r.title_id)
    into v_nr
    from rental r
    where r.member_id = v_id;
    
    dbms_output.put_line('Membrul ' || v_name || ' a imprumutat ' || v_nr || ' filme.');
exception
    when no_data_found then 
        dbms_output.put_line(v_name || 'nu este membru');
    when too_many_rows then
        dbms_output.put_line('Mai multi membrii cu numele ' || v_name);
end;


--4
declare
    v_name varchar2(50) := '&p_name';
    v_nr number := 0;
    v_id number := 0;
    v_nr_titluri number := 0;
begin
    --v_name := &p_name;
    select m.member_id
    into v_id
    from member m
    where m.last_name || ' ' || m.first_name = v_name;
    
    select count(distinct r.title_id)
    into v_nr
    from rental r
    where r.member_id = v_id;
    
    dbms_output.put_line('Membrul ' || v_name || ' a imprumutat ' || v_nr || ' filme.\n');
    
    select count(title_id)
    into v_nr_titluri
    from title;
    
    case 
        when v_nr > 3*v_nr_titluri/4 then dbms_output.put_line('Categoria 1');
        when v_nr > 5*v_nr_titluri/10 then dbms_output.put_line('Categoria 2');
        when v_nr > v_nr_titluri/5 then dbms_output.put_line('Categoria 3');
        else dbms_output.put_line('Categoria 4');
    end case;
    
exception
    when no_data_found then 
        dbms_output.put_line(v_name || 'nu este membru');
    when too_many_rows then
        dbms_output.put_line('Mai multi membrii cu numele ' || v_name);
end;


--5
create table member_rg
    as (select * from member);
    
alter table member_rg
    add discount number default 0;
    
select * from member_rg

declare 
    v_id member_rg.member_id%type := &id;
    v_discount member_rg.discount%type;
    v_nr number;
    v_nr_titluri number;
    i number;
begin

    select count(distinct r.title_id)
    into v_nr
    from rental r
    where r.member_id = v_id;
    
    select count(title_id)
    into v_nr_titluri
    from title;
    
    case 
        when v_nr > 3*v_nr_titluri/4 then v_discount := 10;
        when v_nr > 5*v_nr_titluri/10 then v_discount := 5;
        when v_nr > v_nr_titluri/5 then v_discount := 3;
        else v_discount := 0;
    end case;
    
    update member_rg
    set discount = v_discount
    where member_id = v_id;
    i := SQL%rowcount;
    
    if i > 0 then 
        dbms_output.Put_line('OK');
    else 
        dbms_output.Put_line('Niciun rand modificat');
    end if;
end;

