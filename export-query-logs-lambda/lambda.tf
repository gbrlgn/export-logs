data "archive_file" "create_dist_pkg" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function"
  output_path = "${path.module}/lambda_function.zip"
}

data "aws_db_instance" "db_arn" {
  db_instance_identifier = "galaxpay-prod"
}

data "aws_secretsmanager_secret" "db_secret" {
  name = "galaxpay-prod-secret"
}

resource "aws_lambda_function" "export_query" {
  function_name = "export-query-logs-${var.env}"
  role          = aws_iam_role.export_query_role.arn
  handler       = export_pi.lambda_handler
  filename      = data.archive_file.create_dist_pkg.output_path
  runtime       = "python3.9"
  timeout       = 180
  tags          = { Environment = var.env }
  env           = {
    DB_ARN    = data.aws_db_instance.db_arn.db_instance_arn
    DB_SECRET = data.aws_secretsmanager_secret.db_secret.arn
  }
}

resource "aws_lambda_permission" "export_query_invoke" {
  statement_id  = "AllowExecutionFromCloudWatchStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.export_query.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.export_query_start.arn
}

output "arn" {
  value = aws_lambda_function.export_query.arn
}
