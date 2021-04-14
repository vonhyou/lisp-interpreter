# It's a minimal lisp interpreter written in Ruby-lang
# Author: @vonhyou
# Start at: Apr. 10, 2021

##### Parser
# :parse
# :tokenize
# :read_tokens
# :atom
#####

module Lisp

  def self.parse(program)
    read_tokens(tokenize(program))
  end

  def self.tokenize(program)
    # Convert scripts to token lists
    program.gsub('(', ' ( ').gsub(')', ' ) ').split
  end

  def self.make_list(tokens)
    lst = []
    lst << read_tokens(tokens) while tokens[0] != ')'
    tokens.shift
    lst
  end

  def self.read_tokens(tokens, lst = [])
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

  def self.atom(token)
    # Analyse numbers and symbols
    case token
    when /\d/
      (token.to_f % 1).positive? ? token.to_f : token.to_i
    else
      token.to_sym
    end
  end

  ##### Environments

  def self.make_global
    @global_env ||= begin
      ops = %i[== != < <= > >= + - * /]
      ops.inject({}) do |scope, op|
        scope.merge op => ->(*args) { args.inject(&op) }
      end
    end
    lisp_methods = { 'min': ->(arr) { arr.min },
                     'max': ->(arr) { arr.max },
                     'car': ->(arr) { arr[0] },
                     'cdr': ->(arr) { arr[1..-1] },
                     'cons': ->(arr) { arr },
                     'quote': ->(*args) { args },
                     'print': ->(arg) { p arg },
                     'begin': ->(*_args) { true }}
    @global_env.merge lisp_methods
  end

  ##### Lisp Eval
  def self.lisp_eval(elem, env = make_global)
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
      func, *args = elem.map { |e| lisp_eval e, env }
      func.call *args
    end
  end

  # (def fib (lambda (n) (if (<= n 2) 1 (+ (fib (- n 1)) (fib (- n 2))))))

  $copyleft = "Copyleft (Ↄ) 2021 vonhyou@lenva.tech
(PRO)cessor of (L)ist for Mathematical Calculation
This is an open source software, you can view its source code on github:
https://github.com/vonhyou/lisp-interpreter\n\n"

  ##### REPL
  def self.repl(prompt = 'prol ƛ>> ')
    puts $copyleft
    loop do
      print prompt
      val = lisp_eval(parse(gets.chomp))

      print_value val unless val.nil? || val.instance_of?(Proc)
    end
  end

  def self.print_value(value)
    puts ";Value: #{value}"
  end
end

Lisp.repl
