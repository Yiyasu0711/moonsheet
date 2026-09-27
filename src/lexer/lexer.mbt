// MoonSheet Lexer
// Tokenizes formula strings into tokens

/// The lexer state
pub struct Lexer {
  pub input : String
  pub pos : Int
  pub line : Int
  pub col : Int
  pub tokens : Array[@token.Token]
}

/// Create a new lexer
pub fn Lexer::new(input : String) -> Lexer {
  // Strip leading '=' if present
  let input = if input.length() > 0 && input[0] == 61 {
    input.substring(start=1)
  } else {
    input
  }
  Lexer { input, pos: 0, line: 1, col: 1, tokens: [] }
}

/// Check if at end of input
pub fn Lexer::is_at_end(self : Lexer) -> Bool {
  self.pos >= self.input.length()
}

/// Get current character (as Int code point)
pub fn Lexer::peek(self : Lexer) -> Int {
  if self.is_at_end() {
    0
  } else {
    self.input[self.pos]
  }
}

/// Get character at offset
pub fn Lexer::peek_at(self : Lexer, offset : Int) -> Int {
  let idx = self.pos + offset
  if idx >= self.input.length() || idx < 0 {
    0
  } else {
    self.input[idx]
  }
}

/// Advance to next character
pub fn Lexer::advance(self : Lexer) -> (Lexer, Int) {
  let ch = self.peek()
  let new_pos = self.pos + 1
  let new_col = self.col + 1
  let new_line = if ch == 10 { self.line + 1 } else { self.line }
  let new_col2 = if ch == 10 { 1 } else { new_col }
  (Lexer { input: self.input, pos: new_pos, line: new_line, col: new_col2, tokens: self.tokens }, ch)
}

/// Skip whitespace
pub fn Lexer::skip_whitespace(self : Lexer) -> Lexer {
  let mut l = self
  let mut done = false
  while not(done) {
    if l.is_at_end() {
      done = true
    } else {
      let ch = l.peek()
      if ch == 32 || ch == 9 || ch == 10 || ch == 13 {
        let (l2, _) = l.advance()
        l = l2
      } else {
        done = true
      }
    }
  }
  l
}

/// Read a number literal
pub fn Lexer::read_number(self : Lexer) -> (Lexer, @token.Token) {
  let mut l = self
  let mut result = ""
  let mut has_dot = false
  let mut has_e = false
  let mut done = false
  while not(done) {
    if l.is_at_end() {
      done = true
    } else {
      let ch = l.peek()
      if ch >= 48 && ch <= 57 {
        result = result + Char::from_int(ch).to_string()
        let (l2, _) = l.advance()
        l = l2
      } else if ch == 46 && not(has_dot) && not(has_e) {
        has_dot = true
        result = result + "."
        let (l2, _) = l.advance()
        l = l2
      } else if (ch == 69 || ch == 101) && not(has_e) {
        has_e = true
        result = result + "e"
        let (l2, _) = l.advance()
        l = l2
        // Check for + or - after e
        if not(l.is_at_end()) {
          let next = l.peek()
          if next == 43 || next == 45 {
            result = result + Char::from_int(next).to_string()
            let (l3, _) = l.advance()
            l = l3
          }
        }
      } else {
        done = true
      }
    }
  }
  (l, @token.Token::new(@token.Number, result, self.pos, self.line, self.col))
}

/// Read a string literal (enclosed in double quotes)
pub fn Lexer::read_string(self : Lexer) -> (Lexer, @token.Token) {
  let mut l = self
  // Skip opening quote
  let (l2, _) = l.advance()
  l = l2
  let mut result = ""
  let mut done = false
  let mut closed = false
  while not(done) {
    if l.is_at_end() {
      done = true
    } else {
      let ch = l.peek()
      if ch == 34 {
        // Closing quote
        let (l3, _) = l.advance()
        l = l3
        done = true
        closed = true
      } else if ch == 92 {
        // Escape sequence
        let (l3, _) = l.advance()
        l = l3
        if not(l.is_at_end()) {
          let next = l.peek()
          match next {
            110 => result = result + "\n"
            116 => result = result + "\t"
            114 => result = result + "\r"
            34 => result = result + "\""
            92 => result = result + "\\"
            _ => result = result + Char::from_int(next).to_string()
          }
          let (l4, _) = l.advance()
          l = l4
        }
      } else {
        result = result + Char::from_int(ch).to_string()
        let (l3, _) = l.advance()
        l = l3
      }
    }
  }
  (l, @token.Token::new(@token.StringLit, result, self.pos, self.line, self.col))
}

/// Read an identifier or cell reference
pub fn Lexer::read_identifier(self : Lexer) -> (Lexer, @token.Token) {
  let mut l = self
  let mut result = ""
  let mut done = false
  while not(done) {
    if l.is_at_end() {
      done = true
    } else {
      let ch = l.peek()
      if (ch >= 65 && ch <= 90) || (ch >= 97 && ch <= 122) || (ch >= 48 && ch <= 57) || ch == 95 || ch == 36 || ch == 46 {
        result = result + Char::from_int(ch).to_string()
        let (l2, _) = l.advance()
        l = l2
      } else {
        done = true
      }
    }
  }
  // Determine if it's a boolean, cell ref, or identifier
  let upper = result.to_upper()
  let kind = {
    if upper == "TRUE" || upper == "FALSE" {
      @token.BoolLit
    } else if is_cell_ref(result) {
      @token.CellRef
    } else {
      @token.Identifier
    }
  }
  (l, @token.Token::new(kind, result, self.pos, self.line, self.col))
}

/// Check if a string is a valid cell reference (A1, $A$1, B2, etc.)
fn is_cell_ref(s : String) -> Bool {
  let mut i = 0
  // Skip leading $ for absolute column
  if i < s.length() && s[i] == 36 {
    i = i + 1
  }
  // Must have at least one letter
  let mut has_letter = false
  while i < s.length() && s[i] >= 65 && s[i] <= 90 || i < s.length() && s[i] >= 97 && s[i] <= 122 {
    has_letter = true
    i = i + 1
  }
  if not(has_letter) {
    return false
  }
  // Skip $ for absolute row
  if i < s.length() && s[i] == 36 {
    i = i + 1
  }
  // Must have at least one digit
  let mut has_digit = false
  while i < s.length() && s[i] >= 48 && s[i] <= 57 {
    has_digit = true
    i = i + 1
  }
  has_digit && i == s.length()
}

/// Read a comparison operator (two-char or one-char)
pub fn Lexer::read_operator(self : Lexer) -> (Lexer, @token.Token) {
  let ch = self.peek()
  let next = self.peek_at(1)
  // Two-character operators
  if ch == 60 && next == 62 {
    // <>
    let (l, _) = self.advance()
    let (l2, _) = l.advance()
    (l2, @token.Token::new(@token.NotEqual, "<>", self.pos, self.line, self.col))
  } else if ch == 60 && next == 61 {
    // <=
    let (l, _) = self.advance()
    let (l2, _) = l.advance()
    (l2, @token.Token::new(@token.LessEqual, "<=", self.pos, self.line, self.col))
  } else if ch == 62 && next == 61 {
    // >=
    let (l, _) = self.advance()
    let (l2, _) = l.advance()
    (l2, @token.Token::new(@token.GreaterEqual, ">=", self.pos, self.line, self.col))
  } else {
    // Single character operator
    match @token.Token::from_char(ch, self.pos, self.line, self.col) {
      Some(tok) => {
        let (l, _) = self.advance()
        (l, tok)
      }
      None => {
        // Unknown character, skip it
        let (l, _) = self.advance()
        (l, @token.Token::new(@token.Identifier, Char::from_int(ch).to_string(), self.pos, self.line, self.col))
      }
    }
  }
}

/// Get the next token
pub fn Lexer::next_token(self : Lexer) -> (Lexer, @token.Token) {
  let l = self.skip_whitespace()
  if l.is_at_end() {
    (l, @token.Token::eof(l.pos, l.line, l.col))
  } else {
    let ch = l.peek()
    if ch >= 48 && ch <= 57 {
      l.read_number()
    } else if ch == 46 {
      // Could be a number starting with .
      l.read_number()
    } else if ch == 34 {
      l.read_string()
    } else if (ch >= 65 && ch <= 90) || (ch >= 97 && ch <= 122) || ch == 36 {
      l.read_identifier()
    } else {
      l.read_operator()
    }
  }
}

/// Tokenize the input and return all tokens
pub fn Lexer::tokenize(self : Lexer) -> Array[@token.Token] {
  let mut l = self.skip_whitespace()
  while not(l.is_at_end()) {
    l = l.skip_whitespace()
    if l.is_at_end() {
      break
    }
    let (l2, tok) = l.next_token()
    l = l2
    l.tokens.push(tok)
    l = l.skip_whitespace()
  }
  l.tokens.push(@token.Token::eof(l.pos, l.line, l.col))
  l.tokens
}

/// Convenience function to tokenize a formula string
pub fn tokenize(formula : String) -> Array[@token.Token] {
  Lexer::new(formula).tokenize()
}
