# bacenr: pacote em R para download e análise de dados do Banco Central do Brasil

O objetivo deste trabalho de conclusão de curso será criar um pacote em R e disponibilizá-lo de forma que qualquer pessoa possa acessar os dados com facilidade, mesmo aquelas que possuam pouco conhecimento em programação.

Também será feita uma demonstração de análise de dados baixados através deste pacote.

As informações baixadas serão: 

 - Normas reguladoras
 - Balanços e Balancetes

Para instalar o pacote, acesse [https://github.com/rtheodoro/bacenR](https://github.com/rtheodoro/bacenR)


### Contribuição

Sinta-se à vontade para contribuir com melhorias e novas funcionalidades. Abra uma issue ou envie um pull request.
Licença

Este projeto está licenciado sob a MIT License.

### Autor

- [Ricardo Theodoro](https://www.linkedin.com/in/rtheodoro/)


---

Documentação futura sobre download das normas reguladoras:

### Descrição

Este repositório contém scripts em R para baixar, processar e analisar dados normativos do site do Banco Central do Brasil. O objetivo é extrair informações relevantes de normativos específicos, como tipos de normativos, números, assuntos e textos associados, para fins de análise e pesquisa.
Estrutura do Repositório

    webscrapping_txt_normas_bacen.R: Script para baixar dados normativos do site do Banco Central do Brasil em formato JSON, processá-los e extrair informações específicas.

### Resultados obtidos

```r
> names(normative_data)
 [1] "title"                   "RefinableString01"       "AssuntoNormativoOWSMTXT" "ResponsavelOWSText"      "listItemId"              "TipodoNormativoOWSCHCS"  "NumeroOWSNMBR"           "RevogadoOWSBOOL"         "HitHighlightedSummary"  
[10] "CanceladoOWSBOOL"        "data"                    "RefinableString03"       "RowNumber"

> names(normative_txt)
 [1] "Titulo"           "Tipo"             "DOU"              "Id"               "Data"             "DataTexto"        "Numero"           "Assunto"          "Revogado"         "Cancelado"        "Texto"            "Voto"            
[13] "Documentos"       "VersaoNormativo"  "NormasVinculadas" "Referencias"      "Atualizacoes"    
```

### Instruções de Uso

    Clone o repositório para o seu ambiente local.
    Instale os pacotes necessários.
    Execute o script normativos_analysis.R para baixar, processar e analisar os dados normativos.