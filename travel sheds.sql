--------------------------------------------
-- all streets
--------------------------------------------
DROP TABLE IF EXISTS generated.shed_all_streets;
DROP TABLE IF EXISTS generated.shed_all_streets_agg;

CREATE TABLE generated.shed_all_streets (
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



use alpha shapes (points as polygon function)

SELECT  *
FROM    pgr_drivingDistance('
            SELECT  link_id AS id,
                    source_vert AS source,
                    target_vert AS target,
                    link_cost AS cost
            FROM    roads_net_link
            WHERE   link_stress <= 2',
            ARRAY[148,1455],
            2640,
            directed := true);


        pgr_dijkstra('
            SELECT  link_id AS id,
                    source_vert AS source,
                    target_vert AS target,
                    link_cost AS cost
            FROM    roads_net_link
            WHERE   link_stress <= 2',
            destinations.id,
            5280,
            directed := true)
