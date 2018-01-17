module Rucc
  class Parser
    module Enum
      # @return [Type]
      def read_enum_def
        tag = nil
        tok = get

        # Enum is handled as a synonym for int. We only check if the enum
        # is declared.
        if tok.kind == T::IDENT
          tag = tok.sval
          tok = get
        end
        if tag
          ty = @tags[tag]
          if ty && ty.kind != Kind::ENUM
            raise "declarations of #{tag} does not match"
            # errort(tok, "declarations of %s does not match", tag);
          end
        end
        if !Token.is_keyword?(tok, '{')
          if !tag || !@tags[tag]
            raise "enum tag #{tag} is not defined"
            # errort(tok, "enum tag %s is not defined", tag);
          end
          @lexer.unget_token(tok)
          return Type::INT
        end

        # NOTE: read enum declaration
        if tag
          @tags[tag] = Type::ENUM
        end

        val = 0
        while true
          tok = get
          if Token.is_keyword?(tok, '}')
            break
          end
          if tok.kind != T::IDENT
            raise "identifier expected, but got #{tok}"
            # errort(tok, "identifier expected, but got %s", tok2s(tok));
          end
          name = tok.sval

          if next_token?('=')
            val = read_intexpr
          end
          constval = Node.ast_inttype(Type::INT, val)
          val += 1
          env[name] = constval
          if next_token?(',')
            next
          end
          if next_token?('}')
            break
          end
          raise "',' or '}' expected, but got #{peek}"
          # errort(peek(), "',' or '}' expected, but got %s", tok2s(peek()));
        end

        Type::INT
      end
    end
  end
end
