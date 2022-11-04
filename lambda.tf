module "export-pi-metrics-lambda" {
    source = "./export-pi-metrics-lambda"
    enabled = local.workspace.lambda.enabled
    env = local.workspace.lambda.env
}