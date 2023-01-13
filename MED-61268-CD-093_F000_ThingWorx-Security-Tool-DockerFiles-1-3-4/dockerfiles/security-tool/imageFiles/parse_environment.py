import os
import subprocess
from datetime import datetime

startTime = datetime.now()

SECURITY_TOOL='/opt/security-tool/bin/security-common-cli'
CONFIG='/opt/cli.conf'

def log(string):
    print(f"{datetime.now()} " + string)
# set a key into the keystore with the specified value
# outputs the results of the security tool call
def store_in_keystore(k, v):
    output = subprocess.run([SECURITY_TOOL,CONFIG,'set',k,v],check=True, stdout=subprocess.PIPE, universal_newlines=True)
    log(output.stdout)

# imports from another keystore
# outputs the results of the security tool call
def import_config_to_keystore():
    output = subprocess.run([SECURITY_TOOL,CONFIG,'import', '/tmp/config.json'],check=True, stdout=subprocess.PIPE, universal_newlines=True)
    log(output.stdout)

# parse the list fo customer secrets from a common delimited string.   String is in the
# format keytouse:envname,...
def parse_custom_secret_list():
    custom_secrets= {}
    list = os.environ.get('CUSTOM_SECRET_LIST')
    if list != None:
        # split list and build dictionary of envname to key
        custom_secrets = {v:k for k, v in [i.split(':') for i in list.split(',')]}
    log(f'custom_secrets={custom_secrets}')
    return custom_secrets

custom_env_list = parse_custom_secret_list()

# loop through all environment variables.   If env names starts with SECRET_ or it is a key
# from the custom list then insert into keystore
for k, v in os.environ.items():
    #print(f'{k}={v}')
    if k.startswith("SECRET_"):
        store_in_keystore(k[7:].lower(),v)
    elif k in custom_env_list:
        # add env using custom key with value of environment variable
        store_in_keystore(custom_env_list.get(k),v)
    elif k == 'command' and v == 'import':
        import_config_to_keystore()

log(f"completed in {datetime.now() - startTime}")
