'
' Core functions: el, list, mount, setChildren
'
function el(nodeType, fields = invalid as object, children = invalid as object)
    element = createObject("roSGNode", nodeType)

    if (fields <> invalid)
        ' Add nodes to component context m, keyed by id.
        if (fields.id <> invalid)
            m[fields.id] = element
        end if

        element.setFields(fields)
    end if

    if (children <> invalid)
        if (not type(children) = "roArray")
            children = [children]
        end if

        for i = 0 to children.count() - 1
            mount(element, children[i])
        end for
    end if

    return element
end function

' TODO: maybe make this a sg component too, for consistency.
' TODO: update to include parent as first arg.
function list(nodeType as string, key = invalid)
    this = {}
    this.__resg_is_list = true
    this.nodeType = nodeType
    this.views = []

    if (key <> invalid)
        this.key = key
        this.lookup = {}
    end if

    this.update = sub(datas)
        ' We use a temp views array so that it has the same length as the new data coming in.
        views = []

        if (m.key <> invalid)
            oldLookup = m.lookup
            lookup = {}

            for i = 0 to datas.count() - 1
                data = datas[i]
                ' The id has to be a string for assocarray lookup.
                id = data[m.key].toStr()

                ' Check if view is in lookup.
                view = oldLookup[id]

                if (view = invalid)
                    view = el(m.nodeType)
                end if

                views[i] = view
                lookup[id] = view

                ' There is no way to check if the component has an update function,
                ' but if it doesn't the program doesn't crash, we just get a warning in the console.
                view.callFunc("update", data)
            end for

            ' Update the lookup cache with the new lookup.
            m.lookup = lookup
        else
            for i = 0 to datas.count() - 1
                data = datas[i]
                ' Check if view is in local cache.
                view = m.views[i]

                if (view = invalid)
                    view = el(m.nodeType)
                end if

                views[i] = view

                view.callFunc("update", data)
            end for
        end if

        ' Reset the views array.
        m.views = views

        ' m.parent is set on the list in mount().
        if (m.parent <> invalid)
            setChildren(m.parent, m.views)
        end if
    end sub

    return this
end function

sub mount(parent as object, child as object, insertIndex = invalid)
    if (type(child) = "roSGNode")
        if (insertIndex <> invalid)
            parent.insertChild(child, insertIndex)
        else
            parent.appendChild(child)
        end if
    else if (type(child) = "roArray")
        for i = 0 to child.count() - 1
            mount(parent, child[i])
        end for
    else if (child.__resg_is_list)
        ' TODO: update when we add parent to list args.
        child.parent = parent
        mount(parent, child.views)
    end if
end sub

sub setChildren(parent, children)
    for i = 0 to children.count() - 1
        child = children[i]
        current = parent.getChild(i)

        if (not child.isSameNode(current))
            ' Insert the child at the current index.
            mount(parent, child, i)
        end if
    end for

    ' Remove remaining children from parent.
    i++
    nextChild = parent.getChild(i)

    while (nextChild <> invalid)
        parent.removeChild(nextChild)

        ' Since we just removed, the remaining children will slide back one, so we can get the next at the same index.
        nextChild = parent.getChild(i)
    end while
end sub