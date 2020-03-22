sub init()
    m.SCREEN_WIDTH = 1920
    m.CARD_WIDTH = 150
    m.CARD_HEIGHT = 180

    m.layoutGoup = el("LayoutGroup")

    mount(m.top, m.layoutGoup)

    mount(m.layoutGoup, [
        el("Label", { text: "Hello RE:SG" }),
        el("Label", { text: "Here is a label." }),
    ])

    m.listItems = [
        "list item 1",
        "list item 2",
        "list item 3",
        "list item 4",
        "list item 5",
    ]

    m.list = list("Li")
    m.list.update(m.listItems)
    m.listContainer = el("Group", invalid, [
        el("LayoutGroup", {translation: [20, 0]}, m.list)
    ])

    mount(m.layoutGoup, m.listContainer)

    m.cardData = []

    for i = 0 to 50 - 1
        width = 75 + rnd(75)
        height = 75 + rnd(75)

        m.cardData[i] = {
            id: i,
            img: {
                width: width,
                height: height,
                uri: "https://picsum.photos/" + width.toStr() + "/" + height.toStr()
            },
            name: "Image " + (i + 1).toStr(),
        }
    end for

    m.cardList = list("Card", "id")
    mount(m.layoutGoup, el("Group", { id: "cardListContainer" }, m.cardList))
    m.cardList.update(m.cardData)
    gridifyChildren(m.cardListContainer, m.SCREEN_WIDTH, m.CARD_WIDTH, m.CARD_HEIGHT)

    m.timer = el("Timer")
    m.timer.duration = 1
    m.timer.repeat = true
    m.timer.observeFieldScoped("fire", "onFireTimer")

    m.timer.control = "start"
end sub

sub onFireTimer()
    m.cardData = sort(m.cardData, function(item)
        return rnd(m.cardData.count())
    end function)
    cardDataRandomSlice = slice(m.cardData, 0, rnd(m.cardData.count() - 1))
    m.cardList.update(cardDataRandomSlice)
    gridifyChildren(m.cardListContainer, m.SCREEN_WIDTH, m.CARD_WIDTH, m.CARD_HEIGHT)
end sub

sub gridifyChildren(parent as object, gridWidth, itemWidth, itemHeight)
    itemsPerRow = gridWidth \ itemWidth

    for i = 0 to parent.getChildCount() - 1
        child = parent.getChild(i)
        x = i MOD itemsPerRow
        y = i \ itemsPerRow

        child.translation = [x * itemWidth, y * itemHeight]
    end for
end sub

'
' Array helper functions.
'
' TODO: add more checks to not get invalid values in the returned array.
function slice(array, beginIndex = 0, endIndex = invalid)
    newArray = []

    if (endIndex = invalid)
        endIndex = array.count() - 1
    end if

    for i = beginIndex to endIndex
        newArray[i] = array[i]
    end for

    return newArray
end function

function sort(array, sortKeyFunction = invalid)
    itemsWithSortKey = []
    count = array.count()

    for i = 0 to count - 1
        itemsWithSortKey.push({
            i: i,
            sortKey: sortKeyFunction(array[i]),
        })
    end for

    itemsWithSortKey.sortBy("sortKey")

    newArray = []

    for i = 0 to count - 1
        newArray.push(array[itemsWithSortKey[i].i])
    end for

    return newArray
end function

