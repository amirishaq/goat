DROP FUNCTION IF EXISTS mapping_cycleways_segregated;
CREATE OR REPLACE FUNCTION mapping_cycleways_segregated()
RETURNS TABLE (osm_id bigint, highway text, osm_type text, geom geometry) AS
$$
    SELECT w.osm_id, w.highway, 'way' AS osm_type, w.geom
    FROM ways_mapping w, study_area s 
    WHERE (bicycle = 'designated' OR (highway IN ('cycleway') and (bicycle NOT IN ('no','use_sidepath') OR bicycle IS NULL)) 
    OR (highway = 'path' AND bicycle IN ('designated','yes')))
    AND w.foot IN ('yes','designated')
    AND w.segregated IS NULL
    AND ST_Intersects(s.geom,w.geom);
$$
LANGUAGE sql;
    
COMMENT ON FUNCTION mapping_cycleways_segregated() 
IS '**FOR-API-FUNCTION** RETURNS col_names[osm_id,highway,osm_type,geom] **FOR-API-FUNCTION**';