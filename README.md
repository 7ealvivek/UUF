# UUF

UUF (Unique URL Phasor) is a script designed for URL reconnaissance and parameter discovery, useful for bug bounty hunters and security researchers. It helps in finding and analyzing URLs that might be vulnerable to various types of attacks.

## Features
- Gather URLs using `gau`, `waybackurls`, and `katana`.
- Deduplicate URLs using `urldedupe`.
- Discover parameters with `arjun`.

## Vulnerability Categories
- **Local File Inclusion (LFI)**: [Learn more about LFI](https://owasp.org/www-community/attacks/Local_File_Inclusion)
- **SQL Injection (SQLi)**: [Learn more about SQLi](https://owasp.org/www-community/attacks/SQL_Injection)
- **Cross-Site Scripting (XSS)**: [Learn more about XSS](https://owasp.org/www-community/attacks/xss/)
- **Cross-Site Request Forgery (CSRF)**: [Learn more about CSRF](https://owasp.org/www-community/attacks/csrf)
- **Remote Code Execution (RCE)**: [Learn more about RCE](https://owasp.org/www-community/attacks/Remote_Code_Execution)

## Installation

Ensure the following tools are installed on your system:
- `gau`
- `waybackurls`
- `katana`
- `arjun`
- `urldedupe`
- `jq`

## Usage

```bash
./uuf.sh [-l target_file] [-u url]
