resource "aws_iam_role" "export_pi_metrics_role" {
  name = "export_pi_metrics_role"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "export_pi_metrics_policy" {
  name = "export_pi_metrics_policy"
  role = aws_iam_role.export_pi_metrics_role.name

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "rds:*"
        ],
        "Effect": "Allow",
        "Resource": "${data.aws_db_instance.db_arn.db_instance_arn}"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "cw_full_access" {
  role       = aws_iam_role.export_pi_metrics_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}
