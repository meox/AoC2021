defmodule SnailG do
  defstruct [
    :id,
    :parent,
    :val,
    :left,
    :right,
    :level
  ]

  def make_val(parent, me, val, level) do
    %SnailG{
      id: me,
      parent: parent,
      val: val,
      level: level,
      left: nil,
      right: nil
    }
  end

  def make(snail) do
    make(nil, :root, snail, 0, %{})
  end


  def make(parent, me, val, level, g) when is_number(val) do
    node = make_val(parent, me, val, level)
    Map.put(g, me, node)
  end

  def make(parent, me, [l, r], level, g) do
    left_id = make_ref()
    right_id = make_ref()

    ng = make(me, left_id, l, level + 1, g)
    ng = make(me, right_id, r, level + 1, ng)

    node = %SnailG{
      id: me,
      parent: parent,
      left: left_id,
      right: right_id,
      level: level
    }
    Map.put(ng, me, node)
  end

  def to_list(g) when is_map(g) do
    to_list(g, Map.get(g, :root))
  end
  def to_list(_g, %SnailG{val: v}) when v != nil, do: v
  def to_list(g, %SnailG{left: l, right: r}), do: [to_list(g, g[l]), to_list(g, g[r])]


  def left_most_explode(g) do
    root_node = g[:root]
    left_most_explode(g, root_node)
  end

  def left_most_explode(_g, nil), do: nil
  def left_most_explode(_g, %SnailG{level: level, val: val} = node) when level == 4  and val == nil, do: node
  def left_most_explode(g, %SnailG{left: l, right: r}) when l != nil and l != nil do
    case left_most_explode(g, g[l]) do
      nil ->
        left_most_explode(g, g[r])
      node ->
        node
    end
  end
  def left_most_explode(g, %SnailG{left: l}) when l != nil do
    left_most_explode(g, g[l])
  end
  def left_most_explode(g, %SnailG{right: r}) when r != nil do
    left_most_explode(g, g[r])
  end
  def left_most_explode(_g, _), do: nil

  def left(g, %SnailG{left: l}) when l != nil, do: Map.get(g, l)
  def left(_g, _), do: nil

  def right(g, %SnailG{right: r}) when r != nil, do: Map.get(g, r)
  def right(_g, _), do: nil

  def parent(g, %SnailG{parent: p}) when p != nil, do: Map.get(g, p)
  def parent(_g, _), do: nil

  def next_right(g, %SnailG{id: node_id} = node) do
    case parent(g, node) do
      nil ->
        nil
      pnode ->
        case right(g, pnode) do
          %SnailG{id: ^node_id} ->
            next_right(g, pnode)
          nr ->
            first_left_val(g, nr)
        end
    end
  end

  def next_left(g, %SnailG{id: node_id} = node) do
    case parent(g, node) do
      nil ->
        nil
      pnode ->
        case left(g, pnode) do
          %SnailG{id: ^node_id} ->
            next_left(g, pnode)
          nl ->
            first_right_val(g, nl)
        end
    end
  end

  def first_left_val(_g, %SnailG{val: val} = node) when val != nil, do: node
  def first_left_val(g, %SnailG{left: l}), do: first_left_val(g, g[l])

  def first_right_val(_g, %SnailG{val: val} = node) when val != nil, do: node
  def first_right_val(g, %SnailG{right: r}), do: first_right_val(g, g[r])

end
