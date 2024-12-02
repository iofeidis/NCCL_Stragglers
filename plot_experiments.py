import pandas as pd
import matplotlib.pyplot as plt
import re

def parse_nccl_output(file_path):
    data = []
    with open(file_path, 'r') as file:
        lines = file.readlines()
        for line in lines:
            match = re.match(r'\s*(\d+)\s+(\d+)\s+\w+\s+(\w+)\s+-1\s+([\d.]+)', line)
            if match:
                size = int(match.group(1))
                redop = match.group(3)
                time = float(match.group(4))
                data.append((size, redop, time))
    return pd.DataFrame(data, columns=['size', 'redop', 'time'])

def plot_experiments(file1, file2, version1, version2):
    df1 = parse_nccl_output(file1)
    df2 = parse_nccl_output(file2)

    redops = df1['redop'].unique()

    for redop in redops:
        plt.figure()
        df1_redop = df1[df1['redop'] == redop]
        df2_redop = df2[df2['redop'] == redop]

        plt.plot(df1_redop['size'], df1_redop['time'], label=f'{version1}')
        plt.plot(df2_redop['size'], df2_redop['time'], label=f'{version2}')

        plt.xlabel('Size (bytes)')
        plt.ylabel('Time (us)')
        plt.title(f'Reduction Operation: {redop}')
        plt.legend()
        plt.grid(True)
        plt.tight_layout()
        plt.savefig(f'figures/27ms/{redop}_comparison_nonblocking.png')
        plt.close()

if __name__ == "__main__":
    file1 = 'results/27ms_delay_nonblocking_1732743445.txt'
    file2 = 'results/no_delay_nonblocking_1732739879.txt'
    # file2 = 'results/no_delay_1732739782.txt'
    version1 = 'NCCL with 27ms delay'
    version2 = 'NCCL default'

    plot_experiments(file1, file2, version1, version2)