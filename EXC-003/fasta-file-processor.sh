check_start_fasta=$(head -n 1 $1 | awk '{print(substr($1, 1, 1))}')

if [ -r "$1" ] && [ $check_start_fasta == '>' ]
then
	#if not the case print sequences to one line in fasta file
	awk '/>/ {if (seq) print seq; print; seq=""; next} {seq=seq $0} END {print seq}' $1 > fasta_one_line.fa
	
	#count the number of sequences
	no_seq=$(grep '>' fasta_one_line.fa | wc -l)
	
	#get the total length of seq
	total_length=$(grep -v '>' fasta_one_line.fa | awk '{totalseq=totalseq $0} END {print length(totalseq)}')
	
	#get the shortest sequence
	length_shortest_seq=$(grep -v '>' fasta_one_line.fa | awk '{print length}' | sort -n | head -n 1) 
	
	#get the longest sequence
	length_longest_seq=$(grep -v '>' fasta_one_line.fa | awk '{print length}' | sort -n | tail -n 1)
	
	#get the average sequence length
	avg_seq_length=$(($total_length/$no_seq))
	
	#gc count
	gc_count=$(grep -v '>' fasta_one_line.fa | awk '{gc_count += gsub(/[GgCc]/, "", $1)} END {print gc_count}')
	gc_count_perc=$(( gc_count * 100 / total_length ))

	echo "FASTA File Statistics:
----------------------
Number of sequences: $no_seq
Total length of sequences: $total_length
Length of the longest sequence: $length_longest_seq
Length of the shortest sequence: $length_shortest_seq
Average sequence length: $avg_seq_length
GC Content (%): $gc_count_perc"

else
	echo "$1 is not a suitable fasta file to run this script!"
fi

#remove fasta_one_line
rm fasta_one_line.fa

