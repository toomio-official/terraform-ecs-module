output "alb_url" {
  description = "Application Load Balancer URL"
  value       = aws_alb.application_load_balancer.dns_name
}