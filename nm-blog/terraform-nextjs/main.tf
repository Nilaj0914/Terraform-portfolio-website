#s3 Bucket Resource
resource "aws_s3_bucket" "website" {
  bucket = "nilaj-terraform-website"

  tags = {
    Name = "Portfolio Website"
    Enviroment = "Production"
  }
}

# Ownership Control
resource "aws_s3_bucket_ownership_controls" "website_ownership_control" {
  bucket = aws_s3_bucket.website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Bucket public access
resource "aws_s3_bucket_public_access_block" "website_public_access_block" {
  bucket = aws_s3_bucket.website.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

#Bucket ACL
resource "aws_s3_bucket_acl" "website_bucket_acl" {
  bucket = aws_s3_bucket.website.id
  depends_on = [ 
    aws_s3_bucket_ownership_controls.website_ownership_control,
    aws_s3_bucket_public_access_block.website_public_access_block
   ]
   acl = "public-read"
}

# website index document configuration
resource "aws_s3_bucket_website_configuration" "website-policy" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }
  
  error_document {
    key = "index.html"
  }
}

# S3 Bucket Policy Resource
resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.website.id

  policy = jsondecode(({
    Version = "2012-10-17"
    Statement = [
        {
            Sid = "PublicReadGetObject"
            Effect = "Allow"
            Principal = "*"
            Action = "s3:GetObject"
            Resource = "${aws_s3_bucket.website.arn}/*"
        }
    ]
  }))
}

# Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "Website_OAI" {
  comment = "OAI for NextJS portfolio site"
}

#Cloudfront Distribution
resource "aws_cloudfront_distribution" "website_distribution" {
  
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id = "S3-website-bucket"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.Website_OAI.cloudfront_access_identity_path
    }
  }

  enabled = true
  is_ipv6_enabled = true
  comment = "Next.js portfolio site"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods = [ "GET", "HEAD" ]
    target_origin_id = "S3-Website"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = none
    }
  }

  viewer_certificate {
    
    cloudfront_default_certificate = true
    
  }
}