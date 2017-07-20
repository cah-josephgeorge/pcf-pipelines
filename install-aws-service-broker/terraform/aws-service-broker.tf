# Users
resource "aws_iam_user" "pcf_aws_service_broker_iam_user" {
  name = "${var.prefix}_pcf_aws_service_broker_iam_user"
  path = "/system/"
}
resource "aws_iam_access_key" "pcf_iam_user_access_key" {
  user = "${aws_iam_user.pcf_aws_service_broker_iam_user.name}"
}
resource "aws_iam_user_policy_attachment" "PCFInstallationPolicy_role_attach" {
  user = "${aws_iam_user.pcf_aws_service_broker_iam_user.name}"
  policy_arn = "${aws_iam_policy.PCFInstallationPolicy.arn}"
}

# Policies
resource "aws_iam_policy" "PCFInstallationPolicy" {
  name = "${var.prefix}_PCFInstallationPolicy"
  description = "Installation Policy for PCF"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:PutBucketAcl",
          "s3:PutBucketLogging",
          "s3:PutBucketTagging",
          "s3:GetObject",
          "s3:ListBucket",
          "iam:CreateAccessKey",
          "iam:CreateUser",
          "iam:GetUser",
          "iam:DeleteAccessKey",
          "iam:DeleteUser",
          "iam:DeleteUserPolicy",
          "iam:ListAccessKeys",
          "iam:ListAttachedUserPolicies",
          "iam:ListUserPolicies",
          "iam:ListPolicies",
          "iam:PutUserPolicy",
          "iam:GetPolicy",
          "iam:GetAccountAuthorizationDetails",
          "rds:CreateDBCluster",
          "rds:CreateDBInstance",
          "rds:DeleteDBCluster",
          "rds:DeleteDBInstance",
          "rds:DescribeDBClusters",
          "rds:DescribeDBInstances",
          "rds:DescribeDBSnapshots",
          "rds:DeleteDBSnapshot",
          "rds:CreateDBParameterGroup",
          "rds:ModifyDBParameterGroup",
          "rds:DeleteDBParameterGroup",
          "dynamodb:ListTables",
          "dynamodb:DeleteTable",
          "dynamodb:DescribeTable",
          "sqs:CreateQueue",
          "sqs:DeleteQueue"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "PCFAppDeveloperPolicy-s3" {
  name = "${var.prefix}_PCFAppDeveloperPolicy-s3"
  description = "Service Broker for AWS Service Key policy for S3"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "allowtagging",
      "Effect": "Allow",
      "Action": [
          "s3:GetBucketTagging",
          "s3:PutBucketTagging"
      ],
      "Resource": [
          "arn:aws:broker:resource::"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "PCFAppDeveloperPolicy-sqs" {
  name = "${var.prefix}_PCFAppDeveloperPolicy-sqs"
  description = "Service Broker for AWS Service Key policy for SQS"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1471890189000",
      "Effect": "Allow",
      "Action": [
          "sqs:ListQueues",
          "sqs:PurgeQueue",
          "sqs:ReceiveMessage",
          "sqs:SendMessage"
      ],
      "Resource": [
          "arn:aws:broker:resource::"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "PCFAppDeveloperPolicy-dynamodb" {
  name = "${var.prefix}_PCFAppDeveloperPolicy-dynamodb"
  description = "Service Broker for AWS Service Key policy for DynamoDB"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1471873911000",
      "Effect": "Allow",
      "Action": [
          "dynamodb:*"
      ],
      "Resource": [
          "arn:aws:broker:resource::"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "PCFAppDeveloperPolicy-rds" {
  name = "${var.prefix}_PCFAppDeveloperPolicy-rds"
  description = "Service Broker for AWS Service Key policy for RDS"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1471636048000",
      "Effect": "Allow",
      "Action": [
          "rds:ListTagsForResource",
          "rds:DescribeDbInstances"
      ],
      "Resource": [
          "arn:aws:broker:resource::"
      ]
    }
  ]
}
EOF
}
