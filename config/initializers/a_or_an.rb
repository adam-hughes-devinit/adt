String.class_eval { def a_or_an; %w(a e i o u).include?(downcase.first) ? "an #{self}" : "a #{self}"; end }
