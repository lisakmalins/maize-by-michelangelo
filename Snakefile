READS=["85seed_42xsub_SRR2960981"]

rule targets:
    input:
        expand("data/kmer-counts/{read}_17mer_histo.txt", read=READS),
        expand("data/kmer-counts/{read}_17mer_dumps.fa", read=READS),
        "data/maps/zmays_AGPv4_map_filtered_42x_scores_histo.txt"

rule score_histogram:
    input:
        "data/scores/zmays_AGPv4_map_filtered_42x_scores.sam"
    output:
        "data/scores/zmays_AGPv4_map_filtered_42x_scores_histo.txt"
    shell:
        "python3 JellyfishKmers/ScoresHistogram.py {input} {output}"

rule calc_scores:
    input:
        dump="data/kmer-counts/{read}_17mer_dumps.fa"
        map="data/maps/zmays_AGPv4_map_filtered.sam"
    output:
        "data/scores/zmays_AGPv4_map_filtered_42x_scores.sam"
    shell:
        "python3 CalcScores/CalcKmerScores.py {input.dump} {input.map} {output}"

rule binned_counts:

rule make_bins:
    input:
        "data/maps/zmays_AGPv4_map.sam"
    output:
        "data/maps/zmays_AGPv4_map_1000000_win.bed"
    shell:
        "bash setup_bins.sh {input} {output} 1000000"

rule dump:
    input:
        "data/kmer-counts/{read}_17mer_counts.jf"
    output:
        "data/kmer-counts/{read}_17mer_dumps.fa"
    shell:
        "jellyfish dump {input} > {output}"

rule histo:
    input:
        "data/kmer-counts/{read}_17mer_counts.jf"
    output:
        "data/kmer-counts/{read}_17mer_histo.txt"
    shell:
        "jellyfish histo {input} > {output}"

rule count_pass2:
    input:
        fastq="data/reads/{read}.fastq",
        bc="data/kmer-counts/{read}.bc"
    output:
        "data/kmer-counts/{read}_17mer_counts.jf"
    threads: 16
    shell:
        "jellyfish count -m 17 -C -s 3G -t 16 --bc {input.bc} -o {output} {input.fastq}"

rule count_pass1:
    input:
        "data/reads/{read}.fastq"
    output:
        "data/kmer-counts/{read}.bc"
    threads: 16
    shell:
        "jellyfish bc -m 17 -C -s 20G -t 16 -o {output} {input}"
