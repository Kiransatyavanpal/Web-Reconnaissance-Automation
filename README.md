# Web-Reconnaissance-Automation

This project is a web reconnaissance tool that can be used to automate the process of generating reports for a website's security vulnerabilities. The tool can be used by both technical and non-technical users, and it generates a detailed report that can be sent via email to the user.

## Table of Contents
* Overview
* Features
* Installation
* Usage
* Database
* Scripts
* License

## Overview

Web reconnaissance is an important process that involves identifying the vulnerabilities of a website. The process can be time-consuming and requires technical expertise. This project aims to automate the process of web reconnaissance and generate a detailed report that can be used by non-technical users.

The tool takes a website URL and an email address as input. It then scans the website for vulnerabilities and generates a report in HTML format. The report is then sent via email to the user.

## Features

Automated web reconnaissance
Generates a detailed report in HTML format
Sends report via email to the user
User-friendly interface
Easy to use
Fast and efficient

## Installation

To use this tool, you will need to have the following:
* Python 3
* SQL database

## Usage
To use this tool, follow the steps below:
1. Enter the website URL and email address in the user interface
2. Click on the submit button
3. Wait for the report to be generated
4. Check your email for the report

## Database
The project uses an SQL database to store user data. 

The database has the following structure:
| Field | Type |
| --- | --- |
| id | INT |
| url | VARCHAR(50) |
| email | VARCHAR(50) |
| created_at | TIMESTAMP |

## Scripts
The project includes the following scripts:
* __script.sh:__ A shell script that automates scanning of url and generates the report.
* **mail.py:** sends the generated reported via email to the user.


## License
This project is licensed under the MIT License.

