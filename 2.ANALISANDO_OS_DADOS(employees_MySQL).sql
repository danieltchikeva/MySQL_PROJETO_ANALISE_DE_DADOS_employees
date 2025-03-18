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

# Departamentos com maior rotatividade em %
SELECT d.dept_name,
	COUNT(de.emp_no) AS total_funcionarios,
    SUM(CASE WHEN de.to_date != '9999-01-01' THEN 1 ELSE 0 END) AS funcionarios_saidos,
    ROUND((SUM(CASE WHEN de.to_date != '9999-01-01' THEN 1 ELSE 0 END) / COUNT(de.emp_no)) * 100, 2) AS taxa_rotatividade
FROM dept_emp de
JOIN departments d ON de.dept_no = d.dept_no
GROUP BY d.dept_name
ORDER BY taxa_rotatividade DESC;
/*Eis os resultados da porcentagem dos funcionários que deixaram a empresa
dept_name			total_funcionarios	funcionarios_saidos		taxa_rotatividade
Development			85707				24321					28.38
Finance				17346				4909					28.30
Sales				52245				14544					27.84
Quality Management	20117				5571					27.69
Human Resources		17786				4888					27.48
Production			73485				20181					27.46
Research			21126				5685					26.91
Marketing			20211				5369					26.56
Customer Service	23580				6011					25.49
*/

# Idade Média dos Funcionários que Saíram
SELECT ROUND(AVG(YEAR(de.to_date) - YEAR(e.birth_date)), 2) AS idade_media_saida
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
WHERE de.to_date != '9999-01-01';
/*Como resultado, a idade média dos funcionários que deixam a empresa é de 38 anos,
dando-nos a entender que são os jovens que, na maioria, deixam a empresa*/

#Relacionar Salário com Rotatividade
SELECT ROUND(AVG(s.salary), 2) AS salario_medio_saida
FROM salaries s 
JOIN dept_emp de ON s.emp_no = de.emp_no
WHERE de.to_date != '9999-01-01';
/*A média salarial dos que deixam a empresa é de 61.780 dólares.
Comparando com a média salarial por cargo, já calculado acima, 
concluí-se que o salário não influenciou na saída dos funcionários*/

########################   Projeções e Tendências   #############################

# Projeção de gastos com salários no próximo ano:
SELECT YEAR(NOW()) + 1 AS ano_projecao, SUM(s.salary) * 1.05 AS gastos_projetados
FROM salaries s;
/*Aplicando um aumento hipotético de 5%, a projeção de gastos salariais para o ano seguinte é de $ 190554795289*/

# Identificação de padrões de promoção:
SELECT e.gender, t.title, COUNT(*) AS qtd_promocoes
FROM employees e 
JOIN titles t ON e.emp_no = t.emp_no
GROUP BY e.gender, t.title
ORDER BY qtd_promocoes DESC;
/*Eis os resultados:
gender		title					qtd_promocoes
M			Engineer				68940
M			Staff					64537
M			Senior Engineer			58609
M			Senior Staff			55766
F			Engineer				46063
F			Staff					42854
F			Senior Engineer			39141
F			Senior Staff			37087
M			Assistant Engineer		9176
M			Technique Leader		9045
F			Technique Leader		6114
F			Assistant Engineer		5952
F			Manager					13
M			Manager					11
Concluindo, portanto, que os homens são mais promovidos em relação às mulheres*/
