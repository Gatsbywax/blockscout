defmodule Explorer.SmartContract.Vyper.PublisherWorker do
  @moduledoc """
  Background smart contract verification worker.
  """

  use Que.Worker, concurrency: 5

  alias Explorer.Chain.Events.Publisher, as: EventsPublisher
  alias Explorer.SmartContract.Vyper.Publisher

  def perform({address_hash, params, %Plug.Conn{} = conn}) do
    result =
      case Publisher.publish(address_hash, params) do
        {:ok, _contract} = result ->
          result

        {:error, changeset} ->
          {:error, changeset}
      end

    EventsPublisher.broadcast([{:contract_verification_result, {address_hash, result, conn}}], :on_demand)
  end

  def perform({address_hash, params, files}) do
    result =
      case Publisher.publish(address_hash, params, files) do
        {:ok, _contract} = result ->
          result

        {:error, changeset} ->
          {:error, changeset}
      end

    EventsPublisher.broadcast([{:contract_verification_result, {address_hash, result}}], :on_demand)
  end

  def perform({address_hash, params}) do
    result =
      case Publisher.publish(address_hash, params) do
        {:ok, _contract} = result ->
          result

        {:error, changeset} ->
          {:error, changeset}
      end

    EventsPublisher.broadcast([{:contract_verification_result, {address_hash, result}}], :on_demand)
  end
end
