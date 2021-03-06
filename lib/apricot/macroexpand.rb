module Apricot
  def self.macroexpand(form)
    ex = macroexpand_1(form)

    until ex.equal?(form)
      form = ex
      ex = macroexpand_1(form)
    end

    ex
  end

  def self.macroexpand_1(form)
    return form unless form.is_a? Seq

    callee = form.first
    return form unless callee.is_a?(Identifier) && !callee.constant?

    name = callee.name
    name_s = name.to_s
    args = form.rest

    # Handle the (.method receiver args*) send expression form
    if name.length > 1 && name != :'..' && name_s.start_with?('.')
      raise ArgumentError, "Too few arguments to send expression, expecting (.method receiver ...)" if args.empty?

      dot = Identifier.intern(:'.')
      method = Identifier.intern(name_s[1..-1])
      return List[dot, args.first, method, *args.rest]
    end

    # Handle the (Class. args*) shorthand new form
    if name.length > 1 && name != :'..' && name_s.end_with?('.')
      dot = Identifier.intern(:'.')
      klass = Identifier.intern(name_s[0..-2])
      new = Identifier.intern(:new)
      return List[dot, klass, new, *args]
    end

    # Handle defined macros
    if callee.qualifier.is_a?(Namespace) && callee.qualifier.vars.include?(callee.unqualified_name)
      potential_macro = callee.qualifier.get_var(callee.unqualified_name)
      meta = potential_macro.apricot_meta

      if meta && meta[:macro]
        return potential_macro.call(*args)
      end
    end

    # Default case
    form
  end
end
