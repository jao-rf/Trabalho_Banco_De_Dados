-- =====================================================================
-- Trabalho Final de Banco de Dados
-- Controle de almoxarifado e empréstimos do PET
-- =====================================================================

-- 1. Criação das tabelas base
CREATE TABLE IF NOT EXISTS discente (
    id SERIAL NOT NULL,
    nome VARCHAR(50) NOT NULL,
    matricula VARCHAR(20) NOT NULL,
    curso VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    telefone VARCHAR(14) NOT NULL,
    petiano BOOL NOT NULL DEFAULT FALSE, -- TRUE - integrante, FALSE - externo
    ativo BOOL NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_discente PRIMARY KEY(id)
);

CREATE TABLE IF NOT EXISTS local_armazenado (
    id SERIAL NOT NULL,
    nome_local VARCHAR(50) NOT NULL,
    compartimento VARCHAR(30),
    descricao VARCHAR(100),
    CONSTRAINT pk_local_armazenado PRIMARY KEY(id)
);

CREATE TABLE IF NOT EXISTS categoria_produto (
    id SERIAL NOT NULL,
    nome_categoria VARCHAR(50) NOT NULL,
    consumivel BOOL NOT NULL DEFAULT FALSE, -- TRUE - consumível, FALSE - permanente
    CONSTRAINT pk_categoria_produto PRIMARY KEY(id)
);

-- 2. Criação das tabelas que dependem das tabelas base
CREATE TABLE IF NOT EXISTS produto (
    id SERIAL NOT NULL,
    categoria_produto_id INT NOT NULL,
    local_armazenado_id INT NOT NULL,
    nome VARCHAR(80) NOT NULL,
    estoque_minimo INT NOT NULL DEFAULT 1,
    estoque_desejavel DECIMAL NOT NULL DEFAULT 2,
    em_estoque INT NOT NULL DEFAULT 0,
    custo_unitario DECIMAL,
    link_produto VARCHAR(200),
    nivel_estoque CHAR(1) NOT NULL DEFAULT 'a', -- b - baixo, m - médio, a - alto
    ativo BOOL NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_produto PRIMARY KEY(id),
    CONSTRAINT fk_produto_categoria_produto FOREIGN KEY(categoria_produto_id) REFERENCES categoria_produto(id),
    CONSTRAINT fk_produto_local_armazenado FOREIGN KEY(local_armazenado_id) REFERENCES local_armazenado(id),
    CONSTRAINT ck_produto_nivel_estoque CHECK (nivel_estoque IN ('b', 'm', 'a'))
);

CREATE TABLE IF NOT EXISTS emprestimo (
    id SERIAL NOT NULL,
    discente_id INT NOT NULL,
    finalidade VARCHAR(80) NOT NULL,
    data_emprestimo DATE NOT NULL,
    data_prevista_devolucao DATE NOT NULL,
    status_emprestimo CHAR(1) NOT NULL DEFAULT 'a', -- a - em aberto, d - devolvido, t - atrasado
    CONSTRAINT pk_emprestimo PRIMARY KEY(id),
    CONSTRAINT fk_emprestimo_discente FOREIGN KEY(discente_id) REFERENCES discente(id),
    CONSTRAINT ck_emprestimo_status CHECK (status_emprestimo IN ('a', 'd', 't'))
);

-- 3. Criação das tabelas que dependem das tabelas secundárias
CREATE TABLE IF NOT EXISTS entrada (
    id SERIAL NOT NULL,
    produto_id INT NOT NULL,
    discente_id INT NOT NULL,
    data_de_entrada DATE NOT NULL,
    descricao VARCHAR(30) NOT NULL,
    quantidade INT NOT NULL,
    custo_unitario DECIMAL NOT NULL,
    custo_total DECIMAL NOT NULL,
    CONSTRAINT pk_entrada PRIMARY KEY(id),
    CONSTRAINT fk_entrada_produto FOREIGN KEY(produto_id) REFERENCES produto(id),
    CONSTRAINT fk_entrada_discente FOREIGN KEY(discente_id) REFERENCES discente(id)
);

CREATE TABLE IF NOT EXISTS saida_baixa (
    id SERIAL NOT NULL,
    produto_id INT NOT NULL,
    discente_id INT NOT NULL,
    data_de_saida DATE NOT NULL,
    descricao VARCHAR(100) NOT NULL,
    quantidade INT NOT NULL,
    motivo_baixa CHAR(1) NOT NULL, -- q - queimou, b - quebrou, c - consumido, p - perda
    CONSTRAINT pk_saida_baixa PRIMARY KEY(id),
    CONSTRAINT fk_saida_baixa_produto FOREIGN KEY(produto_id) REFERENCES produto(id),
    CONSTRAINT fk_saida_baixa_discente FOREIGN KEY(discente_id) REFERENCES discente(id),
    CONSTRAINT ck_saida_baixa_motivo CHECK (motivo_baixa IN ('q', 'b', 'c', 'p'))
);

CREATE TABLE IF NOT EXISTS compra_reposicao (
    id SERIAL NOT NULL,
    produto_id INT NOT NULL,
    discente_id INT NOT NULL,
    data_compra DATE NOT NULL,
    descricao VARCHAR(50) NOT NULL,
    quantidade DECIMAL NOT NULL,
    status_compra CHAR(1) NOT NULL DEFAULT 'c', -- p - pendente, c - comprado, r - recebido
    CONSTRAINT pk_compra_reposicao PRIMARY KEY(id),
    CONSTRAINT fk_compra_reposicao_produto FOREIGN KEY(produto_id) REFERENCES produto(id),
    CONSTRAINT fk_compra_reposicao_discente FOREIGN KEY(discente_id) REFERENCES discente(id),
    CONSTRAINT ck_compra_reposicao_status CHECK (status_compra IN ('p', 'c', 'r'))
);

CREATE TABLE IF NOT EXISTS item_emprestimo (
    id SERIAL NOT NULL,
    produto_id INT NOT NULL,
    emprestimo_id INT NOT NULL,
    quantidade_emprestada INT NOT NULL,
    data_devolucao DATE,
    condicao_devolucao CHAR(1) DEFAULT 'b', -- b - bom, r - ruim, p - precisa de reparo
    observacao VARCHAR(100),
    CONSTRAINT pk_item_emprestimo PRIMARY KEY(id),
    CONSTRAINT fk_item_emprestimo_produto FOREIGN KEY(produto_id) REFERENCES produto(id),
    CONSTRAINT fk_item_emprestimo_emprestimo FOREIGN KEY(emprestimo_id) REFERENCES emprestimo(id),
    CONSTRAINT ck_item_emprestimo_condicao CHECK (condicao_devolucao IN ('b', 'r', 'p'))
);