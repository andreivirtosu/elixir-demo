defmodule Issues.CLI do
  require Logger

  @default_count 4

  def main(argv) do
    Logger.info "main"
    argv
    |> parse_args
    |> process
  end

  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [ count | #{@default_count} ] ]
    """
    System.halt(0)
  end

  def process({user, project, count}) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response
    |> sort_into_ascending_order
    |> Enum.take(count)
    |> print_nicely
  end

  def print_nicely(list_of_issues) do

    list_of_issues
    |> Enum.map( &( Map.get(&1, "created_at") <> " | " <> Map.get(&1, "title") ) )
    |> Enum.join("\n")
    |> IO.puts
  end

  def sort_into_ascending_order(list_of_issues) do
    list_of_issues
    |> Enum.sort( fn i1, i2 -> Map.get(i1, "created_at") <= Map.get(i2, "created_at") end)
  end

  def decode_response({:ok, body}), do: body

  def decode_response({:error, error}) do
    {_, message} = List.keyfind(error, "message", 0)
    IO.puts "Error fetching from GIthub: #{message}"
    System.halt(2)
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean],
                                      aliases: [h: :help])

    case parse do
      { [help: true], _, _ } -> :help
      { _, [user, project, count], _ } -> {user, project, String.to_integer(count) }
      { _, [user, project], _ } -> {user, project, @default_count }
      _ -> :help
    end

  end


end
