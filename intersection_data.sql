UPDATE  roads_intersections
SET     signalized = 'f',
        stops = 'f';

-- traffic signals
UPDATE  roads_intersections
SET     signalized = 't'
WHERE   legs > 2
AND     EXISTS (
            SELECT  1
            FROM    traffic_signals
            WHERE   traffic_signals.asset IN (
                        'CDOT SIGNAL',
                        'TRAFFIC SIGNAL',
                        'WESTMINSTER SIGNAL',
                        'WHEAT RIDGE SIGNAL'
            )
            AND     traffic_signals.geom <-> roads_intersections.geom < 150
);

-- all-way stops
UPDATE  roads_intersections
SET     stops= 't'
WHERE   legs > 2
AND     (
            SELECT  COUNT(stop_signs.id)
            FROM    stop_signs
            WHERE   stop_signs.geom <-> roads_intersections.geom < 100
) >= roads_intersections.legs;
