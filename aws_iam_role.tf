resource "aws_iam_role_policy" "lab_role_policy" {
  name   = "${var.id}_role_policy"
  role   = aws_iam_role.lab_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "ec2:DescribeTags",
            "Resource": "*"
        }
    ]
}
EOF

}

resource "aws_iam_role" "lab_role" {
  name = "${var.id}_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_instance_profile" "lab_profile" {
name = "${var.id}_profile"
role = aws_iam_role.lab_role.name
}

