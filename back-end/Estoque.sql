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