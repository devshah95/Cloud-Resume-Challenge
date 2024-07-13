provider "aws" {
  profile = "CloudResumeRole"
  region  = var.region
}

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "aws_s3_bucket" "frontend-bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "frontend-bucket-public-access-block" {
  bucket = aws_s3_bucket.frontend-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "frontend-bucket-website" {
  bucket = aws_s3_bucket.frontend-bucket.bucket
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "frontend-bucket-policy" {
  bucket = aws_s3_bucket.frontend-bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.frontend-bucket.id}/*"
      }
    ]
  })
}

# Create a basic HTML file
resource "local_file" "index_html" {
  filename = "${path.module}/index.html"
  content  = <<-EOF
    <!DOCTYPE html>
    <html>
    <head>
        <title>Welcome to CloudResume</title>
    </head>
    <body>
        <h1>Welcome to CloudResume</h1>
        <p>This is a simple static website hosted on Amazon S3.</p>
    </body>
    </html>
  EOF
}

# Upload the HTML file to S3
resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.frontend-bucket.bucket
  key    = "index.html"
  source = local_file.index_html.filename
}

locals {
  s3_bucket_endpoint = "https://${var.bucket_name}.s3.${var.region}.amazonaws.com"
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      type    = dvo.resource_record_type
      value   = dvo.resource_record_value
      zone_id = var.cloudflare_zone_id
    }
  }

  zone_id = each.value.zone_id
  name    = each.value.name
  type    = each.value.type
  value   = each.value.value
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.resource_record_name]
  
  depends_on = [cloudflare_record.cert_validation]
}

resource "time_sleep" "wait_for_validation" {
  depends_on = [aws_acm_certificate_validation.cert_validation]
  create_duration = "5m"  # Waits for 5 minutes to allow DNS propagation and validation
}

locals {
  s3_origin_id = "S3-frontend-origin"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Access identity for S3 bucket"
}

resource "aws_cloudfront_distribution" "frontend_distribution" {
  depends_on = [time_sleep.wait_for_validation]

  origin {
    domain_name = aws_s3_bucket.frontend-bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for CloudResume S3 bucket"

  aliases = [var.domain_name]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"  # Ensure this matches your SSL configuration
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.cert.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
    cloudfront_default_certificate = false
  }
}

resource "cloudflare_record" "validation" {
  zone_id = var.cloudflare_zone_id
  name    = var.domain_name
  value   = aws_cloudfront_distribution.frontend_distribution.domain_name
  type    = "CNAME"
  ttl     = 1
  proxied = true 
}

resource "null_resource" "set_ssl_mode" {
  provisioner "local-exec" {
    command = <<EOT
      curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${var.cloudflare_zone_id}/settings/ssl" \
      -H "Authorization: Bearer ${var.cloudflare_api_token}" \
      -H "Content-Type: application/json" \
      --data '{"value":"strict"}'
    EOT
  }
  depends_on = [cloudflare_record.validation]
}

output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.frontend_distribution.domain_name
}

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
#   provisioner "local-exec" {
#     command = "AWS_PROFILE=CloudResumeRole aws dynamodb put-item --region us-east-1 --table-name ${aws_dynamodb_table.WebsiteVisits.name} --item '{\"CounterID\": {\"S\": \"visitor_count\"}, \"count\": {\"N\": \"0\"}}'"
#   }
#   depends_on = [aws_dynamodb_table.WebsiteVisits]
# }
