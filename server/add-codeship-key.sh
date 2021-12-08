# Add Codeship Key
echo "${1} ${2} ${3}" | sudo tee -a /home/codeship/.ssh/authorized_keys >/dev/null
