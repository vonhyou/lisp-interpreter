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
    '+': ->(args) { args.sum }, # args.inject(0, :+)
    '-': ->(*args) { eval args.join('-') },
    '*': ->(*args) { eval args.join('*') },
    '/': ->(*args) { eval args.join('/') },
    '>': ->(args) { args[0] > args[1] },
    '<': ->(args) { args[0] < args[1] },
    '=': ->(args) { args[0] == args[1] },
    '>=': ->(args) { args[0] >= args[1] },
    '<=': ->(args) { args[0] <= args[1] },
    'min': ->(*args) { args.min },
    'max': ->(*args) { args.max },
    'car': ->(arr) { arr[0] },
    'cdr': ->(arr) { arr[1..-1] },
    'cons': ->(arr) { arr },
    'print': ->(arg) { p arg },
    'begin': ->(*_args) { true }
  }
end

# puts lisp_env[:+].call 1, 2, 3
# puts lisp_env[:-].call 1, 2, 3
# puts lisp_env[:*].call 2, 3, 4
# puts lisp_env[:/].call 9, 5, 1
# puts lisp_env[:>].call 1, 2
# p lisp_env[:car].call [1, 2, 3]
# p lisp_env[:cdr].call [1, 2, 3]

##### Lisp Eval

$global_env = generate_env
def lisp_eval(elem, env = $global_env)
  if elem.instance_of?(Symbol)
    env[elem]
  elsif elem.instance_of?(Integer) || elem.instance_of?(Float)
    elem
  elsif elem[0] == :def
    _, sym, exp = elem
    env[sym] = lisp_eval(exp, env)
  elsif elem[0] == :if
    _, cod, if_true, if_false = elem
    exp = lisp_eval(cod, env) ? if_true : if_false
    lisp_eval exp, env
  else
    args = []
    elem[1..-1].each { |arg| args << lisp_eval(arg, env) }
    p lisp_eval(elem[0], env)
    lisp_eval(elem[0], env).call args
  end
end


# p lisp_eval(parse '(/ (+ 1 (* 2 3) 1 1 (+ 1 (- 7 2) 1)) 4)')
# lisp_eval(parse '(begin (def var1 7) (print (if (> var1 1) (+ 1 30) (- 10 2))))')

##### REPL

def repl(prompt='minlisp>> ')
  loop do
    print prompt
    val = lisp_eval(parse(gets.chomp))

    print_value val unless val.nil?
  end
end

def print_value(value)
  puts ";Value: #{value.to_s}"
end

repl()
# lisp_eval(parse('(begin (def var1 7) (if (> var1 8) (+ 3 11) (/ 7 3)))'))
