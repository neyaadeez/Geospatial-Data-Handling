create extension POSTGIS;


CREATE TABLE locations (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  longitude DECIMAL(10,8) NOT NULL,
  latitude DECIMAL(10,8) NOT NULL
);

ALTER TABLE locations ALTER COLUMN longitude TYPE DECIMAL(11, 8);
ALTER TABLE locations ALTER COLUMN latitude TYPE DECIMAL(11, 8);


INSERT INTO locations (name, longitude, latitude)
VALUES ('MyHome', -118.288260, 34.030660);
INSERT INTO locations (name, longitude, latitude)
VALUES ('StarBucksVilage', -118.2843846, 34.0246307);
INSERT INTO locations (name, longitude, latitude)
VALUES ('CinematicArtDep', -118.2861595, 34.0230609);
INSERT INTO locations (name, longitude, latitude)
VALUES ('BlueLight1', -118.2850095, 34.0218576);
INSERT INTO locations (name, longitude, latitude)
VALUES ('WaterWork1', -118.2853017, 34.0203106);
INSERT INTO locations (name, longitude, latitude)
VALUES ('MarshalDep', -118.2854842, 34.0187744);
INSERT INTO locations (name, longitude, latitude)
VALUES ('DornsifeDep', -118.2872093, 34.0193267);
INSERT INTO locations (name, longitude, latitude)
VALUES ('ViterbiWaterW', -118.2891651, 34.0206833);
INSERT INTO locations (name, longitude, latitude)
VALUES ('BlueLight2', -118.287513, 34.0212782);
INSERT INTO locations (name, longitude, latitude)
VALUES ('BlueLight3', -118.2846021, 34.0210432);
INSERT INTO locations (name, longitude, latitude)
VALUES ('LeavyStarBucks', -118.2825773, 34.0213515);
INSERT INTO locations (name, longitude, latitude)
VALUES ('WaterWorkLeavy', -118.283349, 34.0222326);
INSERT INTO locations (name, longitude, latitude)
VALUES ('Dulce', -118.2854137, 34.0252522);


SELECT * FROM locations;

-- Compute the convex hull for the points
WITH convex_hull AS (
    SELECT ST_AsText(ST_ConvexHull(ST_Collect(geom))) AS geom
    FROM (
        SELECT ST_SetSRID(ST_MakePoint(longitude, latitude), 4326) AS geom
        FROM locations
    ) AS subquery
)

-- Retrieve the coordinates of the convex hull
SELECT ST_AsKML(ST_SetSRID(ST_GeomFromText(geom), 4326)) AS kml_polygon
FROM convex_hull;

SELECT AddGeometryColumn('locations', 'geom', 4326, 'POINT', 2);
UPDATE locations
SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326);



SELECT l2.name AS neighbor_name,
       ST_Distance(l1.geom, l2.geom) AS distance_m 
FROM locations AS l1
JOIN locations AS l2 ON l1.name != l2.name
WHERE l1.name = 'MyHome'
ORDER BY distance_m 
LIMIT 4;


SELECT nearest.name AS place_name,
       ST_AsKML(
           ST_MakeLine(
               ST_SetSRID(ST_MakePoint(l1.longitude, l1.latitude), 4326),
               ST_SetSRID(ST_MakePoint(nearest.longitude, nearest.latitude), 4326)
           )
       ) AS kml_line
FROM locations AS l1
JOIN (
    SELECT l2.name,
           l2.longitude,
           l2.latitude,
           nearest_neighbors.distance_m
    FROM (
        SELECT l2.name AS neighbor_name, 
               ST_Distance(l1.geom, l2.geom) AS distance_m
        FROM locations AS l1
        JOIN locations AS l2 ON l1.name != l2.name
        WHERE l1.name = 'MyHome'
        ORDER BY distance_m
        LIMIT 4
    ) AS nearest_neighbors
    JOIN locations AS l2 ON nearest_neighbors.neighbor_name = l2.name
) AS nearest ON ST_Distance(ST_SetSRID(ST_MakePoint(l1.longitude, l1.latitude), 4326), ST_SetSRID(ST_MakePoint(nearest.longitude, nearest.latitude), 4326)) = nearest.distance_m;
