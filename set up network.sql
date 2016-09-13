SELECT tdg.tdgMakeNetwork('generated.roads');
SELECT tdg.tdgNetworkCostFromDistance('generated.roads');

-- run intersection_data.sql

-- run intersection_stress.sql

-- run part of destinations.sql (no need to re-create the table unless geoms
-- have changed)

-- copy the roads table using the QGIS tool and name it roads_all_ints

UPDATE generated.roads_all_ints SET ft_int_stress = 1, tf_int_stress = 1;
SELECT tdg.tdgMakeNetwork('generated.roads_all_ints');
SELECT tdg.tdgNetworkCostFromDistance('generated.roads_all_ints');
