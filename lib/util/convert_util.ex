defmodule  Convert.Util do

    @doc """
        convert binary to integer

        123=Convert.Util.b2i("123")
        123=Convert.Util.b2i(123)
        123=Convert.Util.b2i!("123")
        123=Convert.Util.b2i!(123)
    """
    # -> integer | {error,reason}
    def b2i(binary) do 
        case is_binary(binary) do 
                true -> 
                    :erlang.binary_to_integer(binary)
                false -> 
                    if is_integer(binary) do 
                        binary
                    else 
                        # :erlang.error(:badarg,[binary])
                        {:error,:bad_arg}
                    end
        end
    end
    # -> integer 
    def b2i!(binary) do 
        if is_integer(binary) do 
            binary
        else 
            :erlang.binary_to_integer(binary)
        end 
    end

    

    @doc """
        convert binary to integer

        123.0=Convert.Util.b2f("123.0")
        123.0=Convert.Util.b2f(123.0)
        123.0=Convert.Util.b2f!("123.0")
        123.0=Convert.Util.b2f!(123.0)
    """
    # -> integer | {error,reason}
    def b2f(binary) do 
        case is_binary(binary) do 
                true -> 
                    :erlang.binary_to_float(binary)
                false -> 
                    if is_float(binary) do 
                        binary
                    else 
                        # :erlang.error(:badarg,[binary])
                        {:error,:bad_arg}
                    end
        end
    end
    # -> integer 
    def b2f!(binary) do 
        if is_float(binary) do 
            binary
        else 
            :erlang.binary_to_float(binary)
        end 
    end

end