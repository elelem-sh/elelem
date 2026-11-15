# frozen_string_literal: true

class FakeProvider
  def self.calling(name, arguments = {}) = new([{ type: "doing", id: "1", name: name, arguments: arguments }])

  def initialize(first_reply_events = [])
    @pending = first_reply_events
  end

  def fetch(_messages, _tools, &)
    yield(type: "saying", text: "ok")
    @pending.each(&)
    @pending = []
  end
end
