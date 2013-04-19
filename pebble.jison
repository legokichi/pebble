%lex
%%

\s+                    return 'SPACE'
[0-9]+                 return 'NUMBER'
[a-zA-Z]+              return 'SYMBOL'
"("                    return '('
")"                    return ')'
<<EOF>>                return 'EOF'
/lex

%%

file
  : sExp EOF            return $sExp
  ;

sExpList
  : sExp                $$ = [$sExp]
  | sExpList SPACE sExp $$ = $sExpList.concat([$sExp])
  ;

sExp
  : atom
  | list
  ;

atom
  : SYMBOL              $$ = yytext
  | Number              $$ = Number(yytext)
  ;

list
  : '(' ')'             $$ = []
  | '(' sExpList ')'    $$ = $sExpList
  ;