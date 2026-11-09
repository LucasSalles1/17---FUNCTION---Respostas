DROP DATABASE IF EXISTS db_funcoes_functions;
CREATE DATABASE db_funcoes_functions;
USE db_funcoes_functions;


-- 1. TABELAS E DADOS DE TESTE
CREATE TABLE Fornecedor (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100)
);

CREATE TABLE Estoque (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ingrediente VARCHAR(100),
    quantidade INT
);

CREATE TABLE ClasseTerapeuta (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100)
);

CREATE TABLE CategoriaImposto (
    id INT PRIMARY KEY AUTO_INCREMENT,
    percentual DECIMAL(5,2)
);


INSERT INTO Fornecedor
VALUES
    (1, 'Moinho Real');

INSERT INTO Estoque
VALUES
    (1, 'Farinha de Trigo', 3);

INSERT INTO ClasseTerapeuta
VALUES
    (1, 'Analgésico');

INSERT INTO CategoriaImposto
VALUES
    (1, 12.50);


-- 2. CRIAÇÃO DAS FUNÇÕES (1 A 20)
DELIMITER //


-- Padaria (1 a 5)

CREATE FUNCTION fn_acrescimo_10(p_preco DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_preco * 1.10;
END //


CREATE FUNCTION fn_tipo_venda(p_qtd INT, p_limite INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    IF p_qtd >= p_limite THEN
        RETURN 'ATACADO';
    ELSE
        RETURN 'UNITÁRIO';
    END IF;
END //


CREATE FUNCTION fn_nome_fornecedor(p_id INT)
RETURNS VARCHAR(100)
READS SQL DATA
BEGIN
    DECLARE v_nome VARCHAR(100);

    SELECT nome
    INTO v_nome
    FROM Fornecedor
    WHERE id = p_id;

    RETURN v_nome;
END //


CREATE FUNCTION fn_farinha_baixo_estoque()
RETURNS VARCHAR(20)
READS SQL DATA
BEGIN
    DECLARE v_qtd INT;

    SELECT quantidade
    INTO v_qtd
    FROM Estoque
    WHERE ingrediente = 'Farinha de Trigo'
    LIMIT 1;

    IF v_qtd < 5 THEN
        RETURN 'BAIXO ESTOQUE';
    ELSE
        RETURN 'ESTOQUE OK';
    END IF;
END //


CREATE FUNCTION fn_dias_validade(
    p_fabricacao DATE,
    p_validade DATE
)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN DATEDIFF(p_validade, p_fabricacao);
END //


-- Farmácia (6 a 10)

CREATE FUNCTION fn_total_item(
    p_qtd INT,
    p_preco DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_qtd * p_preco;
END //


CREATE FUNCTION fn_status_medicamento(p_qtd INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    IF p_qtd = 0 THEN
        RETURN 'Esgotado';
    ELSEIF p_qtd <= 10 THEN
        RETURN 'Baixo';
    ELSE
        RETURN 'Suficiente';
    END IF;
END //


CREATE FUNCTION fn_medicamento_vencido(
    p_hoje DATE,
    p_validade DATE
)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    IF p_validade < p_hoje THEN
        RETURN 'Vencido';
    ELSE
        RETURN 'Na Validade';
    END IF;
END //


CREATE FUNCTION fn_classe_terapeutica(p_id INT)
RETURNS VARCHAR(100)
READS SQL DATA
BEGIN
    DECLARE v_nome VARCHAR(100);

    SELECT nome
    INTO v_nome
    FROM ClasseTerapeuta
    WHERE id = p_id;

    RETURN v_nome;
END //


CREATE FUNCTION fn_calcula_desconto(
    p_valor DECIMAL(10,2),
    p_pct DECIMAL(5,2),
    p_limite DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_desc DECIMAL(10,2);

    SET v_desc = p_valor * (p_pct / 100);

    IF v_desc > p_limite THEN
        RETURN p_limite;
    ELSE
        RETURN v_desc;
    END IF;
END //


-- Agência de Viagens (11 a 15)

CREATE FUNCTION fn_passagem_com_taxa(
    p_valor DECIMAL(10,2),
    p_taxa DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_valor + p_taxa;
END //


CREATE FUNCTION fn_categoria_vagas(p_vagas INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    IF p_vagas = 0 THEN
        RETURN 'Esgotado';
    ELSEIF p_vagas <= 5 THEN
        RETURN 'Últimas Vagas';
    ELSE
        RETURN 'Disponível';
    END IF;
END //


CREATE FUNCTION fn_nome_completo_upper(
    p_nome VARCHAR(50),
    p_sobrenome VARCHAR(50)
)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    RETURN UPPER(CONCAT(p_nome, ' ', p_sobrenome));
END //


CREATE FUNCTION fn_dias_para_viagem(p_data_viagem DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN DATEDIFF(p_data_viagem, CURDATE());
END //


CREATE FUNCTION fn_classifica_diaria(p_preco DECIMAL(10,2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    IF p_preco <= 200.00 THEN
        RETURN 'Econômica';
    ELSE
        RETURN 'Premium';
    END IF;
END //


-- Supermercado (16 a 20)

CREATE FUNCTION fn_total_venda(
    p_qtd INT,
    p_preco DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_qtd * p_preco;
END //


CREATE FUNCTION fn_estoque_critico(
    p_qtd INT,
    p_minimo INT
)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    IF p_qtd <= p_minimo THEN
        RETURN 'Estoque Crítico';
    ELSE
        RETURN 'Estoque Normal';
    END IF;
END //


CREATE FUNCTION fn_imposto_categoria(p_id_cat INT)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_pct DECIMAL(5,2);

    SELECT percentual
    INTO v_pct
    FROM CategoriaImposto
    WHERE id = p_id_cat;

    RETURN v_pct;
END //


CREATE FUNCTION fn_total_funcoes_banco()
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_qtd INT;

    SELECT COUNT(*)
    INTO v_qtd
    FROM information_schema.routines
    WHERE routine_schema = DATABASE()
      AND routine_type = 'FUNCTION';

    RETURN v_qtd;
END //


CREATE FUNCTION fn_padroniza_nome(p_nome VARCHAR(100))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    RETURN TRIM(UPPER(p_nome));
END //

DELIMITER ;


-- 3. TESTES DE EXECUÇÃO (VIA SELECT)
SELECT fn_acrescimo_10(50.00) AS ex01;
SELECT fn_tipo_venda(15, 10) AS ex02;
SELECT fn_nome_fornecedor(1) AS ex03;
SELECT fn_farinha_baixo_estoque() AS ex04;
SELECT fn_dias_validade('2026-01-01', '2026-01-31') AS ex05;
SELECT fn_total_item(5, 12.00) AS ex06;
SELECT fn_status_medicamento(0) AS ex07;
SELECT fn_medicamento_vencido('2026-11-09', '2026-10-01') AS ex08;
SELECT fn_classe_terapeutica(1) AS ex09;
SELECT fn_calcula_desconto(500.00, 10.00, 30.00) AS ex10;
SELECT fn_passagem_com_taxa(1000.00, 150.00) AS ex11;
SELECT fn_categoria_vagas(3) AS ex12;
SELECT fn_nome_completo_upper('maria', 'silva') AS ex13;
SELECT fn_dias_para_viagem('2026-12-25') AS ex14;
SELECT fn_classifica_diaria(180.00) AS ex15;
SELECT fn_total_venda(10, 4.50) AS ex16;
SELECT fn_estoque_critico(4, 5) AS ex17;
SELECT fn_imposto_categoria(1) AS ex18;
SELECT fn_total_funcoes_banco() AS ex19;
SELECT fn_padroniza_nome(' biscoito recheado ') AS ex20;