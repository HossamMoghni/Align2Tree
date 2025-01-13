#!/bin/bash

# Align2Tree: Bioinformatics Automation Script

# Function to display menu
function display_menu() {
    echo "=================================================================================================================="
    echo "                                 Align2Tree: Bioinformatics Automation Script                                     "
    echo "This script automates database retrieval, sequence alignment, multiple sequence alignment (MSA), and phylogenetic "
    echo "tree construction. Follow the instructions below to get started."
    echo "=================================================================================================================="
    echo "--- Instructions:"
    echo "1. Ensure the required tools are installed before running (Check Align2Tree GitHub reporepository):"
    echo "   - **BLAST**: For sequence alignment."
    echo "   - **Clustal Omega**: For multiple sequence alignment."
    echo "   - **FastTree**: For phylogenetic tree construction."
    echo "   - **Python with ETE Toolkit**: For phylogenetic tree visualization as PNG."
    echo "2. Input files must be in FASTA format (.fasta) unless specified otherwise."
    echo "3. For database retrieval, provide a text file with each accession ID on a separate line."
    echo "4. Use 'Option 6' for an automated pipeline combining data retrieval, MSA, and phylogenetic tree analysis."
    echo "5. Press '9' at any point to return to the main menu or exit a sub-process."
    echo "6. Check all outputs for any errors or warnings before proceeding to the next step."
    echo
    echo "--- Menu Options:"
    echo "1. Database Retrieval: Fetch sequences or structures from databases like NCBI, UniProt, Ensembl, or PDB."
    echo "2. Sequence Alignment: Align sequences using BLAST with various alignment options."
    echo "3. Multiple Sequence Alignment (MSA): Align multiple sequences using Clustal Omega."
    echo "4. Phylogenetic Tree Construction: Build and visualize a phylogenetic tree using FastTree and Python."
    echo "5. Exit: Exit the script."
    echo "6. Combined Pipeline: Run Data Retrieval + MSA + Phylogenetic Tree Analysis in one go."
    echo "7. Help: Get detailed information about each menu option and required tools."
    echo
    echo "--- Select an Option by Entering Its Number Below ---"
    echo -n "Your Choice: "
}

# Function to display help
function display_help() {
    echo "===================================================================================================================="
    echo "                                                     Help Menu                                                     "
    echo "This script automates common bioinformatics tasks such as database retrieval, sequence alignment, multiple sequence "
    echo "alignment (MSA), and phylogenetic tree construction. Below is a detailed explanation of the tasks and required tools."
    echo "===================================================================================================================="
    echo "--- Bioinformatics Tasks Automated by This Script ---"
    echo "1. **Database Retrieval**: Fetch sequence or structure data from databases such as:"
    echo "   - NCBI: Retrieve nucleotide, protein, or gene sequences."
    echo "   - UniProt: Fetch protein sequences and annotations."
    echo "   - Ensembl: Retrieve nucleotide and protein sequences for various species."
    echo "   - PDB: Download protein structure files."
    echo
    echo "2. **Sequence Alignment**: Perform sequence alignment using BLAST with the following options:"
    echo "   - blastn: Align nucleotide sequences."
    echo "   - blastp: Align protein sequences."
    echo "   - blastx: Translate nucleotide sequences and align against protein sequences."
    echo "   - tblastn: Align protein sequences against translated nucleotide sequences."
    echo "   - tblastx: Translate and align nucleotide sequences."
    echo
    echo "3. **Multiple Sequence Alignment (MSA)**: Align multiple sequences using Clustal Omega."
    echo "   - Input: FASTA file containing sequences to align."
    echo "   - Output: Aligned sequences in FASTA format."
    echo
    echo "4. **Phylogenetic Tree Construction**: Generate and visualize a phylogenetic tree:"
    echo "   - Construct the tree using FastTree."
    echo "   - Visualize the tree as a PNG image using Python and the ETE Toolkit."
    echo
    echo "6. **Combined Pipeline**: Automate the entire workflow:"
    echo "   - Retrieve data, perform MSA, and construct a phylogenetic tree in a single run."
    echo
    echo "7. **Exit**: Exit the script."
    echo
    echo "--- Tools Required ---"
    echo "Ensure the following tools are installed and accessible in your system's PATH:"
    echo "   - **BLAST**: For sequence alignment. (Install via package manager or NCBI website)"
    echo "   - **Clustal Omega**: For multiple sequence alignment."
    echo "   - **FastTree**: For constructing phylogenetic trees."
    echo "   - **Python with ETE Toolkit**: For visualizing phylogenetic trees as PNG images."
    echo "     - Python libraries needed: ete3, pillow, pyqt5, and numpy."
    echo
    echo "--- Additional Notes ---"
    echo "1. Input files should be in FASTA format unless specified otherwise."
    echo "2. For database retrieval, ensure your input file contains one search criterion (e.g., accession ID) per line."
    echo "3. Use 'Option 9' during any step to return to the main menu."
    echo "=================================================================================================================="
}

# Function for database retrieval
function database_retrieval() {
    echo "--- Database Retrieval ---"

    # Validate database input
    while true; do
        read -p "Enter the database to search (e.g., NCBI, UniProt, Ensembl, PDB) or '9' to return to the main menu: " database
        if [[ "$database" == "9" ]]; then
            echo "Returning to the main menu..."
            return
        fi
        case $database in
            NCBI|UniProt|Ensembl|PDB)
                break
                ;;
            *)
                echo "Error: Unsupported database '$database'. Please enter one of: NCBI, UniProt, Ensembl, PDB."
                ;;
        esac
    done

    # Validate input file
    while true; do
        read -p "Enter input file with accession IDs (one per line) or '9' to return to the main menu: " input_file
        if [[ "$input_file" == "9" ]]; then
            echo "Returning to the main menu..."
            return
        fi
        if [[ -f "$input_file" ]]; then
            break
        else
            echo "Error: Input file '$input_file' does not exist. Please provide a valid file."
        fi
    done

    # Validate save option
    while true; do
        read -p "Enter 'single' to save all results in one file or 'multiple' to save each result in separate files, or '9' to return to the main menu: " save_option
        if [[ "$save_option" == "9" ]]; then
            echo "Returning to the main menu..."
            return
        fi
        if [[ "$save_option" == "single" || "$save_option" == "multiple" ]]; then
            break
        else
            echo "Error: Invalid save option '$save_option'. Please enter 'single' or 'multiple'."
        fi
    done

    if [[ "$save_option" == "single" ]]; then
        read -p "Enter output file name for all results (.fasta) or '9' to return to the main menu: " output_file
        if [[ "$output_file" == "9" ]]; then
            echo "Returning to the main menu..."
            return
        fi
        >"$output_file" # Clear or create the output file
    fi

    if [[ "$database" == "NCBI" ]]; then
        read -p "Enter the specific NCBI database (e.g., nucleotide, protein, gene) or '9' to return to the main menu: " db_type
        if [[ "$db_type" == "9" ]]; then
            echo "Returning to the main menu..."
            return
        fi
    fi

    echo "Retrieving sequences from $database based on accession IDs in $input_file..."

    while IFS= read -r id; do
        if [[ -z "$id" ]]; then
            echo "Skipping empty line in input file."
            continue
        fi

        echo "Processing ID '$id'... Using $database database for retrieval..."

        case $database in
        NCBI)
            echo "Using NCBI $db_type database for retrieval..."
            if [[ "$save_option" == "single" ]]; then
                if ! curl -s -f "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=$db_type&id=$id&rettype=fasta&retmode=text" >>"$output_file"; then
                    echo "Error: Sequence not found for ID '$id' in NCBI $db_type." >>"$output_file"
                fi
            else
                if ! curl -s -f "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=$db_type&id=$id&rettype=fasta&retmode=text" >"${id}.fasta"; then
                    echo "Error: Sequence not found for ID '$id' in NCBI $db_type." >"${id}.fasta"
                fi
            fi
            ;;
        UniProt)
            if [[ "$save_option" == "single" ]]; then
                if ! curl -s -f "https://rest.uniprot.org/uniprotkb/$id.fasta" >>"$output_file"; then
                    echo "Error: Sequence not found for ID '$id' in UniProt." >>"$output_file"
                fi
            else
                if ! curl -s -f "https://rest.uniprot.org/uniprotkb/$id.fasta" >"${id}.fasta"; then
                    echo "Error: Sequence not found for ID '$id' in UniProt." >"${id}.fasta"
                fi
            fi
            ;;
        Ensembl)
            if [[ "$save_option" == "single" ]]; then
                if ! curl -s -f "https://rest.ensembl.org/sequence/id/$id?content-type=text/x-fasta" >>"$output_file"; then
                    echo "Error: Sequence not found for ID '$id' in Ensembl." >>"$output_file"
                fi
            else
                if ! curl -s -f "https://rest.ensembl.org/sequence/id/$id?content-type=text/x-fasta" >"${id}.fasta"; then
                    echo "Error: Sequence not found for ID '$id' in Ensembl." >"${id}.fasta"
                fi
            fi
            ;;
        PDB)
            if [[ "$save_option" == "single" ]]; then
                if ! curl -s -f "https://files.rcsb.org/download/$id.pdb" >>"$output_file"; then
                    echo "Error: File not found for ID '$id' in PDB." >>"$output_file"
                fi
            else
                if ! curl -s -f "https://files.rcsb.org/download/$id.pdb" -o "${id}.pdb"; then
                    echo "Error: File not found for ID '$id' in PDB." >"${id}.pdb"
                fi
            fi
            ;;
        esac
    done < "$input_file"

    if [[ "$save_option" == "single" ]]; then
        echo "Data retrieval complete. Results saved to $output_file."
    else
        echo "Data retrieval complete. Results saved to individual files."
    fi
}

# Function for sequence alignment
function sequence_alignment() {
    echo "--- Sequence Alignment ---"

    # Prompt user to select BLAST option
    while true; do
        echo "Choose BLAST option:"
        echo "1. blastn: Nucleotide sequence alignment"
        echo "2. blastp: Protein sequence alignment"
        echo "3. blastx: Nucleotide translated to protein alignment"
        echo "4. tblastn: Protein to nucleotide translated alignment"
        echo "5. tblastx: Nucleotide to nucleotide translated alignment"
        read -p "Enter your choice (1-5) or '9' to return to main menu: " blast_choice
        if [[ $blast_choice == "9" ]]; then
            echo "Returning to main menu..."
            return
        fi
        case $blast_choice in
            1) blast_type="blastn"; description="Nucleotide sequence alignment." ;;
            2) blast_type="blastp"; description="Protein sequence alignment." ;;
            3) blast_type="blastx"; description="Nucleotide translated to protein alignment." ;;
            4) blast_type="tblastn"; description="Protein to nucleotide translated alignment." ;;
            5) blast_type="tblastx"; description="Nucleotide to nucleotide translated alignment." ;;
            *) echo "Error: Invalid choice '$blast_choice'. Please enter a number between 1 and 5."; continue ;;
        esac
        break
    done

    echo "You selected $blast_type: $description"

    # Prompt for input file containing sequences
    while true; do
        read -p "Enter input file containing sequences in FASTA format or '9' to return: " input_file
        if [[ $input_file == "9" ]]; then
            echo "Returning to main menu..."
            return
        fi
        if [[ -f $input_file ]]; then
            break
        else
            echo "Error: File '$input_file' does not exist. Please provide a valid file."
        fi
    done

    # Prompt for reference sequence (optional)
    while true; do
        read -p "Do you have a reference sequence in FASTA format? (yes/no or '9' to return): " use_reference
        if [[ $use_reference == "9" ]]; then
            echo "Returning to main menu..."
            return
        elif [[ $use_reference == "yes" || $use_reference == "no" ]]; then
            break
        else
            echo "Error: Invalid input '$use_reference'. Please enter 'yes', 'no', or '9'."
        fi
    done

    if [[ $use_reference == "yes" ]]; then
        while true; do
            read -p "Enter the path to the reference FASTA file: " reference_file
            if [[ -f $reference_file ]]; then
                break
            else
                echo "Error: File '$reference_file' does not exist. Please provide a valid file."
            fi
        done
        echo "Processing input sequences against the provided reference using $blast_type..."
    else
        echo "Processing input sequences within the same file using $blast_type..."
    fi

    # File to save output
    output_file="blast_results.txt"
    >"$output_file"

    # Read and process sequences
    current_header=""
    current_sequence=""
    while read -r line; do
        if [[ $line == ">"* ]]; then
            if [[ -n $current_sequence ]]; then
                # Write query to temp file and run BLAST
                echo "$current_header" > temp_query.fasta
                echo "$current_sequence" >> temp_query.fasta
                if [[ $use_reference == "yes" ]]; then
                    $blast_type -query temp_query.fasta -subject "$reference_file" -out temp_output.txt -outfmt 7
                else
                    $blast_type -query temp_query.fasta -subject "$input_file" -out temp_output.txt -outfmt 7
                fi

                if [[ $? -eq 0 ]]; then
                    echo "Successfully aligned $current_header." >> "$output_file"
                    cat temp_output.txt >> "$output_file"
                else
                    echo "Error: Alignment failed for $current_header." >> "$output_file"
                fi
            fi
            current_header=$line
            current_sequence=""
        else
            current_sequence+=$line
        fi
    done < "$input_file"

    # Process the last sequence in the file
    if [[ -n $current_sequence ]]; then
        echo "$current_header" > temp_query.fasta
        echo "$current_sequence" >> temp_query.fasta
        if [[ $use_reference == "yes" ]]; then
            $blast_type -query temp_query.fasta -subject "$reference_file" -out temp_output.txt -outfmt 7
        else
            $blast_type -query temp_query.fasta -subject "$input_file" -out temp_output.txt -outfmt 7
        fi

        if [[ $? -eq 0 ]]; then
            echo "Successfully aligned $current_header." >> "$output_file"
            cat temp_output.txt >> "$output_file"
        else
            echo "Error: Alignment failed for $current_header." >> "$output_file"
        fi
    fi

    echo "Alignment completed. Results saved to $output_file."
    rm -f temp_query.fasta temp_output.txt
}

# Function for multiple sequence alignment (MSA)
function msa() {
    echo "--- Multiple Sequence Alignment ---"

    while true; do
        echo -n "Enter the path to the input FASTA file or '9' to return to the main menu: "
        read aligned_file

        # Handle option 9 to return to the main menu
        if [[ $aligned_file == "9" ]]; then
            echo "Returning to main menu..."
            return
        fi

        # Validate input file
        if [[ -f $aligned_file ]]; then
            break
        else
            echo "Error: File '$aligned_file' does not exist. Please provide a valid file."
        fi
    done

    echo "Performing multiple sequence alignment using Clustal Omega..."
    clustalo -i "$aligned_file" -o msa_output.fasta --force

    # Check for errors during MSA process
    if [[ $? -eq 0 ]]; then
        echo "MSA completed successfully. Results saved to msa_output.fasta."
    else
        echo "Error: MSA process failed. Please ensure Clustal Omega is installed and the input file is valid."
    fi
}

# Function for phylogenetic tree construction
function phylogenetic_tree() {
    echo "--- Phylogenetic Tree Construction ---"

    # Prompt for input aligned FASTA file
    while true; do
        echo -n "Enter the path to the input aligned FASTA file or '9' to return to the main menu: "
        read aligned_file

        # Handle option 9 to return to the main menu
        if [[ $aligned_file == "9" ]]; then
            echo "Returning to main menu..."
            return
        fi

        # Validate input file
        if [[ -f $aligned_file ]]; then
            break
        else
            echo "Error: File '$aligned_file' does not exist. Please provide a valid file."
        fi
    done

    # Construct the phylogenetic tree
    echo "Constructing phylogenetic tree using FastTree..."
    tree_output="phylogenetic_tree.newick"
    if FastTree -nt "$aligned_file" > "$tree_output"; then
        echo "Phylogenetic tree construction completed. Tree saved to $tree_output. Use ITOL to visualize"
    else
        echo "Error: Phylogenetic tree construction failed. Returning to main menu."
        return
    fi

    # Prompt for tree visualization
    while true; do
        echo -n "Would you like to visualize the tree as a PNG image? (yes/no or '9' to return to the main menu): "
        read visualize_choice

        if [[ $visualize_choice == "9" ]]; then
            echo "Returning to main menu..."
            return
        elif [[ $visualize_choice == "yes" ]]; then
            while true; do
                echo -n "Enter the output PNG file name (e.g., tree.png) or '9' to return to the main menu: "
                read png_output

                if [[ $png_output == "9" ]]; then
                    echo "Returning to main menu..."
                    return
                fi

                # Use default name if none provided
                if [[ -z $png_output ]]; then
                    png_output="tree.png"
                fi

                # Visualize the tree using Python and ETE Toolkit
                python3 - <<END
import sys
import os
from ete3 import Tree, TreeStyle

# Input: Tree file and output PNG file
tree_file = "$tree_output"
png_file = "$png_output"

# Ensure the input tree file exists
if not os.path.exists(tree_file):
    print(f"Error: The tree file '{tree_file}' does not exist. Please check the input file path.")
    sys.exit(1)

# Ensure the output file has a '.png' extension
if not png_file.lower().endswith(".png"):
    png_file += ".png"

try:
    # Load the tree and set up visualization style
    tree = Tree(tree_file)
    ts = TreeStyle()
    ts.show_leaf_name = True

    # Render the tree to the specified PNG file
    tree.render(png_file, tree_style=ts)
    print(f"Tree visualization saved as {png_file}.")
except Exception as e:
    print(f"Error: Tree visualization failed. Ensure Python and ETE Toolkit are installed. Details: {e}")
END

                break
            done
            break
        elif [[ $visualize_choice == "no" ]]; then
            echo "Skipping tree visualization."
            break
        else
            echo "Error: Invalid choice '$visualize_choice'. Please enter 'yes', 'no', or '9'."
        fi
    done
}

# Function for combined data retrieval, MSA, and phylogenetic tree analysis
function combined_pipeline() {
    # Step 1: Database Retrieval
    echo "Step 1: Starting Database Retrieval..."
    database_retrieval
    if [[ $? -ne 0 ]]; then 
        echo "Error during database retrieval. Returning to the main menu."
        return
    fi

    # Prompt user to check retrieved files
    echo "Please check the retrieved FASTA files for errors (e.g., incomplete sequences)."
    echo "Press 'Enter' to continue to alignment, or '9' to return to the main menu: "
    read user_input
    if [[ $user_input == "9" ]]; then
        echo "Returning to the main menu..."
        return
    fi

    # Step 2: Multiple Sequence Alignment (MSA)
    echo "Step 2: Starting Multiple Sequence Alignment (MSA)..."
    msa
    if [[ $? -ne 0 ]]; then 
        echo "Error during MSA. Returning to the main menu."
        return
    fi

    # Inform the user about the output of MSA
    echo "MSA completed. The aligned sequences have been saved to 'msa_output.fasta'."
    echo "This file will be used as input for phylogenetic tree construction."

    # Step 3: Phylogenetic Tree Construction
    echo "Step 3: Starting Phylogenetic Tree Construction..."
    phylogenetic_tree
    if [[ $? -ne 0 ]]; then 
        echo "Error during phylogenetic tree construction. Returning to the main menu."
        return
    fi

    echo "Combined pipeline completed successfully!"
}

# Main script loop
while true; do
    display_menu
    read choice
    case $choice in
        1) database_retrieval ;;
        2) sequence_alignment ;;
        3) msa ;;
        4) phylogenetic_tree ;;
        5) echo "Exiting Align2Tree...Goodbye!"; exit 0 ;;
        6) combined_pipeline ;;
        7) display_help ;;
        *) echo "Invalid option...Please try again." ;;
    esac
    echo
done

done


# Thank you for using Align2Tree...Goodbye!