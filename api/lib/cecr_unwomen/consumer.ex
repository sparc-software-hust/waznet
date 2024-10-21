defmodule CecrUnwomen.Consumer do
  use GenServer
  use AMQP

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: ConsumerMQ)
  end

  @exchange    "gen_server_test_exchange"
  @queue       "gen_server_test_queue"
  @queue_error "#{@queue}_error"

  def init(_opts) do
    {:ok, conn} = Connection.open("amqp://guest:guest@localhost")
    {:ok, chan} = Channel.open(conn)
    setup_queue(chan)

    :ok = Basic.qos(chan, prefetch_count: 10)
    {:ok, _consumer_tag} = Basic.consume(chan, @queue)
    {:ok, chan}
  end

  def handle_call(:get_chan, _, chan) do
    {:reply, chan, chan}
  end

  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, chan) do
    {:noreply, chan}
  end

  def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, chan) do
    {:stop, :normal, chan}
  end

  def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, chan) do
    {:noreply, chan}
  end

  def handle_info({:basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}}, chan) do
    IO.inspect(Time.utc_now(), label: "queue at")
    consume(chan, tag, redelivered, payload)
    {:noreply, chan}
  end

  defp setup_queue(chan) do
    {:ok, _} = Queue.declare(chan, @queue_error, durable: true)
    {:ok, _} = Queue.declare(chan, @queue,
      durable: true,
      arguments: [
        {"x-dead-letter-exchange", :longstr, ""},
        {"x-dead-letter-routing-key", :longstr, @queue_error},
      ]
    )

    {:ok, _} = Queue.declare(chan, "wait_10_sec",
      durable: true,
      arguments: [
        {"x-dead-letter-exchange", :longstr, ""},
        {"x-dead-letter-routing-key", :longstr, @queue},
        {"x-message-ttl", :signedint, 3000}
      ]
    )

    :ok = Exchange.fanout(chan, @exchange, durable: true)
    :ok = Queue.bind(chan, @queue, @exchange)
    # :ok = Queue.bind(chan, "wait_10_sec", @exchange)
  end

  defp consume(channel, tag, redelivered, payload) do
    number = String.to_integer(payload)
    if number <= 10 do
      IO.inspect(Time.utc_now(), label: "consume at")
      :ok = Basic.ack channel, tag
      IO.puts "Consumed a #{number}."
    else
      :ok = Basic.reject channel, tag, requeue: false
      IO.puts "#{number} is too big and was rejected."
    end

  rescue
    # Requeue unless it's a redelivered message.
    # This means we will retry consuming a message once in case of exception
    # before we give up and have it moved to the error queue
    #
    # You might also want to catch :exit signal in production code.
    # Make sure you call ack, nack or reject otherwise consumer will stop
    # receiving messages.
    _exception ->
      :ok = Basic.reject channel, tag, requeue: not redelivered
      IO.puts "Error converting #{payload} to integer"
  end
end
