defmodule CecrUnwomen.Fcm.FcmPayload do
    # fields khi bắn noti bình thường cho IOS (comment card, issue)
    def create_payload(:ios, token, notification, data) do
      %{
        "message" => %{
          "token" => token,
          "data" => data,
          "apns" => %{
            "payload" => %{
              "aps" => %{
                "alert" => %{} |> Map.merge(notification),
              }
            }
          }
        }
      }
    end

    # fields khi bắn noti custom (noti với badge, sound, hoặc silent)
    # các trường trong apns xem ở link:
    # https://developer.apple.com/documentation/usernotifications/generating-a-remote-notification
    # https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages#apnsconfig
    def create_payload(:ios_custom, token, data, apns_field) do
      %{
        "message" => %{
          "token" => token,
          "data" => data,
          "apns" => apns_field
        }
      }
    end


    def create_payload(:android, token, data) do
      %{
        "message" => %{
          "token" => token,
          "android" => %{
            "priority" => "high",
            "data" => data
          }
        }
      }
    end
end
