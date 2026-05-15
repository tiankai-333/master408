import subprocess
import sys

result = subprocess.run(
    ['java', '-cp', 'source/xzs/target/classes', '-Dloader.main=com.mindskip.xzs.TestBCrypt', 'org.springframework.boot.loader.launch.PropertiesLauncher'],
    capture_output=True, text=True, cwd='C:/Dev/Workspaces/master408'
)
print(result.stdout)
print(result.stderr)
