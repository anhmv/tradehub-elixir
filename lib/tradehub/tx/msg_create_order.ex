defmodule Tradehub.Tx.MsgCreateOrder do
  @moduledoc """
  The payload message of the `order/CreateOrder` private endpoint.
  """

  use Tradehub.Tx.Type

  @typedoc "The shopping side of the order."
  @type side :: :buy | :sell

  @typedoc "Order types supported by the Tradeub"
  @type(order_type :: :limit, :market, :"stop-limit", :"stop-market")

  @typedoc "Time in force"
  @type time_in_force :: :gtc | :fok | :ioc

  @typedoc """
  Payload message
  """
  @type t :: %__MODULE__{
          market: String.t(),
          side: side(),
          quantity: integer(),
          price: String.t(),
          type: order_type(),
          time_in_force: time_in_force(),
          stop_price: String.t(),
          trigger_type: String.t(),
          is_post_only: boolean(),
          is_reduce_only: boolean(),
          originator: Tradehub.Wallet.address()
        }

  defstruct market: "",
            side: nil,
            quantity: "1",
            price: nil,
            type: :limit,
            time_in_force: :gtc,
            stop_price: nil,
            trigger_type: nil,
            is_post_only: false,
            is_reduce_only: false,
            originator: nil

  def type, do: "order/MsgCreateOrder"

  @doc """
  Validate the payload.
  """
  def validate!(message) do
    if blank?(message.market), do: raise("Market is required")

    if message.market != String.downcase(message.market) do
      raise("Market must in lowercase")
    end

    if blank?(message.quantity), do: raise("Quantity is required")

    if blank?(message.type), do: raise("Order type is required")

    if Enum.member?([:limit, :"stop-limit"], message.type) do
      if blank?(message.price), do: raise("Price is required for limit orders")
    end

    if message.type == :"stop-limit" do
      if blank?(message.stop_price), do: raise("Stop price is required for stop limit orders")
    end

    if Enum.member?([:"stop-limit", :"stop-market"], message.type) do
      if blank?(message.trigger_type), do: raise("Trigger type is required for stop orders")
    end

    if blank?(message.originator), do: raise("Originator is required")

    message
  end
end
