# npm-scan-sh

`npm-scan-sh` is a simple shell script to detect compromised npm packages in your project.  

It scans all `node_modules` directories under a given path and checks installed packages against a provided CSV list.

---

## Installation

Clone the repository and make the script executable:

```bash
git clone https://github.com/your-username/npm-scan-sh.git
cd npm-scan-sh
chmod +x npm-scan.sh
```

Optionally, move it somewhere in your PATH :

`sudo mv npm-scan.sh /usr/local/bin/npm-scan`

---

## Purpose

Supply a list of compromised npm packages (name + version) via CSV, and the script will:

Recursively scan node_modules directories under the target path

Compare each package name@version with the compromised list

Print compromised packages immediately as they are found, with their location

---

## Input format

The compromised package list must be in CSV format, with `;` as separator for package name and versions, and a `,` to separate versions.

```csv
package-name;1.0.0,1.0.1,2.0.0
another-package;3.2.1
```

This means:

- package-name versions 1.0.0, 1.0.1, and 2.0.0 are compromised
- another-package version 3.2.1 is compromised

---

## Usage

Pipe the CSV: `cat compromised.csv | ./scan-npm.sh [path to directory to recursively scan]`

Note : The repository includes a list of compromised packages as of 16/09/2025, found on [mend.io](https://www.mend.io/blog/npm-supply-chain-attack-packages-compromised-by-self-spreading-malware/)

---

## Example

```bash
cat ./16_09_2025_mend.io.csv | ./scan-npm.sh ~/projects
``` 

Sample output: 

```
🔍 Scanning for compromised packages under ./my-project ...

⚠️  Compromised package found: yoo-styles@6.0.326
   Location: /home/username/projects/my-project/node_modules/yoo-styles/package.json

✅ Scan completed.
```

---

## License

This project is licensed under the MIT License.