resource "aws_kinesis_stream" "tf-kinesis-hella" {
  name             = "tf-kinesis-hella"
  shard_count      = 1
  retention_period = 48
  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]
  tags = {
    Environment = "test"
  }
}

resource "aws_s3_bucket" "tf-bucket-hellabessaoud2" {
  bucket = "tf-bucket-hellabessaoud2"
  acl    = "private"
}

resource "aws_iam_role" "firehose_role_hella" {
  name = "firehose_role_hella"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "firehose-stream-policy" {
  name = "firehose-stream-policy"
  role = "${aws_iam_role.firehose_role_hella.id}"

 policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
       {
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:GetShardIterator",
                "kinesis:GetRecords",
                "kinesis:ListShards"
            ],
            "Resource": "*"
        },
	    {
            "Effect": "Allow",
            "Action":[
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],   
            "Resource": [        
                "arn:aws:s3:::tf-bucket-hellabessaoud2",
                "arn:aws:s3:::tf-bucket-hellabessaoud2/*"		    
            ]    
            
      },
{
           "Effect": "Allow",
           "Action": [
               "kms:Decrypt",
               "kms:GenerateDataKey"
           ],
           "Resource": [
               "arn:aws:kms:eu-west-1:267535810682:access_key/secret_key"           
           ],
           "Condition": {
               "StringEquals": {
                   "kms:ViaService": "s3.eu-west-1.amazonaws.com"
               },
               "StringLike": {
                   "kms:EncryptionContext:aws:s3:arn": "arn:aws:s3:::tf-bucket-hellabessaoud2/prefix*"
               }
           }
        },
        {
           "Effect": "Allow",
           "Action": [
               "logs:PutLogEvents"
           ],
           "Resource": [
               "arn:aws:logs:eu-west-1:267535810682:log-group:log-group-name:log-stream:log-stream-name"
           ]
        }
 ]     
}
EOF
}


resource "aws_kinesis_firehose_delivery_stream" "firehose-stream-hella" {
  name        = "firehose-stream-hella"
  destination = "s3"

  s3_configuration {
    role_arn   = "${aws_iam_role.firehose_role_hella.arn}"
    bucket_arn = "${aws_s3_bucket.tf-bucket-hellabessaoud2.arn}"	
    buffer_size = 10
    buffer_interval = 400
  }
}

resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name = "mydbtp"
}

resource "aws_glue_crawler" "example" {
  database_name = aws_glue_catalog_database.aws_glue_catalog_database.name
  name          = "glue_tp"
  role          = aws_iam_role.glue.arn

  s3_target {
    path = "s3://${aws_s3_bucket.tf-bucket-hellabessaoud2.bucket}"
  }
}

resource "aws_iam_role" "glue" {
  name = "AWSGlueServiceRoleDefault"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_s3_bucket" "hoge" {
  bucket = "hoge"
}

resource "aws_athena_database" "hoge" {
  name   = "athenadb"
  bucket = aws_s3_bucket.hoge.bucket
}