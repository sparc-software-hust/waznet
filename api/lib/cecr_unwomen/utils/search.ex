defmodule CecrUnwomen.Utils.Search do
  alias CecrUnwomen.{Utils.Helper}

  def search_by_name(user_names, text) do
    # Chia thành 5 list: exactly, start, last, contain exactly, contains 
    # Với từng list, chia nhỏ thành 4 case theo độ ưu tiên giảm dần:
    # gốc (chưa bỏ dấu + chưa downcase) > chưa bỏ dấu + downcase > bỏ dấu + chưa downcase > bỏ dấu + downcase
    downcased_text = String.downcase(text)

    # Use Enum.reduce_while to stop further checks for each user once a match is found
    Enum.reduce(user_names, initial_acc(), fn user, acc ->
      Enum.reduce_while([:exact_match, :start_match, :last_match, :contains_exact, :contains], acc, fn x, acc ->
        case x do     
          :exact_match ->
            check_exact_match(user, text, downcased_text, acc)

          :start_match ->
            check_start_with(user, text, downcased_text, acc)
            
          :last_match ->
            check_last_with(user, text, downcased_text, acc)

          :contains_exact ->
            check_contains_exact(user, text, downcased_text, acc)

          :contains ->
            check_contains(user, text, downcased_text, acc)
        end
      end)
    end)
    |> merge_results()
  end

  # Initialize accumulator using a map to store categorized results
  defp initial_acc do
    %{
      exact: %{
        original: [],
        downcase: [],
        unsign: [],
        unsign_downcase: []
      },
      start: %{
        original: [],
        downcase: [],
        unsign: [],
        unsign_downcase: []
      },
      last: %{
        original: [],
        downcase: [],
        unsign: [],
        unsign_downcase: []
      },
      contain_exact: %{
        original: [],
        downcase: [],
        unsign: [],
        unsign_downcase: []
      },
      contain: %{
        original: [],
        downcase: [],
        unsign: [],
        unsign_downcase: []
      }
    }
  end

  # 1.exact
  defp check_exact_match(user, text, downcased_text, acc) do
    cond do
      user == text ->
        {:halt, update_acc(acc, :exact, :original, user)}

      String.downcase(user) == downcased_text ->
        {:halt, update_acc(acc, :exact, :downcase, user)}

      Helper.unsign_vietnamese(user, downcase: false) == text ->
        {:halt, update_acc(acc, :exact, :unsign, user)}

      Helper.unsign_vietnamese(user, downcase: true) == downcased_text ->
        {:halt, update_acc(acc, :exact, :unsign_downcase, user)}

      true ->
        {:cont, acc}
    end
  end

  # 2.start with
  defp check_start_with(user, text, downcased_text, acc) do
    cond do
      String.starts_with?(user, text) ->
        {:halt, update_acc(acc, :start, :original, user)}

      String.starts_with?(String.downcase(user), downcased_text) ->
        {:halt, update_acc(acc, :start, :downcase, user)}

      String.starts_with?(Helper.unsign_vietnamese(user, downcase: false), text) ->
        {:halt, update_acc(acc, :start, :unsign, user)}

      String.starts_with?(Helper.unsign_vietnamese(user, downcase: true), downcased_text) ->
        {:halt, update_acc(acc, :start, :unsign_downcase, user)}

      true ->
        {:cont, acc}
    end
  end
  
  # 3.last with
  defp check_last_with(user, text, downcased_text, acc) do
      last_name = String.split(user) |> List.last() || ""
      
      cond do
        String.starts_with?(last_name, text) ->
          {:halt, update_acc(acc, :last, :original, user)}
  
        String.starts_with?(String.downcase(last_name), downcased_text) ->
          {:halt, update_acc(acc, :last, :downcase, user)}
  
        String.starts_with?(Helper.unsign_vietnamese(last_name, downcase: false), text) ->
          {:halt, update_acc(acc, :last, :unsign, user)}
  
        String.starts_with?(Helper.unsign_vietnamese(last_name, downcase: true), downcased_text) ->
          {:halt, update_acc(acc, :last, :unsign_downcase, user)}
  
        true ->
          {:cont, acc}
      end
    end

  # 4.contain exactly
  defp check_contains_exact(user, text, downcased_text, acc) do
    cond do
      contains_in_words?(user, text) ->
        {:halt, update_acc(acc, :contain_exact, :original, user)}

      contains_in_words_downcase?(user, downcased_text) ->
        {:halt, update_acc(acc, :contain_exact, :downcase, user)}

      contains_in_words_unsign?(user, text) ->
        {:halt, update_acc(acc, :contain_exact, :unsign, user)}

      contains_in_words_unsign_downcase?(user, downcased_text) ->
        {:halt, update_acc(acc, :contain_exact, :unsign_downcase, user)}

      true ->
        {:cont, acc}
    end
  end

  # 5.contains
  defp check_contains(user, text, downcased_text, acc) do
    cond do
      String.contains?(user, text) ->
        {:halt, update_acc(acc, :contain, :original, user)}

      String.contains?(String.downcase(user), downcased_text) ->
        {:halt, update_acc(acc, :contain, :downcase, user)}

      String.contains?(Helper.unsign_vietnamese(user, downcase: false), text) ->
        {:halt, update_acc(acc, :contain, :unsign, user)}

      String.contains?(Helper.unsign_vietnamese(user, downcase: true), downcased_text) ->
        {:halt, update_acc(acc, :contain, :unsign_downcase, user)}

      true ->
        {:cont, acc}
    end
  end

  # update acc
  defp update_acc(acc, match_type, case_type, user) do
    update_in(acc[match_type][case_type], &[user | &1])
  end

  # merge results from different categories
  defp merge_results(acc) do
    exact = acc[:exact].original ++ acc[:exact].downcase ++ acc[:exact].unsign ++ acc[:exact].unsign_downcase
    start = acc[:start].original ++ acc[:start].downcase ++ acc[:start].unsign ++ acc[:start].unsign_downcase
            |> Enum.sort_by(&String.length/1)
          
    last = acc[:last].original ++ acc[:last].downcase ++ acc[:last].unsign ++ acc[:last].unsign_downcase
            |> Enum.sort_by(&String.length/1)
          
    contain_exact = acc[:contain_exact].original ++ acc[:contain_exact].downcase ++ acc[:contain_exact].unsign ++ acc[:contain_exact].unsign_downcase
    contain = acc[:contain].original ++ acc[:contain].downcase ++ acc[:contain].unsign ++ acc[:contain].unsign_downcase

    Enum.uniq(exact ++ start ++ last ++ contain_exact ++ contain)
  end

  # contains exactly checking
  defp contains_in_words?(user, text) do
    String.split(user)
    |> Enum.any?(fn word -> word == text end)
  end

  defp contains_in_words_downcase?(user, text) do
    String.split(user)
    |> Enum.any?(fn word -> String.downcase(word) == text end)
  end

  defp contains_in_words_unsign?(user, text) do
    String.split(user)
    |> Enum.any?(fn word -> Helper.unsign_vietnamese(word, downcase: false) == text end)
  end

  defp contains_in_words_unsign_downcase?(user, text) do
    String.split(user)
    |> Enum.any?(fn word -> Helper.unsign_vietnamese(word, downcase: true) == text end)
  end
end
