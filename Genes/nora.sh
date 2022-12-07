#!/bin/bash

input=$1

while read -r line
do
    # save only necessary info to json
    curl -s -H "Content-Type: application/json" "https://www.yeastgenome.org/webservice/locus/$line/sequence_details" \
    | jq -r '
        .genomic_dna[] | 
        select(.strain.status == "Reference") |
        { start:.start, end:.end, chrom: .contig.display_name, link: .locus.link, display: .locus.display_name, format: .locus.format_name, res: .residues }
    ' \
    > "$line.json"
    # convert to fsa: first line with info
    cat "$line.json" | jq -r '. | 
    ">\(.display) \(.format) SGDID:\(.link[7:]), \(.chrom):\(.start)..\(.end)"
    ' > "$line.fsa"
    # convert to fsa: other lines with sequence
    cat "$line.json" | jq -r '.res' | fold -w60 >> "$line.fsa"
    # remove json
    rm "$line.json"
    echo "Finished: $line"
done < "$input"
