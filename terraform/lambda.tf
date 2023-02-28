# aws_lambda_function to control air conditioner

resource "aws_lambda_function" "ac_control_lambda" {
  filename      = "files/empty_package.zip"
  function_name = "ac_control_lambda"
  handler       = "ac_control_lambda.lambda_handler"
  runtime       = "python3.7"
  role = aws_iam_role.lambda_role.arn   
}


# aws_cloudwatch_event_rule scheduled action every minute

resource "aws_cloudwatch_event_rule" "every_one_minute" {
  name                = "every_one_minute"
  description         = "An example CloudWatch event rule"
  schedule_expression = "rate(1 minute)"
}


# aws_cloudwatch_event_target to link the schedule event and the lambda function

resource "aws_cloudwatch_event_target" "example_target" {
  rule      = aws_cloudwatch_event_rule.example_rule.name
  target_id = "lambda"
  arn       = aws_lambda_function.ac_control_lambda.arn
}


# aws_lambda_permission to allow CloudWatch (event) to call the lambda function

resource "aws_lambda_permission" "example_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ac_control_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_one_minute.arn
}
