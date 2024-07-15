variable "bucket_name" {
  description = "Name of the S3 bucket"
  type = string 
}

variable "region" {
  description = "AWS region to create the resource in"
  type = string
}

variable "domain_name" {
  description = "Domain name for the CloudFront distribution"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Zone ID for the Cloudflare domain"
  type        = string
}

variable "cloudflare_api_token" {
  description = "API token for Cloudflare account"
  type        = string
  sensitive   = true
}
