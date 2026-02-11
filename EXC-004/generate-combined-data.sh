#make combined-data directory if not already exists and entering
mkdir -p COMBINED-DATA
cd RAW-DATA/

#copying the unbinned fastas to the new directory with the new name and def line, same as for gtdb and checkm txt files
for unbinned_dir in $(ls -d */) 
do
	dir=$(echo "$unbinned_dir" | awk 'BEGIN{FS="/"}{print $1}')
	cult2metg=$(grep "$dir" sample-translation.txt | awk '{print $2}')
	
	##changing the def line to contain the culture name
	awk -v cult2metg="$cult2metg" '/^>/ {print ">"cult2metg"-"substr($0, 2); next } {print $0}' "$unbinned_dir"bins/bin-unbinned.fasta >../COMBINED-DATA/"$cult2metg"_UNBINNED.fa
	cp "$unbinned_dir"checkm.txt ../COMBINED-DATA/"$cult2metg"-CHECKM.txt
	cp "$unbinned_dir"gtdb.gtdbtk.tax ../COMBINED-DATA/"$cult2metg"-GTDB-TAX.txt
done

#writing the MAGs into the new directory with awk whilst modifying their def line to contain culture name as well
for bin_dir in $(ls -d */ )
do 
	dir_name=$(echo "$bin_dir"| awk 'BEGIN{FS="/"}{print $1}')
	rename_bin=$(grep "$dir_name" sample-translation.txt | grep -v 'bin-unbinned.fasta'  | awk '{print $2}')
	MAG_count=0	
	for bin in $(ls "$bin_dir"bins/ | grep -v 'bin-unbinned.fasta')
	do
			
			##check completeness =>50 and contamination <=5; here only the ones copied that meet the conditions-->MAGs
			bin_short=$(basename "$bin" .fasta)
			compl=$(grep "$bin_short" "$bin_dir"checkm.txt| awk '{print $13}' )
			cont=$(grep "$bin_short" "$bin_dir"checkm.txt| awk '{print $14}')

			##checks if compl =>50 and cont <=5, exit 0 if condition true --> success, continue to then, exit 1 condition not met --> fail: else
			if awk -v c="$compl" -v t="$cont" 'BEGIN {exit !(c >= 50 && t <= 5)}'
			then
				((MAG_count++))
				awk -v rename_bin="$rename_bin" '/^>/ {print ">"rename_bin"-"substr($0, 2); next } {print $0}' "$bin_dir"bins/"$bin" > ../COMBINED-DATA/"$rename_bin"_MAG_$(printf "%03d" $MAG_count).fa
			fi
	done

#writing the BINs into the new directory with awk whilst modifying their def line to contain culture name as well
	bin_count=$MAG_count
	for bin in $(ls "$bin_dir"bins/ | grep -v 'bin-unbinned.fasta')
        do
			##check completeness =>50 and contamination <=5; here only the ones copied that dont meet the conditions-->BINs
                        bin_short=$(basename "$bin" .fasta)
                        compl=$(grep "$bin_short" "$bin_dir"checkm.txt| awk '{print $13}' )
                        cont=$(grep "$bin_short" "$bin_dir"checkm.txt| awk '{print $14}' )
                        if awk -v c="$compl" -v t="$cont" 'BEGIN {exit (c >= 50 && t <= 5)}'
                        then
                                ((bin_count++))
				awk -v rename_bin="$rename_bin" '/^>/ {print ">"rename_bin"-"substr($0, 2); next } {print $0}' "$bin_dir"bins/"$bin" > ../COMBINED-DATA/"$rename_bin"_BIN_$(printf "%03d" $bin_count).fa
                        fi
                        
        done


done
	
