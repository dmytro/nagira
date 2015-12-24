module OutputTypeable
  def list?
    @output == :list
  end

  def state?
    @output == :state
  end

  def full?
    @output == :full
  end

  def body_with_list(body)
    if list?
      body.keys
    else
      body
    end
  end

end
