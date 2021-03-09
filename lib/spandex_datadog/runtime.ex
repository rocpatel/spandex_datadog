defmodule SpandexDatadog.Runtime do
  @line_regex ~r/^(\d+):([^:]*):(.+)$/ 
  @uuid_container_regex ~r/([0-9a-f]{8}[-_][0-9a-f]{4}[-_][0-9a-f]{4}[-_][0-9a-f]{4}[-_][0-9a-f]{12}|[0-9a-f]{64})(?:.scope)?$/

  def container_id() do
    case File.exists?("/proc/self/cgroup") do
      true -> File.read!("/proc/self/cgroup")
              |> String.split("\n", trim: true)
              |> parse_cgroup()
              |> parse_cgroup_path()
              |> parse_container_id()
              |> Enum.at(0)
      _ -> ""
    end
  end

  defp parse_cgroup(content) do
    content |> Enum.flat_map(&Regex.scan(@line_regex, &1)) |> Enum.filter(fn x -> Enum.count(x) == 4 end) 
  end

  defp parse_cgroup_path(content) do
    content |> Enum.map(fn x -> Enum.at(x,3) end) |> Enum.map(fn x -> Enum.at(String.split(x,"/"), -1) end)
  end

  defp parse_container_id(content) do
    content 
    |> Enum.filter(fn x -> x != nil end)
    |> Enum.flat_map(&Regex.scan(@uuid_container_regex,&1))
    |> Enum.map(fn x -> Enum.at(x,1) end)
  end
end
