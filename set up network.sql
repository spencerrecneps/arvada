SELECT tdg.tdgMakeNetwork('generated.roads');
SELECT tdg.tdgNetworkCostFromDistance('generated.roads');

-- run intersection_data.sql

-- run intersection_stress.sql

-- run part of destinations.sql (no need to re-create the table unless geoms
-- have changed)
