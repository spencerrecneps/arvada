--------------------------------------------
-- all streets
--------------------------------------------
DROP TABLE IF EXISTS generated.travel_sheds;

-- set up tables
CREATE TABLE generated.travel_sheds (
    id SERIAL PRIMARY KEY,
    dest_id INT,
    dest_name TEXT,
    geom_all_streets geometry(multipolygon,2232),
    geom_low_stress geometry(multipolygon,2232),
    geom_all_ints geometry(multipolygon,2232),
    geom_elevation geometry(multipolygon,2232)
);
INSERT INTO generated.travel_sheds (dest_id, dest_name)
SELECT id, dest_name FROM destinations;
CREATE INDEX idx_trvlsheds_destid ON generated.travel_sheds (dest_id);
ANALYZE generated.travel_sheds (dest_id);

-- shed analysis for all streets
CREATE TEMP TABLE tmp_shed_all_verts (
    id SERIAL PRIMARY KEY,
    dest_id INT,
    node BIGINT
)
ON COMMIT DROP;

INSERT INTO tmp_shed_all_verts (
    dest_id,
    node
)
SELECT  destinations.id,
        shed.node
FROM    destinations,
        pgr_drivingDistance('
            SELECT  link_id AS id,
                    source_vert AS source,
                    target_vert AS target,
                    link_cost AS cost
            FROM    roads_net_link',
            destinations.vert_id,
            10560,                       -- 2 mile distance
            directed := true) shed;
CREATE INDEX tidx_trvlshedsall_dstid ON tmp_shed_all_verts (node);
ANALYZE tmp_shed_all_verts (node);

-- create geom_all_streets
UPDATE  generated.travel_sheds
SET     geom_all_streets = ST_Multi(ST_SetSRID(pgr_pointsAsPolygon('
            SELECT  id,
                    ST_X(verts.geom) AS x,
                    ST_Y(verts.geom) AS y
            FROM    tmp_shed_all_verts,
                    roads_net_vert verts
            WHERE   tmp_shed_all_verts.node = verts.vert_id
            AND     dest_id = '||travel_sheds.dest_id
),2232));

-- shed analysis for low stress streets
CREATE TEMP TABLE tmp_shed_lowstress_verts (
    id SERIAL PRIMARY KEY,
    dest_id INT,
    node BIGINT
)
ON COMMIT DROP;

INSERT INTO tmp_shed_lowstress_verts (
    dest_id,
    node
)
SELECT  destinations.id,
        shed.node
FROM    destinations,
        pgr_drivingDistance('
            SELECT  link_id AS id,
                    source_vert AS source,
                    target_vert AS target,
                    link_cost AS cost
            FROM    roads_net_link
            WHERE   link_stress <= 2',
            destinations.vert_id,
            10560,                       -- 2 mile distance
            directed := true) shed;
CREATE INDEX tidx_trvlshedls_dstid ON tmp_shed_lowstress_verts (node);
ANALYZE tmp_shed_lowstress_verts (node);

-- create geom_all_streets
UPDATE  generated.travel_sheds
SET     geom_low_stress = ST_Multi(ST_SetSRID(pgr_pointsAsPolygon('
            SELECT  id,
                    ST_X(verts.geom) AS x,
                    ST_Y(verts.geom) AS y
            FROM    tmp_shed_lowstress_verts,
                    roads_net_vert verts
            WHERE   tmp_shed_lowstress_verts.node = verts.vert_id
            AND     dest_id = '||travel_sheds.dest_id
),2232))
WHERE   (SELECT COUNT(id) FROM tmp_shed_lowstress_verts WHERE dest_id = travel_sheds.dest_id) > 2;
UPDATE  generated.travel_sheds
SET     geom_low_stress = ST_Multi(ST_Buffer(verts.geom,50))
FROM    destinations,
        roads_net_vert verts
WHERE   travel_sheds.dest_id = destinations.id
AND     destinations.vert_id = verts.vert_id
AND     travel_sheds.geom_low_stress IS NULL;
