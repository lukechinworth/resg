sub init()
    m.listItems = [
        Li("list item 1"),
        Li("list item 2"),
        Li("list item 3")
    ]

    m.app = el("LayoutGroup", { horizAlignment: "custom" }, [
        el("Label", { text: "Hello re:sg" }),
        el("Label", { text: "Here is a label." }),
        el("Group", invalid, [
            el("LayoutGroup", { ref: "list", translation: [20, 0], horizAlignment: "custom" }, m.listItems)
        ])
    ])

    mount(m.top, m.app)

    m.timer = el("Timer")
    m.timer.duration = 2
    m.timer.observeFieldScoped("fire", "onFireTimer")
    m.timer.control = "start"
end sub

function Li(data) as object
    return {
        el: el("Label", { text: "* " + data })
    }
end function

sub onFireTimer()
    m.listItems.reverse()
    m.listItems.pop()
    setChildren(m.list, m.listItems)
end sub