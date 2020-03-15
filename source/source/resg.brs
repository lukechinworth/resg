'
' Core functions: el, list, mount, setChildren
'
function el(tagName, fields = invalid as object, children = invalid as object)
    element = createObject("roSGNode", tagName)

    if (fields <> invalid)
        ' Use the passed in context, defaulting to calling context.
        if (fields.context <> invalid)
            context = fields.context
        else
            context = m
        end if

        ' Handle ref field, which makes element available to context.
        if (fields.ref <> invalid)
            context[fields.ref] = element
        end if

        ' Handle on field, which adds event listeners.
        if (fields.on <> invalid)
            items = fields.on.items()

            for i = 0 to items.count() - 1
                item = items[i]

                ' TODO: is there a better way to add/remove field observers?
                ' TODO: maybe attach function here that calls  context["method"]()?
                element.observeFieldScoped(item.key, item.value)
            end for
        end if

        fields.delete("on")
        fields.delete("ref")
        fields.delete("context")

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
function list(View as function, key = invalid)
    this = {}
    this.__resg_is_list = true
    this.View = View
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
                    view = m.View().init()
                end if

                views[i] = view
                lookup[id] = view

                if (view.update <> invalid)
                    ' TODO: add other args here.
                    view.update(data)
                end if
            end for

            ' Rest the lookup.
            m.lookup = lookup
        else
            for i = 0 to datas.count() - 1
                data = datas[i]
                ' Check if view is in local cache.
                view = m.views[i]

                if (view = invalid)
                    view = m.View().init()
                end if

                views[i] = view

                if (view.update <> invalid)
                    ' TODO: add other args here.
                    view.update(data)
                end if
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
    parentEl = getEl(parent)
    childEl = getEl(child)

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
    parentEl = getEl(parent)

    for i = 0 to children.count() - 1
        child = children[i]
        current = parentEl.getChild(i)

        childEl = getEl(child)

        if (not childEl.isSameNode(current))
            ' Insert the child at the current index.
            mount(parentEl, childEl, i)
        end if
    end for

    ' Remove remaining children from parent.
    i++
    nextChild = parentEl.getChild(i)

    while (nextChild <> invalid)
        parentEl.removeChild(nextChild)

        ' Since we just removed, the remaining children will slide back one, so we can get the next at the same index.
        nextChild = parentEl.getChild(i)
    end while
end sub

'
' Utils.
'
function getEl(elementOrComponent)
    if (type(elementOrComponent) = "roAssociativeArray" and elementOrComponent.el <> invalid)
        return elementOrComponent.el
    else
        return elementOrComponent
    end if
end function