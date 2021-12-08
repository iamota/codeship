# Add Codeship Key
echo "${1}" | sudo tee -a /home/codeship/.ssh/authorized_keys >/dev/null
