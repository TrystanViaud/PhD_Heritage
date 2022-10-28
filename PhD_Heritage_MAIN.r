#-----------------------------------------------------------------------
#-----------------------------Chargement des packages------------------
#----------------------------------------------------------------------

# install.packages(c("tidyverse", "igraph", "rvest", "pingr"))

library(tidyverse)
library(igraph)
library(rvest)
library(pingr)

#-------------------------------------------------------
#----------------Variables globales----------------------
langue <- "fr"

#------------------------------------------------------------------
#------------------ FONCTIONS -------------------------------------
#-----------------------------------------------------------------


#--------------------------------------------------------------------
#-------------------------- SCRIPT PRINCIPAL -------------------------
#--------------------------------------------------------------------

discipline <- readline("Discipline : ") #ex : Taper Geographie

motcle <- readline("mot cl� ? : ") %>% str_replace_all(" ", "%20")#ex : Taper "Saint-Julien" ou "mobilit�s" (taper "%20" � la place des espaces...)

url_base <- paste("https://theses.fr/fr/?q=",motcle,"&status=status:soutenue&checkedfacets=discipline=",discipline, sep="") #cr�ation de la requ�te http get

print(url_base) #v�rif de l'url

page_accueil <- read_html(url_base) #requete get et r�cup du code html

resultats <- page_accueil %>% html_nodes("div#resultat") #on r�cup sur la page la div contenant les r�sultats de la recherche

infos_theses <- resultats %>% html_nodes("div.informations") #on r�cup dans les r�sultats les div contenant les infos de chaque th�se

infos_tmp <- infos_theses %>% html_text() %>% data.frame(RESULTS = .) #on convertir le html en texte pour affichage test
infos_tmp$RESULTS #affichage des intitul�s pour v�rif



#dans la div resultats on r�cup les dates (petit encart � droite du nom de la th�se)
dates_theses <- resultats %>% html_nodes("h5.soutenue") %>% html_text() #r�cup�ration du contenue du petit encart soutenue � droite, dans un titre h5 de classe "soutenue" (texte vert sur le site)
dates_theses <- str_split(string=dates_theses, pattern=" ", simplify=TRUE)[,3] #on split le texte pour ne garder que la date
dates_theses <- dates_theses %>% str_sub(., -4, -1) %>% as.integer()#on ne garde que l'ann�e, convertie en nombre entier

#on r�cup�re la discipline
discipline_theses <- resultats %>% html_nodes("div.domaine") %>% html_node("h5") %>% html_text() #nom de la discipline dans une div de classe "domaine" (puis titre h5) dans l'encart � droite, convertie ensuite en texte

#on r�cup�re les noms, qui sont dans un lien dans un titre h2
noms_theses <- infos_theses %>% html_nodes("h2") %>% html_text() %>% str_replace_all("\r\n", "")

#on r�cup�re l'auteur
auteurs_theses <- infos_theses %>% html_nodes("p") %>% html_text()
auteurs_theses <- str_split(auteurs_theses, pattern="\r\n", simplify = TRUE)[,1]
auteurs_theses <- auteurs_theses %>% str_replace("par ", "") %>% str_to_title(locale=langue)
#id de l'auteur #premier lien a du paragraphe p
id_auteur <- infos_theses %>% html_node("p a:nth-child(1)") %>% html_attr("href") %>% substr(2,nchar(.))

#on r�cup�re l'encadrant num�ro 1 et l'universit� de soutenance
#nom du directeur
dir_theses <- infos_theses %>% html_nodes("p") %>% html_text()
dir_theses <- str_split(dir_theses, pattern="sous la direction de", simplify=TRUE)
dir_theses <- dir_theses[,2] %>% str_replace_all("\r\n", "") %>% str_replace_all(" \r\n", "") %>% substr(x=.,start=2, stop=nchar(.))
directeur_theses <- str_split(dir_theses, pattern=" - ", simplify=TRUE)[,1]
directeur_theses <- str_split(directeur_theses, pattern=" et de ", simplify=TRUE)[,1]
#id du dirthese #deuxi�me lien a du paragraphe p
id_dirtheses <- infos_theses %>% html_nodes("p a:nth-child(2)") %>% html_attr("href") %>% substr(2,nchar(.)) %>% str_replace_all("fr/", "")
#univ du directeur
univ_theses <- str_split(dir_theses, pattern=" - ", simplify=TRUE)[,2] %>% substr(x=.,start=1, stop=nchar(.)-2)

LIENS <- data.frame(ID_AUTEUR= id_auteur, AUTEUR=auteurs_theses, ANNEE= dates_theses, ID_DIR=id_dirtheses, DIR=directeur_theses, UNIV_DIR= univ_theses, INTITULE = noms_theses, DISCIPLINE = discipline_theses)

View(LIENS)
