grammar POSL;

// Currently a rulebase is defined as 0 or more clauses followed by an end of file charater
// This will likely be expanded in the future to allow for modules
rulebase:
    clause;

// A clause is one atom (the head), optionally followed by the separator (:-) and a list 
// of one or more atoms for the body of a rule, followed by a period to end the clause. 
clause:
    atom (':-' atoms)? '.';

// Defines a list of 1 or more atom - this is 1 atom followed by 0 or more
// repeats of a comma and atom.    
atoms:
    atom (',' atom) *;

// This defines an atom - this is a relation name, followed by a "(", an optional oid 
// and an optional parameter list (positional/slotted combination) and a closing ")".
atom:
    rel '(' ((oid)? |) (ps)? ')';

// This is the definition of a slotted/positional argument list combination.
// There are several options that describe all valid combinations; the most
// common forms would be the first option and the second option (with 2nd sub-case).
ps:
      // In this case the parameter list starts with 1 or more positional terms
      // this can optionally be followed by a positional rest parameter, 
      // slotted parameters (separated by a semi-colon (;)), and/or a 
      // slotted rest parameter
      pos (prest)? (';' slots)? (srest)?
      
      // In this case the parameter list starts with 1 or more slotted parameters
      // there are two sub cases for this rule
    | slots
        ( 
            // The first sub-case handles when there are no positional parameters;
            // there can optionally be a positional rest (and then optionally more 
            // slotted parameters) followed by an optional slotted rest parameter.
            (prest (';' slots)?)? (srest)?

            // The second sub-case handles when tere are positional parameters;
            // first there is a semi-colon then one or more positional parameters,
            // optionally followed by a positional rest parameter, more slotted 
            // parameters, and/or a slotted rest parameter 
            | ';' pos (prest)? (';' slots)? (srest)? 
        )
    // In this case the parameter list starts witha  positional rest parameter
    // It can optionally be followed by slotted parameters and a slotted rest
    | prest (';' slots)? (srest)?

    // The final case is having just a slotted rest parameter
    | srest 
    ;

// This is an oid; which is defined as a term followed by the (^) symbol.
// This may be expanded in the future to allow for multiple oids.
// While any term can be used, typically inds, variables, or skolems are used
oid:
     term '^';

// This is a positional rest term - this is a (|) symbol followed by
// a variable, or a plex that only has positional arguments
prest:
    '|' (variable | posplex);

// This is a slotted rest term - this is a (!) symbol by 
// a variable, or a plex that only has slotted arguments
srest:
    '!' (variable | slotplex);

// This is a sepcial version of plex that only allows positional terms (this is
// used for the definition of a positional rest).
posplex:
    '[' (pos)? (prest)? ']';

// This is a special version of plex that only allows slotted terms (this is used
// for the definition of slotted rest).
slotplex:
    '[' (slots)? (srest)? ']';

// Defines a list of 1 or more positional parameters - this is 1 term followed by 0 
// or more repeats of a comma and term.
pos:
    term (',' term) *; 

// Defines a list of 1 or more slotted parameters - this is 1 slot followed by 0 
// or more repeats of a semi-colon and slot.
slots:
    slot (';' slot) *;

// A slot is defined as being a role name, followed by an (->) symbol
// and any term
slot:
    role '->' term;

// A term can be either an ind, var, cterm, skolem, or plex
term:
      ind
    | variable
    | cterm
    | skolem
    | plex
    ;

cterm:
    ctor '[' (ps)? ']' (':' token_type)?;

plex:
    '[' (ps)? ']';

ctor:
    symbol;
    
rel:
    symbol;

role:
    symbol;

token_type: 
    symbol;

ind:
    (symbol (uri)? | uri) (':' token_type)?; 
        
skolem:
    '_' (symbol)? (':' token_type)?;

variable:
    '?' (symbol)? (':' token_type)?;

symbol:
      SYMBOL | QSYMBOL;

uri:
    URI;

URI:	'<' ('a'..'z'|'A'..'Z'|'0'..'9'|'_'|':'|'/'|'.'|'?'|'&'|'%'|'#'|'-')+ '>';
// this should be replaced with a better URI definition so that it meets the IETF
// standards for URI naming

SYMBOL:  ('-')? ('a'..'z'|'A'..'Z'|'0'..'9'|'$') ('a'..'z'|'A'..'Z'|'0'..'9'|'_'|'.'|'$')*; 
QSYMBOL: '"' (~('"'))* '"';

// For single‑line comments
COMMENT
    : '%' ~[\n\r]* ( [\n\r] | EOF) -> skip
    ;

// Multi line comments follows Prolog, and thus, C-style comment delimiters /* .... */
MLCOMMENT
    : '/*' ( MLCOMMENT | . )*? ('*/' | EOF) -> skip
    ;

WS
    : [ \t\r\n\u000C]+ -> skip
    ;