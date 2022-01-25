#' @export
scholar_df <- function(query, num_pages, language = "EN") {

  scholar_urls <- scholar_url(
    query = query,
    num_pages = num_pages,
    language = language
  )

  do.call("rbind",
    lapply(scholar_urls, scholar_df_one_page)
  )
}

#' @importFrom dplyr %>%
scholar_df_one_page <- function(scholar_url){

  scholar_html <- rvest::read_html(scholar_url)

  # titulos
  titles <- scholar_html %>%
    rvest::html_nodes('.gs_rt') %>%
    rvest::html_text() %>%
    stringr::str_remove_all("\\[.*\\]") %>%
    stringr::str_trim()

  # autores

  # Autor
  authors_years <- scholar_html %>%
    rvest::html_nodes('.gs_a') %>%
    rvest::html_text()

  authors <- stringr::str_remove(authors_years, "\\s-\\s.*")
  # Ano
  years <- stringr::str_extract(authors_years, "\\d{4}")

  # journal
  journal <- stringr::str_extract(authors_years, "\\s-\\s.*\\s-\\s|\\s-\\s.*") %>%
    stringr::str_remove_all("\\s-\\s")

  # citation
  citation <- scholar_html %>%
    rvest::html_nodes('.gs_fl a') %>%
    rvest::html_text() %>%
    dplyr::as_tibble() %>%
    dplyr::rename(citation = value) %>%
    dplyr::mutate(citation = dplyr::if_else(
      stringr::str_detect(citation, "Citar"), dplyr::lead(citation), NULL
    )) %>%
    stats::na.omit() %>%
    dplyr::mutate(citation = dplyr::if_else(
      stringr::str_detect(citation, "Citado"),
      as.numeric(stringr::str_remove(citation, "Citado por ")), 0
    ))

  # links
  article_id_link <- dplyr::tibble(
    article_id = scholar_html %>%
      rvest::html_nodes('.gs_rt a') %>%
      rvest::html_attr("id"),
    article_link = scholar_html %>%
      rvest::html_nodes('.gs_rt a') %>%
      rvest::html_attr("href")
  )

  article_id <- scholar_html %>%
    rvest::html_nodes('.gs_or') %>%
    rvest::html_attr("data-cid") %>%
    dplyr::as_tibble() %>%
    dplyr::rename(article_id = value)

  links <- dplyr::left_join(article_id, article_id_link, by = "article_id") %>%
    dplyr::select(article_link)

  dplyr::tibble(
    titulo = titles,
    autores = authors,
    ano = years,
    revista = journal,
    citacao = citation$citation,
    link = links$article_link
  )
}
