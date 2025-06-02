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

