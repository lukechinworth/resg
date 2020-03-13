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
        if (not type(children) = "roArray")
            children = [children]
        end if

        for i = 0 to children.count() - 1
            mount(element, children[i])
        end for
    end if

    return element
end function

' TODO: update to include parent as first arg.
' TODO: add key to args to maintain item state.
function list(View as function)
    return {
        __resg_is_list: true,
        View: View,
        views: [],
        update: sub(datas)
            ' We use a temp views array so that it has the same length as the new data coming in.
            views = []

            for i = 0 to datas.count() - 1
                data = datas[i]
                ' Check if view is in local cache.
                view = m.views[i]

                if (view = invalid)
                    view = m.View().init()
                end if

                views[i] = view

                if (view.update <> invalid)
                    view.update(data)
                end if
            end for

            ' m.parent is set on the list in mount().
            if (m.parent <> invalid)
                setChildren(m.parent, views)
            end if

            m.views = views
        end sub
    }
end function

sub mount(parent as object, child as object, insertIndex = invalid as object)
    if (type(parent) = "roAssociativeArray" and parent.el <> invalid)
        parentEl = parent.el
    else
        parentEl = parent
    end if

    if (type(child) = "roAssociativeArray" and child.el <> invalid)
        childEl = child.el
    else
        childEl = child
    end if

    if (type(childEl) = "roSGNode")
        if (insertIndex <> invalid)
            parentEl.insertChild(childEl, insertIndex)
        else
            parentEl.appendChild(childEl)
        end if
    else if (type(childEl) = "roArray")
        for i = 0 to childEl.count() - 1
            mount(parentEl, childEl[i])
        end for
    else if (childEl.__resg_is_list)
        ' TODO: update when we add parent to list args.
        childEl.parent = parentEl
        mount(parentEl, childEl.views)
    end if
end sub

sub setChildren(parent, children)
    if (type(parent) = "roAssociativeArray" and parent.el <> invalid)
        parentEl = parent.el
    else
        parentEl = parent
    end if

    currentIndex = 0
    current = parentEl.getChild(currentIndex)

    for i = 0 to children.count() - 1
        child = children[i]

        if (type(child) = "roAssociativeArray" and child.el <> invalid)
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
        parentEl.removeChild(current)

        ' Update current to next child to end the loop or remove it on the next pass.
        current = nextChild
    end while
end sub
