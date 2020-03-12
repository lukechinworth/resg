sub init()
    m.layoutGoup = el("LayoutGroup")

    mount(m.top, m.layoutGoup)

    m.labels = [
        el("Label", { text: "Hello re:sg" }),
        el("Label", { text: "Here is a label." }),
    ]

    mount(m.layoutGoup, m.labels)

    m.listItems = [
        Li("list item 1"),
        Li("list item 2"),
        Li("list item 3"),
        Li("list item 4"),
        Li("list item 5")
    ]

    m.listContainer = el("Group", invalid, [
        el("LayoutGroup", { ref: "list", translation: [20, 0], horizAlignment: "custom" }, m.listItems)
    ])

    mount(m.layoutGoup, m.listContainer)

    m.cardData = []
    m.cardList = []

    for i = 0 to 50 - 1
        width = 75 + rnd(75)
        height = 75 + rnd(75)

        m.cardData[i] = {
            img: {
                width: width,
                height: height,
                uri: "https://picsum.photos/" + width.toStr() + "/" + height.toStr()
            },
            name: "Image " + (i + 1).toStr()
        }
        m.cardList[i] = Card().init()
        m.cardList[i].update(m.cardData[i])
    end for

    ' TODO: implement the list helper.
    ' m.cardList = list(Card)

    mount(m.layoutGoup, m.cardList)

    m.timer = el("Timer")
    m.timer.duration = 2
    m.timer.observeFieldScoped("fire", "onFireTimer")
    m.timer.control = "start"
end sub

sub onFireTimer()
    m.listItems.reverse()
    m.listItems.pop()
    m.listItems.pop()
    setChildren(m.list, m.listItems)
end sub

'
' Components
'
function Li(data) as object
    return {
        el: el("Label", { text: "* " + data })
    }
end function

function Card() as object
    return {
        ' We use init to gain access to the context m.
        init: function()
            m.el = el("LayoutGroup", invalid, [
                el("Poster", { ref: "poster", context: m }),
                el("Label", { ref: "name", context: m })
            ])

            return m
        end function,
        update: sub(data)
            m.poster.width = data.img.width
            m.poster.height = data.img.height
            m.poster.uri = data.img.uri

            m.name.text = data.name
        end sub,
    }
end function