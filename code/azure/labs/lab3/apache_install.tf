
# Null Resource for Apache Installation
resource "null_resource" "provision_apache" {
  depends_on = [azurerm_linux_virtual_machine.vm]

  # Trigger to force rerun whenever timestamp changes
  triggers = {
    always_run = timestamp()
  }





  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y apache2",
      "echo '<h1>Welcome to \"${data.azurerm_virtual_machine.computer_name.name}\" Web Server for jb!</h1>' | sudo tee /var/www/html/welcome.html",
      "sudo systemctl start apache2",
      "sudo systemctl enable apache2"
    ]

    connection {
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
      host     = data.azurerm_public_ip.example.ip_address
      timeout  = "1m"
    }
  }
}
# Define a data source to fetch an existing Azure Public IP
  data "azurerm_virtual_machine" "computer_name" {
    name                = "vm-yanivc"
    resource_group_name = "rg-yanic"
  }

# Reference the IP address later in the configuration
  output "yanicmac" {
    value = data.azurerm_virtual_machine.computer_name
  }
# Updated Output for Server Information to use data source
output "server_info" {
  value       = "Please browse: http://${data.azurerm_public_ip.example.ip_address}/welcome.html"
  description = "Browse the above link"
}