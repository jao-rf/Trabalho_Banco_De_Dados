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


-- =====================================================================
-- 4. Inserção dos dados
-- =====================================================================

-- Discentes (FICTÍCIOS)
INSERT INTO discente (nome, matricula, curso, email, telefone, petiano, ativo) VALUES
('Ana Beatriz Souza', '2023114400011', 'Engenharia de Controle e Automação', 'ana.souza@estudante.ifmt.edu.br', '65999110001', TRUE, TRUE), -- id 1
('Lucas Henrique Martins', '2023114400028', 'Engenharia de Controle e Automação', 'lucas.martins@estudante.ifmt.edu.br', '65999110002', TRUE, TRUE), -- id 2
('Mariana Costa Lima', '2022214400153', 'Engenharia da Computação', 'mariana.lima@estudante.ifmt.edu.br', '65999110003', TRUE, TRUE), -- id 3
('Pedro Augusto Ribeiro', '2024114400231', 'Engenharia de Controle e Automação', 'pedro.ribeiro@estudante.ifmt.edu.br', '65999110004', TRUE, TRUE), -- id 4
('Gabriela Fernandes Rocha', '2021114400305', 'Engenharia de Controle e Automação', 'gabriela.rocha@estudante.ifmt.edu.br', '65999110005', TRUE, FALSE), -- id 5
('Rafael Oliveira Santos', '2024123400412', 'Engenharia Elétrica', 'rafael.santos@estudante.ifmt.edu.br', '65999110006', FALSE, TRUE), -- id 6
('Juliana Pereira Alves', '2023223400527', 'Engenharia da Computação', 'juliana.alves@estudante.ifmt.edu.br', '65999110007', FALSE, TRUE), -- id 7
('Thiago Barbosa Nunes', '2025114400118', 'Engenharia de Controle e Automação', 'thiago.nunes@estudante.ifmt.edu.br', '65999110008', FALSE, TRUE); -- id 8

INSERT INTO local_armazenado (nome_local, compartimento, descricao) VALUES
('Armário de componentes', 'Gaveteiro A', 'Circuitos integrados e reguladores de tensão'), -- id 1
('Armário de componentes', 'Gaveteiro B', 'Transistores, diodos e LEDs'), -- id 2
('Armário de componentes', 'Gaveteiro C', 'Capacitores, cristais, fusíveis e outros passivos'), -- id 3
('Armário de componentes', 'Gaveteiro D', 'Conectores, chaves, bornes, soquetes e relés'), -- id 4
('Armário de placas', 'Prateleira 1', 'Arduinos, ESPs, Raspberry Pi e shields'), -- id 5
('Armário de placas', 'Prateleira 2', 'Sensores, atuadores, módulos, baterias e fontes'), -- id 6
('Bancada de instrumentos', NULL, 'Osciloscópios, geradores de função, fontes e multímetros'), -- id 7
('Bancada de instrumentos', 'Gaveta de cabos', 'Pontas de prova e cabos de medição'), -- id 8
('Sala do PET', NULL, 'Computadores, monitores, impressoras e mobiliário'), -- id 9
('Armário de ferramentas', 'Prateleira inferior', 'Ferramentas e equipamentos diversos'); -- id 10

INSERT INTO categoria_produto (nome_categoria, consumivel) VALUES
('Microcontroladores e placas de desenvolvimento', FALSE), -- id 1
('Circuitos integrados', TRUE), -- id 2
('Semicondutores discretos e LEDs', TRUE), -- id 3
('Componentes passivos', TRUE), -- id 4
('Conectores, chaves e relés', TRUE), -- id 5
('Sensores, atuadores e módulos', FALSE), -- id 6
('Instrumentos de medição e acessórios', FALSE), -- id 7
('Informática e mobiliário', FALSE), -- id 8
('Ferramentas e equipamentos diversos', FALSE), -- id 9
('Energia e baterias', FALSE); -- id 10

INSERT INTO produto (categoria_produto_id, local_armazenado_id, nome, estoque_minimo, estoque_desejavel, em_estoque, custo_unitario, nivel_estoque) VALUES
(1, 5, 'Raspberry PI 4 Modelo B', 1, 1.5, 1, 700, 'm'), -- id 1
(1, 5, 'Raspberry PI 5', 1, 1.5, 2, 1200, 'a'), -- id 2
(2, 1, '74HC164N', 2, 3, 1, 3, 'b'), -- id 3
(5, 4, 'ADAPTADOR J4-FEMEA', 5, 7.5, 5, 2, 'm'), -- id 4
(5, 4, 'ADAPTADOR SD CARD', 2, 3, 5, 5, 'a'), -- id 5
(2, 1, 'AND 4081', 2, 3, 7, 3, 'a'), -- id 6
(2, 1, 'AND 7400', 2, 3, 2, 2.5, 'm'), -- id 7
(1, 5, 'Arduino Leonardo', 1, 1.5, 1, 80, 'm'), -- id 8
(1, 5, 'Arduino nano', 1, 1.5, 2, 40, 'a'), -- id 9
(1, 5, 'Arduino Uno', 7, 10.5, 23, 40, 'a'), -- id 10
(2, 1, 'ATMEGA328P', 3, 4.5, 5, 20, 'a'), -- id 11
(5, 4, 'BARRA DE PINOS', 30, 45, 100, 2, 'a'), -- id 12
(10, 6, 'Bateria de lítio 18650', 9, 13.5, 25, NULL, 'a'), -- id 13
(2, 1, 'BCD 7-SEGMENT 4511', 4, 6, 16, 4, 'a'), -- id 14
(2, 1, 'BCD-TO-DECIMAL 4028', 4, 6, 10, 4, 'a'), -- id 15
(2, 1, 'BCD-UP-DOWN 4510', 4, 6, 20, 4.5, 'a'), -- id 16
(5, 4, 'BORNE 3 VIAS', 5, 7.5, 3, 1.5, 'b'), -- id 17
(5, 4, 'BORNE PRESSÃO 4 VIAS', 10, 15, 2, 3, 'b'), -- id 18
(9, 10, 'BORRACHA SUGADOR DE SOLDA', 2, 3, 4, 5, 'a'), -- id 19
(1, 5, 'Brick Pi Dexter Industries', 1, 1.5, 1, 900, 'm'), -- id 20
(6, 6, 'BUZZER', 5, 7.5, 3, 2, 'b'), -- id 21
(7, 8, 'cabo de gerador de função BNC/jacaré', 2, 3, 6, 40, 'a'), -- id 22
(7, 8, 'Cabo ponta de prova banana / banana', 4, 6, 39, 30, 'a'), -- id 23
(7, 8, 'Cabo ponta de prova banana / jacaré preto', 4, 6, 7, 23, 'a'), -- id 24
(7, 8, 'Cabo ponta de prova banana / jacaré vermelho', 4, 6, 9, 23, 'a'), -- id 25
(8, 9, 'Cadeiras de escritório giratórias', 8, 12, 18, 900, 'a'), -- id 26
(4, 3, 'CAPACITOR 100uF 25V', 10, 15, 10, 0.3, 'm'), -- id 27
(4, 3, 'CAPACITOR 10uF 16V', 10, 15, 10, 0.2, 'm'), -- id 28
(4, 3, 'CAPACITOR 10uF 25V', 10, 15, 10, 0.2, 'm'), -- id 29
(4, 3, 'CAPACITOR 47nF 50V', 10, 15, 10, 0.2, 'm'), -- id 30
(10, 6, 'Carregador de Bateria de litio 18650', 5, 7.5, 7, NULL, 'm'), -- id 31
(5, 4, 'CHAVE 2 ESTÁGIO 3A 125VAC', 5, 7.5, 4, 4, 'b'), -- id 32
(5, 4, 'CHAVE 3 ESTÁGIO 6A 125VAC', 5, 7.5, 3, 4, 'b'), -- id 33
(5, 4, 'CHAVE GANGORRA', 5, 7.5, 12, 2, 'a'), -- id 34
(2, 1, 'CI 4015', 2, 3, 10, 4, 'a'), -- id 35
(2, 1, 'CI 4071', 2, 3, 2, 3, 'm'), -- id 36
(2, 1, 'CI 4093', 2, 3, 1, 3, 'b'), -- id 37
(2, 1, 'CI INA12828PA', 2, 3, 1, 45, 'b'), -- id 38
(2, 1, 'CI L298N', 2, 3, 2, 15, 'm'), -- id 39
(1, 5, 'CNC Shield V3', 1, 1.5, 1, 50, 'm'), -- id 40
(8, 9, 'Computador', 8, 12, 4, 1500, 'b'), -- id 41
(5, 4, 'CONECTOR 2 VIAS QUADRADO', 10, 15, 6, 1, 'b'), -- id 42
(5, 4, 'CONECTOR 2 VIAS QUADRADO MACHO', 10, 15, 4, 1, 'b'), -- id 43
(5, 4, 'CONECTOR BORNE 2 VIAS', 10, 15, 10, 1.5, 'm'), -- id 44
(5, 4, 'CONECTOR BULLE1', 5, 7.5, 0, 1, 'b'), -- id 45
(5, 4, 'CONECTOR DE FIO', 10, 15, 65, 0.5, 'a'), -- id 46
(5, 4, 'CONECTOR JACK P4 DC', 5, 7.5, 15, 2, 'a'), -- id 47
(5, 4, 'CONECTOR JACK-P4 MACHO', 5, 7.5, 3, 2, 'b'), -- id 48
(5, 4, 'CONECTOR P4-FEMEA', 5, 7.5, 22, 2, 'a'), -- id 49
(4, 3, 'CRISTAL 16MHz', 5, 7.5, 5, 2, 'm'), -- id 50
(4, 3, 'CRISTAL 20MHz', 5, 7.5, 10, 2, 'a'), -- id 51
(3, 2, 'DIODO 1N4004', 5, 7.5, 1, 0.2, 'b'), -- id 52
(3, 2, 'DIODO 1N4007', 5, 7.5, 12, 0.2, 'a'), -- id 53
(3, 2, 'DIODO ZENER', 5, 7.5, 0, 0.3, 'b'), -- id 54
(3, 2, 'DISPLAY HS-5202 AG 7SEGMENT', 2, 3, 4, 4, 'a'), -- id 55
(2, 1, 'DRIVER MOTOR L293D', 5, 7.5, 12, 8, 'a'), -- id 56
(9, 10, 'Impressora 3D Ender 3', 1, 1.5, 1, 1800, 'm'), -- id 57
(8, 9, 'Impressora Samsung ProXpress SL-M407', 1, 1.5, 1, 5000, 'm'), -- id 58
(1, 5, 'Esp32', 10, 15, 12, 45, 'm'), -- id 59
(1, 5, 'ESP32-CAM', 1, 1.5, 1, 55.86, 'm'), -- id 60
(1, 5, 'Esp8266', 4, 6, 3, 30, 'b'), -- id 61
(5, 4, 'ESPAÇADOR MACHO-FEMEA', 5, 7.5, 22, 0.5, 'a'), -- id 62
(1, 5, 'Ethernet Shield W5100', 1, 1.5, 2, 80, 'a'), -- id 63
(2, 1, 'FLIP-FLOP 4013', 2, 3, 10, 3.5, 'a'), -- id 64
(7, 7, 'fonte minipa MPL-3303M', 2, 3, 7, 1800, 'a'), -- id 65
(10, 6, 'Fonte para Raspberry PI 5', 1, 1.5, 1, 142, 'm'), -- id 66
(4, 3, 'FUSÍVEL 0,25A', 5, 7.5, 10, 0.3, 'a'), -- id 67
(4, 3, 'FUSÍVEL 0,5A', 5, 7.5, 10, 0.3, 'a'), -- id 68
(4, 3, 'FUSÍVEL 1A', 5, 7.5, 8, 0.3, 'a'), -- id 69
(4, 3, 'FUSÍVEL 2A', 5, 7.5, 8, 0.3, 'a'), -- id 70
(4, 3, 'FUSÍVEL 3A', 5, 7.5, 10, 0.3, 'a'), -- id 71
(7, 7, 'Gerador De Função GF-220 instrutherm', 2, 3, 6, 2000, 'a'), -- id 72
(9, 10, 'Gravadora K150 de PIC', 1, 1.5, 1, 150, 'm'), -- id 73
(2, 1, 'HCF 4017', 2, 3, 10, 3.5, 'a'), -- id 74
(2, 1, 'HCF 4027', 2, 3, 7, 3.5, 'a'), -- id 75
(2, 1, 'HCF 4093', 2, 3, 9, 3, 'a'), -- id 76
(2, 1, 'HCF4066', 2, 3, 10, 3, 'a'), -- id 77
(2, 1, 'HEX INVERTER 4049', 2, 3, 9, 3, 'a'), -- id 78
(1, 5, 'Kit IFMT 4.0 (Arduino Mega)', 8, 12, 16, 500, 'a'), -- id 79
(4, 3, 'LDR', 2, 3, 1, 1, 'b'), -- id 80
(3, 2, 'LED AMARELO', 10, 15, 30, 0.25, 'a'), -- id 81
(3, 2, 'LED AZUL', 10, 15, 30, 0.25, 'a'), -- id 82
(3, 2, 'LED BRANCO', 10, 15, 30, 0.25, 'a'), -- id 83
(3, 2, 'LED RGB', 10, 15, 8, 1.5, 'b'), -- id 84
(3, 2, 'LED VERDE', 10, 15, 30, 0.25, 'a'), -- id 85
(3, 2, 'LED VERMELHO', 10, 15, 24, 0.25, 'a'), -- id 86
(2, 1, 'LM324N', 2, 3, 2, 2, 'm'), -- id 87
(2, 1, 'LM3914', 2, 3, 1, 15, 'b'), -- id 88
(1, 5, 'Lora32 433Mhz neo-6m Lilygo Ttgo T-beam V1.1', 1, 1.5, 1, 300, 'm'), -- id 89
(8, 9, 'Monitor', 8, 12, 12, 550, 'm'), -- id 90
(1, 5, 'Motor Shield L293D', 1, 1.5, 5, 30, 'a'), -- id 91
(7, 7, 'Multimetro De Bancada Minipa MDM-8145', 2, 3, 3, 1500, 'm'), -- id 92
(7, 7, 'Multimetro Digital Instrutherm MD-360', 2, 3, 2, 200, 'm'), -- id 93
(2, 1, 'NAND 4011', 2, 3, 9, 3, 'a'), -- id 94
(2, 1, 'NAND 4023', 2, 3, 8, 3.5, 'a'), -- id 95
(2, 1, 'NAND SN74HC00', 2, 3, 3, 2.5, 'm'), -- id 96
(2, 1, 'NE555P', 2, 3, 8, 1.5, 'a'), -- id 97
(2, 1, 'NOR 7402', 2, 3, 1, 2.5, 'b'), -- id 98
(2, 1, 'NOR HEF 4001BP', 2, 3, 8, 3, 'a'), -- id 99
(2, 1, 'NOT 7404', 2, 3, 2, 2.5, 'm'), -- id 100
(2, 1, 'OR 7432', 2, 3, 4, 2.5, 'a'), -- id 101
(7, 7, 'Osciloscópio tektronix TDS 2002C 70Mhz', 2, 3, 6, 7000, 'a'), -- id 102
(7, 8, 'Ponta de prova para osciloscópio tektronix 100mhz 300v 10x cat2', 2, 3, 9, 1000, 'a'), -- id 103
(6, 6, 'Ponte H', 10, 15, 11, 18, 'm'), -- id 104
(4, 3, 'POTENCIÔMETRO', 10, 15, 3, 3, 'b'), -- id 105
(5, 4, 'PUSH-BUTTON MINI', 10, 15, 45, 0.4, 'a'), -- id 106
(5, 4, 'PUSH-BUTTON MINI 8,5mm', 10, 15, 3, 1, 'b'), -- id 107
(1, 5, 'Raspberry Pi (c)2011.12 Modelo B', 1, 1.5, 2, 300, 'a'), -- id 108
(1, 5, 'Raspberry Pi Zero 2W', 1, 1.5, 1, 270, 'm'), -- id 109
(2, 1, 'Regulador 7805', 5, 7.5, 10, 2.5, 'a'), -- id 110
(2, 1, 'Regulador 7809', 5, 7.5, 10, 2.5, 'a'), -- id 111
(2, 1, 'Regulador 7812', 5, 7.5, 4, 2.5, 'b'), -- id 112
(2, 1, 'Regulador 7912', 5, 7.5, 6, 3, 'm'), -- id 113
(10, 6, 'Regulador de tensão LM2596 (Step-Down)', 2, 3, 3, 20, 'm'), -- id 114
(5, 4, 'RELÉ 10A 125VAC', 5, 7.5, 12, 5, 'a'), -- id 115
(7, 8, 'SONDA OSCILOSCÓPIO', 1, 1.5, 2, 80, 'a'), -- id 116
(5, 4, 'SOQUETE 16 PINOS', 5, 7.5, 11, 0.5, 'a'), -- id 117
(5, 4, 'SOQUETE 8 PINOS', 5, 7.5, 12, 0.5, 'a'), -- id 118
(5, 4, 'TERMINAL ENCAIXE MACHO', 5, 7.5, 7, 0.3, 'm'), -- id 119
(3, 2, 'Transistor 2N5551', 2, 3, 17, 0.5, 'a'), -- id 120
(3, 2, 'Transistor 327-25', 2, 3, 1, 0.6, 'b'), -- id 121
(3, 2, 'Transistor BC 337-25', 2, 3, 5, 0.5, 'a'), -- id 122
(3, 2, 'Transistor BC547B', 2, 3, 10, 0.3, 'a'), -- id 123
(3, 2, 'Transistor BC548B', 2, 3, 17, 0.3, 'a'), -- id 124
(3, 2, 'Transistor C32716', 2, 3, 1, 0.6, 'b'), -- id 125
(3, 2, 'Transistor C33725', 2, 3, 4, 0.5, 'a'), -- id 126
(3, 2, 'Transistor C547B', 2, 3, 3, 0.5, 'm'), -- id 127
(3, 2, 'Transistor C557B', 2, 3, 19, 0.5, 'a'), -- id 128
(3, 2, 'Transistor C558B', 2, 3, 5, 0.5, 'a'), -- id 129
(3, 2, 'Transistor de Potência 2N3055', 2, 3, 4, 12, 'a'), -- id 130
(2, 1, 'XNOR 4077', 2, 3, 8, 4, 'a'), -- id 131
(2, 1, 'XOR 4070', 2, 3, 7, 3, 'a'), -- id 132
(8, 9, 'Cabo USB tipo C 30cm', 7, 10.5, 12, NULL, 'a'), -- id 133
(6, 6, 'Sensor Ultrassonico', 10, 15, 25, NULL, 'a'), -- id 134
(6, 6, 'Servo Motor MG90S', 6, 9, 13, NULL, 'a'), -- id 135
(6, 6, 'Servo Motor SG90', 3, 4.5, 3, NULL, 'm'), -- id 136
(9, 10, 'micro retifica Smart AD-19F 12V', 1, 1.5, 1, NULL, 'm'), -- id 137
(9, 10, 'Balança Digital 10kg', 1, 1.5, 1, NULL, 'm'), -- id 138
(9, 10, 'Ferro de Passar', 1, 1.5, 1, NULL, 'm'); -- id 139

INSERT INTO entrada (produto_id, discente_id, data_de_entrada, descricao, quantidade, custo_unitario, custo_total) VALUES
(79, 5, '2025-04-05', 'Inventário', 16, 500, 8000), -- Kit IFMT 4.0 (Arduino Mega)
(102, 5, '2025-04-05', 'Inventário', 6, 7000, 42000), -- Osciloscópio tektronix TDS 2002C 70Mhz
(72, 5, '2025-04-05', 'Inventário', 6, 2000, 12000), -- Gerador De Função GF-220 instrutherm
(26, 5, '2025-04-05', 'Inventário', 18, 900, 16200), -- Cadeiras de escritório giratórias
(41, 5, '2025-04-05', 'Inventário', 4, 1500, 6000), -- Computador
(58, 5, '2025-04-05', 'Inventário', 1, 5000, 5000), -- Impressora Samsung ProXpress SL-M407
(57, 5, '2025-04-05', 'Inventário', 1, 1800, 1800), -- Impressora 3D Ender 3
(59, 5, '2025-04-05', 'Inventário', 12, 45, 540), -- Esp32
(61, 5, '2025-04-05', 'Inventário', 3, 30, 90), -- Esp8266
(90, 5, '2025-04-05', 'Inventário', 12, 550, 6600), -- Monitor
(104, 5, '2025-04-05', 'Inventário', 12, 18, 216), -- Ponte H
(123, 5, '2025-04-22', 'Inventário', 14, 0.3, 4.2), -- Transistor BC547B
(124, 5, '2025-06-18', 'Inventário', 17, 0.3, 5.1), -- Transistor BC548B
(92, 5, '2025-06-30', 'Inventário', 3, 1500, 4500), -- Multimetro De Bancada Minipa MDM-8145
(93, 5, '2025-06-30', 'Inventário', 2, 200, 400), -- Multimetro Digital Instrutherm MD-360
(65, 5, '2025-06-30', 'Inventário', 7, 1800, 12600), -- fonte minipa MPL-3303M
(126, 1, '2026-01-30', 'Inventário', 4, 0.5, 2), -- Transistor C33725
(127, 1, '2026-01-30', 'Inventário', 3, 0.5, 1.5), -- Transistor C547B
(128, 1, '2026-01-31', 'Inventário', 19, 0.5, 9.5), -- Transistor C557B
(125, 1, '2026-02-01', 'Inventário', 1, 0.6, 0.6), -- Transistor C32716
(121, 1, '2026-02-02', 'Inventário', 1, 0.6, 0.6), -- Transistor 327-25
(122, 1, '2026-02-03', 'Inventário', 5, 0.5, 2.5), -- Transistor BC 337-25
(129, 1, '2026-02-04', 'Inventário', 5, 0.5, 2.5), -- Transistor C558B
(130, 1, '2026-02-05', 'Inventário', 4, 12, 48), -- Transistor de Potência 2N3055
(120, 1, '2026-02-06', 'Inventário', 17, 0.5, 8.5), -- Transistor 2N5551
(112, 1, '2026-02-07', 'Inventário', 4, 2.5, 10), -- Regulador 7812
(113, 1, '2026-02-08', 'Inventário', 6, 3, 18), -- Regulador 7912
(111, 1, '2026-02-09', 'Inventário', 10, 2.5, 25), -- Regulador 7809
(110, 1, '2026-02-10', 'Inventário', 10, 2.5, 25), -- Regulador 7805
(6, 1, '2026-02-11', 'Inventário', 7, 3, 21), -- AND 4081
(7, 1, '2026-02-12', 'Inventário', 2, 2.5, 5), -- AND 7400
(101, 1, '2026-02-13', 'Inventário', 4, 2.5, 10), -- OR 7432
(100, 1, '2026-02-14', 'Inventário', 2, 2.5, 5), -- NOT 7404
(99, 1, '2026-02-15', 'Inventário', 8, 3, 24), -- NOR HEF 4001BP
(98, 1, '2026-02-16', 'Inventário', 1, 2.5, 2.5), -- NOR 7402
(131, 1, '2026-02-17', 'Inventário', 8, 4, 32), -- XNOR 4077
(132, 1, '2026-02-18', 'Inventário', 7, 3, 21), -- XOR 4070
(94, 1, '2026-02-19', 'Inventário', 9, 3, 27), -- NAND 4011
(95, 1, '2026-02-20', 'Inventário', 8, 3.5, 28), -- NAND 4023
(64, 1, '2026-02-21', 'Inventário', 10, 3.5, 35), -- FLIP-FLOP 4013
(96, 1, '2026-02-22', 'Inventário', 3, 2.5, 7.5), -- NAND SN74HC00
(37, 1, '2026-01-30', 'Inventário', 1, 3, 3), -- CI 4093
(38, 1, '2026-01-31', 'Inventário', 1, 45, 45), -- CI INA12828PA
(35, 1, '2026-02-01', 'Inventário', 10, 4, 40), -- CI 4015
(76, 1, '2026-02-02', 'Inventário', 9, 3, 27), -- HCF 4093
(75, 1, '2026-02-03', 'Inventário', 7, 3.5, 24.5), -- HCF 4027
(74, 1, '2026-02-04', 'Inventário', 10, 3.5, 35), -- HCF 4017
(15, 1, '2026-02-05', 'Inventário', 10, 4, 40), -- BCD-TO-DECIMAL 4028
(78, 1, '2026-02-06', 'Inventário', 9, 3, 27), -- HEX INVERTER 4049
(39, 1, '2026-02-07', 'Inventário', 2, 15, 30), -- CI L298N
(97, 1, '2026-02-08', 'Inventário', 8, 1.5, 12), -- NE555P
(77, 1, '2026-02-09', 'Inventário', 10, 3, 30), -- HCF4066
(36, 1, '2026-02-10', 'Inventário', 2, 3, 6), -- CI 4071
(16, 1, '2026-02-11', 'Inventário', 20, 4.5, 90), -- BCD-UP-DOWN 4510
(87, 1, '2026-02-12', 'Inventário', 2, 2, 4), -- LM324N
(3, 1, '2026-02-13', 'Inventário', 1, 3, 3), -- 74HC164N
(11, 1, '2026-02-14', 'Inventário', 5, 20, 100), -- ATMEGA328P
(88, 1, '2026-02-15', 'Inventário', 1, 15, 15), -- LM3914
(56, 1, '2026-02-16', 'Inventário', 12, 8, 96), -- DRIVER MOTOR L293D
(14, 1, '2026-02-17', 'Inventário', 16, 4, 64), -- BCD 7-SEGMENT 4511
(55, 1, '2026-02-18', 'Inventário', 4, 4, 16), -- DISPLAY HS-5202 AG 7SEGMENT
(67, 1, '2026-02-19', 'Inventário', 10, 0.3, 3), -- FUSÍVEL 0,25A
(68, 1, '2026-02-20', 'Inventário', 10, 0.3, 3), -- FUSÍVEL 0,5A
(69, 1, '2026-02-21', 'Inventário', 10, 0.3, 3), -- FUSÍVEL 1A
(70, 1, '2026-02-22', 'Inventário', 8, 0.3, 2.4), -- FUSÍVEL 2A
(71, 1, '2026-02-23', 'Inventário', 10, 0.3, 3), -- FUSÍVEL 3A
(30, 1, '2026-02-24', 'Inventário', 10, 0.2, 2), -- CAPACITOR 47nF 50V
(28, 1, '2026-02-25', 'Inventário', 10, 0.2, 2), -- CAPACITOR 10uF 16V
(29, 1, '2026-02-26', 'Inventário', 10, 0.2, 2), -- CAPACITOR 10uF 25V
(27, 1, '2026-02-27', 'Inventário', 10, 0.3, 3), -- CAPACITOR 100uF 25V
(81, 1, '2026-02-28', 'Inventário', 30, 0.25, 7.5), -- LED AMARELO
(86, 1, '2026-03-01', 'Inventário', 30, 0.25, 7.5), -- LED VERMELHO
(83, 1, '2026-03-02', 'Inventário', 30, 0.25, 7.5), -- LED BRANCO
(82, 1, '2026-03-03', 'Inventário', 30, 0.25, 7.5), -- LED AZUL
(85, 1, '2026-03-04', 'Inventário', 30, 0.25, 7.5), -- LED VERDE
(84, 1, '2026-03-05', 'Inventário', 8, 1.5, 12), -- LED RGB
(46, 1, '2026-03-06', 'Inventário', 80, 0.5, 40), -- CONECTOR DE FIO
(54, 1, '2026-03-07', 'Inventário', 0, 0.3, 0), -- DIODO ZENER
(52, 1, '2026-03-08', 'Inventário', 1, 0.2, 0.2), -- DIODO 1N4004
(53, 1, '2026-03-09', 'Inventário', 12, 0.2, 2.4), -- DIODO 1N4007
(43, 1, '2026-01-30', 'Inventário', 4, 1, 4), -- CONECTOR 2 VIAS QUADRADO MACHO
(42, 1, '2026-01-31', 'Inventário', 6, 1, 6), -- CONECTOR 2 VIAS QUADRADO
(44, 1, '2026-02-01', 'Inventário', 10, 1.5, 15), -- CONECTOR BORNE 2 VIAS
(17, 1, '2026-02-02', 'Inventário', 3, 1.5, 4.5), -- BORNE 3 VIAS
(18, 1, '2026-02-03', 'Inventário', 2, 3, 6), -- BORNE PRESSÃO 4 VIAS
(107, 1, '2026-02-04', 'Inventário', 3, 1, 3), -- PUSH-BUTTON MINI 8,5mm
(12, 1, '2026-02-05', 'Inventário', 100, 2, 200), -- BARRA DE PINOS
(45, 1, '2026-02-06', 'Inventário', 0, 1, 0), -- CONECTOR BULLE1
(32, 1, '2026-02-07', 'Inventário', 4, 4, 16), -- CHAVE 2 ESTÁGIO 3A 125VAC
(33, 1, '2026-02-08', 'Inventário', 3, 4, 12), -- CHAVE 3 ESTÁGIO 6A 125VAC
(119, 1, '2026-02-09', 'Inventário', 7, 0.3, 2.1), -- TERMINAL ENCAIXE MACHO
(47, 1, '2026-02-10', 'Inventário', 15, 2, 30), -- CONECTOR JACK P4 DC
(34, 1, '2026-02-11', 'Inventário', 12, 2, 24), -- CHAVE GANGORRA
(4, 1, '2026-02-12', 'Inventário', 5, 2, 10), -- ADAPTADOR J4-FEMEA
(51, 1, '2026-02-13', 'Inventário', 10, 2, 20), -- CRISTAL 20MHz
(50, 1, '2026-02-14', 'Inventário', 5, 2, 10), -- CRISTAL 16MHz
(49, 1, '2026-02-15', 'Inventário', 22, 2, 44), -- CONECTOR P4-FEMEA
(115, 1, '2026-02-16', 'Inventário', 12, 5, 60), -- RELÉ 10A 125VAC
(105, 1, '2026-02-17', 'Inventário', 3, 3, 9), -- POTENCIÔMETRO
(80, 1, '2026-02-18', 'Inventário', 1, 1, 1), -- LDR
(48, 1, '2026-02-19', 'Inventário', 3, 2, 6), -- CONECTOR JACK-P4 MACHO
(21, 1, '2026-02-20', 'Inventário', 3, 2, 6), -- BUZZER
(116, 1, '2026-02-21', 'Inventário', 2, 80, 160), -- SONDA OSCILOSCÓPIO
(19, 1, '2026-02-22', 'Inventário', 4, 5, 20), -- BORRACHA SUGADOR DE SOLDA
(5, 1, '2026-02-23', 'Inventário', 5, 5, 25), -- ADAPTADOR SD CARD
(62, 1, '2026-02-24', 'Inventário', 26, 0.5, 13), -- ESPAÇADOR MACHO-FEMEA
(118, 1, '2026-02-25', 'Inventário', 12, 0.5, 6), -- SOQUETE 8 PINOS
(117, 1, '2026-02-26', 'Inventário', 11, 0.5, 5.5), -- SOQUETE 16 PINOS
(106, 1, '2026-02-27', 'Inventário', 45, 0.4, 18), -- PUSH-BUTTON MINI
(60, 1, '2026-02-28', 'Inventário', 1, 55.86, 55.86), -- ESP32-CAM
(103, 1, '2026-03-01', 'Inventário', 9, 1000, 9000), -- Ponta de prova para osciloscópio tektronix 100mhz 300v 10x cat2
(22, 1, '2026-03-02', 'Inventário', 6, 40, 240), -- cabo de gerador de função BNC/jacaré
(25, 1, '2026-03-03', 'Inventário', 9, 23, 207), -- Cabo ponta de prova banana / jacaré vermelho
(24, 1, '2026-03-04', 'Inventário', 7, 23, 161), -- Cabo ponta de prova banana / jacaré preto
(23, 1, '2026-03-05', 'Inventário', 41, 30, 1230), -- Cabo ponta de prova banana / banana
(2, 1, '2026-03-06', 'Inventário', 2, 1200, 2400), -- Raspberry PI 5
(66, 1, '2026-03-07', 'Inventário', 1, 142, 142), -- Fonte para Raspberry PI 5
(109, 1, '2026-03-08', 'Inventário', 1, 270, 270), -- Raspberry Pi Zero 2W
(108, 1, '2026-03-09', 'Inventário', 2, 300, 600), -- Raspberry Pi (c)2011.12 Modelo B
(20, 1, '2026-03-10', 'Inventário', 1, 900, 900), -- Brick Pi Dexter Industries
(1, 1, '2026-03-11', 'Inventário', 1, 700, 700), -- Raspberry PI 4 Modelo B
(114, 1, '2026-03-12', 'Inventário', 3, 20, 60), -- Regulador de tensão LM2596 (Step-Down)
(10, 1, '2026-03-13', 'Inventário', 23, 40, 920), -- Arduino Uno
(9, 1, '2026-03-14', 'Inventário', 2, 40, 80), -- Arduino nano
(8, 1, '2026-03-15', 'Inventário', 1, 80, 80), -- Arduino Leonardo
(63, 1, '2026-03-16', 'Inventário', 2, 80, 160), -- Ethernet Shield W5100
(91, 1, '2026-03-17', 'Inventário', 5, 30, 150), -- Motor Shield L293D
(40, 1, '2026-03-18', 'Inventário', 1, 50, 50), -- CNC Shield V3
(89, 1, '2026-03-19', 'Inventário', 1, 300, 300), -- Lora32 433Mhz neo-6m Lilygo Ttgo T-beam V1.1
(73, 1, '2026-03-20', 'Inventário', 1, 150, 150), -- Gravadora K150 de PIC
(31, 1, '2026-03-21', 'Inventário', 7, 0, 0), -- Carregador de Bateria de litio 18650
(13, 1, '2026-03-22', 'Inventário', 25, 0, 0), -- Bateria de lítio 18650
(133, 1, '2026-03-23', 'Inventário', 12, 0, 0), -- Cabo USB tipo C 30cm
(134, 1, '2026-03-24', 'Inventário', 25, 0, 0), -- Sensor Ultrassonico
(135, 1, '2026-03-25', 'Inventário', 13, 0, 0), -- Servo Motor MG90S
(136, 1, '2026-03-26', 'Inventário', 3, 0, 0), -- Servo Motor SG90
(137, 1, '2026-03-27', 'Inventário', 1, 0, 0), -- micro retifica Smart AD-19F 12V
(139, 1, '2026-03-28', 'Inventário', 1, 0, 0), -- Ferro de Passar
(138, 1, '2026-03-28', 'Inventário', 1, 0, 0); -- Balança Digital 10kg

INSERT INTO compra_reposicao (produto_id, discente_id, data_compra, descricao, quantidade, status_compra) VALUES
(41, 2, '2026-10-06', 'Reposição de estoque', 8, 'c'), -- Computador
(61, 2, '2026-10-06', 'Reposição de estoque', 3, 'c'), -- Esp8266
(125, 2, '2026-10-06', 'Reposição de estoque', 2, 'c'), -- Transistor C32716
(121, 2, '2026-10-06', 'Reposição de estoque', 2, 'c'), -- Transistor 327-25
(112, 2, '2026-10-06', 'Reposição de estoque', 3.5, 'c'), -- Regulador 7812
(98, 2, '2026-10-06', 'Reposição de estoque', 2, 'c'), -- NOR 7402
(37, 2, '2026-10-06', 'Reposição de estoque', 2, 'c'), -- CI 4093
(38, 2, '2026-10-06', 'Reposição de estoque', 2, 'c'), -- CI INA12828PA
(3, 2, '2026-10-06', 'Reposição de estoque', 2, 'c'), -- 74HC164N
(88, 2, '2026-10-06', 'Reposição de estoque', 2, 'c'), -- LM3914
(84, 2, '2026-10-06', 'Reposição de estoque', 7, 'c'), -- LED RGB
(54, 2, '2026-10-06', 'Reposição de estoque', 7.5, 'c'), -- DIODO ZENER
(52, 2, '2026-10-06', 'Reposição de estoque', 6.5, 'c'), -- DIODO 1N4004
(43, 2, '2026-10-06', 'Reposição de estoque', 11, 'c'), -- CONECTOR 2 VIAS QUADRADO MACHO
(42, 2, '2026-10-06', 'Reposição de estoque', 9, 'c'), -- CONECTOR 2 VIAS QUADRADO
(17, 2, '2026-10-06', 'Reposição de estoque', 4.5, 'c'), -- BORNE 3 VIAS
(18, 2, '2026-10-06', 'Reposição de estoque', 13, 'c'), -- BORNE PRESSÃO 4 VIAS
(107, 2, '2026-10-06', 'Reposição de estoque', 12, 'c'), -- PUSH-BUTTON MINI 8,5mm
(45, 2, '2026-10-06', 'Reposição de estoque', 7.5, 'c'), -- CONECTOR BULLE1
(32, 2, '2026-10-06', 'Reposição de estoque', 3.5, 'c'), -- CHAVE 2 ESTÁGIO 3A 125VAC
(33, 2, '2026-10-06', 'Reposição de estoque', 4.5, 'c'), -- CHAVE 3 ESTÁGIO 6A 125VAC
(105, 2, '2026-10-06', 'Reposição de estoque', 12, 'c'), -- POTENCIÔMETRO
(80, 2, '2026-10-06', 'Reposição de estoque', 2, 'c'), -- LDR
(48, 2, '2026-10-06', 'Reposição de estoque', 4.5, 'c'), -- CONECTOR JACK-P4 MACHO
(21, 2, '2026-10-06', 'Reposição de estoque', 4.5, 'c'); -- BUZZER

INSERT INTO saida_baixa (produto_id, discente_id, data_de_saida, descricao, quantidade, motivo_baixa) VALUES
(86, 1, '2026-08-12', 'Consumidos na oficina de eletrônica básica', 6, 'c'), -- LED VERMELHO
(69, 4, '2026-08-26', 'Fusíveis queimados em teste de fonte', 2, 'q'), -- FUSÍVEL 1A
(123, 2, '2026-09-10', 'Usados na montagem da PCI do projeto', 4, 'c'), -- Transistor BC547B
(104, 2, '2026-09-28', 'Queimou durante a oficina de seguidor de linha', 1, 'q'), -- Ponte H
(23, 1, '2026-10-24', 'Conector quebrado após o evento de robótica', 2, 'b'), -- Cabo ponta de prova banana / banana
(46, 3, '2026-11-05', 'Consumidos na manutenção de cabos da bancada', 15, 'c'), -- CONECTOR DE FIO
(62, 4, '2026-11-12', 'Não encontrados na conferência do gaveteiro D', 4, 'p'); -- ESPAÇADOR MACHO-FEMEA

-- Empréstimos (FICTÍCIOS)
INSERT INTO emprestimo (discente_id, finalidade, data_emprestimo, data_prevista_devolucao, status_emprestimo) VALUES
(6, 'Prática de laboratório de Eletrônica Analógica', '2026-08-10', '2026-08-17', 'd'), -- id 1
(2, 'Oficina PET de robô seguidor de linha', '2026-09-01', '2026-09-30', 'd'), -- id 2
(7, 'TCC - aquisição de sinais com ESP32', '2026-09-15', '2026-10-15', 't'), -- id 3
(3, 'Monitoria de Sistemas Digitais', '2026-10-05', '2026-10-09', 'd'), -- id 4
(1, 'Evento de robótica - IFMT de Portas Abertas', '2026-10-20', '2026-10-25', 'd'), -- id 5
(8, 'Projeto de extensão - estação meteorológica', '2026-11-03', '2026-11-24', 'a'), -- id 6
(4, 'Bancada de testes de fontes - projeto PET', '2026-11-10', '2026-11-20', 'a'); -- id 7

INSERT INTO item_emprestimo (produto_id, emprestimo_id, quantidade_emprestada, data_devolucao, condicao_devolucao, observacao) VALUES
(93, 1, 1, '2026-08-15', 'b', NULL), -- Multimetro Digital Instrutherm MD-360
(25, 1, 2, '2026-08-15', 'b', NULL), -- Cabo ponta de prova banana / jacaré vermelho
(24, 1, 2, '2026-08-15', 'b', NULL), -- Cabo ponta de prova banana / jacaré preto
(10, 2, 4, '2026-09-28', 'b', NULL), -- Arduino Uno
(104, 2, 4, '2026-09-28', 'r', '1 unidade queimou durante a oficina (baixa registrada)'), -- Ponte H
(134, 2, 4, '2026-09-28', 'b', NULL), -- Sensor Ultrassonico
(59, 3, 2, NULL, NULL, NULL), -- Esp32
(135, 3, 2, NULL, NULL, NULL), -- Servo Motor MG90S
(79, 4, 4, '2026-10-09', 'b', NULL), -- Kit IFMT 4.0 (Arduino Mega)
(102, 4, 1, '2026-10-09', 'p', 'Botão de trigger falhando, encaminhar para reparo'), -- Osciloscópio tektronix TDS 2002C 70Mhz
(79, 5, 6, '2026-10-24', 'b', NULL), -- Kit IFMT 4.0 (Arduino Mega)
(23, 5, 4, '2026-10-24', 'r', '2 cabos com conector quebrado (baixa registrada)'), -- Cabo ponta de prova banana / banana
(1, 6, 1, NULL, NULL, NULL), -- Raspberry PI 4 Modelo B
(133, 6, 1, NULL, NULL, NULL), -- Cabo USB tipo C 30cm
(89, 6, 1, NULL, NULL, NULL), -- Lora32 433Mhz neo-6m Lilygo Ttgo T-beam V1.1
(65, 7, 1, NULL, NULL, NULL), -- fonte minipa MPL-3303M
(92, 7, 1, NULL, NULL, NULL), -- Multimetro De Bancada Minipa MDM-8145
(72, 7, 1, NULL, NULL, NULL); -- Gerador De Função GF-220 instrutherm
