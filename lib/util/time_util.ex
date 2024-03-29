defmodule Time.Util do

  def day_mills(), do: 86400_000 # 24 * 3600 * 1000
  def hour_mills(), do: 3600_000 #3600*1000
  def min_mills(), do: 60_000 #60 * 1000
  

  @doc """
      get mills utc time
  """
  @spec curr_mills() :: integer
  def curr_mills() do
    {mega, secs, micro} = :os.timestamp()
    (mega * 1_000_000 + secs) * 1000 + div(micro, 1000)
  end

  @doc """
      get geregorian {1970,1,1,0,0,0} seconds
  """
  @spec gregorian_zero_seconds() :: integer
  def gregorian_zero_seconds() do
    :calendar.datetime_to_gregorian_seconds({{1970, 1, 1}, {0, 0, 0}})
  end

  @doc """
      get date by mills : integer ->   {{y,m,d},{h,m,s}}
      Time.Util.mills_to_date(1521331200000)
  """
  @spec mills_to_date(mills :: integer) :: tuple
  def mills_to_date(mills) do
    secs = div(mills, 1000)
    :calendar.gregorian_seconds_to_datetime(secs + gregorian_zero_seconds())
  end

  @doc """
      get mills by date  {{y,m,d},{h,m,s}} -> integer
      Time.Util.date_to_mills({{2018,3,18},{0,0,0}})
  """
  @spec date_to_mills(date :: tuple) :: integer
  def date_to_mills(date) do 
      1000*(:calendar.datetime_to_gregorian_seconds(date) -gregorian_zero_seconds())
  end

  @doc """
          set a timer
  """
  @spec start_timer(time_mills :: integer, msg :: any, timer :: reference) :: reference
  def start_timer(time_mills, msg, timer \\ nil) do
    case timer do
      nil -> :ok
      _ -> :erlang.cancel_timer(timer)
    end

    :erlang.start_timer(time_mills, self(), msg)
  end


  @doc """
          cancle a timer
  """
  @spec cancle_timer(timer :: reference) ::  integer | boolean
  def cancle_timer(timer) do
    case timer do
      nil -> :ok
      _ -> :erlang.cancel_timer(timer)
    end
  end

  @doc """
    get mills-seconds left until the timer expires 
  """
  @spec get_timer_left_time(timer :: reference, default :: integer) :: integer
  def get_timer_left_time(timer,default \\ 0) do
      case timer do 
          nil -> 
              default
          _ -> 
              case :erlang.read_timer(timer) do 
                    false -> 
                      default
                    time_mills -> 
                      time_mills
              end
      end
  end

@doc """
  check is new day
"""
def is_new_day?(mills1,mills2) do 
    :erlang.abs(mills1 - mills2) > 86400000 #3600*1000*24
end

def is_new_day_diff_day?(mills1,mills2) do 
    {{y1,m1,d1},_}=mills_to_date(mills1)
    {{y2,m2,d2},_}=mills_to_date(mills2)
    y1 != y2 or m1 != m2 or d1 != d2
end

@doc """
    get next day zero time info 
    return {now_to_zero_time_mills_span, zero_time_mills}
"""
def get_next_zero_time_info() do 
    now = curr_mills()
    {{y1,m1,d1},{hh,mm,ss}}=mills_to_date(now)
    days1= :calendar.date_to_gregorian_days({y1,m1,d1})
    days2=days1 + 1 
    {y2,m2,d2}=:calendar.gregorian_days_to_date(days2)
    secs1=:calendar.datetime_to_gregorian_seconds({{y1,m1,d1},{hh,mm,ss}})
    secs2=:calendar.datetime_to_gregorian_seconds({{y2,m2,d2},{0,0,0}})
    span =  1000*(secs2 - secs1)
    {span, now + span}
end

@doc """
   get time string as "2018-09-13T12:41:09.799+08:00"
"""
@spec time_string() :: String.t()
def time_string() do 
  time_string(curr_mills())
end

@spec time_string(mills :: integer) :: String.t()
def time_string(mills) do 
  universal_time= mills_to_date(mills)
  local_time= :erlang.universaltime_to_localtime(universal_time)
  {{y,m,d},{hh,mm,ss}}= local_time

  millis1 = rem(mills , 1000)
  diff_secs= :calendar.datetime_to_gregorian_seconds(local_time) - 
                :calendar.datetime_to_gregorian_seconds(universal_time)
  zone = zone(diff_secs)
  result = :io_lib.format("~4..0w-~2..0w-~2..0wT~2..0w:~2..0w:~2..0w.~3..0w~s",
      [y, m, d, hh, mm, ss, millis1,zone])
  :erlang.iolist_to_binary(result)
end


@spec zone(diff_secs :: integer) :: String.t()
def zone(diff_secs) do 
    cond do 
      diff_secs == 0 -> "Z"
      diff_secs > 0 -> zone(diff_secs,"+")
      diff_secs < 0 -> zone(-diff_secs,"-")
      true -> "Z"
    end
end

@spec zone(abs_secs :: integer, sign :: String.t()) :: String.t()
def zone(abs_secs,sign) do 
  abs_mins= div(abs_secs,60)
  h= div(abs_mins,60)
  m= rem(abs_mins,60)
  result= :io_lib.format("~s~2..0w:~2..0w", [sign, h, m])
  :erlang.iolist_to_binary(result)
end


  ### test ### 
  # timer=Time.Util.start_timer(10000,:test_timer)
  # Time.Util.get_timer_left_time(timer)

end

