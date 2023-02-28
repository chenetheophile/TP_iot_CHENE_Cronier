# aws_dynamodb_table

resource "aws_dynamodb_table" "Temperature" {
  name = "Temperature"
  hash_key = "id"
  billing_mode = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  attribute {
    name = "id"
    type = "S"
  }
}