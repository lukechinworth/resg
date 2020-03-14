sub init()
    m.layoutGoup = el("LayoutGroup")

    mount(m.top, m.layoutGoup)

    m.labels = [
        el("Label", { text: "Hello RE:SG" }),
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
    end for

    m.cardList = list(Card)
    m.cardList.update(m.cardData)
    ' TODO: is there a better way to add/remove field observers?
    mount(m.layoutGoup, el("Group", { ref: "listContainer", on: { change: "onChangeListContainer" } }, m.cardList))

    m.timer = el("Timer")
    m.timer.duration = 1
    m.timer.repeat = true
    m.timer.observeFieldScoped("fire", "onFireTimer")

    m.timer.control = "start"
end sub

sub onFireTimer()
    m.cardData = sortRandom(m.cardData)
    cardDataRandomSlice = slice(m.cardData, 0, rnd(50 - 1))
    m.cardList.update(cardDataRandomSlice)
end sub

sub onChangeListContainer(e as object)
    change = e.getData()

    newIndex = invalid

    if (change.operation = "move")
        newIndex = change.index2
    else if (change.operation = "add" or change.operation = "insert")
        newIndex = change.index1
    end if

    if (newIndex = invalid)
        return
    end if

    SCREEN_WIDTH = 1920
    CARD_WIDTH = 150
    CARD_HEIGHT = 170
    cardsPerRow = SCREEN_WIDTH \ CARD_WIDTH
    x = newIndex MOD cardsPerRow
    y = newIndex \ cardsPerRow

    listContainer = e.getRoSGNode()
    child = listContainer.getChild(newIndex)
    child.translation = [x * CARD_WIDTH, y * CARD_HEIGHT]
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

' TODO: add more checks to not get invalid values.
function slice(array, begin = 0, endIndex = invalid)
    newArray = []

    if (endIndex = invalid)
        endIndex = array.count() - 1
    end if

    for i = begin to endIndex
        newArray[i] = array[i]
    end for

    return newArray
end function

function sortRandom(array)
    itemsWithRandomNumber = []
    count = array.count()

    for i = 0 to count - 1
        itemsWithRandomNumber.push({
            sortKey: rnd(count),
            i: i
            items: array[i],
        })
    end for

    itemsWithRandomNumber.sortBy("sortKey")

    newArray = []

    for i = 0 to count - 1
        newArray.push(array[itemsWithRandomNumber[i].i])
    end for

    return newArray
end function

