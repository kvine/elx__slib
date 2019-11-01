defmodule Game.Global do 
    require Logger    
    @doc """
            全局模块
        """
    @match_room_module "Elixir.Game.Global.MatchRoom"
    
    # -> string 
    def get_match_room_name(vs_mode_id) do 
        name=String.to_atom(@match_room_module <>"#{inspect vs_mode_id}")
        Logger.info("name=#{inspect name}")
        name
    end

    # -> pid | nil 
    def get_match_room_pid(vs_mode_id) do 
        case :global.whereis_name(get_match_room_name(vs_mode_id)) do 
                :undefined -> 
                    nil
                pid -> 
                    pid 
        end
    end

    # 获取匹配房间的数据（人数，匹配时间等相关统计信息）
    # -> {id,%{}}
    def get_match_room_data(id) do 
        room_pid= get_match_room_pid(id)
          case room_pid do 
            nil -> 
                {id,%{}}
            _ -> 
                try do 
                    {id,GenServer.call(room_pid,{:get_match_room_data})}
                rescue
                    _ -> 
                        {id,%{}}
                end
          end
    end


    # Game.Global.get_all_match_room_data()
    @doc """
        [{id,%{
            total_cnt: num
            playing_with_robot_cnt: num
            wait_cnt: num
            playing_with_user_cnt: num
            extra_data: %{}
        }]
    """
    # -> [{id,%{}}] 
    def get_all_match_room_data() do 
        vs_mode_ids= Application.get_env(:elx__slib, :vs_mode_ids, [])
        List.foldr(vs_mode_ids,[],fn(x,acc)->
                        [get_match_room_data(x)|acc]
                     end)
    end





end