static func set_node_visible(node, visible):
	var original = { "children": {} }
	if "visible" in node:
		original["current"] = node.visible
		node.visible = visible
	for child in node.get_children():
		original["children"][child.get_name()] = set_node_visible(child, visible)
	return original
static func restore_node_visibility(node, original):
	if "visible" in node and "current" in original:
		node.visible = original["current"]
	for child_name in original["children"]:
		restore_node_visibility(node.get_node(child_name), original["children"][child_name])

static func set_node_mouse_filter(node, filter):
	if "mouse_filter" in node:
		node.mouse_filter = filter
	for child in node.get_children():
		set_node_mouse_filter(child, filter)

static func set_node_scale(node, scale):
	if "scale" in node:
		node.scale = scale
	for child in node.get_children():
		if child is CanvasLayer:
			set_node_scale(child, scale)

static func add_node_position(node, position):
	if node is CanvasLayer:
		node.offset += position
	elif "position" in node:
		node.position += position
	for child in node.get_children():
		if child is CanvasLayer:
			add_node_position(child, position)


static func pascal_to_snake_case(string):
	var result = PoolStringArray()
	for ch in string:
		if ch == ch.to_lower():
			result.append(ch)
		else:
			result.append('_' + ch.to_lower())
	result[0] = result[0][1]
	return result.join('')

static func snake_to_pascal_case(string):
	var result = PoolStringArray()
	var prev_is_underscore = true
	for ch in string:
		if ch == '_':
			prev_is_underscore = true
		else:
			if prev_is_underscore:
				result.append(ch.to_upper())
			else:
				result.append(ch)
			prev_is_underscore = false
	return result.join('')
