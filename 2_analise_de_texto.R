set.seed(2024)

# Funções

`%!in%` <- Negate(`%in%`)

## Função principal de pré-processamento de texto
preprocess_text <- function(text) {
  regex_numeros_romanos <- "(?i)\\s+(?=[MDCLXVI])M{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})\\s+" ## Expressão regular para números romanos (case insensitive)
  text |>
  stringr::str_to_lower() |>
  abjutils::rm_accent() |> 
  stringr::str_replace_all("\\d+", " ") |> # Remove números
  stringr::str_replace_all(regex_numeros_romanos, " ") |>
  stringr::str_replace_all("[^[:alnum:][:space:]]", " ") |>
  stringr::str_replace_all("\\s+[a-z]\\s+", " ") |> # remove letras soltas no texto
  stringr::str_replace_all("ubdki[a-z]+-", "") |>  # remove sequencia de texto sem sentido, deve ser código de algo
  stringr::str_squish() |> 
  stringr::str_trim() |> 
  stringr::str_replace_all("conselho de administracao", "cons_adm") |>
  stringr::str_replace_all("ato cooperativo", "ato_coop") |>
  stringr::str_replace_all("conselho fiscal", "cons_fiscal") |>
  stringr::str_replace_all("membros da diretoria", "membros_diretoria") |> 
  stringr::str_replace_all("cooperativa de credito", "coop_cred") |> 
  stringr::str_replace_all("cooperativas de credito", "coop_cred") |>
  stringr::str_replace_all("banco central", "bcb") |> 
  stringr::str_replace_all("orgao estatutario", "orgao_estatutario") |> 
  stringr::str_replace_all("credito mutuo", "cred_mutuo") |> 
  stringr::str_replace_all("operacoes de credito", "op_cred") |>
  stringr::str_replace_all("rurais", "rural") |> 
  stringr::str_replace_all("cooperativas centrais", "coop_central") |> 
  stringr::str_replace_all("cooperativa central", "coop_central") |> 
  stringr::str_replace_all("coop_cred central", "coop_central") |> 
  stringr::str_replace_all("assembleia geral", "assem_geral")
}

# Carregar e preparar os dados
normative_txt <- readr::read_csv("normative_txt_2020a202409.csv") |> 
  janitor::clean_names()

textos <- normative_txt |>  
  dplyr::select(titulo, data, texto)

textos$texto_processado <- sapply(textos$texto, preprocess_text)

# Tokenização e remoção de stop words
## Palavras e padrões a serem removidos ou substituídos
stop_words <- 
  tibble::tibble(word = c(
    stopwords::stopwords("pt"), 
    "cpf",
    "cnpj",
    "n°", 
    "nº",             
    "data",        
    "art",         
    "º",  
    "despacho",               
    "brasil",      
    "silva",
    "nome",
    "nomes",
    "ser",
    "trata",
    "bcb",
    "lei",
    "inciso",
    "jose",
    "resolucao",
    "lei", 
    "forma",
    "geral",
    "processo",
    "carlos",
    "ato",
    "caput",
    "capitulo",
    "rodrigues",
    "souza",
    "antonio",
    "luiz",
    "pereira",
    "roberto",
    "ltda",
    "paragrafo",
    "cuja",
    "registrar",
    "ubdkifjactswrlmnhyz",
    ""
  ))

tokens <- textos |>
  tidytext::unnest_tokens(word, texto_processado) |>
  dplyr::anti_join(
  stop_words, by = "word")  

# Criar uma matriz documento-termo
dtm <- tokens |>
  dplyr::count(documento = dplyr::row_number(), word) |>
  tidytext::cast_dtm(documento, word, n)

# Ajustar o modelo LDA
## Ajuste o número de tópicos (k) conforme necessário
lda_model <- topicmodels::LDA(dtm, k = 6, control = list(seed = 1234))

## Extrair os principais termos para cada tópico
top_terms <- tidytext::tidy(lda_model, matrix = "beta") |>
  dplyr::group_by(topic) |>
  dplyr::top_n(15, beta) |> # quantidade de palavras
  dplyr::ungroup() |>
  dplyr::arrange(topic, -beta)

## Visualizar os principais termos para cada tópico
top_terms |>
  dplyr::mutate(term = tidytext::reorder_within(term, beta, topic)) |>
  ggplot2::ggplot(ggplot2::aes(term, beta, fill = factor(topic))) +
  ggplot2::geom_col(show.legend = FALSE) +
  ggplot2::facet_wrap(~ topic, scales = "free") +
  ggplot2::coord_flip() +
  tidytext::scale_x_reordered()

## Atribuir tópicos aos documentos originais
documento_topicos <- tidytext::tidy(lda_model, matrix = "gamma") |>
  dplyr::group_by(document) |>
  dplyr::top_n(1, gamma) |>
  dplyr::ungroup() |>
  dplyr::mutate(document = as.integer(document))  # Converter 'document' para inteiro

## Juntar os tópicos atribuídos aos dados originais
dados_com_topicos <- textos |>
  dplyr::mutate(documento = dplyr::row_number()) |>
  dplyr::inner_join(documento_topicos, by = c("documento" = "document"))

## Exibir um resumo dos tópicos atribuídos
print(dados_com_topicos |> dplyr::select(titulo, topic, gamma))

dados_com_topicos |> dplyr::count(topic)


# Bigram

## Usar texto ou texto_processado?? Remover stop_words antes?
textos |> 
  tidytext::unnest_tokens(bigram, texto_processado, token = "ngrams", n = 2) |> 
  dplyr::filter(!is.na(bigram)) |> 
  tidyr::separate(bigram, c("word1", "word2"), sep = " ") |> 
  dplyr::filter(word1 %!in% stop_words$word &
                word2 %!in% stop_words$word) |> 
  dplyr::group_by(titulo) |> 
  dplyr::count(word1, word2, sort = TRUE)


# Trigram

## Usar texto ou texto_processado?? Remover stop_words antes?
textos |> 
  tidytext::unnest_tokens(trigram, texto_processado, token = "ngrams", n = 3) |> 
  dplyr::filter(!is.na(trigram)) |> 
  tidyr::separate(trigram, c("word1", "word2", "word3"), sep = " ") |> 
  dplyr::filter(word1 %!in% stop_words$word & 
                word2 %!in% stop_words$word &
                word3 %!in% stop_words$word) |> 
  dplyr::group_by(titulo) |> 
  dplyr::count(word1, word2, word3, sort = TRUE) 

# Gráficos

textos |> 
  tidytext::unnest_tokens(bigram, texto_processado, token = "ngrams", n = 2) |> 
  dplyr::filter(!is.na(bigram)) |> 
  tidyr::separate(bigram, c("word1", "word2"), sep = " ") |> 
  dplyr::filter(word1 %!in% stop_words$word &
                word2 %!in% stop_words$word) |> 
  dplyr::group_by(titulo) |> 
  dplyr::count(word1, word2, sort = TRUE) |> 
  dplyr::filter(n > 150) |> 
  igraph::graph_from_data_frame() |> 
  ggraph::ggraph(layout = "fr") +
  ggraph::geom_edge_link() +
  ggraph::geom_node_point() +
  ggraph::geom_node_text(ggplot2::aes(label = name), vjust = 1, hjust = 1)
    