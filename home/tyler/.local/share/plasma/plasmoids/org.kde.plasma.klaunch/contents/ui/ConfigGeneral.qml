/***************************************************************************
 *   Copyright (C) 2014 by Eike Hein <hein@kde.org>                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0
import org.kde.draganddrop 2.0 as DragDrop
import org.kde.kirigami 2.4 as Kirigami
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.private.kicker 0.1 as Kicker

Kirigami.FormLayout {
    id: configGeneral

    property string cfg_icon: plasmoid.configuration.icon
    property bool cfg_useCustomButtonImage: plasmoid.configuration.useCustomButtonImage
    property string cfg_customButtonImage: plasmoid.configuration.customButtonImage
    property alias cfg_iconSize: iconSize.value
    property alias cfg_spaceWidth: spaceWidth.value
    property alias cfg_spaceHeight: spaceHeight.value
    property alias cfg_backgroundOpacity: backgroundOpacity.value
    property alias cfg_useCustomSizeGrid: useCustomSizeGrid.checked
    property alias cfg_numberColumns: numberColumns.value
    property alias cfg_numberRows: numberRows.value
    property alias cfg_scrollAnimationDuration: scrollAnimationDuration.value
    property alias cfg_showRoundedCorners: showRoundedCorners.checked

    // ----------------- Icon -----------------
    RowLayout {
        Kirigami.FormData.label: i18n("Icon:")
        spacing: units.smallSpacing

        Button {
            id: iconButton

            Layout.minimumWidth: previewFrame.width + units.smallSpacing * 2
            Layout.maximumWidth: Layout.minimumWidth
            Layout.minimumHeight: previewFrame.height + units.smallSpacing * 2
            Layout.maximumHeight: Layout.minimumWidth
            // just to provide some visual feedback, cannot have checked without checkable enabled
            checkable: true
            checked: dropArea.containsAcceptableDrag
            onClicked: {
                checked = Qt.binding(function() {
                    // never actually allow it being checked
                    return iconMenu.status === PlasmaComponents.DialogStatus.Open || dropArea.containsAcceptableDrag;
                });
                iconMenu.open(0, height);
            }

            DragDrop.DropArea {
                id: dropArea

                property bool containsAcceptableDrag: false

                anchors.fill: parent
                onDragEnter: {
                    // Cannot use string operations (e.g. indexOf()) on "url" basic type.
                    var urlString = event.mimeData.url.toString();
                    // This list is also hardcoded in KIconDialog.
                    var extensions = [".png", ".xpm", ".svg", ".svgz"];
                    containsAcceptableDrag = urlString.indexOf("file:///") === 0 && extensions.some(function(extension) {
                        return urlString.indexOf(extension) === urlString.length - extension.length; // "endsWith"
                    });
                    if (!containsAcceptableDrag)
                        event.ignore();

                }
                onDragLeave: containsAcceptableDrag = false
                onDrop: {
                    if (containsAcceptableDrag)
                        // Strip file:// prefix, we already verified in onDragEnter that we have only local URLs.
                        iconDialog.setCustomButtonImage(event.mimeData.url.toString().substr("file://".length));

                    containsAcceptableDrag = false;
                }
            }

            KQuickAddons.IconDialog {
                id: iconDialog

                function setCustomButtonImage(image) {
                    cfg_customButtonImage = image || cfg_icon || "start-here-kde";
                    cfg_useCustomButtonImage = true;
                }

                onIconNameChanged: setCustomButtonImage(iconName)
            }

            PlasmaCore.FrameSvgItem {
                id: previewFrame

                anchors.centerIn: parent
                imagePath: plasmoid.location === PlasmaCore.Types.Vertical || plasmoid.location === PlasmaCore.Types.Horizontal ? "widgets/panel-background" : "widgets/background"
                width: units.iconSizes.large + fixedMargins.left + fixedMargins.right
                height: units.iconSizes.large + fixedMargins.top + fixedMargins.bottom

                PlasmaCore.IconItem {
                    anchors.centerIn: parent
                    width: units.iconSizes.large
                    height: width
                    source: cfg_useCustomButtonImage ? cfg_customButtonImage : cfg_icon
                }

            }

        }

        // QQC Menu can only be opened at cursor position, not a random one
        PlasmaComponents.ContextMenu {
            id: iconMenu

            visualParent: iconButton

            PlasmaComponents.MenuItem {
                text: i18nc("@item:inmenu Open icon chooser dialog", "Choose...")
                icon: "document-open-folder"
                onClicked: iconDialog.open()
            }

            PlasmaComponents.MenuItem {
                text: i18nc("@item:inmenu Reset icon to default", "Clear Icon")
                icon: "edit-clear"
                onClicked: {
                    cfg_useCustomButtonImage = false;
                }
            }

        }

    }

    // ----------------- Appearance -----------------
    Item {
        Kirigami.FormData.isSection: true
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Appearance:")
        Layout.fillWidth: true

        Label {
            text: i18n("Size of application icons:")
            Layout.minimumWidth: 200
        }

        SpinBox {
            id: iconSize

            minimumValue: 24
            maximumValue: 256
            stepSize: 4
        }

    }

    RowLayout {
        Layout.fillWidth: true

        Label {
            text: i18n("Space between columns:")
            Layout.minimumWidth: 200
        }

        SpinBox {
            id: spaceWidth

            minimumValue: 10
            maximumValue: 128
            stepSize: 4
        }

    }

    RowLayout {
        Layout.fillWidth: true

        Label {
            text: i18n("Space between rows:")
            Layout.minimumWidth: 200
        }

        SpinBox {
            id: spaceHeight

            minimumValue: 10
            maximumValue: 128
            stepSize: 4
        }

    }

    RowLayout {
        Layout.fillWidth: true

        Label {
            text: i18n("Rounded corners:")
            Layout.minimumWidth: 200
        }

        CheckBox {
            id: showRoundedCorners
        }

    }

    RowLayout {
        Layout.fillWidth: true

        Label {
            text: i18n("Background opacity:")
            Layout.minimumWidth: 200
        }

        Slider {
            id: backgroundOpacity

            minimumValue: 0
            maximumValue: 100
            stepSize: 10
            implicitWidth: 100
        }

        Label {
            text: i18n(backgroundOpacity.value + "%")
        }

    }

    // ----------------- Custom Sized Grid -----------------
    Item {
        Kirigami.FormData.isSection: true
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Custom Grid:")
        spacing: units.smallSpacing

        CheckBox {
            id: useCustomSizeGrid

            text: i18n("Enable custom grid")
        }

    }

    GroupBox {
        flat: true
        enabled: useCustomSizeGrid.checked

        ColumnLayout {
            RowLayout {
                Layout.fillWidth: true

                Label {
                    Layout.leftMargin: units.smallSpacing
                    text: i18n("Number of columns:")
                }

                SpinBox {
                    id: numberColumns

                    minimumValue: 4
                    maximumValue: 20
                }

            }

            RowLayout {
                Layout.fillWidth: true

                Label {
                    Layout.leftMargin: units.smallSpacing
                    text: i18n("Number of rows:")
                }

                SpinBox {
                    id: numberRows

                    minimumValue: 4
                    maximumValue: 20
                }

            }

        }

    }

    // ----------------- Other -----------------
    Item {
        Kirigami.FormData.isSection: true
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Other:")
        Layout.fillWidth: true

        Label {
            text: i18n("Scroll animation duration (ms):")
        }

        SpinBox {
            id: scrollAnimationDuration

            minimumValue: 0
            maximumValue: 2000
            stepSize: 200
        }

    }

    RowLayout {
        //Layout.fillWidth: true
        Button {
            text: i18n("Unhide all hidden applications")
            onClicked: {
                plasmoid.configuration.hiddenApplications = [""];
                unhideAllAppsPopup.text = i18n("Unhidden!");
            }
        }

        Label {
            id: unhideAllAppsPopup
        }

    }

}
