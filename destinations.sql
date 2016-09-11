--DROP TABLE IF EXISTS generated.destinations;

CREATE TABLE generated.destinations (
    id SERIAL PRIMARY KEY,
    dest_name TEXT,
    geom geometry(Point,2232),
    road_id INT,
    vert_id INT
);

CREATE INDEX sidx_destinations_geom ON destinations USING gist (geom);

INSERT INTO generated.destinations (dest_name, geom)
SELECT  "Name",
        ST_Force2D(geom)
FROM    "Regional_Destinations_CURRENT";

-- had to move a couple of locations so check for differences in geoms

UPDATE  generated.destinations
SET     road_id = (
            SELECT      road_id
            FROM        roads
            ORDER BY    ST_Distance(destinations.geom,roads.geom) ASC
            LIMIT       1
);

UPDATE  generated.destinations
SET     vert_id = roads_net_vert.vert_id
FROM    roads_net_vert
WHERE   destinations.road_id = roads_net_vert.road_id;
