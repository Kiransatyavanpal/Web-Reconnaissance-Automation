# Web-Reconnaissance-Automation
Automated Web Recon Tool
This project is a web reconnaissance tool that can be used to automate the process of generating reports for a website's security vulnerabilities. The tool can be used by both technical and non-technical users, and it generates a detailed report that can be sent via email to the user.

Table of Contents
Overview
Features
Installation
Usage
Database
Scripts
Contributing
License
Overview
Web reconnaissance is an important process that involves identifying the vulnerabilities of a website. The process can be time-consuming and requires technical expertise. This project aims to automate the process of web reconnaissance and generate a detailed report that can be used by non-technical users.

The tool takes a website URL and an email address as input. It then scans the website for vulnerabilities and generates a report in HTML format. The report is then sent via email to the user.

Features
Automated web reconnaissance
Generates a detailed report in HTML format
Sends report via email to the user
User-friendly interface
Easy to use
Fast and efficient
Installation
To use this tool, you will need to have the following:

Python 3
SQL database
To install the required packages, run the following command:

bash
Copy code
pip install -r requirements.txt
Usage
To use this tool, follow the steps below:

Enter the website URL and email address in the user interface
Click on the submit button
Wait for the report to be generated
Check your email for the report
Database
The project uses an SQL database to store user data. The database has the following structure:

Field	Type
id	INT
url	VARCHAR(50)
email	VARCHAR(50)
created_at	TIMESTAMP
Scripts
The project includes the following scripts:

generate_report.py: Generates a report for a given website URL and sends it via email to the user.
run.py: Runs the user interface for the project.
script.sh: A shell script that runs the generate_report.py script.
Contributing
If you would like to contribute to this project, please follow the guidelines below:

Fork the repository.
Create a new branch.
Make your changes.
Submit a pull request.
License
This project is licensed under the MIT License.
