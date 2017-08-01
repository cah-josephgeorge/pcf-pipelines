output "broker_access_key_id" {
    value = "${aws_iam_access_key.pcf_iam_user_access_key.id}"
}

output "broker_secret_access_key" {
    value = "${aws_iam_access_key.pcf_iam_user_access_key.secret}"
}
