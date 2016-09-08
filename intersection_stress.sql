UPDATE  generated.roads
SET     ft_int_stress = NULL,
        tf_int_stress = NULL;

-- set the baseline stress as the highest stress of the crossing segment
UPDATE  generated.roads
SET     ft_int_stress = (
            SELECT  MAX(GREATEST(r.ft_seg_stress,r.tf_seg_stress))
            FROM    generated.roads r
            WHERE   NOT r.road_id = roads.road_id
            AND     roads.intersection_to IN (r.intersection_from,r.intersection_to)
);
UPDATE  generated.roads
SET     tf_int_stress = (
            SELECT  MAX(GREATEST(r.ft_seg_stress,r.tf_seg_stress))
            FROM    generated.roads r
            WHERE   NOT r.road_id = roads.road_id
            AND     roads.intersection_from IN (r.intersection_from,r.intersection_to)
);

-- reduce stress for stoplights or all-way stops
UPDATE  generated.roads
SET     ft_int_stress = 1
WHERE   Exists (
            SELECT  1
            FROM    generated.roads_intersections i
            WHERE   i.int_id = roads.intersection_to
            AND     (i.signalized OR i.stops)
);
UPDATE  generated.roads
SET     tf_int_stress = 1
WHERE   Exists (
            SELECT  1
            FROM    generated.roads_intersections i
            WHERE   i.int_id = roads.intersection_from
            AND     (i.signalized OR i.stops)
);
