Place all your *labelled* equations here, as a single .tex file per equation,
containing the relevant equation code.

If possible, use the same filename as the reference label used in your text to
refer to the respective equation.

Do not include any "\begin{equation}" statements etc in your equation files;
these should be inserted in the main latex file instead.

E.g., if you have a file called "ExampleEquation.tex"
containing a mathematical formula, then this means that in your main file, you
would include this equation like so:

    \begin{equation}
      \label{eq:ExampleEquation}
      \input{resources/equations/ExampleEquation}.
    \end{equation}
