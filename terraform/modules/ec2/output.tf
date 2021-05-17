output "server_ip" {

  value = length(aws_eip.eip) > 0 ? aws_eip.eip.public_ip : ""
}
output "private_ip" {

  value = length(aws_instance.ud_server) > 0 ? aws_instance.ud_server.private_ip : ""
}
