module NgLib
  module FastIn
    extend self

    lib LibC
      fun getchar = getchar_unlocked : Char
    end

    module Scanner
      extend self

      {% for int_t in Int::Primitive.union_types %}
        {% if Int::Signed.union_types.includes?(int_t) %}
        def read_{{ int_t.name.downcase[0..0] }}{{ int_t.name.downcase[3...int_t.name.size] }}(offset = 0)
        {% else %}
        def read_{{ int_t.name.downcase[0..0] }}{{ int_t.name.downcase[4...int_t.name.size] }}(offset = 0)
        {% end %}
          c = next_char
          res = {{ int_t }}.new(c.ord - '0'.ord)
          sgn = 1

          case c
          when '-'
            res = {{ int_t }}.new(LibC.getchar.ord - '0'.ord)
            sgn = -1
          when '+'
            res = {{ int_t }}.new(LibC.getchar.ord - '0'.ord)
          end

          until ascii_voidchar?(c = LibC.getchar)
            res = res*10 + (c.ord - '0'.ord)
          end

          res * sgn + offset
        end
      {% end %}

      def read_char : Char
        next_char
      end

      def read_word : String
        c = next_char
        s = [c]
        until ascii_voidchar?(c = LibC.getchar)
          s << c
        end
        s.join
      end

      private def next_char : Char
        c = '_'
        while ascii_voidchar?(c = LibC.getchar)
        end
        c
      end

      private def ascii_voidchar?(c)
        c.ascii_whitespace? || c.ord == -1
      end
    end
  end
end
