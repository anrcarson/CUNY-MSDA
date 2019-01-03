# Seinfield Analysis

#### Final Project - CUNY DATA 620 Web Analytics, Summer 2018
__Team:__ Andy Carson, Nathan Cooper, Walt Wells

## Overview:
Put on your urban sombreros and join us as we explore who among us is spongeworthy.  “Serenity Now!”  Seinfeld is a sitcom that ran on the US NBC network from 1989 to 1998, is universally beloved, and is generally considered to be one of the most important and influential sitcoms ever made.  In this project we will ‘double-dip’ with our data, reviewing full episode scripts and metadata associated with the cast, writers and directors of each episode to learn more about both the associated social networks and the text dialogue.   “That’s Gold, Jerry!   Gold!”  

## Repo Assets:

1) Project Proposal - [Seinfeld_Proposal.ipynb](https://github.com/wwells/CUNY_DATA_620_GROUP/blob/master/Final_Project/Seinfeld_Proposal.ipynb)
2) Data Preparation - [SeinfeldScriptScrape.ipynb](https://github.com/wwells/CUNY_DATA_620_GROUP/blob/master/Final_Project/SeinfeldScriptScrape.ipynb)
	* Data Prep Video:  https://raw.githubusercontent.com/wwells/CUNY_DATA_620_GROUP/master/Final_Project/SeinfeldScriptScrape_Presentation.m4v
3) Social Network Analysis - [Seinfeld_SNA.ipynb](https://github.com/wwells/CUNY_DATA_620_GROUP/blob/master/Final_Project/Seinfeld_SNA.ipynb)
	* SNA Video Part 1: https://github.com/wwells/CUNY_DATA_620_GROUP/blob/master/Final_Project/Final_SNA_part1.mp4
	* SNA Video Part 2: https://github.com/wwells/CUNY_DATA_620_GROUP/blob/master/Final_Project/Final_SNA_part2.mp4
4) Natural Language Processing - [DATA_620_NLP.ipynb](https://github.com/wwells/CUNY_DATA_620_GROUP/blob/master/Final_Project/DATA_620_NLP.ipynb)
	* NLP Video: https://github.com/wwells/CUNY_DATA_620_GROUP/blob/master/Final_Project/DATA_620_NLP_Seinfeld.mp4

### Data

#### Source:

Seinology - Citizen transcribed Seinfield scripts. http://www.seinology.com/scripts.shtml

* Seinfield_Metadata.csv - KEY: Ep/SeasonNum, AirDate, EpTitle, Director
* Seinfield_Cast.csv - KEY Ep/SeasonNum, Actor Name, Character
* Seinfield_Writers.csv - KEY Ep/SeasonNum, Writer Name
* Seinfield_Dialogue.csv - KEY Ep/SeasonNum, Character, Text, Scene Location, Scene Dialogue Index
* Seinfield_DialogueSUBSET.csv - Same as Seinfeld Dialogue, but only keeps those entries with > 2 lines of dialogue across the entire corpus. Cuts out most of the scrape noise from inconsistencies in transcription style.
