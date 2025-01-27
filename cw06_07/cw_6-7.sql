SELECT postgis_full_version();
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;

-- Tworzenie schematu 
CREATE SCHEMA golda;

-- Tworzenie schematu rasters
CREATE SCHEMA rasters;

-- Tworzenie schematu vectors
CREATE SCHEMA vectors;

CREATE table rasters.dem();

-- Tworzenie tabel w schemacie vectors
CREATE TABLE vectors.railroad (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    geom GEOMETRY(LineString, 4326)
);

CREATE TABLE vectors.places (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    geom GEOMETRY(Point, 4326)
);

CREATE TABLE vectors.porto_parishes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    geom GEOMETRY(Polygon, 4326)
);


drop table vectors.places;

select * from public.raster_columns;


-----------------------------------------------------------------------------


-- Przyklad 1
CREATE TABLE golda.intersects AS
SELECT a.rast, b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';

alter table golda.intersects
add column rid SERIAL PRIMARY KEY;

CREATE INDEX idx_intersects_rast_gist ON Golda.intersects
USING gist (ST_ConvexHull(rast));

-- schema::name table_name::name raster_column::name
SELECT AddRasterConstraints('golda'::name,
'intersects'::name,'rast'::name);

select * from golda.intersects
order by rid asc limit 50

-- Przyklad 2
CREATE TABLE golda.clip AS
SELECT ST_Clip(a.rast, b.geom, true), b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality like 'PORTO';

select * from golda.clip
limit 50

-- Przykład 3
CREATE TABLE golda.union AS
SELECT ST_Union(ST_Clip(a.rast, b.geom, true))
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast);

select * from golda.union
limit 50


-----------------------------------------------------------------------------


-- Przykład 1
CREATE TABLE golda.porto_parishes AS
WITH r AS (SELECT rast FROM rasters.dem LIMIT 1)
SELECT ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

select * from golda.porto_parishes
limit 50

-- Przykład 2
DROP TABLE golda.porto_parishes; --> drop table porto_parishes first

CREATE TABLE golda.porto_parishes AS
WITH r AS (SELECT rast FROM rasters.dem LIMIT 1)
SELECT st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

-- Przykład 3
DROP TABLE golda.porto_parishes; --> drop table porto_parishes first

CREATE TABLE golda.porto_parishes AS
WITH r AS (SELECT rast FROM rasters.dem LIMIT 1)
SELECT st_tile(st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-
32767)),128,128,true,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';


-----------------------------------------------------------------------------


-- Przykład 1
CREATE TABLE golda.intersection as
SELECT a.rid,(ST_Intersection(b.geom,a.rast)).geom,(ST_Intersection(b.geom,a.rast)).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

select * from golda.intersection
limit 50

-- Przykład 2
CREATE TABLE golda.dumppolygons AS
SELECT a.rid,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).geom,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

select * from golda.dumppolygons
limit 50


-----------------------------------------------------------------------------


-- Przykład 1
CREATE TABLE golda.landsat_nir AS
SELECT rid, ST_Band(rast,4) AS rast
FROM rasters.landsat8;

select * from golda.landsat_nir
limit 50

-- Przykład 2
CREATE TABLE golda.paranhos_dem AS
SELECT a.rid,ST_Clip(a.rast, b.geom,true) as rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

select * from golda.paranhos_dem
limit 50

-- Przykład 3
CREATE TABLE golda.paranhos_slope AS
SELECT a.rid,ST_Slope(a.rast,1,'32BF','PERCENTAGE') as rast
FROM golda.paranhos_dem AS a;

select * from golda.paranhos_slope
limit 50

-- Przykład 4
CREATE TABLE golda.paranhos_slope_reclass AS
SELECT a.rid,ST_Reclass(a.rast,1,']0-15]:1, (15-30]:2, (30-9999:3', '32BF',0)
FROM golda.paranhos_slope AS a;

select * from golda.paranhos_slope_reclass
limit 50

-- Przykład 5
SELECT st_summarystats(a.rast) AS stats
FROM golda.paranhos_dem AS a;

-- Przykład 6
SELECT st_summarystats(ST_Union(a.rast))
FROM golda.paranhos_dem AS a;

-- Przrykład 7
WITH t AS (
SELECT st_summarystats(ST_Union(a.rast)) AS stats
FROM golda.paranhos_dem AS a)
SELECT (stats).min,(stats).max,(stats).mean FROM t;

-- Przykład 8
WITH t AS (
SELECT b.parish AS parish, st_summarystats(ST_Union(ST_Clip(a.rast,
b.geom,true))) AS stats
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
group by b.parish)
SELECT parish,(stats).min,(stats).max,(stats).mean FROM t;

-- Przykład 9
SELECT b.name,st_value(a.rast,(ST_Dump(b.geom)).geom)
FROM rasters.dem a, vectors.places AS b
WHERE ST_Intersects(a.rast,b.geom)
ORDER BY b.name;


-----------------------------------------------------------------------------


-- Przyklad 10
CREATE TABLE golda.tpi30 AS
SELECT ST_TPI(a.rast,1) AS rast
FROM rasters.dem a; 

CREATE INDEX idx_tpi30_rast_gist ON golda.tpi30S;

SELECT AddRasterConstraints('golda'::name,
'tpi30'::name,'rast'::name);

CREATE TABLE golda.tpi30_porto AS
SELECT ST_TPI(a.rast, 1) AS rast
FROM rasters.dem AS a, vectors.porto_parishes AS p
WHERE ST_Intersects(a.rast, p.geom) AND p.municipality ILIKE 'porto'; 

CREATE INDEX idx_tpi30_rast_gist1 ON golda.tpi30_porto
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('golda'::name,
'tpi30_porto'::name,'rast'::name);


-----------------------------------------------------------------------------


-- Przykład 1
CREATE TABLE golda.porto_ndvi AS
WITH r AS (
SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast))
SELECT r.rid,ST_MapAlgebra(r.rast, 1, r.rast, 4, '([rast2.val] - [rast1.val]) / ([rast2.val] +
[rast1.val])::float','32BF') AS rast
FROM r;

CREATE INDEX idx_porto_ndvi_rast_gist ON golda.porto_ndvi
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('golda'::name,
'porto_ndvi'::name,'rast'::name);

select * from golda.porto_ndvi
limit 50

-- Przykład 2
CREATE OR REPLACE FUNCTION golda.ndvi(
value double precision [] [] [],
pos integer [][],
VARIADIC userargs text [])
RETURNS double precision AS
$$
BEGIN
--RAISE NOTICE 'Pixel Value: %', value [1][1][1];-->For debug purposes
RETURN (value [2][1][1] - value [1][1][1])/(value [2][1][1]+value
[1][1][1]); --> NDVI calculation!
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;


CREATE TABLE golda.porto_ndvi2 AS
WITH r AS (
SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast))
SELECT r.rid,ST_MapAlgebra(r.rast, ARRAY[1,4], 'golda.ndvi(double precision[],
integer[],text[])'::regprocedure, --> function!
'32BF'::text) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi2_rast_gist ON golda.porto_ndvi2
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('golda'::name,
'porto_ndvi2'::name,'rast'::name);

























