function el(tagName, fields = invalid as object, children = invalid as object)
    element = createObject("roSGNode", tagName)

    if (fields <> invalid)
        ' Handle ref field, which makes element available to context.
        if (fields["ref"] <> invalid)
            ' Use the passed in context, defaulting to calling context.
            if (fields["context"] <> invalid)
                context = fields["context"]
            else
                context = m
            end if

            context[fields["ref"]] = element

            fields.delete("ref")
            fields.delete("context")
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

' TODO: get parent.el for components.
sub mount(parent as object, child as object, insertIndex = invalid as object)
    ' If child is a poo, it is one of our components.
    if (type(child) = "roAssociativeArray")
        childEl = child.el
    else
        childEl = child
    end if

    if (type(childEl) = "roSGNode")
        if (insertIndex <> invalid)
            parent.insertChild(childEl, insertIndex)
        else
            parent.appendChild(childEl)
        end if
    else if (type(childEl) = "roArray")
        for i = 0 to childEl.count() - 1
            mount(parent, childEl[i])
        end for
    end if
end sub

sub setChildren(parent, children)
    ' If parent is a poo, it is one of our components.
    if (type(parent) = "roAssociativeArray")
        parentEl = parent.el
    else
        parentEl = parent
    end if

    currentIndex = 0
    current = parentEl.getChild(currentIndex)

    for i = 0 to children.count() - 1
        child = children[i]

        ' If child is a poo, it is one of our components.
        if (type(child) = "roAssociativeArray")
            childEl = child.el
        else
            childEl = child
        end if

        if (not childEl.isSameNode(current))
            ' Insert the child at the current index.
            mount(parentEl, childEl, currentIndex)
        end if

        currentIndex++
        current = parentEl.getChild(currentIndex)
    end for

    ' Remove remaining children from parent.
    while (current <> invalid)
        currentIndex++
        ' Cache reference to next child.
        nextChild = parent.getChild(currentIndex)

        ' Remove current.
        parent.removeChild(current)

        ' Update current to next child to end the loop or remove it on the next pass.
        current = nextChild
    end while
end sub
