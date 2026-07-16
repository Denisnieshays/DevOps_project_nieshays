# Это клиент, поэтому server = false
server = false

# Уникальное имя узла (для каждой VM будет разное!)
node_name = "client-node"

# Адрес для подключения к этому клиенту
advertise_addr = "192.168.56.11"

# Локальный интерфейс
bind_addr = "enp0s8"

datacenter = "dc1"
data_dir = "/opt/consul"

# Автоматическое подключение к серверу Consul
retry_join = ["192.168.56.10"]