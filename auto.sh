#!/bin/bash

# Comprehensive Linux Hardening Script

# Function to execute a command and handle errors
execute_command() {
    echo "Executing: $1"
    eval $1
    if [ $? -ne 0 ]; then
        echo "Error executing: $1"
        exit 1
    fi
}

# 1. Check system log files
echo "Checking system log files..."
execute_command "sudo cat /var/log/*"
execute_command "sudo cat /home/*/.bash_history"
execute_command "sudo cat /home/*/.sh_history"

# 2. Check installed software and remove unnecessary ones
echo "Checking installed software..."
execute_command "sudo apt-get install synaptic -y"
execute_command "sudo synaptic"

# 3. Secure root
echo "Securing root access..."
execute_command "sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config"

# 4. Disable the guest user
echo "Disabling guest user..."
execute_command "sudo usermod -L guest"

# 5. Audit user accounts
echo "Auditing user accounts..."
execute_command "awk -F: '($3 == \"0\"){print}' /etc/passwd"  # Should only return root
execute_command "ls -l /etc/passwd"  # Should only return root

# 6. Delete unauthorized users
# Example: sudo userdel -r unauthorized_user
# execute_command "sudo userdel -r $user"

# 7. Enforce strong password policy
echo "Enforcing strong password policy..."
execute_command "sudo apt-get install libpam-cracklib -y"
execute_command "sudo sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 90/' /etc/login.defs"
execute_command "sudo sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 0/' /etc/login.defs"
execute_command "sudo sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE 7/' /etc/login.defs"
execute_command "sudo sed -i 's/pam_unix.so/pam_unix.so remember=5 minlen=8/' /etc/pam.d/common-password"
execute_command "sudo sed -i 's/pam_cracklib.so/pam_cracklib.so ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/' /etc/pam.d/common-password"
execute_command "echo 'auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800' | sudo tee -a /etc/pam.d/common-auth"

# 8. Check user groups
echo "Checking user groups..."
execute_command "cat /etc/group"

# 9. Enable firewall
echo "Enabling firewall..."
execute_command "sudo apt-get install ufw -y"
execute_command "sudo ufw enable"
execute_command "sudo ufw status"

# 10. Install and run anti-malware/rootkit checkers
echo "Installing and running rootkit checkers..."
execute_command "sudo apt-get install rkhunter chkrootkit -y"
execute_command "sudo chkrootkit"
execute_command "sudo rkhunter --check"

# 11. Secure cron jobs
echo "Securing cron jobs..."
execute_command "sudo chown -R root:root /etc/*cron*"
execute_command "sudo chmod -R 600 /etc/*cron*"
execute_command "sudo chown -R root:root /var/spool/cron"
execute_command "sudo chmod -R 600 /var/spool/cron"
execute_command "sudo vim -p /etc/*crontab"
execute_command "sudo vim -p /etc/*cron*/*"

# 12. Update all packages
echo "Updating all packages..."
execute_command "sudo apt-get update"
execute_command "sudo apt-get upgrade -y"

# 13. Check for world-writable directories and files
echo "Checking for world-writable directories..."
execute_command "sudo find / -xdev -type d \\( -perm -0002 -a ! -perm -1000 \\) -print"
execute_command "sudo find / -xdev -type f -perm -0002 -print"

# 14. Check for unauthorized media
echo "Checking for unauthorized media files..."
# Example: sudo find / -name "*.filetype" -type f
# execute_command "sudo find / -name '*.filetype' -type f"

# 15. Check SSH failed attempts
echo "Checking SSH failed attempts..."
execute_command "grep sshd.*Failed /var/log/auth.log"

# 16. Check /etc/hosts file
echo "Checking /etc/hosts file..."
execute_command "cat /etc/hosts"

# 17. Check running services
echo "Checking running services..."
execute_command "service --status-all"

# 18. Close unnecessary ports
echo "Checking active ports..."
execute_command "sudo ss -ln"

# 19. Disable automounting (optional)
echo "Disabling automounting..."
# Modify appropriate settings in /etc/fstab or relevant configurations

# Finalize
echo "Linux hardening script completed successfully."
