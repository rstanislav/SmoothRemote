import QtQuick 2.2
import QtGraphicalEffects 1.0


Item
{
    id : slideMenu
    property bool deployed : false
    property alias model : slideMenuListView.model
    property alias delegate : slideMenuListView.delegate
    signal currentIndexChanged(int index)

    QtObject
    {
        id : d
        property int  dragOffset : 50
        property int  offsetVal : 50
    }

    onDeployedChanged: {checkDeployMenu(deployed);}

    function setMenuItemIndex(idx)
    {
        slideMenuListView.currentIndex = idx;
    }

    function checkDeployMenu(deploy)
    {
        if (deployed !== deploy)
            deployed = deploy;
        else
            d.dragOffset = (deploy) ? (slideMenuPanel.width) : (d.offsetVal);
        return deployed;
    }
    Rectangle
    {
        anchors.fill: parent
        opacity : (d.dragOffset / 1000)
        color : "black"
    }

    Rectangle
    {
        id : slideMenuPanel
        width : mainScreen.portrait ? Math.floor(mainScreen.width * 0.8) : 400 * mainScreen.dpiMultiplier
        height : parent.height
        x : d.dragOffset - width
        opacity : (deployed || slideMenuMA.dragging) ? 1 : 0
        Behavior on x {SmoothedAnimation {velocity : 5; duration : 250}}
        Behavior on opacity {SmoothedAnimation {velocity : 5; duration : 500}}
        color : "#111111"

//        LinearGradient
//        {
//            anchors.fill: parent
//            start: Qt.point(width, 0)
//            end: Qt.point(0, height)
//            gradient: Gradient {
//                GradientStop {position: 0; color: "#25282d"}
//                GradientStop {position: 1; color: "black"}
//            }
//        }

        ListView
        {
            id : slideMenuListView
            anchors.fill: parent
            anchors.topMargin: 2
            clip : true
            enabled : deployed
            onCurrentIndexChanged:  {slideMenu.currentIndexChanged(slideMenuListView.currentIndex);}
        }
        Rectangle
        {
            anchors
            {
                bottom: parent.bottom
                left: parent.right
                leftMargin: 5
            }
            width : parent.height
            height : 5
            rotation : -90
            transformOrigin: Item.BottomLeft
            gradient : Gradient {
                GradientStop {position : 0.0; color : "#aa000000"}
                GradientStop {position : 1.0; color : "#00000000"}
            }
        }
    }
    MouseArea
    {
        id : slideMenuMA
        anchors.fill: parent
        property int    oldOffset
        property bool   dragging

        onPressed :
        {
            if (mouseX >= slideMenu.x && mouseX <= d.dragOffset)
            {
                oldOffset = mouseX - d.dragOffset;
                dragging = true;
                mouse.accepted = true;
            }
            else
            {
                checkDeployMenu(false);
                mouse.accepted = false;
            }
        }
        onPositionChanged:
        {
            if (!dragging)
                mouse.accepted = false;
            else
            {
                d.dragOffset = mouseX - oldOffset;
                if (d.dragOffset > slideMenuPanel.width)
                    d.dragOffset = slideMenuPanel.width;
                if (d.dragOffset < d.offsetVal)
                    d.dragOffset = d.offsetVal;
                mouse.accepted = true;
            }
        }
        onReleased:
        {
            if (!dragging)
                mouse.accepted = false;
            else
            {
                propagateComposedEvents = (deployed === checkDeployMenu(d.dragOffset > 0.5 * slideMenuPanel.width)) && (d.dragOffset === slideMenuPanel.width);
                mouse.accepted = true;
                dragging = false;
            }
        }
    }
}
