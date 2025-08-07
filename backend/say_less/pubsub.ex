defmodule SayLess.PubSub do
  @moduledoc """
  The PubSub system for the SayLess application.
  """
  # We provide the required otp_app and specify the Local adapter,
  # which is perfect for applications without a database.
  use Phoenix.PubSub,
    otp_app: :say_less,
    adapter: Phoenix.PubSub.Local
end
