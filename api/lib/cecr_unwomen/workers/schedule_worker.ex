defmodule CecrUnwomen.Workers.ScheduleWorker do
  alias CecrUnwomen.Workers.FcmWorker
  alias CecrUnwomen.Utils.Helper
  
  def schedule_to_send_noti_vi(data) do
    channel  =  Application.get_env(:cecr_unwomen, :r_channel)
    case channel do
      nil -> nil
      channel ->  Enum.map(data, fn u -> 
        hour = get_in(u, ["time_reminded","hour"])
        min = get_in(u, ["time_reminded","minute"])
        tokens = get_in(u, ["tokens"]) || ""
        if (hour > 12) do
          task = %{
            action: "broadcast_remind_to_input",
            data: %{
              "time_reminded" => %{
                "hour" => hour - 12,
                "minute" => min
              },
              "tokens" => tokens
            }
          }
          AMQP.Basic.publish channel, "", "wait_hour_12", Jason.encode!(task), persistent: true
        else 
          if (hour > 0) do
            task = %{
              action: "broadcast_remind_to_input",
              data: %{
                "time_reminded" => %{
                  "hour" => 0,
                  "minute" => min
                },
                "tokens" => tokens
              }
            }
            AMQP.Basic.publish channel, "", "wait_hour_#{hour}", Jason.encode!(task), persistent: true
          else 
            if (min > 30) do
              task = %{
                action: "broadcast_remind_to_input",
                data: %{
                  "time_reminded" => %{
                    "hour" => 0,
                    "minute" => min - 30
                  },
                  "tokens" => tokens
                }
              }
              AMQP.Basic.publish channel, "", "wait_min_30", Jason.encode!(task), persistent: true
            else 
              task = %{
                action: "broadcast_remind_to_input",
                data: %{
                  "time_reminded" => %{
                    "hour" => 0,
                    "minute" => 0
                  },
                  "tokens" => tokens
                }
              }
              IO.inspect(task)
              AMQP.Basic.publish channel, "", "wait_min_#{min}", Jason.encode!(task), persistent: true
            end
          end          
        end
        
        if (hour == 0 && min == 0) do
          local_time_string = Helper.get_local_time_now_string("Asia/Ho_Chi_Minh")
          FcmWorker.send_firebase_notification(
            Enum.map(tokens, fn t -> %{"token" => t} end),
             %{
              "title" => "Nhập dữ liệu ngày #{local_time_string}",
              "body" => "Bạn chưa nhập dữ liệu cho hôm nay. Ấn vào thông báo để tiến hành nhập liệu."
            }
          )
        end
      end)
    end
  end
end
