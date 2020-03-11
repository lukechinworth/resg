function el(tagName, fields = invalid as object, children = invalid as object)
    element = createObject("roSGNode", tagName)

    if (fields <> invalid)
        if (fields["ref"] <> invalid)
            m[fields["ref"]] = element

            fields.delete("ref")
        end if

        element.setFields(fields)
    end if

    if (children <> invalid)
        for i = 0 to children.count() - 1
            mount(element, children[i])
        end for
    end if

    return element
end function

sub mount(parent as object, child as object, insertIndex = invalid as object)
    ' If child is a poo, it is one of our components.
    if (type(child) = "roAssociativeArray")
        childEl = child.el
    else
        childEl = child
    end if

    if (insertIndex <> invalid)
        parent.insertChild(childEl, insertIndex)
    else
        parent.appendChild(childEl)
    end if
end sub

sub setChildren(parent, children)
    ' If parent is a poo, it is one of our components.
    if (type(parent) = "roAssociativeArray")
        parentEl = parent.el
    else
        parentEl = parent
    end if

    ' TODO: This works, but I'm surprised. Refactor t to be clearer.
    t = 0
    traverse = parentEl.getChild(t)

    for i = 0 to children.count() - 1
        child = children[i]

        ' If child is a poo, it is one of our components.
        if (type(child) = "roAssociativeArray")
            childEl = child.el
        else
            childEl = child
        end if

        if (childEl.isSameNode(traverse))
            traverse = parentEl.getChild(t + 1)
        else
            mount(parentEl, childEl, t)
            t++
        end if
    end for

    ' Remove remaining children from parent.
    while (traverse <> invalid)
        nextChild = parent.getChild(t + 1)

        parent.removeChild(traverse)

        traverse = nextChild
    end while
end sub