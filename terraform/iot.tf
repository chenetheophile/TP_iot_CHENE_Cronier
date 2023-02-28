# aws_iot_certificate cert

resource "aws_iot_certificate" "cert" {
  active = true
  # Other certificate configuration options go here
}

# aws_iot_policy pub-sub

resource "aws_iot_policy" "pub-sub" {
  name = "pub-sub"

  policy = file("${path.module}/files/iot_policy.json")
}


# aws_iot_policy_attachment attachment

resource "aws_iot_policy_attachment" "attachment" {
  policy = aws_iot_policy.pub-sub.name
  target      = aws_iot_certificate.cert.arn
}

# aws_iot_thing temp_sensor

resource "aws_iot_thing" "temp_sensor" {
  name = "temp-sensor"
}


# aws_iot_thing_principal_attachment thing_attachment

resource "aws_iot_thing_principal_attachment" "thing_attachment" {
  thing      = aws_iot_thing.temp_sensor.name
  principal       = aws_iot_certificate.cert.arn
}

# data aws_iot_endpoint to retrieve the endpoint to call in simulation.py

data "aws_iot_endpoint" "endpoint" {
  endpoint_type = "iot:Data-ATS"
}

# aws_iot_topic_rule rule for sending invalid data to DynamoDB

resource "aws_iot_topic_rule" "rule" {
  name = "rule"
  sql  = "SELECT * FROM 'sensor/temperature/+' where temperature >= 40"
  sql_version = "2016-03-23"
  enabled = true
  dynamodbv2 {
      put_item {
        table_name = aws_dynamodb_table.Temperature.name

      }
      role_arn     = aws_iam_role.iot_role.arn
    }
}

# aws_iot_topic_rule rule for sending valid data to Timestream


resource "aws_iot_topic_rule" "temperature_rule" {
  name = "temperature_rule"
  sql  = "SELECT * FROM 'sensor/temperature/+'"
  enabled = true
  sql_version = "2016-03-23"
  timestream {
    role_arn   = aws_iam_role.iot_role.arn
    database_name = aws_timestreamwrite_database.iot.database_name
    table_name = "temperaturesensor"

    dimension {
      name  = "sensor_id"
      value = "$${sensor_id}"
    }
    dimension {
        name  = "temperature"
        value = "$${temperature}"
    }
    dimension {
      name  = "zone_id"
      value = "$${zone_id}"
    }
  }
}

###########################################################################################
# Enable the following resource to enable logging for IoT Core (helps debug)
###########################################################################################

#resource "aws_iot_logging_options" "logging_option" {
#  default_log_level = "WARN"
#  role_arn          = aws_iam_role.iot_role.arn
#}
