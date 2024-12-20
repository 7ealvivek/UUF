

# UUF: Unique URL Phasor

**UUF** (Unique URL Phasor) is a tool designed for bug bounty hunters and security professionals to perform comprehensive reconnaissance on target domains. It automates the gathering of URLs, deduplicates them, and discovers potential parameters using various tools.


**This tool is intended for educational purposes and ethical security testing only. The author does not take any responsibility for its misuse or any illegal activities performed with it.**

## Features

- **URL Gathering**: Uses `gau`, `waybackurls`, and `katana` to collect URLs from different sources.
- **URL Deduplication**: Deduplicates collected URLs to avoid redundant data.
- **Parameter Discovery**: Uses `arjun` to discover potential parameters for further testing.

## More Accurate on VPS (12-24 hours results) 

## Arjun parameters >> Sqli,XSS,Lfi,RCE ( Injection based attacks )

## Requirements

Ensure the following tools are installed:

- [gau](https://github.com/lc/gau)
- [waybackurls](https://github.com/tomnomnom/waybackurls)
- [katana](https://github.com/ledge/katana)
- [arjun](https://github.com/s0md3v/Arjun)
- [urldedupe](https://github.com/ameenmaali/urldedupe)

## Installation

Clone this repository:

```bash
git clone https://github.com/7ealvivek/UUF.git
cd UUF
```

## Usage

### Process a Single URL

To run UUF on a single URL, use:

```bash
./UUF.sh -u example.org
```

### Process Domains from a File

To run UUF on a list of domains from a file, use:

```bash
./UUF.sh -l targets.txt
```

### Options

- `-u URL` : Specify a single URL to process.
- `-l FILE` : Specify a file containing a list of domains to process.

## Output

The results are saved in the current directory with filenames specific to the target domain:

- `example_org_final_urls.txt`: Final deduplicated URLs.
- `example_org_arjun_params.txt`: Parameters discovered by `arjun`.

## Example

```bash
./UUF.sh -u example.org
```

This command will generate `example_org_final_urls.txt` and `example_org_arjun_params.txt` in the current directory.

## Contributing

Feel free to contribute to this project by submitting issues or pull requests.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

