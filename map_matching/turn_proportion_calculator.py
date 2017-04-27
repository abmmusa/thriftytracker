class TurnProportionCalculator:
    def __init__(self):
        pass
    
    def calculate(self, raw_node_sequences, max_window_width):
        node_sequences = map(lambda x: x.strip("\n").split(" "), raw_node_sequences.readlines())
        
        for window_width in range(2, max_window_width + 1, 1):
            self.calculate_turn_proportions(node_sequences, window_width)
    
    def calculate_turn_proportions(self, node_sequences, window_width):
        turn_counts = {}
        
        for node_sequence in node_sequences:
            for i in range(window_width, len(node_sequence), 1):
                prev_nodes = tuple(node_sequence[(i - window_width):i])
                turn_node = node_sequence[i]
                
                if (prev_nodes not in turn_counts):
                    turn_counts[prev_nodes] = {}
                
                if (turn_node not in turn_counts[prev_nodes]):
                    turn_counts[prev_nodes][turn_node] = 0
                
                turn_counts[prev_nodes][turn_node] += 1
        
        for prev_nodes in turn_counts:
            turn_counts_sum = sum(turn_counts[prev_nodes].values())
            
            for turn_node in turn_counts[prev_nodes]:
                sys.stdout.write(str(" ".join(prev_nodes)) + " " + str(turn_node) + " " + str(float(turn_counts[prev_nodes][turn_node]) / float(turn_counts_sum)) + "\n")

import sys, getopt
if __name__ == "__main__":
    (opts, args) = getopt.getopt(sys.argv[1:],"w:h")
    
    max_window_width = 2
    
    for o,a in opts:
        if o == "-w":
            max_window_width = int(a)
        elif o == "-h":
            print "Usage: <stdin> | python turn_proportion_calculator.py [-w <max_window_width>] [-h]"
            exit()
    
    if (max_window_width < 2):
        print "ERROR!! max_window_width must be 2 or greater!"
        exit(-1)
    
    turn_proportion_calculator = TurnProportionCalculator()
    turn_proportion_calculator.calculate(sys.stdin, max_window_width)
