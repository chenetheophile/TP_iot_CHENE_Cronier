# aws_iam_role iot_role
resource "aws_iam_role" "iot_role" {
  name = "iot_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "iot.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# aws_iam_role_policy iam_policy_for_dynamodb

resource "aws_iam_role_policy" "iam_policy_for_dynamodb" {
  name = "dynamodb_access_policy"
  role = aws_iam_role.iot_role.name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "dynamodb:PutItem"
        Resource = "*"
      }
    ]
  })
}


# aws_iam_role_policy iam_policy_for_timestream_writing

resource "aws_iam_role_policy" "iam_policy_for_timestream_writing" {
  name = "iot_role_policy"
  role = aws_iam_role.iot_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = "timestream:WriteRecords",
        Resource = aws_timestreamwrite_table.temperaturesensor.arn
      },
      {
        Effect = "Allow",
        Action = "timestream:DescribeEndpoints",
        Resource = "*"
      }
    ]
  })
}

# aws_iam_role lambda_role

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


# aws_iam_role_policy iam_policy_for_timestream_reading for Lambda
resource "aws_iam_role_policy" "iam_policy_for_timestream_reading" {
  name = "lambda_role_policy"
  role = aws_iam_role.lambda_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "timestream:Select"
        Resource = aws_timestreamwrite_table.temperaturesensor.arn
      },
      {
        Effect = "Allow"
        Action = "timestream:DescribeEndpoints"
        Resource = "*"
      }
    ]
  })
}


# aws_iam_role_policy iam_policy_for_iot_publishing for Lambda

resource "aws_iam_role_policy" "iam_policy_for_iot_publishing" {
  name = "lambda_role_policy"
  role = aws_iam_role.lambda_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "iot:Publish"
        Resource = "*"
      }
    ]
  })
}



###########################################################################################
# Enable the following resource to enable logging for IoT Core (helps debug)
###########################################################################################

#resource "aws_iam_role_policy" "iam_policy_for_logs" {
#  name = "cloudwatch_policy"
#  role = aws_iam_role.iot_role.id
#
#  policy = <<EOF
#{
#        "Version": "2012-10-17",
#        "Statement": [
#            {
#                "Effect": "Allow",
#                "Action": [
#                    "logs:CreateLogGroup",
#                    "logs:CreateLogStream",
#                    "logs:PutLogEvents",
#                    "logs:PutMetricFilter",
#                    "logs:PutRetentionPolicy"
#                 ],
#                "Resource": [
#                    "*"
#                ]
#            }
#        ]
#    }
#EOF
#}


###########################################################################################
# Enable the following resources to enable logging for your Lambda function (helps debug)
###########################################################################################

#resource "aws_cloudwatch_log_group" "example" {
#  name              = "/aws/lambda/${aws_lambda_function.ac_control_lambda.function_name}"
#  retention_in_days = 14
#}
#
#resource "aws_iam_policy" "lambda_logging" {
#  name        = "lambda_logging"
#  path        = "/"
#  description = "IAM policy for logging from a lambda"
#
#  policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": [
#        "logs:CreateLogGroup",
#        "logs:CreateLogStream",
#        "logs:PutLogEvents"
#      ],
#      "Resource": "arn:aws:logs:*:*:*",
#      "Effect": "Allow"
#    }
#  ]
#}
#EOF
#}
#
#resource "aws_iam_role_policy_attachment" "lambda_logs" {
#  role       = aws_iam_role.lambda_role.name
#  policy_arn = aws_iam_policy.lambda_logging.arn
#}
