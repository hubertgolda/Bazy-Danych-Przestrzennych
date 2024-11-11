create database cw02;

CREATE EXTENSION postgis;

create table roads (id int, geometry GEOMETRY(LineString, 3857), name varchar(50));
create table buildings (id int, geometry GEOMETRY(Polygon, 3857), name varchar(50));
create table poi (id int , geometry GEOMETRY(Point), name varchar(50));

select * from poi;
drop table roads;
drop table buildings;
drop table poi;

insert into roads (id, name, geometry) values
(1, 'RoadX', ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)', 3857)),
(2, 'RoadY', ST_GeomFromText('LINESTRING(7.5 10.5, 7.5 0)', 3857));

insert into buildings (id, name, geometry) values
(1, 'BuildingA', ST_GeomFromText('POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))', 3857)),
(2, 'BuildingB', ST_GeomFromText('POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))', 3857)),
(3, 'BuildingC', ST_GeomFromText('POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))', 3857)),
(4, 'BuildingD', ST_GeomFromText('POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))', 3857)),
(5, 'BuildingF', ST_GeomFromText('POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))', 3857));


insert into poi (id, name, geometry) values
(1, 'G', ST_GeomFromText('POINT(1 3.5)')),
(2, 'H', ST_GeomFromText('POINT(5.5 1.5)')),
(3, 'I', ST_GeomFromText('POINT(9.5 6)')),
(4, 'J', ST_GeomFromText('POINT(6.5 6)')),
(5, 'K', ST_GeomFromText('POINT(6 9.5)'));

--zadania:
--a)

select SUM(ST_Length(geometry)) as total_length
from roads;

--b)

select ST_AsText(geometry) AS wkt, ST_Perimeter(geometry) as obwod, ST_Area(geometry) as pole
from buildings
where id = 1;

--c)

select name as nazwa, ST_Area(geometry) as pole
from buildings
order by name asc;


--d)

select name as nazwa, ST_Perimeter(geometry) as obwod
from buildings
order by ST_Area(geometry) desc
limit 2;


--e)

select ST_Distance(ST_GeomFromText('POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))', 3857),
    ST_GeomFromText('POINT(6 9.5)', 3857)) as odleglosc;

--f)

select ST_Area(ST_Intersection(BuildingC.geometry, ST_Buffer(BuildingB.geometry, 0.5))) as powierzchnia
from buildings as BuildingC, buildings as BuildingB
where BuildingC.name = 'BuildingC'
and BuildingB.name = 'BuildingB';

--g)
 
select buildings.name as nazwa, ST_Centroid(buildings.geometry) as wsp_centroid
from buildings, roads
where ST_X(ST_Centroid(buildings.geometry)) > ST_X(ST_LineInterpolatePoint(roads.geometry, 0.5))
and roads.name = 'RoadX';


--h)

select ST_Area(ST_Difference(buildings.geometry, ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))', 3857))) as pole_budynku,
       ST_Area(ST_Difference(ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))', 3857), buildings.geometry)) as pole_poligonu
from buildings
where  buildings.name = 'BuildingC';





