-- 1
CREATE TABLE obiekty (id int, geometry geometry, name varchar(50));
DROP TABLE obiekty;

--SELECT name, ST_AsText(geometry) AS geometry FROM obiekty;
SELECT name, geometry FROM obiekty;

--DELETE FROM obiekty
--WHERE name = 'obiekt7';


-- a)
INSERT INTO obiekty (id, geometry, name)
VALUES (
    1,
    ST_Union(ARRAY[
        ST_LineFromText('LINESTRING(0 1, 1 1)'),
        ST_GeomFromText('CIRCULARSTRING(1 1, 2 0, 3 1)'),
        ST_GeomFromText('CIRCULARSTRING(3 1, 4 2, 5 1)'),
        ST_LineFromText('LINESTRING(5 1, 6 1)')
    ]),
    'obiekt1'
);


-- b)
INSERT INTO obiekty (id, geometry, name)
VALUES (
    2,
    ST_Union(ARRAY[
        ST_LineFromText('LINESTRING(10 2, 10 6, 14 6)'),
        ST_GeomFromText('CIRCULARSTRING(14 6, 16 4, 14 2)'),
        ST_GeomFromText('CIRCULARSTRING(14 2, 12 0, 10 2)'),
        ST_GeomFromText('CIRCULARSTRING(11 2, 12 3, 13 2)'),
        ST_GeomFromText('CIRCULARSTRING(13 2, 12 1, 11 2)')
    ]),
    'obiekt2'
);


-- c)
INSERT INTO obiekty (id, geometry, name)
VALUES(3,ST_PolygonFromText('POLYGON((7 15, 10 17, 12 13, 7 15))'),'obiekt3');


-- d)
INSERT INTO obiekty (id, geometry, name)
VALUES(4,ST_LineFromText('LINESTRING(20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5)'),'obiekt4');


-- e)
INSERT INTO obiekty (id, geometry, name)
VALUES (5, ST_Collect(ST_MakePoint(38, 32, 234), ST_MakePoint(30, 30, 59)), 'obiekt5');

--INSERT INTO obiekty (id, geometry, name)
--VALUES (5, ST_SetSRID(ST_Collect(ST_MakePoint(38, 32, 234), ST_MakePoint(30, 30, 59)), 0), 'obiekt5');


-- f)
INSERT INTO obiekty (id, geometry, name)
VALUES (6, ST_Collect(ST_MakeLine(ST_MakePoint(1, 1), ST_MakePoint(3, 2)), ST_MakePoint(4, 2)), 'obiekt6');


-- 2
SELECT ST_Area(ST_Buffer(ST_ShortestLine(o1.geometry, o2.geometry), 5)) AS buffer_area
FROM obiekty o1, obiekty o2
WHERE o1.name = 'obiekt3' AND o2.name = 'obiekt4';


-- 3
UPDATE obiekty
SET geometry = ST_PolygonFromText('POLYGON((20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5, 20 20))'),
    name = 'obiekt4'
WHERE id = 4;


-- 4
INSERT INTO obiekty (id, geometry, name)
VALUES (7, ST_Collect((SELECT geometry FROM obiekty WHERE name = 'obiekt3'), (SELECT geometry FROM obiekty WHERE name = 'obiekt4')), 'obiekt7');


-- 5
SELECT SUM(ST_Area(ST_Buffer(geometry, 5))) AS total_area
FROM obiekty
WHERE NOT ST_HasArc(geometry);















