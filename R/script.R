# library(rvest)
# library(stringr)
# library(dplyr)
#
#
# scholar_url <- "https://scholar.google.com/scholar?start=10&q=%22sa%C3%BAde+da+popula%C3%A7%C3%A3o+negra%22&hl=pt-BR&as_sdt=0,5"
#
# scholar_url <- function(query, num_pages = 1, language = "EN") {
#
#   num_pages <- seq(0, num_pages -1) * 10
#   if (language == "PT-BR") {
#     language <- "&hl=pt-BR"
#   } else {
#     language <- NULL
#   }
#
#   scholar_url <- paste0(
#     "https://scholar.google.com/scholar?",
#     "start=", num_pages, "&",
#     "q=", str_replace_all(query, " ", "+"),
#     language
#   )
#
#   scholar_url
# }
#
#
#
# scholar_html <- read_html(scholar_url)
#
# # titulos
# titles <- scholar_html %>%
#   html_nodes('.gs_rt') %>%
#   html_text() %>%
#   stringr::str_remove_all("\\[.*\\]") %>%
#   str_trim()
#
# # autores
#
# # Autor
# authors_years <- scholar_html %>%
#   html_nodes('.gs_a') %>%
#   html_text()
#
# authors <- str_remove(authors_years, "\\s-\\s.*")
# # Ano
# years <- str_extract(authors_years, "\\d{4}")
#
# # journal
# journal <- str_extract(authors_years, "\\s-\\s.*\\s-\\s|\\s-\\s.*") %>%
#   str_remove_all("\\s-\\s")
#
# # citation
# citation <- scholar_html %>%
#   html_nodes('.gs_fl a') %>%
#   html_text() %>%
#   as_tibble() %>%
#   rename(citation = value) %>%
#   mutate(citation = if_else(
#     str_detect(citation, "Citar"), lead(citation), NULL
#   )) %>%
#   na.omit() %>%
#   mutate(citation = if_else(
#     str_detect(citation, "Citado"),
#     as.numeric(str_remove(citation, "Citado por ")), 0
#   ))
#
# # links
# article_id_link <- tibble(
#   article_id = scholar_html %>%
#     html_nodes('.gs_rt a') %>%
#     html_attr("id"),
#   article_link = scholar_html %>%
#     html_nodes('.gs_rt a') %>%
#     html_attr("href")
# )
#
# article_id <- scholar_html %>%
#   html_nodes('.gs_or') %>%
#   html_attr("data-cid") %>%
#   as_tibble() %>%
#   rename(article_id = value)
#
# links <- left_join(article_id, article_id_link, by = "article_id") %>%
#   select(article_link)
#
# tibble(
#   titulo = titles,
#   autores = authors,
#   ano = years,
#   revista = journal,
#   citacao = citation$citation,
#   link = links$article_link
# )
#
#
#
#
#
#
#
