import sys
import codecs
import shutil
import fileinput
import time

PROMPT='> '

def univ_file_read(name, mode):
    # WARNING: ignores mode argument passed to this function
    return open(name, 'rU')

linelen=0
twidth = shutil.get_terminal_size()[0]
logfile=codecs.open('stdout.log', 'w+', encoding='utf-8')
for line in fileinput.input(openhook=univ_file_read):
    if linelen:
        try:
            sys.stdout.write(' '*linelen+'\r')
        except Exception as e:
            print(e)
    try:
        logfile.write(line)
    except Exception as e:
        print(e)
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

