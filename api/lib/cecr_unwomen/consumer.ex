defmodule CecrUnwomen.Consumer do
  use GenServer
  use AMQP
  
  alias CecrUnwomen.Workers.{ ScheduleWorker }

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
    
    Application.put_env(:cecr_unwomen, :r_channel, chan)
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
    IO.inspect("msgggggggggggg")
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
      
    minutes = (1..30 |> Enum.to_list)
    
    Enum.each(minutes, fn min -> 
      Queue.declare(chan, "wait_min_#{min}", durable: true,
        arguments: [{"x-dead-letter-exchange", :longstr, @delay_exchange},
                    {"x-dead-letter-routing-key", :longstr, @delay_queue},
                    {"x-message-ttl", :signedint, 60000 * min}]
                  )
      end
    )
    
    hours = (1..12 |> Enum.to_list)
    Enum.each(hours, fn hour ->
      Queue.declare(chan, "wait_hour_#{hour}", durable: true,
        arguments: [{"x-dead-letter-exchange", :longstr, @delay_exchange},
                    {"x-dead-letter-routing-key", :longstr, @delay_queue},
                    {"x-message-ttl", :signedint, 3600000 * hour}]
                  )
    end
    )
  end

  defp consume(channel, tag, redelivered, payload) do
    case Jason.decode payload do
      {:ok, obj} -> case obj["action"] do
        "broadcast_remind_to_input" ->  IO.inspect("cassaidniuasduisaduiadiuasu")
          
          # ScheduleWorker.schedule_to_send_noti_vi([obj["data"]])
        _ -> nil
        
        Basic.ack channel, tag
      end
      {:error, _} ->
        Basic.reject channel, tag, requeue: false
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
