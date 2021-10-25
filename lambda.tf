# data "aws_subnet_ids" "efs_public_subnets" {
#   vpc_id = aws_vpc.efsvpc.id
# }


resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "ffmpeg.zip"
  layer_name = "ffmpeg"

  compatible_runtimes = ["nodejs12.x"]
}

resource "aws_lambda_function" "lambda_example" {
  
  function_name = "video-processing-example"
  filename      = "test.zip"
  role          = aws_iam_role.lambda_efs.arn
  
  layers        = [aws_lambda_layer_version.lambda_layer.arn]
  handler       = "demo.handler"
  runtime       = "nodejs12.x"
  memory_size   = "512"
  publish       = true

  file_system_config {
    
    arn = aws_efs_access_point.efs_access_point.arn

    
    local_mount_path = "/mnt/access"
  }
  
  #count              = length(slice(local.az_names, 0, 2))

  vpc_config {
    
    
    subnet_ids         = [aws_subnet.efs_public[0].id,aws_subnet.efs_public[1].id]
    security_group_ids = [aws_security_group.efs_access_sg.id]
  }

  
  depends_on = [aws_efs_mount_target.efs_mount]

  
}