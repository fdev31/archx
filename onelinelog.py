import sys
import shutil
import fileinput
import time

PROMPT='> '

def univ_file_read(name, mode):
    # WARNING: ignores mode argument passed to this function
    return open(name, 'rU')

linelen=0
twidth = shutil.get_terminal_size()[0]
logfile=open('stdout.log', 'w+')
for line in fileinput.input(openhook=univ_file_read):
    if linelen:
        sys.stdout.write(' '*linelen+'\r')
    logfile.write(line)
    line = line.strip().replace('\n', '_')
    if not line:
        continue
    if 'Dload' in line:
        line = 'Downloading...'
    elif 'db.lck.' in line:
        print('DATA BASE LOCKED, rm '+(line.rsplit(' ', 1)[-1][:-1]))
        time.sleep(5)
    if len(line)+1  > twidth :
        line = PROMPT + line[:twidth-10] + '...\r'
    else:
        line = PROMPT + line + '\r'
    sys.stdout.write(line)
    sys.stdout.flush()
    linelen = len(line) + 1

