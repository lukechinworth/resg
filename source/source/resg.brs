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