# It's a minimal lisp interpreter written in Ruby-lang
# Author: @vonhyou
# Start at: Apr. 10, 2021

def tokenize(program)
  # Convert scripts to token lists
  replacements = { '(' => ' ( ', ')' => ' ) ' }
  program.gsub(Regexp.union(replacements.keys), replacements)
         .split(' ')
end

def read_tokens(tokens)
  # read expressions from token
  raise SyntaxError, 'Unexpected EOF' if tokens.empty?

  token = tokens.shift
  if token == '('
    lst = []
    lst << read_tokens(tokens) while tokens[0] != ')'
    tokens.shift
    return lst
  elsif token == ')'
    raise SyntaxError, "Unexpected ')'"
  else
    return atom token
  end
end

def isInteger?(atom) = atom.match?(/^-?\d+$/)
def isFloat?(atom)   = atom.match?(/^(-?\d+)(\.\d+)?$/)

def atom(token)
  # Analyse numbers and symbols
  return Integer token if isInteger? token
  return Float   token if isFloat?   token
  token
end

