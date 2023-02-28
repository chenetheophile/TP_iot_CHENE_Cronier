# aws_timestreamwrite_database

resource "aws_timestreamwrite_database" "iot" {
  database_name = "iot"
}

# aws_timestreamwrite_table linked to the database
resource "aws_timestreamwrite_table" "temperaturesensor" {
  database_name = aws_timestreamwrite_database.iot.database_name
  table_name    = "temperaturesensor"
}