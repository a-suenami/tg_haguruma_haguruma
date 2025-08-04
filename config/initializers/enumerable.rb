module Enumerable
  extend T::Sig

  # 今のところ arg の要素数は3個までの分の sig しか書かれていないのでそれ以上の要素を渡したくなったら sig を追加すること
  def typed_zip(arg, &)
    zip(*arg).each(&)
  end
end
