SELECT tdg.tdgNetworkCostFromDistance('generated.roads');
--------------------------------------------
-- all streets
--------------------------------------------
DROP TABLE IF EXISTS generated.routing_all_streets;
DROP TABLE IF EXISTS generated.routing_all_streets_agg;

CREATE TABLE generated.routing_all_streets (
    id SERIAL PRIMARY KEY,
    origin_id INT,
    destination_id INT,
    seq INT,
    path_seq INT,
    node BIGINT,
    edge BIGINT,
    cost FLOAT,
    agg_cost FLOAT,
    geom geometry(linestring,2232)
);

-- this took 30 minutes to run at home
INSERT INTO generated.routing_all_streets (
    origin_id, destination_id, seq, path_seq, node, edge, cost, agg_cost
)
SELECT  o.id,
        d.id,
        routes.seq,
        routes.path_seq,
        routes.node,
        routes.edge,
        routes.cost,
        routes.agg_cost
FROM    destinations o,
        destinations d,
        pgr_dijkstra('
            SELECT  link_id AS id,
                    source_vert AS source,
                    target_vert AS target,
                    link_cost AS cost
            FROM    roads_net_link',
            o.vert_id,
            d.vert_id,
            directed := true) routes
WHERE   NOT o.id = d.id;

-- create indexes
CREATE INDEX idx_rtng_all_node ON routing_all_streets (node);
CREATE INDEX idx_rtng_all_ods ON routing_all_streets (origin_id,destination_id);
ANALYZE routing_all_streets (node, origin_id, destination_id);

-- add road_id and index
ALTER TABLE generated.routing_all_streets ADD COLUMN road_id INT;
UPDATE  generated.routing_all_streets
SET     road_id = verts.road_id
FROM    roads_net_vert verts
WHERE   routing_all_streets.node = verts.vert_id;
CREATE INDEX idx_rtng_all_rdid ON routing_all_streets (road_id);
ANALYZE routing_all_streets (road_id);

-- add geoms and index
UPDATE  generated.routing_all_streets
SET     geom = roads.geom
FROM    generated.roads
WHERE   routing_all_streets.road_id = roads.road_id;
CREATE INDEX sidx_rtng_all_geom ON routing_all_streets USING GIST (geom);
ANALYZE routing_all_streets (geom);

-- aggregate
CREATE TABLE generated.routing_all_streets_agg (
    id SERIAL PRIMARY KEY,
    road_id INT,
    use_count INT,
    geom geometry(Linestring,2232)
);
INSERT INTO generated.routing_all_streets_agg (road_id, use_count, geom)
SELECT      road_id,
            COUNT(id),
            geom
FROM        generated.routing_all_streets
GROUP BY    road_id, geom;

-- indexes
CREATE INDEX idx_rtng_all_agg_rdid ON routing_all_streets_agg (road_id);
CREATE INDEX sidx_rtng_all_agg_geom ON routing_all_streets_agg USING GIST (geom);
ANALYZE routing_all_streets_agg (road_id, geom);


--------------------------------------------
-- low stress
--------------------------------------------
DROP TABLE IF EXISTS generated.routing_low_stress;
DROP TABLE IF EXISTS generated.routing_low_stress_agg;

CREATE TABLE generated.routing_low_stress (
    id SERIAL PRIMARY KEY,
    origin_id INT,
    destination_id INT,
    seq INT,
    path_seq INT,
    node BIGINT,
    edge BIGINT,
    cost FLOAT,
    agg_cost FLOAT,
    geom geometry(linestring,2232)
);

-- this took 20 minutes to run at work
INSERT INTO generated.routing_low_stress (
    origin_id, destination_id, seq, path_seq, node, edge, cost, agg_cost
)
SELECT  o.id,
        d.id,
        routes.seq,
        routes.path_seq,
        routes.node,
        routes.edge,
        routes.cost,
        routes.agg_cost
FROM    destinations o,
        destinations d,
        pgr_dijkstra('
            SELECT  link_id AS id,
                    source_vert AS source,
                    target_vert AS target,
                    link_cost AS cost
            FROM    roads_net_link
            WHERE   link_stress <= 2',
            o.vert_id,
            d.vert_id,
            directed := true) routes
WHERE   NOT o.id = d.id;

-- create indexes
CREATE INDEX idx_rtng_lowstress_node ON routing_low_stress (node);
CREATE INDEX idx_rtng_lowstress_ods ON routing_low_stress (origin_id,destination_id);
ANALYZE routing_low_stress (node, origin_id, destination_id);

-- add road_id and index
ALTER TABLE generated.routing_low_stress ADD COLUMN road_id INT;
UPDATE  generated.routing_low_stress
SET     road_id = verts.road_id
FROM    roads_net_vert verts
WHERE   routing_low_stress.node = verts.vert_id;
CREATE INDEX idx_rtng_lowstress_rdid ON routing_low_stress (road_id);
ANALYZE routing_low_stress (road_id);

-- add geoms and index
UPDATE  generated.routing_low_stress
SET     geom = roads.geom
FROM    generated.roads
WHERE   routing_low_stress.road_id = roads.road_id;
CREATE INDEX sidx_rtng_lowstress_geom ON routing_low_stress USING GIST (geom);
ANALYZE routing_low_stress (geom);

-- aggregate
CREATE TABLE generated.routing_low_stress_agg (
    id SERIAL PRIMARY KEY,
    road_id INT,
    use_count INT,
    geom geometry(Linestring,2232)
);
INSERT INTO generated.routing_low_stress_agg (road_id, use_count, geom)
SELECT      road_id,
            COUNT(id),
            geom
FROM        generated.routing_low_stress
GROUP BY    road_id, geom;

-- indexes
CREATE INDEX idx_rtng_lowstress_agg_rdid ON routing_low_stress_agg (road_id);
CREATE INDEX sidx_rtng_lowstress_agg_geom ON routing_low_stress_agg USING GIST (geom);
ANALYZE routing_low_stress_agg (road_id, geom);


--------------------------------------------
-- low stress links, all intersections
--------------------------------------------
SELECT tdg.tdgNetworkCostFromDistance('generated.roads_all_ints');
DROP TABLE IF EXISTS generated.routing_all_ints;
DROP TABLE IF EXISTS generated.routing_all_ints_agg;

CREATE TABLE generated.routing_all_ints (
    id SERIAL PRIMARY KEY,
    origin_id INT,
    destination_id INT,
    seq INT,
    path_seq INT,
    node BIGINT,
    edge BIGINT,
    cost FLOAT,
    agg_cost FLOAT,
    geom geometry(linestring,2232)
);

-- this took 21 minutes to run at work
INSERT INTO generated.routing_all_ints (
    origin_id, destination_id, seq, path_seq, node, edge, cost, agg_cost
)
SELECT  o.id,
        d.id,
        routes.seq,
        routes.path_seq,
        routes.node,
        routes.edge,
        routes.cost,
        routes.agg_cost
FROM    destinations_all_ints o,
        destinations_all_ints d,
        pgr_dijkstra('
            SELECT  link_id AS id,
                    source_vert AS source,
                    target_vert AS target,
                    link_cost AS cost
            FROM    roads_all_ints_net_link
            WHERE   link_stress <= 2',
            o.vert_id,
            d.vert_id,
            directed := true) routes
WHERE   NOT o.id = d.id;

-- create indexes
CREATE INDEX idx_rtng_allints_node ON routing_all_ints (node);
CREATE INDEX idx_rtng_allints_ods ON routing_all_ints (origin_id,destination_id);
ANALYZE routing_all_ints (node, origin_id, destination_id);

-- add road_id and index
ALTER TABLE generated.routing_all_ints ADD COLUMN road_id INT;
UPDATE  generated.routing_all_ints
SET     road_id = verts.road_id
FROM    roads_all_ints_net_vert verts
WHERE   routing_all_ints.node = verts.vert_id;
CREATE INDEX idx_rtng_allints_rdid ON routing_all_ints (road_id);
ANALYZE routing_all_ints (road_id);

-- add geoms and index
UPDATE  generated.routing_all_ints
SET     geom = roads_all_ints.geom
FROM    generated.roads_all_ints
WHERE   routing_all_ints.road_id = roads_all_ints.road_id;
CREATE INDEX sidx_rtng_allints_geom ON routing_all_ints USING GIST (geom);
ANALYZE routing_all_ints (geom);

-- aggregate
CREATE TABLE generated.routing_all_ints_agg (
    id SERIAL PRIMARY KEY,
    road_id INT,
    use_count INT,
    geom geometry(Linestring,2232)
);
INSERT INTO generated.routing_all_ints_agg (road_id, use_count, geom)
SELECT      road_id,
            COUNT(id),
            geom
FROM        generated.routing_all_ints
GROUP BY    road_id, geom;

-- indexes
CREATE INDEX idx_rtng_allints_agg_rdid ON routing_all_ints_agg (road_id);
CREATE INDEX sidx_rtng_allints_agg_geom ON routing_all_ints_agg USING GIST (geom);
ANALYZE routing_all_ints_agg (road_id, geom);


--------------------------------------------
-- elevation
--------------------------------------------
DROP TABLE IF EXISTS generated.routing_elevation;
DROP TABLE IF EXISTS generated.routing_elevation_agg;

-- modify costs for elevation
UPDATE  generated.roads_net_link
SET     link_cost = link_cost *
            CASE    WHEN 100 * (r1.elevation_mp_ft - r2.elevation_mp_ft) / link_cost > 12 THEN 99
                    WHEN 100 * (r1.elevation_mp_ft - r2.elevation_mp_ft) / link_cost > 8 THEN 3
                    WHEN 100 * (r1.elevation_mp_ft - r2.elevation_mp_ft) / link_cost > 5 THEN 2
                    WHEN 100 * (r1.elevation_mp_ft - r2.elevation_mp_ft) / link_cost > 3 THEN 1.3
                    WHEN 100 * (r1.elevation_mp_ft - r2.elevation_mp_ft) / link_cost > 1 THEN 1.1
                    ELSE 1
                    END
FROM    generated.roads r1,
        generated.roads r2
WHERE   roads_net_link.source_road_id = r1.road_id
AND     roads_net_link.target_road_id = r2.road_id;

-- continue as above
CREATE TABLE generated.routing_elevation (
    id SERIAL PRIMARY KEY,
    origin_id INT,
    destination_id INT,
    seq INT,
    path_seq INT,
    node BIGINT,
    edge BIGINT,
    cost FLOAT,
    agg_cost FLOAT,
    geom geometry(linestring,2232)
);

-- this took 30 minutes to run at home
INSERT INTO generated.routing_elevation (
    origin_id, destination_id, seq, path_seq, node, edge, cost, agg_cost
)
SELECT  o.id,
        d.id,
        routes.seq,
        routes.path_seq,
        routes.node,
        routes.edge,
        routes.cost,
        routes.agg_cost
FROM    destinations o,
        destinations d,
        pgr_dijkstra('
            SELECT  link_id AS id,
                    source_vert AS source,
                    target_vert AS target,
                    link_cost AS cost
            FROM    roads_net_link',
            o.vert_id,
            d.vert_id,
            directed := true) routes
WHERE   NOT o.id = d.id;

-- create indexes
CREATE INDEX idx_rtng_elev_node ON routing_elevation (node);
CREATE INDEX idx_rtng_elev_ods ON routing_elevation (origin_id,destination_id);
ANALYZE routing_elevation (node, origin_id, destination_id);

-- add road_id and index
ALTER TABLE generated.routing_elevation ADD COLUMN road_id INT;
UPDATE  generated.routing_elevation
SET     road_id = verts.road_id
FROM    roads_net_vert verts
WHERE   routing_elevation.node = verts.vert_id;
CREATE INDEX idx_rtng_elev_rdid ON routing_elevation (road_id);
ANALYZE routing_elevation (road_id);

-- add geoms and index
UPDATE  generated.routing_elevation
SET     geom = roads.geom
FROM    generated.roads
WHERE   routing_elevation.road_id = roads.road_id;
CREATE INDEX sidx_rtng_elev_geom ON routing_elevation USING GIST (geom);
ANALYZE routing_elevation (geom);

-- aggregate
CREATE TABLE generated.routing_elevation_agg (
    id SERIAL PRIMARY KEY,
    road_id INT,
    use_count INT,
    geom geometry(Linestring,2232)
);
INSERT INTO generated.routing_elevation_agg (road_id, use_count, geom)
SELECT      road_id,
            COUNT(id),
            geom
FROM        generated.routing_elevation
GROUP BY    road_id, geom;

-- indexes
CREATE INDEX idx_rtng_elev_agg_rdid ON routing_elevation_agg (road_id);
CREATE INDEX sidx_rtng_elev_agg_geom ON routing_elevation_agg USING GIST (geom);
ANALYZE routing_elevation_agg (road_id, geom);

-- replace cost
SELECT tdg.tdgNetworkCostFromDistance('generated.roads');
