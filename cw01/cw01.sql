--cw01

--1
select matchid, player from gole where teamid = 'POL';

--2
select * from mecze where id = 1004;

--3
select * from mecze join gole on (id=matchid);

--4
select mecze.team1, mecze.team2, gole.player
from mecze
join gole on mecze.id = gole.matchid
where gole.player like 'Mario%';

--5
select gole.player, druzyny.id, druzyny.coach, gole.gtime
from druzyny
join gole on (id=teamid)where (gtime<=10);

--6
select 	druzyny.teamname, mecze.mdate
from druzyny
join mecze on mecze.team1 = druzyny.id OR mecze.team2 = druzyny.id
where druzyny.coach = 'Franciszek Smuda';

--7
select gole.player, mecze.stadium 
from gole
join mecze on gole.matchid = mecze.id
where mecze.stadium = 'National Stadium, Warsaw';

--8

select player, gtime
from gole
join mecze on gole.matchid = mecze.id
where gole.teamid != 'GER' and (mecze.team1 = 'GER' or mecze.team2 = 'GER');

--9

select druzyny.teamname, count(gole.matchid) AS liczba_goli
from druzyny
join gole on druzyny.id = gole.teamid 
group by druzyny.teamname order by liczba_goli desc;


--10
select mecze.stadium, COUNT(gole.matchid) as liczba_goli
from mecze 
join gole on matchid = id
group by mecze.stadium
order by liczba_goli desc;



