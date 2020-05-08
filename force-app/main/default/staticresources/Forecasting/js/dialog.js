function FpDialogBox(boxContent, title, buttons, fqContainerClass)
{
    if(!boxContent) return;
    if(!buttons) {
      buttons = [{label: "OK", isSave: true}, {label: "Cancel", isCancel: true}];
    }
    this.name = boxContent.id;
    this.title = title || "Dependent Fields";
    $(boxContent).css("display", "");
    var dialogBody = "<div class=' overlayDialog cssDialog inlineEditDialog "+ ((fqContainerClass)?fqContainerClass:" ") +" ' style='max-width: 650px; display: none; margin-top: -43.75px; margin-left: -172px; visibility: visible;'>" +
                    "<div class='topRight'>" +
                        "<div class='topLeft'>" +
                            "<a title='Close' tabindex='0' onmouseover=\"this.className='dialogCloseOn'\" onmouseout=\"this.className='dialogClose'\" href='javascript:void(0)' class='dialogClose closeBtn'>Close</a>"+
                            "<h2>" + this.title + "</h2>" +
                        "</div>" +
                    "</div>" +
                    "<div class='middle'>" +
                        "<div class='innerContent'>" +
                            "<div class='activeField'>" +
                                "<div class='inlineEditDiv dependentFields'>" +

                                "</div>" +
                            "</div>" +
                            "<div></div>" +
                            "<div style='display: none;'></div>" +
                            "<div class='buttons zen'>";
    for(var i = 0; i < buttons.length; i++) {
      dialogBody +=           "<input class='zen-btn fpDialogButton" + i + "' type='button' value='" + buttons[i].label + "' />";
    }
    dialogBody +=           "</div>" +
                        "</div>" +
                    "</div>" +
                    "<div class='bottomRight'>" +
                        "<div class='bottomLeft'></div>" +
                    "</div>" +
                "</div>";
    this.dialog = $(dialogBody).insertAfter(boxContent);
    this.dialog.find(".inlineEditDiv").append($(boxContent).contents().clone());
    this.id = boxContent.id;
    $(boxContent).detach();
    var d = this;
    this.dialog.find(".closeBtn").click(function() { d.close(); } );
    for(var i = 0, button; button = buttons[i]; i++) {
      var buttonClass = ".fpDialogButton" + i;
      if(typeof(button.action) == "function") {
        var action = button.action;
        this.dialog.find(buttonClass).click(function() { action.call(); d.close(); } );
      }
      else if(button.isSave) {
        this.dialog.find(buttonClass).click(function() { d.onSave(); d.close(); } );
      }
      else if(button.isCancel) {
        this.dialog.find(buttonClass).click(function() { d.onCancel(); d.close(); } );
      }
    }

    if($("#spOverlayBackground").length == 0) {
        $("<div id='spOverlayBackground' class='overlayBackground' style='position: fixed; width: 10000px; height: 20000px; display: none;'></div>").insertAfter(this.dialog);
    }
    this.background = $("#spOverlayBackground");
    var innerFields = $(this.dialog).find("input[data-field-name], select[data-field-name], textarea[data-field-name]");
    this.fields = [];
    if(innerFields.length > 0) {
        for(var i = 0; i < innerFields.length; i++) {
            var field = innerFields[i];
            this.fields.push({ controller: field, name: $(field).attr("data-field-name"), defaultValue: $(field).val() });
        }
    }

    FpDialogBox.dialogs[this.name] = this;

    this.open = function() {
        $(this.dialog).css("display", "block");
        $(this.background).css("display", "block");
    };
    this.close = function() {
        $(this.dialog).css("display", "none");
        $(this.background).css("display", "none");
    };
    this.onCancel = function() {
    };
    this.onSave = function() {
    };
}
FpDialogBox.dialogs = {};
FpDialogBox.close = function() {
    for(var name in FpDialogBox.dialogs)
    {
        FpDialogBox.dialogs[name].close();
    }
};
FpDialogBox.open = function(dialogId) {
    FpDialogBox.close();
    FpDialogBox.dialogs[dialogId].open();
    return FpDialogBox.dialogs[dialogId];
};

FpDialogBox.openWithContent = function(dialogId, content)
{
    FpDialogBox.close();
    $($(FpDialogBox.dialogs[dialogId].dialog).find('.innerContent')).html(content);
    FpDialogBox.dialogs[dialogId].open();
    return FpDialogBox.dialogs[dialogId];
};
