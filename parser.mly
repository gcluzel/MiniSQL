%{

open DataType

%}

%token <string> VAL FILE
%token IN NOT DOT COMMA SELECT FROM WHERE MINUS UNION AS
%token EQ LT AND OR GROUP ORDER BY MAX MIN COUNT AVG SUM
%token LPAREN RPAREN QUOTES
%token EOF




%start main
%type <DataType.requete> main
%%

main:
  | s EOF                                       { $1 }
;


s:
  | SELECT atts FROM rels WHERE cond                       { Where ({ col = $2 ; table = $4 ; cond = $6 }) }
  | LPAREN s RPAREN MINUS LPAREN s RPAREN                  { Minus($2, $6) }
  | LPAREN s RPAREN UNION LPAREN s RPAREN                  { Union($2, $6) }
  | s GROUP BY att                                         { Group($1, $4) }
  | s ORDER BY atts                                        { Order($1, $4) }
  ;

rels:
  | rel COMMA rels                              { $1 :: $3 }
  | rel                                         { [ $1 ] }
;

rel:
  | LPAREN s RPAREN id                          { Req($2, $4) }
  | filename id                                 { File($1, $2) }
  ;

atts:
  | attd COMMA atts                             { $1 @ $3 }
  | attd                                        { $1 }
  ;

attd:
  | atttype AS id                                   { [ Rename($1, $3) ] }
  | atttype                                         { [ Col($1) ] }
;

atttype:
  | id DOT id                                   { CID ($1, $3) }
  | MAX LPAREN att RPAREN                       { Max($3) }
  | MIN LPAREN att RPAREN                       { Min($3) }
  | AVG LPAREN att RPAREN                       { Avg($3) }
  | SUM LPAREN att RPAREN                       { Sum($3) }
  | COUNT LPAREN att RPAREN                     { Count($3) }

att:
  | id DOT id                                    { ID ($1, $3) }
;

id:
  | VAL                                           { $1 }
;

cond:
  | and_cond OR cond                               { Or($1, $3) }
  | and_cond                                       { $1 }

and_cond:
  | at_cond AND and_cond                           { And($1, $3) }
  | at_cond                                        { $1 }
;

at_cond:
  | att EQ att                                      { Rel($1, Eq, $3) }
  | att LT att                                      { Rel($1,Lt, $3) }
  | att IN LPAREN s RPAREN                          { In($1,$4) }
  | att NOT IN LPAREN s RPAREN                      { NotIn($1,$5) }
;

filename:
  | QUOTES FILE QUOTES                                            { $2 }
  ;
