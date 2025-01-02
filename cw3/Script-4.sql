CREATE EXTENSION postgis;
CREATE SCHEMA buildings;
CREATE SCHEMA poi;

SELECT * FROM buildings.buildings_2018 b;
SELECT * FROM poi.poi_2018 p;

--1 budynki wyremontowane lub wybudowane na przestrzeni roku (zmiana między 2018 a 2019)

SELECT b2019.*
FROM buildings.buildings_2019 b2019
LEFT JOIN buildings.buildings_2018 b2018
ON b2018.polygon_id  = b2019.polygon_id 
WHERE b2018.polygon_id IS NULL
   OR (b2018.height  <> b2019.height  OR
       b2018.geom  <> b2019.geom);


--2 nowe POI które pojawiły się w promieniu 500 m od wyremontowanych lub wybudowanych budynków, policzone według ich kategorii


WITH nowe_lub_zm_budynki AS (
    SELECT b2019.*
    FROM buildings.buildings_2019 b2019
    LEFT JOIN buildings.buildings_2018 b2018
    ON b2018.polygon_id = b2019.polygon_id
    WHERE b2018.polygon_id IS NULL
       OR (b2018.height <> b2019.height OR
           b2018.geom <> b2019.geom)
),
nowe_poi AS (
    SELECT p2019.*
    FROM poi.poi_2019 p2019
    LEFT JOIN poi.poi_2018 p2018
    ON p2018.poi_id = p2019.poi_id
    WHERE p2018.poi_id IS null
),
poi_wybrane AS (
    SELECT p.*, b.polygon_id AS building_id
    FROM nowe_poi p
    JOIN nowe_lub_zm_budynki b
    ON ST_DWithin(p.geom, b.geom, 0.00449)
)
SELECT
    p.type,
    COUNT(*) AS poi_count
FROM poi_wybrane p
GROUP BY p.type
ORDER BY poi_count DESC;

  
--3 nowa tabela o nazwie ‘streets_reprojected’, która zawierać będzie dane z tabeli T2019_KAR_STREETS
-- przetransformowane do układu współrzędnych DHDN.Berlin/Cassini


--shp2pgsql.exe "PATH\T2019_KAR_STREETS.shp" 2019_streets | psql -h localhost -p 5432 -U postgres -d postgres

CREATE TABLE streets_reprojected (id integer, geom geometry);

INSERT INTO streets_reprojected SELECT gid, geom FROM "2019_streets";

UPDATE streets_reprojected SET geom = ST_SetSRID(geom, 4326);
UPDATE streets_reprojected SET geom = ST_Transform(geom, 3068);


--4 nowa tabela ‘input_points’ z rekordami o geometrii punktowej

CREATE TABLE input_points (id integer primary key, geom geometry);
INSERT INTO input_points (id, geom)
values	(1, st_setsrid(st_makepoint(8.36093, 49.03174), 4326)),
		(2, st_setsrid(st_makepoint(8.39876, 49.00644), 4326));
SELECT * FROM input_points; 

--5 zaktualizowane dane w tabeli ‘input_points’ w układzie współrzędnych DHDN.Berlin/Cassini.

UPDATE input_points SET geom = ST_SetSRID(geom, 3068);

--6 skrzyżowania, które znajdują się w odległości 200 m od linii zbudowanej z punktów w tabeli ‘input_points‘

UPDATE input_points SET geom = ST_SetSRID(geom, 4326);
UPDATE "2019_street_node" SET geom = ST_SetSRID(geom, 4326);

SELECT DISTINCT sn.geom
FROM "2019_street_node" sn 
JOIN input_points ip
ON ST_Contains(ST_Buffer(ip.geom, 0.00179), sn.geom); 


--7 jak wiele sklepów sportowych znajduje się w odległości 300 m od parku

--SELECT * FROM poi.poi_2019 p WHERE p.type  = 'Sporting Goods Store';

SELECT count(poi_2019.*)
FROM poi.poi_2019
JOIN "2019_land_use_a"
ON st_dwithin(poi_2019.geom, "2019_land_use_a".geom, 0.00269) 
WHERE poi_2019.type='Sporting Goods Store';


--8 punkty przecięcia torów kolejowych (RAILWAYS) z ciekami (WATER_LINES)

CREATE TABLE T2019_KAR_BRIDGES AS
SELECT ST_Intersection(r.geom, w.geom) AS geom
FROM "2019_railways" AS r
JOIN "2019_water_lines" AS w ON ST_Intersects(r.geom, w.geom);

SELECT * FROM T2019_KAR_BRIDGES;










