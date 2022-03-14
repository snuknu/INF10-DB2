/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *																 *  
 *                       USUARIO                                 *
 *                                                               *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
create table stp_usuario(
	usuario_id serial primary key,
	nome varchar(255) not null,
	cpf varchar(11) unique not null,
	senha varchar(50) not null,
	email varchar(255) unique not null,
	nascimento timestamp not null,
	criado_em timestamp not null
);


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *																 *  
 *                       SMART CARD                              *
 *                                                               *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
create table stp_smart_card(
	card_id serial primary key,
	tipo varchar(10) not null,
	saldo numeric(5,2) not null,
	usuario_id int,
	valido_ate timestamp not null,
	criado_em timestamp not null,
	foreign key(usuario_id)
		references stp_usuario (usuario_id)
);


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *																 *  
 *                      PONTO DE ONIBUS                          *
 *                                                               *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
create table stp_ponto(
	ponto_id serial primary key,
	cep int not null,
	coordenadas varchar(50) unique not null
);


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *																 *  
 *                          LINHA                                *
 *                                                               *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
create table stp_linha(
	linha_id serial primary key,
	codigo varchar(8) not null unique,
	nome varchar(250) not null,
	abreviacao varchar(50) not null
);

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *																 *  
 *                  ITINERÁRIO DA LINHA                          *
 *                                                               *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
create table stp_itinerario(
	itinerario_id serial primary key,
	ponto_id int not null,
	linha_id int not null,
	foreign key (ponto_id)
		references stp_ponto(ponto_id),
	foreign key (linha_id)
		references stp_linha(linha_id)
)

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *																 *  
 *                        MOTORISTA                              *
 *                                                               *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
create table stp_motorista(
	motorista_id serial primary key,
	nome varchar(250) not null,
	cnh varchar(10) not null unique
);

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *																 *  
 *                         VEICULO                               *
 *                                                               *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
create table stp_veiculo(
	veiculo_id serial primary key,
	placa varchar(10) not null unique,
	patrimonio varchar(10) not null unique,
	capacidade smallint not null
);


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *																 *  
 *                           VIAGEM                              *
 *                                                               *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
create table stp_viagem(
	viagem_id serial primary key,
	motorista_id int not null,
	veiculo_id smallint not null,
	linha_id int not null,
	
	foreign key(motorista_id)
		references stp_motorista (motorista_id),
	foreign key(veiculo_id)
		references stp_veiculo (veiculo_id),
	foreign key(linha_id)
		references stp_linha (linha_id)
);


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *																 *  
 *                           PASSAGEIRO                          *
 *                                                               *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
create table stp_passageiro(
	passageiro_id serial,
	viagem_id int,
	card_id int,
	foreign key(card_id)
		references stp_smart_card (card_id),
	foreign key(viagem_id)
		references stp_viagem (viagem_id),
	primary key (viagem_id, passageiro_id)
);


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *																 *  
 *                          PAGAMENTO                            *
 *                                                               *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
create table stp_pagamento(
	pagamento_id serial primary key,
	passageiro_id int not null,
	viagem_id int not null,
	valor numeric(6,3),
	
	foreign key(viagem_id, passageiro_id)
		references stp_passageiro (viagem_id, passageiro_id),
	foreign key(viagem_id)
		references stp_viagem (viagem_id)
);



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *																 *  
 *                        VIEW RESUMIDA                          *
 *                                                               *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
create view vw_stp_resumida as 
	select
		ps.passageiro_id,
		vg.viagem_id,
		sc.tipo,
		sc.saldo,
		us.nome,
		mt.nome as motorista,
		vc.placa as veiculo,
		lh.abreviacao,
		vw_ponto.paradas,
		pg.valor 
	from stp_passageiro ps
	left join stp_smart_card sc
		on sc.card_id = ps.card_id 
	left join stp_usuario us
		on us.usuario_id = sc.usuario_id
	inner join stp_viagem vg
		on vg.viagem_id = ps.viagem_id
	inner join stp_motorista mt
		on mt.motorista_id = vg.motorista_id
	inner join stp_veiculo vc
		on vc.veiculo_id = vg.veiculo_id
	inner join stp_linha lh
		on lh.linha_id = vg.linha_id
	inner join stp_pagamento pg
		on pg.passageiro_id = ps.passageiro_id 
	inner join 
		(
			select ponto.id as linha_id,  STRING_AGG(ponto.cep, ', ') AS paradas
			from 
				(
				select
					_l.linha_id as id,
					cast(_p.cep as varchar) as cep
				from stp_linha _l
				
				inner join stp_itinerario _i
					on _i.linha_id = _l.linha_id
				inner join stp_ponto _p
					on _i.ponto_id = _p.ponto_id
				) ponto
			group by  ponto.id
		) vw_ponto
		on vw_ponto.linha_id = vg.linha_id
	order by ps.passageiro_id;
		
		

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *																 *  
 *                        VIEW COMPLETA                          *
 *                                                               *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
create view vw_stp_completa as 
	select
		ps.passageiro_id,
		vg.viagem_id,
		mt.motorista_id,
		us.usuario_id,
		lh.linha_id,
		pg.pagamento_id,
		sc.tipo,
		sc.saldo,
		us.nome,
		us.cpf,
		us.senha,
		us.email,
		mt.cnh,
		mt.nome as motorista,
		vc.placa as veiculo,
		vc.patrimonio,
		lh.codigo,
		lh.nome as linha_desc,
		lh.abreviacao,
		vw_ponto.paradas,
		pg.valor 
	from stp_passageiro ps
	left join stp_smart_card sc
		on sc.card_id = ps.card_id 
	left join stp_usuario us
		on us.usuario_id = sc.usuario_id
	inner join stp_viagem vg
		on vg.viagem_id = ps.viagem_id
	inner join stp_motorista mt
		on mt.motorista_id = vg.motorista_id
	inner join stp_veiculo vc
		on vc.veiculo_id = vg.veiculo_id
	inner join stp_linha lh
		on lh.linha_id = vg.linha_id
	inner join stp_pagamento pg
		on pg.passageiro_id = ps.passageiro_id 
	inner join 
		(
			select ponto.id as linha_id,  STRING_AGG(ponto.cep, ', ') AS paradas
			from 
				(
				select
					_l.linha_id as id,
					cast(_p.cep as varchar) as cep
				from stp_linha _l
				
				inner join stp_itinerario _i
					on _i.linha_id = _l.linha_id
				inner join stp_ponto _p
					on _i.ponto_id = _p.ponto_id
				) ponto
			group by  ponto.id
		) vw_ponto
		on vw_ponto.linha_id = vg.linha_id
	order by ps.passageiro_id;




/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *																 *  
 *                       CONSULTAS ÚTEIS                         *
 *                                                               *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

-- Retorna as paradas de uma linha 
select
	l.abreviacao as linha,
	p.coordenadas as cordenada
from stp_linha l
inner join stp_itinerario i
	on i.linha_id = l.linha_id
inner join stp_ponto p
	on i.ponto_id = p.ponto_id
where l.codigo = 'BAON1235' 

        
-- Apresenta paradas de uma linha como coordenadas com paradas concatenadas em uma linha
SELECT linha.id, linha.abreviacao, STRING_AGG(linha.cordenada, ', ') AS coordenadas
FROM 
	(
	select
		l.linha_id as id,
		l.abreviacao as abreviacao,
		p.coordenadas as cordenada
	from stp_linha l
	
	inner join stp_itinerario i
		on i.linha_id = l.linha_id
	inner join stp_ponto p
		on i.ponto_id = p.ponto_id
	) linha
GROUP BY linha.abreviacao, linha.id


-- Apresenta paradas de uma linha como CEPs com paradas concatenadas em uma linha
SELECT linha.id, linha.abreviacao, STRING_AGG(linha.cep, ', ') AS paradas
FROM 
	(
	select
		l.linha_id as id,
		l.abreviacao as abreviacao,
		cast(p.cep as varchar) as cep
	from stp_linha l
	inner join stp_itinerario i
		on i.linha_id = l.linha_id
	inner join stp_ponto p
		on i.ponto_id = p.ponto_id
	) linha
GROUP BY linha.abreviacao, linha.id


-- Detalha informacoes sobre linhas
select *
from stp_linha l
inner join stp_itinerario i
	on i.linha_id = l.linha_id
inner join stp_ponto p
	on i.ponto_id = p.ponto_id


-- Detalha usuarios de cartões
select c.card_id,
	c.tipo,
	c.saldo,
	valido_ate,
	c.criado_em as card_criado_em,
	u.usuario_id,
	u.nome,
	u.cpf,
	u.senha,
	u.email,
	u.nascimento,
	u.criado_em as usuario_criado_em
from stp_smart_card c
inner join stp_usuario u
	on u.usuario_id = c.usuario_id;


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *																 *  
 *                  POPULA DADOS PARA TESTES                     *
 *                                                               *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

-- Popula a tabela stp_usuario
insert into stp_usuario (nome, cpf, senha, email, nascimento, criado_em)
	values('Eric Azevedo', '11111111111', ' d767bb158cd06e2b3898e563c3be217b', 'snuknu@gmail.com', '1986-09-05 00:00:00', now());
insert into stp_usuario (nome, cpf, senha, email, nascimento, criado_em)
	values('Thalia Azevedo', '22222222222', ' d767bb158cd06e2b3898e563c3be217b', 'thalia@gmail.com', '2000-03-15 00:00:00', now());
insert into stp_usuario (nome, cpf, senha, email, nascimento, criado_em)
	values('Paloma Carvalho', '33333333333', ' d767bb158cd06e2b3898e563c3be217b', 'paloma@gmail.com', '1994-07-12 00:00:00', now());
insert into stp_usuario (nome, cpf, senha, email, nascimento, criado_em)
	values('Marcia Carvalho', '44444444444', ' d767bb158cd06e2b3898e563c3be217b', 'marcia@gmail.com', '1930-02-02 00:00:00', now());


-- Popula tabela dos cartões de passagens
insert into stp_smart_card (tipo, saldo, usuario_id , valido_ate, criado_em)
	values('estudante', 50.20, 2, '2030-12-30 00:00:00', now());
insert into stp_smart_card (tipo, saldo, usuario_id , valido_ate, criado_em)
	values('trabalho', 80.20, 2, '2032-12-30 00:00:00', now());
insert into stp_smart_card (tipo, saldo, usuario_id , valido_ate, criado_em)
	values('especial', 00.00, 5, '2035-12-30 00:00:00', now());
insert into stp_smart_card (tipo, saldo, usuario_id , valido_ate, criado_em)
	values('normal', 60.20, 3, '2028-12-30 00:00:00', now());
insert into stp_smart_card (tipo, saldo, usuario_id , valido_ate, criado_em)
	values('normal', 50.20, 4, '2028-01-30 00:00:00', now());


-- Popula a tabela dos pontos de ônibus
insert into stp_ponto (cep, coordenadas)
	values(40210320, '@-12.9556114,-38.4681531,18.33z');
insert into stp_ponto (cep, coordenadas)
	values(41110330, '@-12.9656059,-36.4972189,18.58z');
insert into stp_ponto (cep, coordenadas)
	values(44105100, '@-11.9831093,-35.5118564,18.83z');
insert into stp_ponto (cep, coordenadas)
	values(41210320, '@-24.9333114,-37.4687771,18.33z');
insert into stp_ponto (cep, coordenadas)
	values(42110330, '@-13.5685059,-24.4947289,18.58z');
insert into stp_ponto (cep, coordenadas)
	values(43105100, '@-10.4451093,-31.5586354,18.83z');


-- Popula a tabela das linhas
insert into stp_linha (codigo, nome, abreviacao)
	values('BAON1235', 'Barra para Ondina', 'BARRA/ONDINA');
insert into stp_linha (codigo, nome, abreviacao)
	values('BECA0120', 'Beiru/Tranquedo Neves  para Cabula VI', 'BEIRU/CABULA-VI');
insert into stp_linha (codigo, nome, abreviacao)
	values('SAVA0550', 'São Tomé de Paripe para Avenida Vasco da Gama', 'PARIPE/VASCO');
insert into stp_linha (codigo, nome, abreviacao)
	values('ITSR0550', 'Itapuã para São Rafael', 'ITAPUA/SAO-RAFAEL');
insert into stp_linha (codigo, nome, abreviacao)
	values('ITSR0550', 'Itaigara para Lapa', 'ITAIGARA/LAPA');
insert into stp_linha (codigo, nome, abreviacao)
	values('ITSR0550', 'Ribrira para Terminal Acesso Norte', 'RIBEIRA/AC-NORTE');

-- Popula Itnerário
insert into stp_itinerario (linha_id, ponto_id )
values
	(2,1), (2,3), (2,6), (2,5),
	(3,2), (3,1), (3,3),
	(4,4), (4,5), (4,6), (4,1),
	(5,3), (5,2), (5,1), (5,4), (5,6);


-- Popula a tabela de motoristas
insert into stp_motorista(nome, cnh)
	values
		('Augusto Oliveira', '1234567891'),
		('Maria Vieira', '7418529637'),
		('Antônio Silva', '0002583697'),
		('Renato Gomes', '9876000219'),
		('Lorival Souza', '0005563697'),
		('Ronaldo Gaucho', '7745800219');		
	
-- Popula  a tabela de veículos
insert into stp_veiculo(placa, patrimonio, capacidade)
	values
		('OCP1258', 'BUZU125', 45),
		('DH1258D', 'MICB145', 25),
		('XGV1258', 'DUOB014', 60),
		('JUH458L', 'DUOB015', 60);

	
-- Popula a tabela de viagens
insert into stp_viagem (linha_id, veiculo_id, motorista_id)
	values
		(2, 1, 4),
		(3, 2, 3),
		(4, 3, 2),
		(5, 4, 1),
		(2, 4, 1),
		(3, 3, 2),
		(4, 2, 3),
		(5, 1, 4);

	
-- Popula tabela passageiro
insert into stp_passageiro (viagem_id, card_id)
	values
		(1,1), (1,null), (1,2), (1,3), (1,4), (1,5), (1,null), (1,null), 	-- viajem 1
		(2,null), (2,2), (2,4), (2,5), (2,5),  								-- viajem 2
		(3,4), (3,3), (3,null), (3,null), (3,null), (3,2), (3,1), (3,4), 	-- viajem 3
		(4,1), (4,2), (4,3), (4,null), (4,null), (4,null), (4,5), 			-- viajem 4
		(5,5), (5,null), (5,4), (5,3), (5,2), (5,1), (5,null), (5,null),	-- viajem 5
		(6,2), (6,null), (6,null), (6,3), (6,4), (6,5), (6,null),			-- viajem 6
		(7,1), (7,1), (7,null), (7,2), (7,null), (7,3), (7,null),			-- viajem 7
		(8,null), (8,null), (8,null), (8,5), (8,4), (8,3), (8,2), (8,null);	-- viajem 8
		

-- Popula tabela pagamento
insert into stp_pagamento (passageiro_id, viagem_id, valor)
	values
		(1,1,2.10),
		(2,1,4.20),
		(3,1,4.20),
		(4,1,0.00),
		(5,1,4.20),
		(6,1,4.20),
		(7,1,4.20),
		(8,1,4.20),
		(9,2,4.20),
		(10,2,4.20),
		(11,2,4.20),
		(12,2,4.20),
		(13,2,4.20),
		(14,3,4.20),
		(15,3,0.00),
		(16,3,4.20),
		(17,3,4.20),
		(18,3,4.20),
		(19,3,4.20),
		(20,3,2.10),
		(21,3,4.20),
		(22,4,2.10),
		(23,4,4.20),
		(24,4,0.00),
		(25,4,4.20),
		(26,4,4.20),
		(27,4,4.20),
		(28,4,4.20),
		(29,5,4.20),
		(30,5,4.20),
		(31,5,4.20),
		(32,5,0.00),
		(33,5,4.20),
		(34,5,2.10),
		(35,5,4.20),
		(36,5,4.20),
		(37,6,4.20),
		(38,6,4.20),
		(39,6,4.20),
		(40,6,0.00),
		(41,6,4.20),
		(42,6,4.20),
		(43,6,4.20),
		(44,7,2.10),
		(45,7,2.10),
		(46,7,4.20),
		(47,7,4.20),
		(48,7,4.20),
		(49,7,0.00),
		(50,7,4.20),
		(51,8,4.20),
		(52,8,4.20),
		(53,8,4.20),
		(54,8,4.20),
		(55,8,4.20),
		(56,8,0.00),
		(57,8,4.20),
		(58,8,4.20);
