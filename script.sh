#!/bin/bash

# This script automates the web reconnaissance process using various tools

# Check if both url and email arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 url email" >&2
    exit 1
fi

# Define the target domain and organization
TARGET_DOMAIN=$1
EMAIL=$2
ORG=$(echo $1 | cut -d '/' -f 3)

#Use Sublist3r to gather subdomains
echo "[*] Gathering subdomains with Sublist3r"
sublist3r -d $TARGET_DOMAIN -o subdomains.txt
awk '!x[$0]++' subdomains.txt > subdomains-new.txt

#Use Subfinder to gather additional subdomains
echo "[*] Gathering additional subdomains with Subfinder"
subfinder -d $TARGET_DOMAIN -o subdomains.txt
awk '!x[$0]++' subdomains.txt > subdomains-new.txt

#Use MassDNS to resolve subdomains to IP addresses
echo "[*] Resolving subdomains to IP addresses with MassDNS"
massdns -r /home/kali/MassDNS/massdns/lists/resolvers.txt -t A -o S subdomains-new.txt | awk '{print $3}' > ips.txt
awk '!x[$0]++' ips.txt > ips-new.txt
# Use nmap to perform port scanning on the IP addresses 
#echo "[*] Performing port scanning with rustscan"
#rustscan --range 1-65535 -a -iL ips.txt -- -A -sC -sV -oA nmap.txt

$html_file='table.html'

#Use dirsearch to find directories and files
#echo "[*] Searching for directories and files with dirsearch"
cat subdomains-new.txt | xargs -I % bash -c "sudo dirsearch -u http://% -e html,php,txt -t 50 -w /usr/share/wordlists/seclists/Discovery/Web-Content/common.txt -x 403,404,400 -r -o dirsearch.txt"
echo "<h1>Directories Discovered Report</h1>" >> table.html
echo "<tr><th>Subdomain</th><th>Directories</th></tr>" >> table.html
while read subdomain; do
 directories=$(grep -E "^/.*" dirsearch.txt | sed 's/^\///' | sort -u | tr '\n' ',')
 echo "<tr><td>$subdomain</td><td>$directories</td></tr>" >> table.html
done < subdomains-new.txt
echo "</table>" >> table.html

# Use FFuF to perform fuzzing
#echo "[*] Fuzzing with FFuF"
#cat subdomains.txt | xargs -I % bash -c "ffuf -w /usr/share/wordlists/seclists/Discovery/Web-Content/common.txt -u http://%/FUZZ -e html,php,txt -t 50 -mc 200,301,302,303,307,401,403,404,500 -o ffuf.txt"

echo "<h1>Historical URLs Report</h1>" >> "$html_file"
# Run command and append results to waybackurls.txt
cat subdomains-new.txt | xargs -I % bash -c "waybackurls % | sort -u >> waybackurls.txt"
echo "<table border='1'><tr><th>Subdomain</th><th>Waybackurls</th></tr></table>" >> table.html
# Loop through subdomains and append waybackurls to table
while read subdomain; do
    waybackurls=$(grep -oP "(?<=^$subdomain/).*$" waybackurls.txt | sort -u)
    if [ -n "$waybackurls" ]; then
        sed -i "s|<tr><td>$subdomain</td><td></td></tr>|<tr><td>$subdomain</td><td>$waybackurls</td></tr><tr><td>$subdomain</td><td></td></tr>|g" waybackurls.html
    fi
done < subdomains-new.txt



# Use vulners to perform vulnerability scanning
echo "[*] Scanning for vulnerabilities with vulners"
#cat ips.txt | xargs -I % bash -c "python3 /path/to/vulners.py -i % -o vulners.txt"
nmap -sV --script vulners --script-args mincvss=5.0 -iL ips-new.txt -oA vulners.txt

# Use GetJS to gather JavaScript files
echo "<h1>JavaScript Files Found Report</h1>" >> "$html_file"
echo "[*] Gathering JavaScript files with GetJS"
SUBDOMAINS_FILE="subdomains-new.txt"
OUTPUT_FILE="getjs.txt"
HTML_FILE="table.html"
cat "$SUBDOMAINS_FILE" | xargs -I % bash -c "getJS --url http://% --output $OUTPUT_FILE"
echo "<table>" > "$HTML_FILE"
echo "<tr><th>Subdomain</th><th>JavaScript File</th></tr>" >> "$HTML_FILE"

while read -r subdomain; do
  while read -r js_file; do
    echo "<tr><td>$subdomain</td><td>$js_file</td></tr>" >> "$HTML_FILE"
  done < <(grep -Po '(?<=\[\*\]\s).+' "$OUTPUT_FILE")
done < "$SUBDOMAINS_FILE"
echo "</table>" >> "$HTML_FILE"


# Use XSSHunter to test for XSS vulnerabilities
#echo "[*] Testing for XSS vulnerabilities with XSSHunter"
#cat subdomains-new.txt | xargs -I % bash -c "python3 XSStrike/xsstrike.py --timeout 1 -u http://% >> xssstrike.txt"

# Use SQLMap to test for SQL injection vulnerabilities
echo "[*] Testing for SQL injection vulnerabilities with SQLMap"
cat subdomains-new.txt | xargs -I % bash -c "sqlmap -u http://% --level=5 --risk=3 --batch --output-dir sqlmap"

# Use XXEInjector to test for XXE vulnerabilities
#echo "[*] Testing for XXE vulnerabilities with XXEInjector"
#cat subdomains.txt | xargs -I % bash -c "ruby XXEinjector/XXEinjector.rb --rhost=http://% -o xxe"

# Define the output file
OUTPUT_FILE="table.html"
# Check if the output file exists, if not create it with the HTML header
echo "<h1>XSS Vulnerability Report</h1>" >> "$html_file"
echo "<table><tr><th>Subdomain</th><th>XSS Parameter</th></tr>" >> "$OUTPUT_FILE"

# Loop through each subdomain in the subdomains-new.txt file
while read subdomain; do
    echo "Scanning $subdomain for XSS vulnerabilities..."
    # Run XSStrike against the subdomain
    output=$(python3 XSStrike/xsstrike.py --timeout 1 -u "http://$subdomain")

    # Check if any vulnerable parameters were found
    if echo "$output" | grep -q "Potentially vulnerable"; then
        # Extract the vulnerable parameters and add them to the HTML table
        echo "$output" | grep -oP "Parameter: \K.*" | while read parameter; do
            echo "<tr><td>$subdomain</td><td>$parameter</td></tr>" >> "$OUTPUT_FILE"
        done
    fi
done < subdomains-new.txt

# Close the HTML table and body
echo "</table>" >> "$OUTPUT_FILE"

echo "[*] Testing for SSRF vulnerabilities with SSRFDetector"
#cat subdomains-new.txt | xargs -I % bash -c "ssrftool -domains http://% -o ssrfdetector.txt"

subdomains="subdomains-new.txt"
output="ssrfdetector.txt"
html_file="tables.html"
table_headers="<tr><th>Subdomain</th><th>SSRF Vulnerabilities</th></tr>"
table_rows=""

while read subdomain; do
    echo "Running SSRF detector on $subdomain ..."
    ssrftool -domains "http://$subdomain" -o "$output"

    if grep -q "Potential SSRF found" "$output"; then
        vulnerabilities=$(grep -Po '(?<=URL: ).*' "$output" | sort -u | paste -sd ',')
        table_rows+="<tr><td>$subdomain</td><td>$vulnerabilities</td></tr>"
    fi
done < "$subdomains"

# Generate HTML report

echo "<h1>SSRF Vulnerability Report</h1>" >> "$html_file"
$table_headers >> "$html_file"
$table_rows >>"$html_file"

#echo "[*] Gathering information about exposed git repositories with GitTools"
#cat subdomains.txt | xargs -I % bash -c "python3 /path/to/gittools.py -u http://% -o gittools.txt"

echo "[*] Searching for sensitive information in git repositories with gitallsecrets"
html_file="table.html"
table_title="Git Secrets"
echo "<h1>$table_title</h1><table border='1'><tr><th>Subdomain</th><th>Git Secrets</th></tr>" >> $html_file
while read subdomain; do
    # run gitallsecrets and store output in a variable
    gitsecrets=$(sudo docker run -it abhartiya/tools_gitallsecrets -token=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 -org=$ORG -output - $subdomain)

    # check if gitsecrets output is not empty
    if [[ ! -z "$gitsecrets" ]]; then
        # append subdomain and gitsecrets to HTML table
        echo "<tr><td>$subdomain</td><td><pre>$gitsecrets</pre></td></tr>" >> $html_file
    fi
done < subdomains-new.txt

#cat subdomains-new.txt | xargs -I % bash -c "sudo docker run -it abhartiya/tools_gitallsecrets -token=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 -org=$ORG -output gitallsecrets.txt"

# echo "[*] Testing for CORS vulnerabilities with CORStest"
# cat subdomains.txt | xargs -I % bash -c "python3 /path/to/corstest.py -u http://% -o corstest.txt"

echo "[*] Testing for hidden vulnerable parameter with Arjun"
html_file="table.html"
#cat subdomains-new.txt | xargs -I % bash -c "arjun --stable -u http://% -o arjun.txt"
vulnerable_params = re.findall(r"\[Vulnerable\] \[.*\] (.*)\?.*=(.*)", arjun_output)

# create an HTML table with the results
table = "<table>\n<tr><th>Subdomain</th><th>Parameter</th><th>Value</th></tr>\n"
while read subdomain; do
    for param, value in vulnerable_params:
        if subdomain in param:
            table += f"<tr><td>{subdomain}</td><td>{param}</td><td>{value}</td></tr>\n"
table += "</table>"

echo "[*] Taking screenshots with Eyewitness"
eyewitness -d imgs -f subdomains-new.txt 
echo "[*] Summary of the results:"
echo " - Subdomains: $(cat subdomains.txt | wc -l)"
echo "<table>\n<tr><th>No of Subdomain</th><th>$(cat subdomains-new.txt | wc -l)</th></tr>\n" >> $html_file
echo " - IP addresses: $(cat ips.txt | wc -l)"
echo "<table>\n<tr><th>IP addresses found</th><th>$(cat ips-new.txt | wc -l)</th></tr>\n" >> $html_file
echo " - Directories and files found: $(cat dirsearch.txt | wc -l)"
echo "<table>\n<tr><th>Directories found</th><th>$(cat dirsearch.txt | wc -l)</th></tr>\n" >> $html_file
#echo " - URLs found: $(cat ffuf.txt | wc -l)"
echo " - Archived content found: $(cat waybackurls.txt | wc -l)"
echo "<table>\n<tr><th>Historical URLs Found</th><th>$(cat waybackurls.txt | wc -l)</th></tr>\n" >> $html_file
#echo " - Vulnerabilities found: $(cat vulners.txt | wc -l)"
echo " - JavaScript files found: $(cat getjs.txt | wc -l)"
echo "<table>\n<tr><th>JavaScripts Files Found</th><th>$(cat getjs.txt | wc -l)</th></tr>\n" >> $html_file
echo " - XSS vulnerabilities found: $(cat xsshunter.txt | wc -l)"
echo "<table>\n<tr><th>XSS Vulnerabilities Found</th><th>$(cat xsshunter.txt | wc -l)</th></tr>\n" >> $html_file
echo " - SQL injection vulnerabilities found: $(grep -r "Vulnerability found" sqlmap | wc -l)"
#echo " - XXE vulnerabilities found: $(cat xxe.txt | wc -l)"
echo " - SSRF vulnerabilities found: $(cat ssrfdetector.txt | wc -l)"
echo "<table>\n<tr><th>SSRF Vulnerabilities found</th><th>$(cat ssrfdetector.txt | wc -l)</th></tr>\n" >> $html_file
#echo " - Exposed git repositories found: $(cat gittools.txt | wc -l)"
echo " - Sensitive information found in git repositories: $(cat gitallsecrets.txt | wc -l)"
echo "<table>\n<tr><th>Sensitive information found in git repositories</th><th>$(cat gitallsecrets.txt | wc -l)</th></tr>\n" >> $html_file
echo " - Hidden vulnerable parameters found: $(cat arjun.txt | wc -l)"
echo "<table>\n<tr><th>Hidden vulnerable parameters found</th><th>$(cat arjun.txt | wc -l)</th></tr>\n" >> $html_file
#echo " - CORS vulnerabilities found: $(cat corstest.txt | wc -l)"
echo " - Screenshots taken: $(ls eyewitness | wc -l)"
echo "<table>\n<tr><th>Screenshot Taken</th><th>$(ls eyewitness | wc -l)</th></tr>\n" >> $html_file

python3 mail.py $EMAIL
