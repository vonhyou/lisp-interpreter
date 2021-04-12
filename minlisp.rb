# It's a minimal lisp interpreter written in Ruby-lang
# Author: @vonhyou
# Start at: Apr. 10, 2021

##### Parser
# :parse
# :tokenize
# :read_tokens
# :atom
#####

def parse(program)
  read_tokens(tokenize(program))
end

def tokenize(program)
  # Convert scripts to token lists
  replacements = { '(' => ' ( ', ')' => ' ) ' }
  program.gsub(Regexp.union(replacements.keys), replacements)
         .split(' ')
end

def make_list(tokens)
  lst = []
  lst << read_tokens(tokens) while tokens[0] != ')'
  tokens.shift
  lst
end

def read_tokens(tokens)
  # read expressions from token
  raise SyntaxError, 'Unexpected EOF' if tokens.empty?

  token = tokens.shift
  case token
  when '('
    make_list tokens
  when ')'
    raise SyntaxError, "Unexpected ')'"
  else
    atom token
  end
end

def atom(token)
  # Analyse numbers and symbols
  isInteger = ->(atom) { atom.match?(/^-?\d+$/) }
  isFloat   = ->(atom) { atom.match?(/^(-?\d+)(\.\d+)?$/) }
  return Integer token if isInteger.call token
  return Float   token if isFloat.call   token

  token.to_sym
end

# p parse '(def 1 2 (c 3.3 (r f r) e))'


##### Environments

def generate_env
  lisp_env = {
    '+': ->(arr) { arr.sum }, # args.inject(0, :+)
    '-': ->(*args) { eval args.join('-') },
    '*': ->(*args) { eval args.join('*') },
    '/': ->(*args) { eval args.join('/') },
    '>': ->(x, y) { x > y },
    '<': ->(x, y) { x < y },
    '=': ->(x, y) { x == y },
    '>=': ->(x, y) { x >= y },
    '<=': ->(x, y) { x <= y },
    'min': ->(*args) { args.min },
    'max': ->(*args) { args.max },
    'car': ->(arr) { arr[0] },
    'cdr': ->(arr) { arr[1..-1] }
  }
end

# puts lisp_env[:+].call 1, 2, 3
# puts lisp_env[:-].call 1, 2, 3
# puts lisp_env[:*].call 2, 3, 4
# puts lisp_env[:/].call 9, 5, 1
# puts lisp_env[:>].call 1, 2

# p lisp_env[:car].call [1, 2, 3]
# p lisp_env[:cdr].call [1, 2, 3]

def do_sth ; end

##### Lisp Eval

def lisp_eval(elem, env = generate_env)
  if elem.instance_of?(Symbol)
    env[elem]
  elsif elem.instance_of?(Integer) || elem.instance_of?(Float)
    elem
  elsif elem[0] == :def
    do_sth
  elsif elem[0] == :if
    do_sth
  else
    args = []
    elem[1..-1].each { |arg| args << lisp_eval(arg, env) }
    p lisp_eval(elem[0], env)
    lisp_eval(elem[0], env).call args
  end
end


p lisp_eval(parse '(/ (+ 1 (* 2 3) 1 1 (+ 1 (- 7 2) 1)) 4)')
