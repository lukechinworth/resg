sub init()
    mount(m.top, [
        ' TODO: update ref to id.
        el("Poster", { id: "poster",}),
        el("Label", { id: "name"})
    ])

    ' Add field observers here if desired, e.g.
    ' m.poster.observeFieldScoped("uri", "callbackFn")
end sub

sub update(data)
    ' These should be the same if keys are used in the list.
    print m.name.text, data.name

    m.poster.width = data.img.width
    m.poster.height = data.img.height
    m.poster.uri = data.img.uri

    m.name.text = data.name
end sub