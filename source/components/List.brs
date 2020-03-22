' TODO: how do we update the parent el?
sub update(datas)
    ' We use a temp views array to call setChildren at the end.
    views = []

    if (not m.top.key = "")
        for i = 0 to datas.count() - 1
            data = datas[i]
            ' The id has to be a string for findNode lookup.
            id = data[m.top.key].toStr()

            ' Check if view is in lookup.
            view = m.top.findNode(id)

            if (view = invalid)
                view = el(m.top.listItemNodeType, {id: id})
            end if

            views[i] = view

            ' There is no way to check if a component has a specific function.
            ' If we callFunc that doesn't exist we just get a warning in the console.
            view.callFunc("update", data)
        end for
    else
        for i = 0 to datas.count() - 1
            data = datas[i]
            ' Check if view is in local cache.
            view = m.top.getChild(i)

            if (view = invalid)
                view = el(m.top.listItemNodeType)
            end if

            views[i] = view

            view.callFunc("update", data)
        end for
    end if

    setChildren(m.top, views)
end sub