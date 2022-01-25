#' @export
scholar_url <- function(query, num_pages = 1, language = "EN") {

  num_pages <- seq(0, num_pages -1) * 10

  if (language == "PT-BR") {
    language <- "&hl=pt-BR"
  } else {
    language <- NULL
  }

  scholar_url <- paste0(
    "https://scholar.google.com/scholar?",
    "start=", num_pages, "&",
    "q=", stringr::str_replace_all(query, " ", "+"),
    language
  )

  scholar_url
}
