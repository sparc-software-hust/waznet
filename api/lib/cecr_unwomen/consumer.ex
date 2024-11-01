defmodule CecrUnwomen.Consumer do
  use GenServer
  use AMQP

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: ConsumerMQ)
  end

  @delay_exchange "delay_exchange"
  @delay_3_sec_queue "delay_3_sec_queue"
  @delay_queue "delay_queue"
  @delay_queue_error "#{@delay_queue}_error"

  def init(_opts) do
    user = System.get_env("RABBITMQ_DEFAULT_USER") || "guest"
    password = System.get_env("RABBITMQ_DEFAULT_PASS") || "guest"
    host = System.get_env("RABBITMQ_HOST") || "localhost"

    {:ok, conn} = Connection.open("amqp://#{user}:#{password}@#{host}")
    {:ok, chan} = Channel.open(conn)
    setup_delay_queue(chan)

    :ok = Basic.qos(chan, prefetch_count: 10)
    {:ok, _consumer_tag} = Basic.consume(chan, @delay_queue)
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
    consume(chan, tag, redelivered, payload)
    {:noreply, chan}
  end

  defp setup_delay_queue(chan) do
    # see message log: AMQP.Basic.get chan, "delay_queue_error", no_ack: true
    {:ok, _} = Queue.declare(chan, @delay_queue_error, durable: true)

    {:ok, _} =
      Queue.declare(chan, @delay_queue,
        durable: true,
        arguments: [
          {"x-dead-letter-exchange", :longstr, ""},
          {"x-dead-letter-routing-key", :longstr, @delay_queue_error}
        ]
      )

    {:ok, _} =
      Queue.declare(chan, @delay_3_sec_queue,
        durable: true,
        arguments: [
          {"x-dead-letter-exchange", :longstr, @delay_exchange},
          {"x-dead-letter-routing-key", :longstr, @delay_queue},
          {"x-message-ttl", :signedint, 3000}
        ]
      )

    :ok = Exchange.direct(chan, @delay_exchange, durable: true)

    # phải có routing key cho exchange direct, nếu không sẽ không gửi được do rabbitmq không xác định được
    :ok = Queue.bind(chan, @delay_queue, @delay_exchange, routing_key: @delay_queue)
    :ok = Queue.bind(chan, @delay_3_sec_queue, @delay_exchange, routing_key: @delay_3_sec_queue)
  end

  defp consume(channel, tag, redelivered, payload) do
    number = String.to_integer(payload)

    if number <= 10 do
      :ok = Basic.ack(channel, tag)
      IO.puts("Consumed a #{number}.")
    else
      :ok = Basic.reject(channel, tag, requeue: false)
      IO.puts("#{number} is too big and was rejected.")
    end
  rescue
    # You might also want to catch :exit signal in production code.
    # Make sure you call ack, nack or reject otherwise consumer will stop
    # receiving messages.
    _exception ->
      :ok = Basic.reject(channel, tag, requeue: not redelivered)
      IO.puts("Error converting #{payload} to integer")
  catch
    :exit, _exception -> Basic.reject(channel, tag, requeue: false)
    _ -> Basic.reject(channel, tag, requeue: false)
  end
end
