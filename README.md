# 403Bypass
Help to bypass 403

Customized for personal use. 
# Resource Used:
https://github.com/iamj0ker/bypass-403<br />
https://github.com/LucasPDiniz/403-Bypass<br />
https://github.com/PortSwigger/403-bypasser<br />

May be not completely useful but I had funny copying and pasting it.

# Special thanks to Chatgpt.

# TODO:
sudo apt install jq -y<br />
git clone https://github.com/dipakthapamagar/403Bypass.git<br />
cd 403Bypass<br />
chmod +x 403bypass.sh<br />
./403bypass.sh -u URL -p PATH <br />

# Usage:
kali@kali:$./403bypass.sh -h<br />
Usage: 403bypass.sh [OPTIONS]<br />
<br />
This script tests various HTTP methods against a given URL and resource to check for potential bypass techniques.<br />
<br />
Options:<br />
  -h, --help        Show this help message.<br />
  -v, --version     Show the version of the script.<br />
  -u, --url URL     Specify the base URL (e.g., http://example.com).<br />
  -p, --path PATH   Specify the resource or endpoint (e.g., path/to/resource, without / at the beginning).<br />
  
# Example:
./403bypass.sh -u https://nodomainyesdomainwhatdomain.anydomain.com -p nodirectoryyesdirectorywhatdirectory
