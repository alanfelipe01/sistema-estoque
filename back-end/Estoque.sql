create database TechFlow
character set utf8mb4
collate utf8mb4_general_ci;
use TechFlow;

-- Login de usuarios
Create Table Login (
id_usuario int auto_increment primary key,
Usuario varchar(50) not null unique,
Senha 	varchar(8) not null,
Cargo  ENUM('admin', 'operador') not null default'operador',
Ativo  boolean not null default true,
Criado_em datetime not null default current_timestamp,

-- Garante que a senha tenha SOMENTE números (0-9)
constraint chk_senha_numerica CHECK (senha REGEXP '^[0-9]{1,8}$')
) ENGINE=InnoDB;

-- categorias
Create table categorias (
id int auto_increment primary key,
nome varchar(100) not null unique,
descricao varchar(255),
criado_em datetime not null default current_timestamp
);

-- produtos (criar / editar / excluir produto)
Create table produtos (
id int auto_increment primary key,
nome varchar(150) not null,
descricao text,
categoria_id int,
preco decimal(10,2) not null default 0,
quantidade_estoque int not null default 0,
estoque_minimo int not null default 0,  -- usado no alerta de ESTOQUE BAIXO	
status enum('ativo', 'excluido') not null default 'ativo', -- exclusão lógica
criado_em datetime not null default current_timestamp,
atualizado_em datetime not null default current_timestamp on update current_timestamp,
foreign key (categoria_id) references categorias(id) on delete set null
);
-- categorias inseridas 
insert into categorias (nome, descricao) values
('computadores', 'Notebooks, desktops'),
('componentes', 'Placas-mãe, processadores, memórias'),
('perifericos', 'Mouse, Teclado, MousePad'),
('monitores', '60Hz, 90Hz, 120Hz'),
('redes', 'roteadores, cabo-de-redes'),
('fontes', '400W, 500W, 650W'),
('impressoras', 'jato-de-tinta, A-Laser, matricial'),
('armazenamento', 'SSD, SSD-SATA, HD-Externo'),
('outros', 'ETC');

-- movimentações de estoque (ENTRADA / SAIDA DE ESTOQUE)
create table movimentacoes_estoque (
id int auto_increment primary key,
produto_id int not null,
usuario_id int not null,
tipo ENUM('entrada', 'saida') not null,
quantidade int not null,
motivo varchar(250),
status ENUM('pendente', 'validado', 'rejeitado') not null default 'validado', -- usado na VALIDAÇÃO DA SAÍDA
criado_em  datetime not null default current_timestamp,
foreign key (produto_id) references produtos(id) on delete cascade,
foreign key (usuario_id) references login(id_usuario)
);
-- CONTROLE DE QUALIDADE
create table controle_qualidade (
id int auto_increment primary key,
produto_id int not null,
movimentacao_id int,
usuario_id int not null,
status enum('aprovado','reprovado') not null,
observacao varchar(255),
criado_em datetime not null default current_timestamp,
foreign key (produto_id) references produtos(id) on delete cascade,
foreign key (movimentacao_id) references movimentacoes_estoque(id) on delete set null,
foreign key (usuario_id) references login(id_usuario)
);

-- VIEW: HITÓRICO COMPLETO (movimentações + qualidade)
create or replace view historico_completo AS
select
'movimentaçao' AS origem,
m.id,
m.produto_id,
p.nome AS produto_nome,
m.tipo AS acao,
m.quantidade,
m.status,
m.usuario_id,
u.usuario AS usuario_nome,
m.criado_em
from movimentacoes_estoque m
join produtos p ON p.id = m.produto_id
join Login u ON u.id_usuario = m.usuario_id

UNION ALL

SELECT
'qualidade' AS origem,
q.id,
q.produto_id,
p.nome AS produto_nome,
q.status AS acao,
NULL AS quantidade,
q.status,
q.usuario_id,
u.usuario AS usuario_nome,
q.criado_em
FROM controle_qualidade q
JOIN produtos p ON p.id = q.produto_id
JOIN Login u ON u.id_usuario = q.usuario_id
ORDER BY criado_em DESC;
