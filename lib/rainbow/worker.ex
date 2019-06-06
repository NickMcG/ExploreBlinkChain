defmodule Rainbow.Worker do
  use GenServer

  # Arrangement looks like this:
  # Y  X: 0  1  2  3  4  5  6  7  8  9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30
  # 0  [  0  1  2  3  4  5  6  7  8  9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30 ]

  alias Blinkchain.Point

  defmodule State do
    defstruct [:timer, :colors]
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    # Send ourselves a message to draw each frame every 33 ms,
    # which will end up being approximately 15 fps.
    {:ok, ref} = :timer.send_interval(33, :draw_frame)

    state = %State{
      timer: ref,
      colors: Rainbow.colors()
    }

    {:ok, state}
  end

  def handle_info(:draw_frame, state) do
    [c1 | tail] = state.colors

    # Shift all pixels to the right
    Blinkchain.copy(%Point{x: 0, y: 0}, %Point{x: 1, y: 0}, 29, 1)

    # Populate the leftmost pixel with new color
    Blinkchain.set_pixel(%Point{x: 0, y: 0}, c1)

    Blinkchain.render()
    {:noreply, %State{state | colors: tail ++ [c1]}}
  end
end
