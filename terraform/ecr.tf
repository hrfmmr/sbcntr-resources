locals {
  ecr-lifecycle-policy = {
    rules = [
      {
        action = {
          type = "expire"
        }
        description  = "Keep only one image"
        rulePriority = 1
        selection = {
          countNumber = 1
          countType   = "imageCountMoreThan"
          tagStatus   = "any"
        }
      }
    ]
  }
}

resource "aws_ecr_repository" "sbcntr" {
  for_each = {
    "frontend" = "1"
    "backend"  = "2"
  }

  name                 = "sbcntr-${each.key}"
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = "true"
  }
}

resource "aws_ecr_lifecycle_policy" "sbcntr" {
  for_each = {
    "frontend" = "1"
    "backend"  = "2"
  }
  repository = aws_ecr_repository.sbcntr[each.key].name
  policy     = jsonencode(local.ecr-lifecycle-policy)
}
