DATABASE_NAME = "iot"
TABLE_NAME = "temperaturesensor"


def get_query_for_zone_id(_zone_id):
    return f"""
    SELECT  temperature 
    FROM {DATABASE_NAME}.{TABLE_NAME} 
    WHERE time > ago(1m) and zone_id like '%{_zone_id}%'
    ORDER BY time ASC
    """
