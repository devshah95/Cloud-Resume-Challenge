provider "aws" {
    profile = "CloudResumeRole"
    region = "us-east-1"
}

resource "aws_s3_bucket" "frontend-bucket" {
  bucket = "cloudresumechallenge-devarshtest"
}

// test