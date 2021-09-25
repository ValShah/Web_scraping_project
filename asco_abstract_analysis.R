##-----------------
#ASCO abstracts#### 
#------------------

#------------------------
##read in json files ####
#------------------------
#install.packages("strex")
#install.packages("rjson")
#install.packages("hrbrthemes")
library(rjson)
library(tidyverse)
library(dplyr)
library(purrr)
library(ggplot2)
library(strex)
library(viridis)
library(forcats)
library(hrbrthemes)
library(extrafont)
#setwd("C:/Users/Vallari/Desktop/NYC_academy/Python/Introduction_to_Scrapy/asco_abstract")
setwd("C:/Users/Vallari Shah/OneDrive/NYC_academy/Python/Introduction_to_Scrapy/asco_abstracts")
asco_abstracts1 <- fromJSON(sprintf("[%s]", paste(readLines("asco_abstracts_1_3255abs.json"),collapse=",")))
asco_abstracts2 <- fromJSON(sprintf("[%s]", paste(readLines("asco_abstracts_1_3438abs.json"),collapse=",")))
asco_abstracts3 <- fromJSON(sprintf("[%s]", paste(readLines("asco_abstracts_1_3257abs.json"),collapse=",")))

ascoabstracts1matrix <- lapply(asco_abstracts1, function(x) {
  x[sapply(x, is.null)] <- NA
  unlist(x)
})

ascoabstracts2matrix <- lapply(asco_abstracts2, function(x) {
  x[sapply(x, is.null)] <- NA
  unlist(x)
})

ascoabstracts3matrix <- lapply(asco_abstracts3, function(x) {
  x[sapply(x, is.null)] <- NA
  unlist(x)
})

asco_1 <- as.data.frame(do.call("rbind", ascoabstracts1matrix))
asco_2 <- as.data.frame(do.call("rbind", ascoabstracts2matrix))
asco_3 <- as.data.frame(do.call("rbind", ascoabstracts3matrix))

all_asco <- rbind(asco_1, asco_2, asco_3)

#check <- distinct(all_asco)

#------------------
#data cleaning ####
#------------------

#abstract text columns to be cleaned later
##HTTP 504 error stopping full download of 5197 abstracts so run 3times 
##number of unique entries = 4104

unique_asco <- all_asco%>% 
  distinct(abstract_num, .keep_all=TRUE)

## take out education sessions
## take out those with abstract number = na #2182

asco_abs <- unique_asco %>% 
  filter(session_type !="Education Session") %>% 
  filter(!is.na(abstract_num))
  

#new column first author/last author. 
#second/second to last not working - error as some <2 authors

asco_abs_new <- asco_abs %>% 
  mutate(author_list = str_split(author_list, ",")) %>% 
  mutate(num_authors = sapply(author_list, length)) %>% 
  mutate(first_author = sapply(author_list,function(x) x[[1]])) %>%
  mutate(last_author = sapply(author_list,function(x) tail(x, 1))) %>%
  mutate(last_author = str_trim(last_author)) %>% 
  #mutate(second_author = sapply(author_list,function(x) {return(x[length(x)-1])})
  #mutate(second_author = ifelse(num_authors >1, map_chr(author_list, 2), NA))
  
  # levels: clinical science symposium, oral, plenary, poster discussion, poster 
  mutate(session_type = as.factor(session_type)) %>% 
  mutate(sub_track = as.factor(sub_track)) %>% 
  mutate(track = as.factor(track)) %>% 
  mutate(session_title = as.factor(session_title)) %>% 
  mutate(rct = ifelse(is.na(clin_trial_registration), 0, 1)) %>% 
  #need to remove several, pending no, jrcts and jrct are the same, 
  mutate(trial_registry = as.factor(str_extract(tolower(clin_trial_registration), "[a-z]+"))) %>% 
  #some trials with more than one registry - if multiple words - gives c(...)
  mutate(trial_registries = str_extract_all(tolower(clin_trial_registration), "[a-z]+")) %>% 
  #institutions ?make dictionary?? some places end in country, us places end in states? 
  #first author institution - before second comma I think - gives 1441 different places...needs neatening up...many are the same places but with different strings
  #? make dictionary of institutions
  mutate(first_auth_inst = as.factor(str_before_nth(author_organisation, ",", n=2)))%>% 
  #research funding
  mutate(research_funding = tolower(research_funding)) %>% 
  mutate(funding = ifelse(research_funding=="none", NA, 0)) #%>% 
  #mutate(funding = ifelse(str_detect(research_funding, c("roche", "flatiron", "genentech", "chugai")), "roche", funding)) %>% 
  #mutate(funding = ifelse(research_funding %in% c("^roche$", "flatiron", "genentech", "chugai"), "roche", funding)) %>% 

  select(author_organisation, first_auth_inst, research_funding, funding) 
  






#-----------------
#Analysis#########
#-----------------

##histogram of number of authors

asco_abs_new %>% 
  ggplot(aes(x=num_authors))+
  geom_histogram(fill="#E69F00", color="black", binwidth=1)+
  labs(title="Number of authors per abstract", x="No. Authors", y="Count")+
  theme_classic()

##Number of abstracts per track


#require(extrafont)
# need only do this once!
#font_import(pattern="[A/a]rial", prompt=FALSE)
#require(ggplot2)

#pdf("No.abstracts.per.track.pdf")
asco_abs_new %>% 
  ggplot(aes(x=num_authors, color=sub_track, fill=sub_track))+
  geom_histogram(alpha=0.6, binwidth=1)+
  scale_fill_viridis(discrete=TRUE) +
  scale_color_viridis(discrete=TRUE) +
  theme_ipsum() +
  labs(title="Number of authors per abstract", x="No. Authors", y="Count")+
  theme(
    legend.position="none",
    panel.spacing = unit(0.1, "lines"),
    strip.text.x = element_text(size = 7)
  ) +
  xlab("") +
  ylab("Assigned Probability (%)") +
  facet_wrap(~sub_track)
#ggsave("authors_per_abstract_track_histo.pdf", width=10, height=8)
#dev.off()

##Pie charts RCT registration 

RCT_pie_data <- asco_abs_new %>% 
  select(rct) %>% 
  group_by(rct) %>% 
  count() %>% 
  ungroup()

data <- RCT_pie_data %>% 
  arrange(desc(rct)) %>%
  mutate(prop = n / sum(RCT_pie_data$n) *100) %>%
  mutate(ypos = cumsum(prop)- 0.5*prop )

#pdf("authors_per_abstract.pdf")
ggplot(data, aes(x="", y=prop, fill=factor(rct))) +
  geom_bar(stat="identity", width=1, color="white") +
  coord_polar("y", start=0) +
  theme_void() + 
  theme(legend.position="none") +
  labs(title="Proportion of Randomised controlled trials")+
  geom_text(aes(y = ypos, label = c("Non-RCT", "RCT")), color = "white", size=6) +
  
  scale_fill_brewer(palette="Set1")

#dev.off()

##Stacked bar chart for RCT vs Non RCT by disease 

#tracks to remove
remove_tracks <- c("Health Services Research and Quality Improvement", "Professional Development and Education Advances"
                   , "Care Delivery and Regulatory Policy")

#levels(asco_abs_new$track)
  
asco_stack <- asco_abs_new %>% 
  select(track, rct) %>% 
  filter(!track %in% remove_tracks) %>% 
  filter(!is.na(track)) %>% 
  mutate(track=as.character(track)) %>% 
  mutate(track = ifelse(track == "Lung Cancer,Lung Cancer", "Lung Cancer", track)) %>% 
  mutate(track = ifelse(track == "Gastrointestinal Cancer-Gastroesophageal, Pancreatic, and Hepatobiliary" , "Upper Gastrointestinal", track)) %>%
  mutate(track = ifelse(track == "Gastrointestinal Cancer-Colorectal and Anal", "Lower Gastrointestinal", track)) %>% 
  mutate(track = ifelse(track == "Developmental Therapeutics-Molecularly Targeted Agents and Tumor Biology", "Tumor biology and molecular targets", track)) %>% 
  mutate(track = ifelse(track == "Prevention, Risk Reduction, and Hereditary Cancer", "Hereditary cancer and prevention", track)) %>% 
  mutate(track = ifelse(track == "Genitourinary Cancer-Kidney and Bladder", "Kidney and Bladder Ca", track)) %>%
  mutate(track = ifelse(track == "Genitourinary Cancer-Prostate, Testicular, and Penile", "Prostate, Testicular, and Penile Ca", track))


levels(as.factor(asco_stack$track))
class(asco_stack$track)

stack_graph <- asco_stack%>% 
  select(track, rct) %>% 
  #mutate(rct = as.character(rct)) %>% 
  count(track, rct) %>% 
  group_by((track)) %>% 
  mutate(prop = prop.table(n)) %>% 
  filter(rct=="1") %>% 
  arrange(prop)

lvls <- as.character(stack_graph$track)

asco_stack %>%
  mutate(track = factor(track, levels = lvls)) %>%
  filter(!is.na(track)) %>% 
  mutate(rct = recode_factor(rct, '0'="Non-RCT", '1'="RCT")) %>%
  ggplot(aes(x = track, fill = factor(rct))) +
  geom_bar(position ="fill") +
  scale_fill_brewer(palette = "Set2", name="")+
  labs(title= "Proportion RCTs by cancer track", y = "Proportion", x="ASCO Track")+
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position="bottom")



##Number of abstracts per track

author_count <- asco_abs_new %>% 
  count(first_author) %>% 
  arrange(desc(n)) %>%
  slice(1:20)

#write.csv(author_count, "top_20_first_authors.csv")

l_author_count <-asco_abs_new %>% 
  count(last_author) %>% 
  arrange(desc(n)) %>%
  slice(1:20)
#write.csv(l_author_count, "top_20_last_authors.csv")

#ggplot(asco_abs_new, aes(x=factor(last_author)))+
#  geom_bar(position="dodge")

#levels(as.factor(asco_abs_new$last_author))

##Network analysis 

##data frame of two columns - 1st and last author 

df_first_last_aut <- asco_abs_new %>% 
  filter(track=="Hematologic Malignancies") %>% 
  select(first_author, last_author)
  

#returns object 
g<- graph.edgelist(as.matrix(df_first_last_aut), directed=TRUE)
g

## returns all vertices in network - 3499
V(g) 

#number vertices
gorder(g)

#number edges 
gsize(g)

##returns all edges - 2182
E(g)

#simple visualisation 
plot(g)
