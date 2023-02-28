import json

import boto3

from timestream_rp import get_query_for_zone_id

ids = [1, 2]


def lambda_handler(event, context):
    session = boto3.Session()
    query_client = session.client('timestream-query')
    query_example = QueryExample(query_client)
    iot_client = boto3.client('iot-data', region_name='eu-west-1')

    for _id in ids:
        zone_mean_temp = query_example.run_query(get_query_for_zone_id(str(_id)))
        print("Mean temperature for Zone {}: {}°C".format(str(_id), str(zone_mean_temp)))
        if zone_mean_temp is not None and zone_mean_temp > 35:
            send_ac_message(iot_client, True, str(_id))

        if zone_mean_temp is not None and zone_mean_temp < 20:
            send_ac_message(iot_client, False, str(_id))


def send_ac_message(_iot_client, _enable_ac, _zone_id):
    _iot_client.publish(
        topic='AC/AC-{}'.format(_zone_id),
        qos=1,
        payload=json.dumps({
            "state": {
                "enabled": _enable_ac
            }
        })
    )


def parse_query_result_and_compute_temp_mean(_query_result):
    temp_array = []
    for row in _query_result['Rows']:
        temp_array.append(float(row['Data'][0]['ScalarValue']))
    try:
        return sum(temp_array) / len(temp_array)
    except Exception as err:
        print("Exception while computing temperature mean:", err)


class QueryExample:

    def __init__(self, client):
        self.client = client
        self.paginator = client.get_paginator('query')

    def run_query(self, query_string):
        try:
            page_iterator = self.paginator.paginate(QueryString=query_string)
            for page in page_iterator:
                return parse_query_result_and_compute_temp_mean(page)
        except Exception as err:
            print("Exception while running query:", err)


if __name__ == '__main__':
    session = boto3.Session()
    query_client = session.client('timestream-query')
    query_example = QueryExample(query_client)
    iot_client = boto3.client('iot-data', region_name='eu-west-1')

    for _id in ids:
        zone_mean_temp = query_example.run_query(get_query_for_zone_id(str(_id)))
        print("Mean temperature for Zone {}: {}°C".format(str(_id), str(zone_mean_temp)))
        if zone_mean_temp is not None and zone_mean_temp > 35:
            send_ac_message(iot_client, True, str(_id))

        if zone_mean_temp is not None and zone_mean_temp < 20:
            send_ac_message(iot_client, False, str(_id))
