
setwd("G:/Shared drives/Nord Lab - Data/SFRI00/ASD1000/ASD1KV5/Karol")

library(seqinr)
library(DECIPHER)
library(stringr)
library(dplyr)
library(parallel)
library(future.apply)
library(data.table)
library(matrixStats)

source("AmplifyDNA_2.R")

# Below is just for testing  how the function behaves with non unique amplicons.
#non_unique_amplicons <- filter(amplicons, UNIQID %in% unique(dup_ID_df$UNIQID))
#primers_3 <- lapply(1:nrow(non_unique_amplicons), function(x) c(non_unique_amplicons$P0_Left[x], #non_unique_amplicons$P0_Right[x], non_unique_amplicons$CHROMOSOME[x], #non_unique_amplicons$UNIQID[x]))  

# Reads amplicon metadata. Only P0 primers were ordered. [,c(1:9)] removes the other primer sets.
amplicons <- read.table("2018-05-08_Combined-SFARI1000-Primers.txt", header = TRUE)[,c(1:9)]
amplicons <- filter(amplicons, P0_Left != "." & P0_Right != ".") #Removes SNVs for which primer3 could not design

# Primer pair list
primers_2 <- lapply(1:nrow(amplicons), function(x) c(amplicons$P0_Left[x], amplicons$P0_Right[x], amplicons$CHROMOSOME[x], amplicons$UNIQID[x], amplicons$START[x]))

# Reads chromosome reference files
chr_1 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.1.fa.gz"), format="fasta")
chr_2 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.2.fa.gz"), format="fasta")
chr_3 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.3.fa.gz"), format="fasta")
chr_4 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.4.fa.gz"), format="fasta")
chr_5 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.5.fa.gz"), format="fasta")
chr_6 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.6.fa.gz"), format="fasta")
chr_7 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.7.fa.gz"), format="fasta")
chr_8 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.8.fa.gz"), format="fasta")
chr_9 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.9.fa.gz"), format="fasta")
chr_10 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.10.fa.gz"), format="fasta")
chr_11 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.11.fa.gz"), format="fasta")
chr_12 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.12.fa.gz"), format="fasta")
chr_13 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.13.fa.gz"), format="fasta")
chr_14 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.14.fa.gz"), format="fasta")
chr_15 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.15.fa.gz"), format="fasta")
chr_16 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.16.fa.gz"), format="fasta")
chr_17 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.17.fa.gz"), format="fasta")
chr_18 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.18.fa.gz"), format="fasta")
chr_19 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.19.fa.gz"), format="fasta")
chr_20 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.20.fa.gz"), format="fasta")
chr_21 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.21.fa.gz"), format="fasta")
chr_22 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.22.fa.gz"), format="fasta")
chr_23 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.X.fa.gz"), format="fasta")
chr_24 <- readDNAStringSet(filepath = c("Chromosomes_GRCh38/Homo_sapiens.GRCh38.dna_sm.chromosome.Y.fa.gz"), format="fasta")



chromosomes <- list(chr_1, chr_2, chr_3, chr_4, chr_5, chr_6, chr_7, chr_8, chr_9, chr_10, chr_11, chr_12, chr_13, chr_14, chr_15, chr_16, chr_17, chr_18, chr_19, chr_20, chr_21, chr_22, chr_23, chr_24)


#Global settings for future_apply
options(future.globals.maxSize = +Inf)
plan(multiprocess)

PCR_in_silico_38_all_chrom <- function(start, end) { 
  
  range_start = start
  range_end = end
  
  
  #It took 8.280362 hours to run the first 500  
  
  t <- Sys.time()
  
  in_silico_products <- lapply(primers_2[range_start:range_end], function(y){
    
    #y <- primers_3[[1]]  
    
    UNIQID <- y[4]
    
    PCR_prod <- future_lapply(chromosomes, function(x) AmplifyDNA_2(y[1:2], x, 
                                                                    maxProductSize = 1500, 
                                                                    annealingTemp = 57, 
                                                                    P = 4e-7,              # molar concentration of primers in the reaction
                                                                    ions = 0.2,            # molar sodium equivalent ionic concentration
                                                                    includePrimers = TRUE, 
                                                                    minEfficiency = 0.90))  # The efficiency is set to a high value
    
    if ( any(str_length(as.character(PCR_prod))) == TRUE ) { # checks if there is any PCR prod  
      
      chrom <- which(unlist(lapply(PCR_prod, function(x) length(x))) != 0)
      
      # This is handling multiple PCR products in multiple chromosomes
      as.data.frame(rbindlist(lapply(chrom, function(x){
        
        prod_seq <- as.character(as.character(PCR_prod[[x]]))
        start <-   start(PCR_prod[[x]])
        end <-   end(PCR_prod[[x]])
        width <-   width(PCR_prod[[x]])
        efficiency <- names(as.character(PCR_prod[[x]]))
        
        df <- data.frame("UNIQID" = UNIQID, 
                         "Chr" = x, 
                         "Amplicon_Start" = start, 
                         "Amplicon_End" = end, 
                         "Amplicon_length" = width, 
                         "PCR_efficiency" = efficiency, 
                         "Sequence" = prod_seq)
        df
      })))
      
    }
    else{
      df <- data.frame("UNIQID" = UNIQID, 
                       "Chr" = NA, 
                       "Amplicon_Start" = NA, 
                       "Amplicon_End" = NA, 
                       "Amplicon_length" = NA, 
                       "PCR_efficiency" = NA, 
                       "Sequence" = NA)
      df
    }
    
  })
  
  
  Sys.time() - t
  
  m <- as.data.frame(rbindlist(in_silico_products))
  final_df <- merge(amplicons[c(range_start:range_end),], m, by = "UNIQID", all.x = TRUE, all.y = TRUE)
  
  write.csv(file=paste0("Amplicons_w_edge_coordinated_and_seq_over_all_chrom_GRCh38", "_", range_start, "_to_", range_end, ".csv"), final_df)
}


t <- Sys.time()
PCR_in_silico_38_all_chrom(1251, 1500)
Sys.time() - t




