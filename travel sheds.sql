use alpha shapes (points as polygon function)

SELECT * FROM pgr_drivingDistance(
        'SELECT id, source, target, cost, reverse_cost FROM edge_table',
        array[2,13], 3


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
