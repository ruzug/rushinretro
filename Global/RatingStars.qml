import QtQuick 2.15
import QtGraphicalEffects 1.12

Item {
    width: vpx(100)
    height: vpx(20)

    property var starsMatrix: [
        { source: getStars(0, rating) },
        { source: getStars(1, rating) },
        { source: getStars(2, rating) },
        { source: getStars(3, rating) },
        { source: getStars(4, rating) }
    ]

    function getStars(index, rate) {
        if (rate <= index) {
            return no_star
        }
        else if (rate <= index + 0.5) {
            return half_star
        }
        else {
            return star
        }
    }

    function getBackgroundColor(rate) {
        if (rate < 2.5) {
            return "#B5714B"
        }
        else if (rate < 4) {
            return colorScheme[theme].main
        }
        else {
            return "#FFCE00"
        }
    }

    Component {
        id: no_star
        Item {
            width: vpx(12 * fontScalingFactor)
            height: vpx(12 * fontScalingFactor)
            Text {
                text: glyphs.emptyStar
                anchors.fill: parent
                font {
                    family: glyphs.name
                    pixelSize: parent.height
                }
                color: colorScheme[theme].accentalt
            }
        }
    }

    Component {
        id: half_star
        Item {
            width: vpx(12 * fontScalingFactor)
            height: vpx(12 * fontScalingFactor)
            Text {
                text: glyphs.halfStar
                anchors.fill: parent
                font {
                    family: glyphs.name
                    pixelSize: parent.height
                }
                color: colorScheme[theme].favorite
            }
        }
    }

    Component {
        id: star
        Item {
            width: vpx(12 * fontScalingFactor)
            height: vpx(12 * fontScalingFactor)
            Text {
                text: glyphs.fullStar
                anchors.fill: parent
                font {
                    family: glyphs.name
                    pixelSize: parent.height
                }
                color: colorScheme[theme].favorite
            }
        }
    }

    Row {
        id: rating_stars
        spacing: vpx(4)
        Repeater {
            model: starsMatrix
            delegate: Loader {
                sourceComponent: modelData.source
                visible: status == Loader.Ready
            }
        }
    }

}