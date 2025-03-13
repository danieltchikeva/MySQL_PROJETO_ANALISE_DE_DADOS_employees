##########################    1º PASSO: EXPLORAÇÃO E LIMPEZA DOS DADOS   ##########################
#Verificar se o banco foi importado corretamente
SHOW DATABASES;

#Acessar o Banco de Dados
USE employees;

#Verificar as Tabelas
SHOW TABLES;
/* O nosso Banco de Dados contém as seguintes tabelas:
employees → Informações sobre os funcionários
departments → Departamentos da empresa
dept_emp → Relação entre funcionários e departamentos
dept_manager → Gerentes de departamento
salaries → Histórico de salários dos funcionários
titles → Títulos (cargos) dos funcionários*/

#Contar registros nas tabelas
SELECT COUNT(*) FROM employees;
/*O banco de dados contém '300024' registros*/

#Verificar valores nulos: Tabela employees
SELECT
	COUNT(*) AS total_nulos_birth_date
FROM employees
WHERE birth_date IS NULL;
/*Nenhum valor nulo*/

SELECT
	COUNT(*) AS total_nulos_first_name
FROM employees
WHERE first_name IS NULL;
/*Nenhum valor nulo*/

SELECT
	COUNT(*) AS total_nulos_gender
FROM employees
WHERE gender IS NULL;
/*Nenhum valor nulo*/

#Verificar valores nulos: Tabela salaries
SELECT
	COUNT(*) AS total_nulos_salary
FROM salaries
WHERE salary IS NULL;
/*Nenhum valor nulo*/

#Verificar valores nulos: Tabela dept_emp
SELECT
	COUNT(*) AS total_nulos_emp_no
FROM dept_emp
WHERE emp_no IS NULL;
/*Nenhum valor nulo*/

SELECT
	COUNT(*) AS total_nulos_dept_no
FROM dept_emp
WHERE dept_no IS NULL;
/*Nenhum valor nulo*/

#Verificar valores nulos: Tabela departments
SELECT
	COUNT(*) AS  total_nulos_dept_name
FROM departments
WHERE dept_name IS NULL;
/*Nenhum valor nulo*/

#Verificar valores inconsistentes: Tabela employees
SELECT *
FROM employees
WHERE birth_date > CURDATE();
/*Nenhum funcionário tem data de nascimento no futuro*/

#Verificar valores negativos ou irrealistas: Tabela salaries
SELECT *
FROM salaries
WHERE salary < 0 OR salary > 1000000;
/*Nenhum salário negativo ou irrealista*/

#Verificar se as datas de contratação são maiores que data de saída
SELECT *
FROM dept_emp
WHERE from_date > to_date;
/*Tudo normalizado*/