DROP TABLE IF EXISTS generated.routing_stress;
DROP TABLE IF EXISTS generated.routing_stress_agg;

CREATE TABLE generated.routing_stress (
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


-- this took 22 minutes to run at home
INSERT INTO generated.routing_stress (
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
WHERE   NOT o.id = d.id


-- create indexes and then aggregate





select * from pgr_dijkstra(
    'SELECT link_id AS id,
         source_vert AS source,
         target_vert AS target,
         link_cost AS cost
        FROM roads_net_link',
    11404, 11121, directed := true
)
