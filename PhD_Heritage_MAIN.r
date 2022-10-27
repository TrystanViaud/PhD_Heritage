#-----------------------------------------------------------------------
#-----------------------------Chargement des packages------------------
#----------------------------------------------------------------------

# install.packages(c("tidyverse", "igraph", "rvest", "pingr"))

library(tidyverse)
library(lubridate)
library(igraph)
library(rvest)
library(pingr)


#--------------------------------------------------------------------
#-------------------------- SCRIPT PRINCIPAL -------------------------
#--------------------------------------------------------------------

discipline <- readline("Discipline : ") #ex : Taper Geographie

motcle <- readline("mot cl� ? : ") #ex : Taper "Saint-Julien" ou "mobilit�s" (taper "%20" � la place des espaces...)

url_base <- paste("https://theses.fr/fr/?q=",motcle,"&checkedfacets=discipline=",discipline, sep="") #cr�ation de la requ�te http get

print(url_base) #v�rif de l'url

page_accueil <- read_html(url_base) #requete et r�cup du code html

resultats <- page_accueil %>% html_nodes("div#resultat") #on r�cup sur la page la div contenant les r�sultats de la recherche

infos_theses <- resultats %>% html_nodes("div.informations") #on r�cup dans les r�sultats les div contenant les infos de chaque th�se

infos_tmp <- infos_theses %>% html_text() %>% data.frame(RESULTS = .) #on convertir le html en texte pour affichage test
result_tmp #affichage pour v�rif


#dans la div resultats on r�cup les dates (petit encart � droite du nom de la th�se)
dates_theses <- resultats %>% html_nodes("h5.soutenue") %>% html_text()
dates_theses <- str_split(string=dates_theses, pattern=" ", simplify=TRUE)[,3]
dates_theses <- dates_theses %>% str_sub(., -4, -1) %>% as.integer()


#on r�cup�re la discipline
discipline_theses <- resultats %>% html_nodes("div.domaine") %>% html_node("h5") %>% html_text()



