create user if not exists 'scientist'@'%' identified by 'scientist';
create user if not exists 'ben'@'%' identified by 'ben';

grant select, insert, update, delete, lock tables, 
	alter, create, drop, 
	index, grant option on specify6.* 
	to 'ben'@'%';

grant reload on *.* to 'ben'@'%';

grant select, insert, update, delete, lock tables 
	on specify6.* to 'scientist'@'%';

flush privileges;
