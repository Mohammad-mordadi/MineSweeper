import QtQuick 2.9
import QtQuick.Window 2.2

Window {
    visible: true
    id:mainwin
    title: qsTr("QML Mine Sweeper")
    readonly property int cellSize: 50
    readonly property int allrows: 10
    readonly property int allcols: 10
    readonly property int bombChance: 7 //0 close to 100% and 10 close to 0%

    property int allbombes: 0
    property int allflags: 0
    property int explodeds: 0
    property int correctFlags: 0
    property int hearts: 3
    property list<Rectangle> cellList
    property bool gameovered: false
    property bool won: false

    width: ((cellSize+maingrid.spacing)*allcols)+25
    height: ((cellSize+maingrid.spacing)*allrows)*1+header.height+footer.height+5

    Rectangle{
        id:header
        color: "darkblue"
        height:50
        anchors{top: parent.top; left: parent.left; right: parent.right}
        z:10
        Column{
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            spacing: 2
            Text {
                id: headerText
                color: "white"
                font.pixelSize: 15
                text: "<b>Mines: </b>"+(mainwin.allbombes-mainwin.explodeds)
            }
            Text {
                id: bombsleft
                color: "white"
                font.pixelSize: 15
                text: "<b>Flagged: </b>"+(mainwin.allflags)
            }
        }


        Rectangle{
            property bool clk: false
            id:imgrec
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            width: 40
            height: 40
            radius: 10
            color: "white"
            Image {
                id: smile
                anchors.fill: parent
                source: "qrc:/smile.png"
                opacity: imgrec.clk? 0.5:1
            }
            MouseArea{
                anchors.fill: parent
                onPressed: {
                    imgrec.clk=true
                    restartGame()
                }
                onReleased: {
                    imgrec.clk=false
                }
            }
        }

    }

    Flipable{
        property bool flipped: false
        id:flippable
        anchors.centerIn: parent
        front:Grid{
            id:maingrid
            anchors.centerIn: parent
            //        anchors{ horizontalCenter: parent.horizontalCenter ;top: header.bottom;bottom: footer.top}
            width: mainwin.cellSize*columns
            height: mainwin.cellSize*rows

            rows: mainwin.allrows
            columns: mainwin.allcols
            spacing: 1
            Repeater{
                model: mainwin.allrows*mainwin.allcols
                Rectangle{
                    property bool bombed: Math.floor(Math.random() * 10)>bombChance
                    property bool clicked: false
                    property string bombsAround: ''
                    id:cell
                    width: mainwin.cellSize
                    height: mainwin.cellSize
                    state: "raw"
                    Text {
                        id:txt
                        anchors.centerIn: parent
                        text: (cell.state=="empty")? cell.bombsAround:''
                        visible: bombsAround>0
                    }
                    Image {
                        id: img
                        visible: txt.text.length==0
                        source: ""
                        anchors.fill: parent
                    }
                    MouseArea{
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: {
                            if(mainwin.gameovered) return;
                            if (mouse.button === Qt.RightButton){
                                if(cell.state=="raw"){
                                    if(allflags<allbombes){
                                        cell.state="flaged"
                                        allflags++;
                                        if(cell.bombed) mainwin.correctFlags++
                                    }
                                }
                                else if(cell.state=="flaged"){
                                    cell.state="raw"
                                    allflags--;
                                    if(cell.bombed) mainwin.correctFlags--
                                }
                                return;
                            }

                            findneighbors(cell)
                            if(cell.state=="raw"){
                                cell.bombed? cell.state="exploded":cell.state="empty"
                                cell.bombed? mainwin.explodeds++:cell.bombed;
                                cell.bombed? mainwin.hearts--:mainwin.hearts
                                if(mainwin.hearts==0){
                                    gameOver();
                                    gameovered=true;
                                    flippable.flipped=true
                                }

                                if(mainwin.allbombes-mainwin.explodeds == mainwin.correctFlags){
                                    mainwin.won=true
                                    gameovered=true;
                                    flippable.flipped=true
                                }
                            }

                        }
                    }
                    Component.onCompleted: {
                        bombed? allbombes++:allbombes
                        mainwin.cellList.push(cell)
                    }

                    states: [
                        State {
                            name: "raw"
                            PropertyChanges {
                                target: cell
                                color:"gray"
                            }
                        },
                        State {
                            name: "empty"
                            PropertyChanges {
                                target: cell
                                color:"green"
                            }
                        },
                        State {
                            name: "exploded"
                            PropertyChanges {
                                target: cell
                                color:"red"
                            }
                            PropertyChanges{
                                target: img
                                source:"qrc:/mine.png"
                            }
                        },
                        State {
                            name: "flaged"
                            PropertyChanges{
                                target: img
                                source:"qrc:/redflag.png"
                            }
                        }
                    ]


                }
            }
        }

        back: Rectangle{
            anchors.centerIn: parent
            width: mainwin.cellSize*mainwin.allcols
            height: mainwin.cellSize*mainwin.allrows
            color: "pink"
            Text {
                id: overtxt
                anchors.centerIn: parent
                text: mainwin.won? "Congratulations!\nYou Won!!!":"Game over"
                font.bold: true
                font.pixelSize: 20
            }
            MouseArea{
                anchors.fill: parent
                onClicked: flippable.flipped=!flippable.flipped
            }
        }

        transform: Rotation{
            axis { x:0 ; y: 1; z: 0 }
            angle: flippable.flipped ? 180:0

            Behavior on angle {
                NumberAnimation { duration: 1000 }
            }
        }

    }
    Rectangle{
        id:footer
        color: "lightblue"
        height: 50
        anchors{bottom: parent.bottom; left: parent.left; right: parent.right}
        Row{
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            Image {
                width: 40
                height: 40
                source: "qrc:/heart.png"
                opacity: hearts>0
            }
            Image {
                width: 40
                height: 40
                source: "qrc:/heart.png"
                opacity: hearts>1
            }
            Image {
                width: 40
                height: 40
                source: "qrc:/heart.png"
                opacity: hearts>2
            }
        }
    }

    Component.onCompleted:{
        console.log(mainwin.cellList.length )
    }

    function findneighbors(cell){
        var num=0
        var cx=cell.x+cell.width/2
        var cy=cell.y+cell.height/2;
        if(maingrid.childAt(cx,cy).bombed) return;

        var item=maingrid.childAt(cx,cy-cellSize);
        if(item)
            if(item.bombed) num++;

        item=maingrid.childAt(cx+cellSize,cy-cellSize)
        if(item)
            if(item.bombed) num++;

        item=maingrid.childAt(cx+cellSize,cy);
        if(item)
            if(item.bombed) num++;

        item=maingrid.childAt(cx+cellSize,cy+cellSize);
        if(item)
            if(item.bombed) num++;

        item=maingrid.childAt(cx,cy+cellSize);
        if(item)
            if(item.bombed) num++;

        item=maingrid.childAt(cx-cellSize,cy+cellSize);
        if(item)
            if(item.bombed) num++;

        item=maingrid.childAt(cx-cellSize,cy);
        if(item)
            if(item.bombed) num++;

        item=maingrid.childAt(cx-cellSize,cy-cellSize);
        if(item)
            if(item.bombed) num++;

        maingrid.childAt(cx,cy).bombsAround=num;
    }

    function gameOver(){ //explodes all bombes
        for(var i=0;i<mainwin.cellList.length;i++){
            if (mainwin.cellList[i].bombed)
                mainwin.cellList[i].state="exploded"
        }
    }

    function restartGame(){
        allbombes=0;
        allflags=0;
        explodeds=0;
        hearts=3;
        gameovered=false;
        correctFlags=0;
        won=false
        flippable.flipped=false

        for(var i=0;i<mainwin.cellList.length;i++){
            mainwin.cellList[i].bombed=Math.floor(Math.random() * 10)>bombChance
            if(mainwin.cellList[i].bombed) allbombes++;
            mainwin.cellList[i].clicked=false
            mainwin.cellList[i].state="raw"
        }
    }
}
