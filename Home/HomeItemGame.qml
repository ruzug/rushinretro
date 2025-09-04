import QtQuick 2.15
import QtGraphicalEffects 1.12
import QtMultimedia 5.15
import "../Global"

Item {
    id: root

    property string clearedShortname: clearShortname(currentGameCollection.shortName)
    readonly property var currentGameCollection: gameData ? gameData.collections.get(0) : ""
    readonly property string currentGameCollectionColor: {
        if (dataConsoles[clearedShortname] !== undefined) {
            return dataConsoles[clearedShortname].color
        } else {
            return dataConsoles["default"].color
        }
    }
    readonly property string currentGameCollectionAltColor: {
        if (dataConsoles[clearedShortname] !== undefined) {
            return accentColorNr !== 0 ? dataConsoles[clearedShortname].altColor : dataConsoles[clearedShortname].altColor2
        } else {
            return accentColorNr !== 0 ? dataConsoles["default"].altColor : dataConsoles["default"].altColor2
        }
    }
    readonly property string selectionFrameColorSelected:{
        if (selectionFrame === 1) {
            return colorScheme[theme].selected
         } else {
            return currentGameCollectionAltColor
        }
    }
    readonly property string selectionFrameColorTransition:{
        if (selectionFrame === 1) {
            return colorScheme[theme].selectedtransition
         } else {
            return currentGameCollectionColor
        }
    }

    signal activated
    signal highlighted
    signal unhighlighted

    property bool selected
    property var gameData: modelData

    // In order to use the retropie icons here we need to do a little collection specific hack
    readonly property bool playVideo: gameData ? gameData.assets.videoList.length : ""
    scale: selected ? 1 : 0.95
    Behavior on scale { NumberAnimation { duration: 100 } }
    z: selected ? 10 : 1

    onSelectedChanged: {
        if (selected && playVideo) {
            fadescreenshot.restart();
        } else {
            fadescreenshot.stop();
            screenshot.opacity = 1;
            imgPrecompose.opacity = 1;
            container.opacity = 1;
            if (homeVideoLogo === false) {
                favelogo.opacity = 1;
            }
        }
    }

    // NOTE: Fade out the bg so there is a smooth transition into the video
    Timer {
        id: fadescreenshot
        interval: 1200
        onTriggered: {
            screenshot.opacity = 0;
            imgPrecompose.opacity = 0;
            if (homeVideoLogo === false) {
                favelogo.opacity = 0;
            }
        }
    }

    Item {
        id: container
        anchors.fill: parent
        Behavior on opacity { NumberAnimation { duration: 200 } }

        GameVideo {
            game: gameData
            anchors.fill: parent
            playing: selected && homeVideo != 1
            sound: homeVideoMute
        }

        Item {
            id: imgPrecompose
            Image {
                id: marquee
                anchors.fill: parent
                source: gameData ? gameData.assets.marquee : ""
                sourceSize: Qt.size(screenshot.width, screenshot.height)
                smooth: false
                asynchronous: true
                visible: false
            }
            Image {
                id: steamgrid
                anchors.fill: parent
                source: gameData ? gameData.assets.steam : ""
                sourceSize: Qt.size(screenshot.width, screenshot.height)
                smooth: false
                asynchronous: true
                visible: homeImgPrecomposePref == "steam" && gameData.assets.steam
            }
            anchors.fill:parent
            Behavior on opacity { NumberAnimation { duration: 200 } } 
            z: 11
            visible: homeImgPrecompose && !doubleFocus && (homeImgPrecomposePref == "marquee" && gameData.assets.marquee || homeImgPrecomposePref == "steam" && gameData.assets.steam)
        }

        Image {
            id: screenshot
            anchors.fill: parent
            anchors.margins: vpx(3)
            source: gameData ? gameData.collections.get(0).shortName === "android" ? "" : gameData.assets.screenshots[0] || gameData.assets.titlescreen || gameData.assets.background || boxArt(gameData) || "" : ""
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(screenshot.width, screenshot.height)
            smooth: false
            asynchronous: true
            visible: imgPrecompose.opacity !== 1 || (!marquee.visible && !steamgrid.visible)
            Behavior on opacity { NumberAnimation { duration: 200 } }

            CompletedIcon {
                id: completedicon
                parentImageWidth: screenshot.width
            }
        }

        Image {
            id: favelogo
            anchors.fill: parent
            anchors.centerIn: parent
            anchors.margins: root.width/10
            property string logoImage: (gameData && gameData.collections.get(0).shortName === "retropie") ? gameData.assets.boxFront : (gameData.collections.get(0).shortName === "steam") ? logo(gameData) : gameData.assets.logo
            source: gameData ? gameData.collections.get(0).shortName === "android" ? boxArt(gameData) : logoImage || "" : ""
            sourceSize: Qt.size(favelogo.width, favelogo.height)
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true
            visible: imgPrecompose.opacity !== 1 || (!marquee.visible && !steamgrid.visible)
            z: 10
        }

        Rectangle {
            id: regborder
            anchors.fill: parent
            color: "transparent"
            anchors.rightMargin: 1
            anchors.leftMargin: 1
            anchors.bottomMargin: 1
            anchors.topMargin: 1
            border.width: vpx(3)
            border.color: colorScheme[theme].secondary
            opacity: 0.5
        }
    }

    Text {
        anchors.fill: parent
        text: gameData.title
        font {
            family: global.fonts.sans
            weight: Font.Medium
            pixelSize: vpx(16 * fontScalingFactor)
        }
        color: colorScheme[theme].text

        horizontalAlignment : Text.AlignHCenter
        verticalAlignment : Text.AlignVCenter
        wrapMode: Text.Wrap
        visible: (favelogo.status === Image.Null && screenshot.status === Image.Null) || (favelogo.status === Image.Error && screenshot.status === Image.Error)
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: vpx(-3)
        color: selectionFrameColorSelected
        opacity: selected
        Behavior on opacity {
            NumberAnimation { duration: 200; }
        }

        // Animation layer
        Rectangle {
            id: rectAnim
            width: parent.width
            height: parent.height
            visible: selected
            color: selectionFrameColorTransition

            SequentialAnimation on opacity {
                id: colorAnim
                running: true
                loops: Animation.Infinite
                NumberAnimation {
                    to: 1
                    duration: 200
                }
                NumberAnimation {
                    to: 0
                    duration: 500
                }
                PauseAnimation { duration: 200 }
            }
        }
        z: -10
    }

    function steamAppID (gameData) {
        var str = gameData.assets.boxFront.split("header");
        return str[0];
    }

    function steamLogo(gameData) {
        return steamAppID(gameData) + "/logo.png";
    }

    function logo(data) {
        if (data != null) {
            if (data.assets.boxFront.includes("header.jpg")) 
                return steamLogo(data);
            else {
                if (data.assets.logo != "")
                    return data.assets.logo;
            }
        }
        return "";
    }
	
	function boxArt(data) {
        if (data != null) {
            if (data.assets.boxFront.includes("header.jpg"))
                return steamBoxFront(data);
        else {
            if (data.assets.boxFront != "" && gamesBoxArtPref == "boxfront")
                return data.assets.boxFront;
            else if (data.assets.poster != "" && gamesBoxArtPref == "poster")
                return data.assets.poster;
            else if (data.assets.steam != "" && gamesBoxArtPref == "steam")
                return data.assets.steam;
            else if (data.assets.marquee != "" && gamesBoxArtPref == "marquee")
                return data.assets.marquee;
            else if (data.assets.boxFront != "")
                return data.assets.boxFront;
            else if (data.assets.poster != "")
                return data.assets.poster;
            else if (data.assets.banner != "")
                return data.assets.banner;
            else if (data.assets.tile != "")
                return data.assets.tile;
            else if (data.assets.cartridge != "")
                return data.assets.cartridge;
            else if (data.assets.logo != "")
                    return data.assets.logo;
            }
        }
        return "";
    }

}
