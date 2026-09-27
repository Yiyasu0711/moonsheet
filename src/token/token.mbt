// MoonSheet Token Types
// Token definitions for the formula lexer

/// Token type enumeration for formula tokens
pub enum TokenType {
  // Literals
  Number       // numeric literal like 42, 3.14
  StringLit   // string literal like "hello"
  BoolLit     // boolean literal: TRUE, FALSE
  // Identifiers and references
  Identifier  // function names, named ranges
  CellRef     // cell reference like A1, $B$2
  RangeRef    // range reference like A1:B2
  // Operators
  Plus        // +
  Minus       // -
  Star        // *
  Slash       // /
  Percent     // %
  Caret       // ^
  Ampersand   // &
  // Comparison operators
  Equal       // =
  NotEqual    // <>
  LessThan    // <
  GreaterThan // >
  LessEqual   // <=
  GreaterEqual // >=
  // Punctuation
  LParen      // (
  RParen      // )
  Comma       // ,
  Colon       // :
  // Special
  EOF         // end of input
} derive(Show, Eq, Compare)

/// A token produced by the lexer
pub struct Token {
  pub kind : TokenType
  pub value : String
  pub pos : Int        // position in input string
  pub line : Int       // line number (1-based)
  pub col : Int        // column number (1-based)
} derive(Show)

/// Create a new token
pub fn Token::new(kind : TokenType, value : String, pos : Int, line : Int, col : Int) -> Token {
  Token { kind, value, pos, line, col }
}

/// Create an EOF token
pub fn Token::eof(pos : Int, line : Int, col : Int) -> Token {
  Token { kind: EOF, value: "", pos, line, col }
}

/// Get token type name as string
pub fn TokenType::to_string(self : TokenType) -> String {
  match self {
    Number => "Number"
    StringLit => "StringLit"
    BoolLit => "BoolLit"
    Identifier => "Identifier"
    CellRef => "CellRef"
    RangeRef => "RangeRef"
    Plus => "Plus"
    Minus => "Minus"
    Star => "Star"
    Slash => "Slash"
    Percent => "Percent"
    Caret => "Caret"
    Ampersand => "Ampersand"
    Equal => "Equal"
    NotEqual => "NotEqual"
    LessThan => "LessThan"
    GreaterThan => "GreaterThan"
    LessEqual => "LessEqual"
    GreaterEqual => "GreaterEqual"
    LParen => "LParen"
    RParen => "RParen"
    Comma => "Comma"
    Colon => "Colon"
    EOF => "EOF"
  }
}

/// Check if token is a comparison operator
pub fn Token::is_comparison(self : Token) -> Bool {
  match self.kind {
    Equal | NotEqual | LessThan | GreaterThan | LessEqual | GreaterEqual => true
    _ => false
  }
}

/// Check if token is an additive operator
pub fn Token::is_additive(self : Token) -> Bool {
  match self.kind {
    Plus | Minus => true
    _ => false
  }
}

/// Check if token is a multiplicative operator
pub fn Token::is_multiplicative(self : Token) -> Bool {
  match self.kind {
    Star | Slash | Percent => true
    _ => false
  }
}

/// Check if token is a power operator
pub fn Token::is_power(self : Token) -> Bool {
  match self.kind {
    Caret => true
    _ => false
  }
}

/// Check if token is a literal
pub fn Token::is_literal(self : Token) -> Bool {
  match self.kind {
    Number | StringLit | BoolLit => true
    _ => false
  }
}

/// Check if token is an identifier
pub fn Token::is_identifier(self : Token) -> Bool {
  match self.kind {
    Identifier => true
    _ => false
  }
}

/// Check if token is a reference
pub fn Token::is_reference(self : Token) -> Bool {
  match self.kind {
    CellRef | RangeRef => true
    _ => false
  }
}

/// Check if token is an operator
pub fn Token::is_operator(self : Token) -> Bool {
  match self.kind {
    Plus | Minus | Star | Slash | Percent | Caret | Ampersand |
    Equal | NotEqual | LessThan | GreaterThan | LessEqual | GreaterEqual => true
    _ => false
  }
}

/// Get operator precedence (higher = binds tighter)
pub fn Token::precedence(self : Token) -> Int {
  match self.kind {
    Equal | NotEqual | LessThan | GreaterThan | LessEqual | GreaterEqual => 1
    Ampersand => 2
    Plus | Minus => 3
    Star | Slash | Percent => 4
    Caret => 5
    _ => 0
  }
}

/// Check if operator is right-associative
pub fn Token::is_right_associative(self : Token) -> Bool {
  match self.kind {
    Caret => true
    _ => false
  }
}

/// Check if token is EOF
pub fn Token::is_eof(self : Token) -> Bool {
  match self.kind {
    EOF => true
    _ => false
  }
}

/// Check if token is LParen
pub fn Token::is_lparen(self : Token) -> Bool {
  match self.kind {
    LParen => true
    _ => false
  }
}

/// Check if token is RParen
pub fn Token::is_rparen(self : Token) -> Bool {
  match self.kind {
    RParen => true
    _ => false
  }
}

/// Check if token is Comma
pub fn Token::is_comma(self : Token) -> Bool {
  match self.kind {
    Comma => true
    _ => false
  }
}

/// Get token value
pub fn Token::get_value(self : Token) -> String {
  self.value
}

/// Get token kind
pub fn Token::get_kind(self : Token) -> TokenType {
  self.kind
}

/// Check if two tokens are equal (by kind and value)
pub fn Token::equals(self : Token, other : Token) -> Bool {
  self.kind == other.kind && self.value == other.value
}

/// Create token from a single character operator
pub fn Token::from_char(ch : Int, pos : Int, line : Int, col : Int) -> Token? {
  match ch {
    43 => Some(Token::new(Plus, "+", pos, line, col))        // +
    45 => Some(Token::new(Minus, "-", pos, line, col))       // -
    42 => Some(Token::new(Star, "*", pos, line, col))        // *
    47 => Some(Token::new(Slash, "/", pos, line, col))       // /
    37 => Some(Token::new(Percent, "%", pos, line, col))     // %
    94 => Some(Token::new(Caret, "^", pos, line, col))       // ^
    38 => Some(Token::new(Ampersand, "&", pos, line, col))    // &
    40 => Some(Token::new(LParen, "(", pos, line, col))      // (
    41 => Some(Token::new(RParen, ")", pos, line, col))      // )
    44 => Some(Token::new(Comma, ",", pos, line, col))       // ,
    58 => Some(Token::new(Colon, ":", pos, line, col))       // :
    _ => None
  }
}
