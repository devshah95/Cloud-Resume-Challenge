provider "aws" {
    profile = "CloudResumeRole"
    region = "us-east-1"
}

# resource "aws_s3_bucket" "frontend-bucket" {
#   bucket = "cloudresumechallenge-devarshtest"
# }

# resource "aws_dynamodb_table" "WebsiteVisits" {
#   name           = "WebsiteVisits"
#   billing_mode   = "PROVISIONED"
#   read_capacity  = 5
#   write_capacity = 5
#   hash_key       = "CounterID"

#   attribute {
#     name = "CounterID"
#     type = "S"
#   }
# }

# resource "null_resource" "insert_data" {
#     provisioner "local-exec" {
#       command = "AWS_PROFILE=CloudResumeRole aws dynamodb put-item --region us-east-1 --table-name ${aws_dynamodb_table.WebsiteVisits.name} --item '{\"CounterID\": {\"S\": \"visitor_count\"}, \"count\": {\"N\": \"0\"}}'"
#     }
#     depends_on = [aws_dynamodb_table.WebsiteVisits]
# }

