DROP FUNCTION IF EXISTS ids_modified_features;
CREATE OR REPLACE FUNCTION public.ids_modified_features(scenario_id_input integer, table_input text)
 RETURNS SETOF INTEGER[]
 LANGUAGE plpgsql
AS $function$
DECLARE 
	t_name text;
BEGIN 

	IF table_input = 'pois' THEN 
		t_name = 'pois_modified';
	ELSEIF table_input = 'ways' THEN
		t_name = 'ways_userinput';
	END IF;

	RETURN query EXECUTE'
		SELECT array_append(array_agg(DISTINCT x.id),0) 
		FROM (
			SELECT Unnest(deleted_'|| quote_ident(table_input) ||')::integer id 
			FROM scenarios
			WHERE scenario_id = $1
			UNION ALL
			SELECT original_id::integer modified
			FROM '|| quote_ident(t_name)||' 
			WHERE scenario_id = $2 
			AND original_id IS NOT NULL
		) x'
		USING scenario_id_input, scenario_id_input;
END;
$function$

--SELECT ids_modified_features(1,'ways')