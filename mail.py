import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication
import sys

recipient_email = sys.argv[1]

# SMTP server details for Outlook
smtp_server = "smtp.office365.com"
port = 587
username = "faizankce120@gst.sies.edu.in"
password = "xxxx"
use_tls = True

# Sender and recipient details
sender_email = "faizankce120@gst.sies.edu.in"
receiver_email = recipient_email

# Email subject and body
subject = "Table HTML"
body = "Please find the attached table HTML file."

# Create a multipart message and set the headers
message = MIMEMultipart()
message["From"] = sender_email
message["To"] = receiver_email
message["Subject"] = subject

# Add body to email
message.attach(MIMEText(body, "plain"))

# Open the file in bynary mode
with open("table.html", "rb") as attachment:
    # Add file as application/octet-stream
    # Email client can usually download this automatically as attachment
    att = MIMEApplication(attachment.read(), _subtype="html")
    att.add_header("Content-Disposition","attachment",filename="table.html")
    message.attach(att)

# Create a secure SSL context
context = smtplib.SMTP(smtp_server, port)
context.ehlo()
# Start TLS for security
context.starttls()
context.ehlo()
# Authentication
context.login(username, password)
# Send the message
context.sendmail(sender_email, receiver_email, message.as_string())
# Close the context
context.quit()

print("Email sent successfully to", receiver_email)
