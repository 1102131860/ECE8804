import argparse
import re

def escape_ansi(line):
    ansi_escape =re.compile(r'(\x9B|\x1B\[)[0-?]*[ -\/]*[@-~]')
    return ansi_escape.sub('', line)

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
header_line = f"{bcolors.HEADER}={bcolors.ENDC}"*100
devide_line = f"{bcolors.HEADER}-{bcolors.ENDC}"*100

def parse_log(filename):
    time_dict = {}
    f = open(filename, "r")
    for line in f:
        all_item = line.replace(" ", "").replace("\n", "").split(",")
        for i, item in enumerate(all_item):
            item = item.split('=')
            if i==0:
                time = item[1]
                time_dict[time] = {}
            else:
                time_dict[time][item[0]] = item[1]
    f.close()
    return time_dict

def print_pass_msg(testname):
    pass_msg = f""
    pass_msg += header_line + f"\n"
    pass_msg += f"   Testname: {testname}" + f"\n"
    pass_msg += f"   Result: {bcolors.OKGREEN}PASS{bcolors.ENDC}" + f"\n"
    pass_msg += header_line + f"\n"
    print(pass_msg)
    f = open("./run_log/run.log", "a")
    f.write(escape_ansi(pass_msg))
    f.close()

def print_fail_msg(testname, dut_dict, golden_dict): 
    fail_msg = f""
    fail_msg += header_line + f"\n"
    fail_msg += f"   Testname: {testname}" + f"\n"
    fail_msg += f"   Result: {bcolors.FAIL}FAIL{bcolors.ENDC}" + f"\n"
    fail_msg += devide_line + f"\n"
    for time_key in golden_dict:
        if time_key not in dut_dict:            
            fail_msg += f"{bcolors.FAIL}Error{bcolors.ENDC} @time= {time_key}: dut has no event logged, "+\
            f"golden={golden_dict[time_key]}" + f"\n"
        else:
            error_exists = False
            error_msg = f"{bcolors.FAIL}Error{bcolors.ENDC} @time= {time_key}: "
            for item_key in golden_dict[time_key]:
                if golden_dict[time_key][item_key] != dut_dict[time_key][item_key]:
                    error_exists = True
                    error_msg += f"[{item_key}] golden={golden_dict[time_key][item_key]} " +\
                                 f"dut={dut_dict[time_key][item_key]}  "
            if error_exists:
                fail_msg += error_msg + f"\n"
    for time_key in dut_dict:
        if time_key not in golden_dict:            
            fail_msg += f"{bcolors.FAIL}Error{bcolors.ENDC} @time= {time_key}: golden has no event logged, "+\
            f"dut={dut_dict[time_key]}" + f"\n"
    fail_msg += header_line + f"\n"
    print(fail_msg)
    f = open("./run_log/error.log", "a")
    f.write(escape_ansi(fail_msg))
    f.close()
    f = open("./run_log/run.log", "a")
    f.write(escape_ansi(fail_msg))
    f.close()

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-t','--test', help='Enter testname such as "all_test"', default='default', required=True)
    args = vars(parser.parse_args())
    testname = args['test']

    dut_dict = parse_log(f"./dut_log/{testname}.log")
    golden_dict = parse_log(f"./golden_log/{testname}.log")
    
    if dut_dict == golden_dict:
        print_pass_msg(testname)
    else:
        print_fail_msg(testname, dut_dict, golden_dict)

if __name__ == "__main__":
    main()