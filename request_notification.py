import os
from email.message import EmailMessage
import ssl
import smtplib
import time
import subprocess

job = 'reqesut_adnare'

def send_email(subject, body, recipients):
    email_sender = 'email'
    email_password = 'pass'

    em = EmailMessage()
    em['From'] = email_sender
    em['To'] = ', '.join(recipients)
    em['Subject'] = subject
    em.set_content(body)

    context = ssl.create_default_context()
    with smtplib.SMTP('smtp-mail.outlook.com', 587) as smtp:
        smtp.starttls(context=context)
        smtp.login(email_sender, email_password)
        smtp.sendmail(email_sender, recipients, em.as_string())

def success_mail():
    subject = 'Adnare.com Working'
    body = "adnare.com is working fine"
    recipients = ['zain@adnare.com', 'kevin@adnare.com']
    send_email(subject, body, recipients)

def fail_mail():
    subject = 'Adnare.com is down'
    body = "adnare.com is not working fine"
    recipients = ['zain@adnare.com', 'kevin@adnare.com']
    send_email(subject, body, recipients)


command = f'schtasks /query /FO LIST /V /TN "{job}"'
process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
stdout, stderr = process.communicate()


output = stdout.decode('utf-8')

last_result_array = []

# Parse the output to find the Last Result
for line in output.split('\n'):
    if "Last Result:" in line:
        last_result = line.split(":")[1].strip()
        last_result_array.append(int(last_result))

print(last_result_array[0])

if (last_result_array[0] != 0):
    print('adnare.com not working error occured sending email')
    fail_mail()
else:
  print('adnare.com working without any error') 
  success_mail()


time.sleep(2)
os.system("exit")

