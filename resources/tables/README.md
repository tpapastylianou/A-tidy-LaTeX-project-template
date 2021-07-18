Place all your tables here, as a single .tex file per table, containing the
relevant "tabular" block.

If possible, use the same filename as the reference label used in your text to
refer to the respective table.

Only include "tabular" environments in these files; do not include any
"\begin{table}" statements etc: these should be inserted in the main latex
document instead, to allow the main document to control the positioning of the
table.

E.g., if you have a table file called "ExampleTable.tex", then this means that
in your main file, you would include this table like so:


    \begin{table}[h]
      \caption{An example table}
      \centering
      \input{resources/tables/ExampleTable}
      \label{tab:ExampleTable}
    \end{table}

