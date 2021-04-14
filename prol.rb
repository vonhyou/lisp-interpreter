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
  program.gsub('(', ' ( ').gsub(')', ' ) ').split
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

  case token = tokens.shift
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
  case token
  when /\d/
    (token.to_f % 1).positive? ? token.to_f : token.to_i
  else
    token.to_sym
  end
end

##### Environments

$global_env = {
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
  'quote': ->(arr) { arr },
  'print': ->(arg) { p arg },
  'begin': ->(*_args) { true }
}

##### Lisp Eval
def lisp_eval(elem, env = $global_env)
  if elem.instance_of? Symbol
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
  elsif elem[0] == :lambda
    _, params, body = elem
    ->(*args) { lisp_eval body, env.merge(Hash[params.zip(args)]) }
  elsif elem[0] == :and
    lisp_eval(elem[1], env) && lisp_eval(elem[2], env)
  elsif elem[0] == :or
    lisp_eval(elem[1], env) || lisp_eval(elem[2], env)
  elsif elem[0] == :not
    !lisp_eval(elem[1], env)
  else
    args = []
    elem[1..-1].each { |arg| args << lisp_eval(arg, env) }
    p lisp_eval(elem[0], env)
    lisp_eval(elem[0], env).call args
  end
end

$copyleft = "Copyleft (Ↄ) 2021 vonhyou@lenva.tech
(PRO)cessor of (L)ist for Mathmatical Calculation
This is an open source software, you can view it's source code on github:
https://github.com/vonhyou/lisp-interpreter\n\n"

##### REPL
def repl(prompt = 'prol ƛ>> ')
  puts $copyleft
  loop do
    print prompt
    val = lisp_eval(parse(gets.chomp))

    print_value val unless val.nil? || val.instance_of?(Proc)
  end
end

def print_value(value)
  puts ";Value: #{value}"
end

repl
