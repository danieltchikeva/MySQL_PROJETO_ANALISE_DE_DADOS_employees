##########################    2º PASSO: ANALISANDO OS DADOS   ##########################

USE employees;

#Analisando o perfil dos funcionários: Distribuição etária
SELECT YEAR(NOW()) - YEAR(birth_date) AS idade, COUNT(*)
FROM employees
GROUP BY idade
ORDER BY idade;
/*A idade correspondente é dos 60 aos 73 anos de idade*/

#Analisando o perfil dos funcionários: Média salarial por cargo
SELECT t.title, ROUND(AVG(s.salary), 2) AS media_salarial
FROM titles t 
JOIN salaries s ON t.emp_no = s.emp_no
GROUP BY t.title;
/*Gerou um erro devido o tempo de processamento;
para solucionar procuramos aumentar o tempo limite de conexão, não deu certo;
criamos índice do title e do salaries também não deu certo.*/
SET GLOBAL max_allowed_packet = 1073741824;
SET GLOBAL wait_timeout = 28800;
SET GLOBAL interactive_timeout = 28800;
#Criando índices
CREATE INDEX idx_emp_no_titles ON titles(emp_no);
CREATE INDEX idx_emp_no_salaries ON salaries(emp_no);

#Como são muitos dados, a solução que encontramos é reduzir os dados antes do JOIN
SELECT t.title, ROUND(AVG(s.salary), 2) AS media_salarial
FROM titles t 
JOIN (SELECT emp_no, AVG(salary) AS salary FROM salaries GROUP BY emp_no) s 
ON t.emp_no = s.emp_no
GROUP BY t.title
LIMIT 1000;
/*No entanto, obtivemos os seguintes resultados da média salarial:
Senior Engineer(Engenheiro Sênior)= $59144; Staff(Funcionário Geral)= $67000;
Engineer(Engenheiro)= $57244; Senior Staff(Funcionário Sênior)= $69119;
Assistant Engineer(Engenheiro Assistente)= $56963; Technique Leader(Líder Técnico)= $57000
Manager(Gerente)= $66000*/

#ANÁLISE DE DESEMPENHO ORGANIZACIONAL
#Quantidade de funcionários por departamento
SELECT d.dept_name, COUNT(de.emp_no) AS total_funcionarios
FROM dept_emp de 
JOIN departments d ON de.dept_no = d.dept_no
GROUP BY d.dept_name
ORDER BY total_funcionarios DESC;
/*Obtivemos os seguintes resultados
dept_name			total_funcionarios
Development			85707
Production			73485
Sales				52245
Customer Service 	23580
Research		 	21126
Marketing			 20211
Quality Management 	20117
Human Resources	  	17786
Finance			 	17346
*/

#Departamentos com maior rotatividade
SELECT d.dept_name, COUNT(DISTINCT de.emp_no) AS funcionarios_totais,
COUNT(DISTINCT de.to_date) AS funcionarios_saindo
FROM dept_emp de
JOIN departments d ON de.dept_no = d.dept_no
GROUP BY d.dept_name
ORDER BY funcionarios_saindo DESC;
/*RESULTADO: é surpreendente o nº de funcionários que sairam
dept_name			funcionarios_totais		funcionarios_saindo
Production			73485					5149
Sales				52245					4779
Customer Service	23580					3375
Research		 	21126					3250
Quality Management 	20117					3211
Marketing			20211					3170
Human Resources		17786					3026
Finance				17346					2982
*/




