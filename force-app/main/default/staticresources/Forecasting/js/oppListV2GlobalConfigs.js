var oppListV2GlobalConfiger = {
    Fields: {},
    Utils: {},
    AngularContainer: "#ngContainer"
};

//Utils
oppListV2GlobalConfiger.Utils.toTwoDigts = function(num) {
    return (num > 9) ? num : ('0' + num);
};
oppListV2GlobalConfiger.Utils.getAngularScope = function() {
    return angular.element($(oppListV2GlobalConfiger.AngularContainer)).scope();
};
oppListV2GlobalConfiger.Utils.toSfdcDateFormat = function(dateToFormat) {
    return oppListV2GlobalConfiger.Utils.toTwoDigts((dateToFormat.getMonth() + 1)) + '/' + oppListV2GlobalConfiger.Utils.toTwoDigts(dateToFormat.getDate()) + '/' + dateToFormat.getFullYear();
};

//Fields inits
oppListV2GlobalConfiger.Fields.sfdcDate = function(config) {
    jsGrid.Field.call(this, config);
};
oppListV2GlobalConfiger.Fields.sfdcName = function(config) {
    jsGrid.Field.call(this, config);
};
oppListV2GlobalConfiger.Fields.sfdcReference = function(config) {
    jsGrid.Field.call(this, config);
};
oppListV2GlobalConfiger.Fields.sfdcCurrency = function(config) {
    jsGrid.Field.call(this, config);
};
oppListV2GlobalConfiger.Fields.sfdcPicklist = function(config) {
    jsGrid.Field.call(this, config);
};

//Fields definitions
oppListV2GlobalConfiger.Fields.sfdcDate.prototype = new jsGrid.Field({
    css: 'jsGrid-sfdc-date',
    align: 'center',
    sfdcFormat: 'YYYY-MM-dd',
    sorter: 'date',
    itemTemplate: function(value) {
        return value;
    },
    insertTemplate: function(value) {
        return this._insertPicker = $("<input>").datepicker({
            defaultDate: new Date()
        });
    },
    editTemplate: function(value, item) {
        this._editPicker = $("<input>").datepicker().datepicker("setDate", new Date(value));
        if (this.editing === true && item.RecordEditable === true) {
            return this._editPicker;
        }
        return value;
    },
    insertValue: function() {
        return oppListV2GlobalConfiger.Utils.toSfdcDateFormat(this._insertPicker.datepicker("getDate"));
    },
    editValue: function() {
        return oppListV2GlobalConfiger.Utils.toSfdcDateFormat(this._editPicker.datepicker("getDate"));
    }
});
oppListV2GlobalConfiger.Fields.sfdcName.prototype = new jsGrid.Field({
    css: 'jsGrid-sfdc-name',
    align: 'center',
    suffix: '',
    preffix: '',
    dependency: true,
    sorter: 'string',

    itemTemplate: function(value) {
        var elem = $('<div>');
        elem.append($('<span>').text(this.preffix));
        var nameLink = $("<a class='js-grid-ext_sfdc-name_link'>").prop('href', '/' + value.dependency).prop('target', '_blank').addClass('js-grid_sfdcName').text(this.scope.unescape(value.value));
        elem.append(nameLink);
        elem.append($('<span>').text(this.suffix));
        return elem;
    },
    insertTemplate: function(value) {
        return this._insertPicker = $("<input>").prop('type', 'text').val(this.scope.unescape(value));
    },
    editTemplate: function(value, item) {

        this._editPicker = $("<input>").prop('type', 'text').val(this.scope.unescape(value.value));
        if (this.editing === true && item.RecordEditable === true) {
            return this._editPicker;
        }
        return this.scope.unescape(value.value);
    },
    insertValue: function() {
        return this._insertPicker.val();
    },
    editValue: function() {
        return this.scope.unescape(this._editPicker.val());
    }
});
oppListV2GlobalConfiger.Fields.sfdcReference.prototype = new jsGrid.Field({
    css: 'jsGrid-sfdc-reference',
    align: 'center',
    dependency: true,

    sorter: 'string',

    itemTemplate: function(value) {
        return $("<a>").prop('href', '/' + value.value).prop('target', '_blank').addClass('js-grid_sfdcUrl').text(this.scope.unescape(this.scope.unescape(value.dependency)));
    },
    insertTemplate: function(value) {
        return this._insertPicker = $("<input>").prop('type', 'text').val(value);
    },
    editTemplate: function(value, item) {
        this._editPicker = this._createLookupInputArea(value, item, this)
        if (this.editing === true && item.RecordEditable === true) {
            return this._editPicker; //$("<input>").prop('type', 'text').val(value.dependency);
        }
        return this.scope.unescape(value.dependency);
    },
    insertValue: function() {
        var uid = this.dplp + '_' + this.lkfield;
        return (this._editPicker.find('#' + uid).val()) ? this._editPicker.find('input[id$="_lkid"]').val() : '';
    },
    editValue: function() {
        var uid = this.dplp + '_' + this.lkfield;
        return (this._editPicker.find('#' + uid).val()) ? this._editPicker.find('input[id$="_lkid"]').val() : '';
    },
    _createLookupInputArea: function(value, item, field) {
        field.dplp = item.OppId;
        var uniqueId = item.OppId + '_' + field.lkfield;
        var fieldValue = (value.value) ? value.value : '';
        var fieldLabel = (value.dependency) ? this.scope.unescape(value.dependency) : '';
        var inlineEditDiv = $('<div>').prop('id', uniqueId + '_ileinneredit').prop('style', 'display: block;');
        var lookupInput = $('<span>').prop('class', 'lookupInput bEditBlock');
        lookupInput.append($('<input>').prop('type', 'hidden').prop('id', uniqueId + '_lkid').prop('name', uniqueId + '_lkid').val(fieldValue));
        lookupInput.append($('<input>').prop('type', 'hidden').prop('id', uniqueId + '_lkold').prop('name', uniqueId + '_lkold').val(fieldValue));
        lookupInput.append($('<input>').prop('type', 'hidden').prop('id', uniqueId + '_lktp').prop('name', uniqueId + '_lktp').val(field.lktp));

        lookupInput.append($("<input>").prop('type', 'text').prop('size', 20).prop('maxlength', 255).prop('id', uniqueId).prop('name', uniqueId).val(this.scope.unescape(fieldLabel)));
        var iconsWrapper = $('<div>');
        iconsWrapper.append($('<img>').prop('class', 'closeIcon').prop('alt', 'Clear').prop('title', 'Clear').prop('src', '/s.gif').prop('style', 'margin-top: 0px;vertical-align: unset;').on('click', function() {
            $('#' + uniqueId + '_lkid').val('');
            $('#' + uniqueId + '_lkold').val('');
            $('#' + uniqueId).val('');
        }));
        var openerIcon = $('<a>').prop('href', 'javascript:void(0);').prop('id', uniqueId + 'Icon').prop('title', field.title).prop('style', 'display: inline-block;').on('click', function() {
            var srch = '';
            var srchInput = $('#' + uniqueId).val();
            srch = (srchInput) ? encodeURIComponent(srchInput) : encodeURIComponent(fieldLabel);
            var a = '/_ui/common/data/LookupPage?lknm=' + uniqueId + '&lktp=' + field.lktp + '&lkent=' + field.lkent + '&lkfield=' + field.lkfield + '&dplp=%5B%22' + field.dplp + '%22%5D&lksrch=' + srch;
            window.openPopup(a, field.title + ' Lookup', 350, 480, "width\x3d" + 670 + ",height\x3d480,toolbar\x3dno,status\x3dno,directories\x3dno,menubar\x3dno,resizable\x3dyes,scrollable\x3dno", !0)
        });
        openerIcon.append($('<img>').prop('src', '/s.gif').prop('class', 'lookupIcon').prop('alt', field.title + ' Lookup (New Window)').prop('style', 'display:block;'));
        iconsWrapper.append(openerIcon);
        lookupInput.append(iconsWrapper);
        inlineEditDiv.append(lookupInput);
        return inlineEditDiv;
    }
});
oppListV2GlobalConfiger.Fields.sfdcCurrency.prototype = new jsGrid.Field({
    css: 'jsGrid-sfdc-currency',
    align: 'center',
    scope: {},
    sorter: 'string',

    itemTemplate: function(value) {
        //var scope = oppListV2GlobalConfiger.Utils.getAngularScope();
        value = (value)?value:0;
        return "<span>" + this.scope.formatDecimal(value, this.scope.displayFormat) + "</span>";
    },
    insertTemplate: function(value) {
        value = (value)?value:0;
        return this._insertPicker = $("<input>").prop('type', 'number').val(value);
    },
    editTemplate: function(value, item) {
        value = (value)?value:0;
        this._editPicker = $("<input>").prop('type', 'number').val(value);
        if (this.editing === true && item.RecordEditable === true) {
            return this._editPicker;
        }
        return this.itemTemplate(value);
    },
    insertValue: function() {
        var val = this._editPicker.val();
        return (val)?val:0;
    },
    editValue: function() {
        var val = this._editPicker.val();
        return (val)?val:0;
    }
});
oppListV2GlobalConfiger.Fields.sfdcPicklist.prototype = new jsGrid.Field({
    css: 'jsGrid-sfdc-picklist',
    align: 'center',
    scope: {},
    options: '',
    numberValueType: "number",
    stringValueType: "string",
    valueType: "string",
    sorter: 'string',

    itemTemplate: function(value, item) {
        var items = this._getOptions(this.scope, this.options),
            valueField = this.valueField,
            textField = this.textField,
			scope = this.scope,
            resultItem;

		value = this.scope.unescape(value);
		if(value !== item[this.name]){
			item[this.name] = value;
		}

        if (valueField) {
            resultItem = $.grep(items, function(item, index) {
                return value === scope.unescape(item[valueField]);
            })[0] || {};
        } else {
            resultItem = items[value];
        }

        var result = (textField ? resultItem[textField] : resultItem);

        return (result === undefined || result === null) ? "" : this.scope.unescape(result);
    },

    filterTemplate: function() {
        if (!this.filtering)
            return "";

        var grid = this._grid,
            $result = this.filterControl = this._createSelect();

        if (this.autosearch) {
            $result.on("change", function(e) {
                grid.search();
            });
        }

        return $result;
    },

    insertTemplate: function() {
        if (!this.inserting)
            return "";

        return this.insertControl = this._createSelect('');
    },

    editTemplate: function(value, item) {
        var $result = this.editControl = this._createSelect(value);
        if (item.RecordEditable === false || this.editing === false)
            return this.itemTemplate.apply(this, arguments);
        (value !== undefined) && $result.val(this.scope.unescape(value));
        return $result;
    },

    filterValue: function() {
        var val = this.filterControl.val();
        return this.valueType === this.numberValueType ? parseInt(val || 0, 10) : val;
    },

    insertValue: function() {
        var val = this.insertControl.val();
        return this.valueType === this.numberValueType ? parseInt(val || 0, 10) : val;
    },

    editValue: function() {
        var val = this.editControl.val();
        return this.valueType === this.numberValueType ? parseInt(val || 0, 10) : val;
    },

    _createSelect: function(defaultValue) {
        var $result = $("<select>"),
            valueField = this.valueField,
            textField = this.textField,
            selectedIndex = this.selectedIndex;

        $.each(this._getOptions(this.scope, this.options), function(index, item) {
            var value = valueField ? item[valueField] : index,
                text = textField ? item[textField] : item;

            var $option = $("<option>")
                .attr("value", value)
                .text(text)
                .appendTo($result);

            $option.prop("selected", (selectedIndex === index));
        });

        $result.prop("disabled", !!this.readOnly);

        if(defaultValue && typeof defaultValue === 'string'){
             $result.val(defaultValue);
         }else {
             $result.val('');
         }

        return $result;
    },
    _getOptions: function(scope, optionName) {
        var props = optionName.split(this.optionSplitor);
        var result = scope[props.shift()];

        while (result && props.length) {
            result = result[props.shift()];
        }

        return result;
    },
});

//Fields instancenation
oppListV2GlobalConfiger.config = function() {
    jsGrid.fields.sfdcDate = oppListV2GlobalConfiger.Fields.sfdcDate;
    jsGrid.fields.sfdcName = oppListV2GlobalConfiger.Fields.sfdcName;
    jsGrid.fields.sfdcReference = oppListV2GlobalConfiger.Fields.sfdcReference;
    jsGrid.fields.sfdcCurrency = oppListV2GlobalConfiger.Fields.sfdcCurrency;
    jsGrid.fields.sfdcPicklist = oppListV2GlobalConfiger.Fields.sfdcPicklist;
};

//starts init
oppListV2GlobalConfiger.config();
