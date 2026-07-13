# {{title}}

**Citekey::** {{citekey}}
**Title::** {{title}}
**Authors::** {% for creator in creators %}{{creator.firstName}} {{creator.lastName}}{% if not loop.last %}, {% endif %}{% endfor %}
**Year::** {{date | format("YYYY")}}
**Publication::** {% if publicationTitle %}{{publicationTitle}}{% elif publisher %}{{publisher}}{% endif %}
**URL::** {% if DOI %}https://doi.org/{{DOI}}{% else %}{{url}}{% endif %}

## Abstract
{{abstractNote}}

## Reading Notes
{% for annotation in annotations -%}
{% if annotation.annotatedText -%}
> {{annotation.annotatedText}}
{% endif -%}
{% if annotation.comment -%}
**Note:** {{annotation.comment}}
{% endif -%}

{% endfor -%}

## Relevance to Thesis
<!-- After import: link to chapters / RQs, e.g. [[01-引言]], RQ1 -->
