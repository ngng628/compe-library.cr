def int(b = 0); read_line.to_i64 + b end
def ints(b = 0); read_line.split.map { |x| x.to_i64 + b } end
def str; read_line.chomp end
macro chmax(a, b); ({{a}} < {{b}} && ({{a}} = {{b}})) end
macro chmin(a, b); ({{a}} > {{b}} && ({{a}} = {{b}})) end
struct Int
  def div_ceil(other : Int); (self + other - 1) // other end
end

macro make_array(s, x)
  Array.new({{ s[0] }}) {
    {% if s[1..s.size].empty? %}; {{ x }}
    {% else %}; make_array({{ s[1..s.size] }}, {{ x }}) {% end %}
  }
end

require "../constants"
