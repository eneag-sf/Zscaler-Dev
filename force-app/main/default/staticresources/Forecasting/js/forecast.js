(function() {
    angular.module('forecastingApp', ['ngAnimate'])
        .controller('forecastingCtrl', function($scope, $q, $timeout, $window) {
            $scope.week = week;
            $scope.fiscalQtr = fiscalQtr;
            $scope.path = userPath;
            $scope.currentUser = currentViewingUserId;
            $scope.CurrentLoginUserId = CurrentLoginUserId;
            $scope.forecastType = forecastType;
            $scope.forecastFamily = forecastFamily;
            $scope.forecastEditable = forecastEditable;
            $scope.canEditPlan = canEditPlan;
            $scope.forecastEnabled = forecastEnabled;
            $scope.zpaForecastEnabled = zpaForecastEnabled;
            $scope.zpaForecastEditable = zpaForecastEditable;
            $scope.isViewingHistory = isViewingHistory;
            $scope.showForecastFamilySwitch = showForecastFamilySwitch;
            $scope.showAsManagerInZPAForecasting = showAsManagerInZPAForecasting;
            $scope.directSubUsers = [];

            $scope.calloutErrorOccured = false;
            $scope.userCancel = false;
            $scope.requestInProgress = 0;
            $scope.errorMessage = null;
            $scope.displayFormat = "W";

            $scope.forecastSummary = {
                isLoading: false,
                data: {},
                collapsed: false
            };
            $scope.teamForecasts = {
                isLoading: false,
                data: [],
                total: {},
                collapsed: false
            };
            $scope.opportunityListing = {
                isLoading: false,
                data: [],
                collapsed: false,
                pageIndex: 1,
                pageCount: 1,
                totalOppAmount: 0,
                hasPrevious: false,
                hasNext: false,
                filter: {
                    pageIndex: 1,
                    stage: 'All Open',
                    probability: 'All',
                    sortField: 'Amount__c',
                    isAscendingOrder: false
                }
            };

            // Opp List Iniline Editting Configs
            $scope.oppListPageSize = 50;
            $scope.inlineEditingState = inlineEditingState;
            $scope.picklistFields = ['Stage', 'PocStatus', 'ForecastCategory', 'DealPath'];
            $scope.oppPicklistFieldsValues = oppListEditPicklistValues;
            $scope.oppListV2 = {
                enabled: (inlineEditingState === 'ALLOWED') ? true : false,
                pageSize: oppListPageSize,
                inlineEditAllowed: (inlineEditingState === 'ALLOWED') ? true : false,
                jsGridInstance: null,
                handlers: {
                    onOppListV2Click: function(args) {},
                    rowDoubleClick: function(args) {
                        if (this.editing === true && args.item.RecordEditable == true) {
                            this.editItem($(args.event.target).closest("tr"));
                        }
                    },
                    onItemUpdating: function(args) {}
                },
                controller: {
                    updateItem: function(item) {}
                },
                amountSortField: function(){
                    return ($scope.forecastFamily ==='ZPA' )? 'ZPA_Amount_For_Sorting__c' : 'Amount__c';
                },
                ownerTitle: function(){
                    return ($scope.forecastFamily === 'ZPA')?'ZPA Rep':'Owner';
                },
                ownerSortField: function(){
                    return ($scope.forecastFamily === 'ZPA')?'ZPA_RSM__r.Name':'SplitOwner.Name';
                },
                errors: [],
                utils: {},
                fieldsToUpdate: ['OppName', 'Amount', 'SplitAmountStamp', 'OppAmountStamp', 'Stage', 'CloseDate', 'NextStep', 'ForecastCategory', 'DealPath', 'PrimaryPartnerId', 'AccountId', 'RecordEditable', 'OwnedByViewingUser'],
                dateFields: ['CloseDate']
            };
            $scope.oppListV2.oppListv2Fields = [
                {
                    name: 'OppName',
                    type: 'sfdcName',
                    scope: $scope,
                    dependencyName: 'OppId',
                    sortDependency: 'Opportunity.Name',
                    sortByDependency: true,
                    title: 'Opportunity Name',
                    suffix: ' - Split ',
                    align: 'left',
                    width: '9%',
                    minWidth: '100px',
                    validate: {
                        validator: 'attrRangeLength',
                        message: function(value, item) {
                            if (value && typeof value[this.param[2]] === 'string') {
                                return "Needs at least 2 and max to 244 characters for " + this.param[3] + " field! Entered length is " + value[this.param[2]].length + ".";
                            } else {
                                return this.param[3] + " is required.";
                            }
                        },
                        param: [2, 254, "value", "Name"]
                    },
                    itemTemplate: function(value, item) {
                        var elem = $('<div>');
                        elem.append($('<span>').text(this.preffix));
                        var nameLink = $("<a class='js-grid-ext_sfdc-name_link'>").prop('href', '/' + value.dependency).prop('target', '_blank').addClass('js-grid_sfdcName').text(this.scope.unescape(value.value));
                        elem.append(nameLink);
                        elem.append($('<span>').text(' '+this.scope.unescape(item.SplitMessage) ));
                        return elem;
                    },
                    editing: true
                },
                {
                    name: 'Amount',
                    type: 'sfdcCurrency',
                    scope: $scope,
                    title: 'Amount',
                    align: 'right',
                    editing: true,
                    sortDependency: $scope.oppListV2.amountSortField(),
                    sortByDependency: true,
                    editTemplate: function(value, item) {
                        this._editPicker = $("<input>").prop('type', 'number').val(value);
                        if (this.editing === true && item.RecordEditable === true && item.AmountEditable === true) {
                            return this._editPicker;
                        }
                        return this.itemTemplate(value);
                    }
                },
                {
                    name: 'Stage',
                    type: 'sfdcPicklist',
                    scope: $scope,
                    validate: "required",
                    options: 'oppPicklistFieldsValues.StageName',
                    optionSplitor: '.',
                    valueField: 'value',
                    textField: 'label',
                    title: 'Sales Stage',
                    align: 'center',
                    sortDependency: 'Opportunity.StageName',
                    sortByDependency: true,
                    editing: true
                },
                {
                    name: 'PocStatus',
                    type: 'text',
                    scope: $scope,
                    title: 'Technical Stage',
                    align: 'center',
                    width: '8%',
                    editing: false,
                    sorting: false,
                    itemTemplate: function(value, item){
                        return this.scope.unescape(value);
                    }
                },
                {
                    name: 'VMOPlay',
                    type: 'text',
                    scope: $scope,
                    title: 'VMO Play',
                    align: 'center',
                    sortDependency: 'Opportunity.VMO_Play__c',
                    sortByDependency: true,
                    editing: false,
                    itemTemplate: function(value, item){
                        return this.scope.unescape(value);
                    }
                },
                {
                    name: 'CloseDate',
                    type: 'sfdcDate',
                    scope: $scope,
                    validate: "sfdcDate",
                    title: 'Close Date',
                    align: 'center',
                    sortDependency: 'Opportunity.CloseDate',
                    sortByDependency: true,
                    editing: true
                },
                {
                    name: 'ForecastCategory',
                    type: 'sfdcPicklist',
                    scope: $scope,
                    validate: "required",
                    options: 'oppPicklistFieldsValues.ForecastCategoryName',
                    optionSplitor: '.',
                    valueField: 'value',
                    textField: 'label',
                    title: 'Forecast Category',
                    align: 'center',
                    sortDependency: 'Opportunity.ForecastCategoryName',
                    sortByDependency: true,
                    editing: true,
                    editTemplate: function(value, item) {
                        var $result = this.editControl = this._createSelect(value);
                        if (item.RecordEditable === false || item.OwnedByViewingUser == false || this.editing === false)
                            return this.itemTemplate.apply(this, arguments);
                        (value !== undefined) && $result.val(this.scope.unescape(value));
                        return $result;
                    }
                },
                {
                    name: 'DealPath',
                    type: 'sfdcPicklist',
                    scope: $scope,
                    options: 'oppPicklistFieldsValues.Deal_Path__c',
                    optionSplitor: '.',
                    valueField: 'value',
                    textField: 'label',
                    title: 'Deal Path',
                    align: 'center',
                    sorting: false,
                    editing: true,
                    editTemplate: function(value, item) {
                        var $result = this.editControl = this._createSelect(value);
                        (value !== undefined) && $result.val(this.scope.unescape(value));
                        if (item.RecordEditable === false || this.editing === false || item.ForecastCategory != 'Upside') {
                            return this.itemTemplate.apply(this, arguments);
                        }
                        return $result;
                    }
                },
                {
                    name: 'NextStep',
                    type: 'textarea',
                    title: 'Next Step',
                    align: 'left',
                    sortDependency: 'Opportunity.NextStep',
                    sortByDependency: true,
                    width: '26%',
                    minWidth: '100px',
                    scope: $scope,
                    validate: {
                        validator: "maxLength",
                        param: 255
                    },
                    editing: true,
                    editTemplate: function(value, item) {
                        var $result = this.editControl = this._createTextArea();
                        $result.val(this.scope.unescape(value));
                        if (this.editing === true && item.RecordEditable === true) {
                            return $result;
                        } else {
                            return this.itemTemplate(this.scope.unescape(value));
                        }
                    }
                },
                {
                    name: "PrimaryPartnerId",
                    type: 'sfdcReference',
                    scope: $scope,
                    dependencyName: "PrimaryPartnerName",
                    title: 'Primary Partner',
                    align: 'center',
                    editing: true,
                    sorting: false,
                    lkfield: '00N70000002qFU2',
                    lktp: '001',
                    lkent: '006',
                    dplp: ''
                },
                {
                    name: "OwnerId",
                    type: 'sfdcReference',
                    scope: $scope,
                    dependencyName: "OwnerName",
                    title: $scope.oppListV2.ownerTitle(),
                    align: 'center',
                    width: '8%',
                    sortDependency: $scope.oppListV2.ownerSortField(),
                    sortByDependency: true,
                    editing: false
                },
                {
                    type: 'control',
                    align: 'center',
                    title: 'Action',
                    editButton: function(args){
                        return (args.item.RecordEditable === true)?true:false;
                    },
                    deleteButton: false,
                    clearFilterButton: false,
                    modeSwitchButton: false,
                    inserting: false,
                }
            ];
            $scope.oppListV2.jsGridConfigurations = {
                editing: $scope.oppListV2.inlineEditAllowed,
                sorting: true,
                paging: true,
                customSort: true,
                width: '100%',
                tableClass: 'jsgrid-table report',
                headerRowClass: 'jsgrid-header-row header',
                headerCellClass: ' headerCell ',
                oddRowClass: 'line2',
                evenRowClass: 'line',
                selectedRowClass: 'line-selected',
                pageCountButton: 5,
                updateOnResize: true,
                data: $scope.opportunityListing.data,
                noDataContent: 'No opportunities found.',
                rowClick: $scope.oppListV2.handlers.onOppListV2Click,
                rowDoubleClick: $scope.oppListV2.handlers.rowDoubleClick,
                onItemUpdating: $scope.oppListV2.handlers.onItemUpdating,
                controller: $scope.oppListV2.controller
            };

            $scope.promiseDirectSubUsers = function(userId) {
                var deferred = $q.defer();
                var serviceIdentifier = "DirectSubUsers" + userId;
                $scope.callRemoteServiceWithCache(ForecastingController.GetDirectSubordinateUsers, [userId, $scope.forecastFamily], serviceIdentifier, function(result) {
                    deferred.resolve({
                        userId: userId,
                        subUsers: result
                    });
                });
                return deferred.promise;
            };

            $scope.promiseAllSubUsers = function(userId) {
                var deferred = $q.defer();
                var serviceIdentifier = "AllSubUsers" + userId;
                $scope.callRemoteServiceWithCache(ForecastingController.GetAllSubordinateUsers, [userId, $scope.forecastFamily], serviceIdentifier, function(result) {
                    deferred.resolve({
                        userId: userId,
                        subUsers: result
                    });
                });
                return deferred.promise;
            };

            $scope.promiseDirectSubUsersWithManagers = function(userId) {
                var deferred = $q.defer();
                var serviceIdentifier = "AllSubUsers" + userId;
                $scope.callRemoteServiceWithCache(ForecastingController.GetDirectSubordinateUsersV2, [userId, $scope.forecastFamily], serviceIdentifier, function(result) {
                    deferred.resolve({
                        userId: userId,
                        subUsers: result
                    });
                });
                return deferred.promise;
            };

            $scope.getCacheValue = function(key, defaultValue) {
                if (typeof(Storage) !== "undefined") {
                    key = "SNAPF." + key;
                    var value = sessionStorage.getItem(key);
                    if (value == null) {
                        return defaultValue;
                    }
                    return JSON.parse(value);
                } else {
                    return defaultValue;
                }
            }

            $scope.setCacheValue = function(key, value) {
                if (typeof(Storage) !== "undefined") {
                    key = "SNAPF." + key;
                    try {
                        return sessionStorage.setItem(key, JSON.stringify(value));
                    } catch (err) {
                        sessionStorage.removeItem(key);
                    }
                }
            }

            $scope.callRemoteServiceWithCache = function(serviceName, parameters, identifier, callback, config) {
                $scope.requestInProgress++;
                var cachedValue = $scope.getCacheValue(identifier, null);
                if (cachedValue != null) {
                    callback.call($scope, cachedValue);
                }
                if (parameters == null) {
                    parameters = [];
                }
                var callbackWrap = function(result, event) {
                    $scope.requestInProgress--;
                    if ($scope.isCalloutSucceeded(event)) {
                        $scope.setCacheValue(identifier, result);
                        callback.call($scope, result);
                    }
                };
                parameters.push(callbackWrap);
                if (config) {
                    parameters.push(config);
                }
                try {
                    serviceName.apply($scope, parameters);
                } catch (e) {
                    callbackWrap(null, {
                        status: false
                    });
                }
            };

            $scope.isCalloutSucceeded = function(event) {
                if (event.status == true) {
                    return true;
                } else {
                    if ($scope.calloutErrorOccured == false && $scope.userCancel == false) {
                        $scope.errorMessage = "Error occured. Please try refreshing the page. ";
                        if (event.message) {
                            $scope.errorMessage += "The error message is: " + event.message;
                        }
                    }
                    $scope.calloutErrorOccured = true;
                    return false;
                }
            };

            $scope.loadForecastSummary = function() {
                $scope.forecastSummary.isLoading = true;
                var serviceIdentifier = "Summary" + $scope.fiscalQtr + $scope.currentUser;
                $scope.callRemoteServiceWithCache(ForecastingStatsService.GetForecastSummary, [$scope.currentUser, $scope.fiscalQtr, $scope.forecastType, $scope.forecastFamily], serviceIdentifier, function(result) {
                    $scope.forecastSummary.isLoading = false;
                    $scope.forecastSummary.data = result;
                    setTimeout(function() {
                        $scope.$apply($scope.forecastSummary);
                    });
                }, {
                    buffer: false,
                    timeout: 60000
                });
            }

            $scope.loadTeamForecasts = function() {
                for (var i = 0; i < $scope.directSubUsers.length; i++) {
                    $scope.teamForecasts.isLoading = true;
                    var uid = $scope.directSubUsers[i].UserId;
                    var serviceIdentifier = "Summary" + $scope.fiscalQtr + uid;
                    $scope.callRemoteServiceWithCache(ForecastingStatsService.GetForecastSummary, [uid, $scope.fiscalQtr, $scope.forecastType, $scope.forecastFamily], serviceIdentifier, function(result) {
                        var isExisted = false;
                        for (var i = 0; i < $scope.teamForecasts.data.length; i++) {
                            if ($scope.teamForecasts.data[i].UserId == result.UserId) {
                                $scope.teamForecasts.data[i] = angular.copy(result);
                                isExisted = true;
                                break;
                            }
                        }
                        if (!isExisted) {
                            $scope.teamForecasts.data.push(angular.copy(result));
                        }

                        $scope.teamForecasts.total = {};
                        for (var i = 0; i < $scope.teamForecasts.data.length; i++) {
                            var member = $scope.teamForecasts.data[i];
                            var total = $scope.teamForecasts.total;
                            !total.QtrCommit ? total.QtrCommit = member.RecentForecasts[0].QtrCommit : total.QtrCommit += member.RecentForecasts[0].QtrCommit || 0;
                            !total.QtrPipeline ? total.QtrPipeline = member.RecentForecasts[0].QtrPipeline : total.QtrPipeline += member.RecentForecasts[0].QtrPipeline || 0;
                            !total.QtrUpside ? total.QtrUpside = member.RecentForecasts[0].QtrUpside : total.QtrUpside += member.RecentForecasts[0].QtrUpside || 0;
                            !total.TotalPipeline ? total.TotalPipeline = member.TotalPipeline : total.TotalPipeline += member.TotalPipeline || 0;
                            !total.TotalCommit ? total.TotalCommit = member.TotalCommit : total.TotalCommit += member.TotalCommit || 0;
                            !total.TotalUpside ? total.TotalUpside = member.TotalUpside : total.TotalUpside += member.TotalUpside || 0;
                            !total.QTDBooking ? total.QTDBooking = member.QTDBooking : total.QTDBooking += member.QTDBooking || 0;
                            !total.QTRQuota ? total.QTRQuota = member.QTRQuota : total.QTRQuota += member.QTRQuota || 0;
                        }
                        $scope.teamForecasts.isLoading = false;
                        setTimeout(function() {
                            $scope.$apply($scope.teamForecasts);
                        });
                    }, {
                        buffer: false,
                        timeout: 60000
                    });
                }
            }

            $scope.loadOpportunityListing = function() {
                $scope.opportunityListing.isLoading = true;
                var request = {
                    UserId: $scope.currentUser,
                    FiscalQtr: $scope.fiscalQtr,
                    PageIndex: $scope.opportunityListing.filter.pageIndex,
                    Stage: $scope.opportunityListing.filter.stage,
                    Probability: $scope.opportunityListing.filter.probability,
                    SortField: $scope.opportunityListing.filter.sortField,
                    IsAscendingOrder: $scope.opportunityListing.filter.isAscendingOrder,
                    ForecastType: $scope.forecastType,
                    ForecastFamily: $scope.forecastFamily
                };

                ForecastingStatsService.GetOpportunityListing(request, function(result, event) {
                    $scope.opportunityListing.isLoading = false;
                    if ($scope.isCalloutSucceeded(event)) {
                        $scope.opportunityListing.data = result.Opportunities;
                        $scope.opportunityListing.hasPrevious = result.HasPrevious;
                        $scope.opportunityListing.hasNext = result.HasNext;
                        $scope.opportunityListing.pageCount = result.PageCount;
                        $scope.opportunityListing.pageIndex = result.PageIndex;
                        $scope.opportunityListing.totalOppAmount = result.totalOppAmount;
                        $scope.opportunityListing.pagers = $scope.buildArray(result.PageCount);
                        $scope.$apply($scope.opportunityListing);
                        if ($scope.oppListV2.enabled) {
                            $scope.oppListV2.refreshOppListV2($scope.opportunityListing);
                        }
                    }
                });
            }
            $scope.turnPageOppList = function(pageIndex) {
                $scope.opportunityListing.filter.pageIndex = pageIndex;
                $scope.loadOpportunityListing();
            };
            $scope.sortOppList = function(sortField) {
                if ($scope.opportunityListing.filter.sortField === sortField) {
                    $scope.opportunityListing.filter.isAscendingOrder = !$scope.opportunityListing.filter.isAscendingOrder;
                }
                $scope.opportunityListing.filter.sortField = sortField;
                $scope.loadOpportunityListing();
            };
            $scope.openErrorNotify = function(title, messages) {
                var content = $scope.oppListV2.generatesErrorMeesgaeNotify(messages);
                $scope.oppListV2.errors = messages;
                $window.FpDialogBox.openWithContent('oppList2ErrorNotify', content);
            };

            $scope.oppListV2.getCommonJsGridConfigs = function() {
                var config = $scope.oppListV2.jsGridConfigurations;
                config.fields = $scope.oppListV2.oppListv2Fields;
                config.pageSize = $scope.oppListV2.pageSize;
                return config;
            };
            $scope.oppListV2.wrappingConfigFromOppListConfig = function(config, oppListParams) {
                config.data = $scope.opportunityListing.data;
                return config;
            };
            $scope.oppListV2.initInstance = function() {
                var configToUse = $scope.oppListV2.getCommonJsGridConfigs();
                configToUse = $scope.oppListV2.wrappingConfigFromOppListConfig(configToUse, $scope.opportunityListing);
                configToUse.invalidNotify = $scope.oppListV2.handlers.invalidNotify;
                configToUse.rowClass = $scope.oppListV2.handlers.getDataRowClass;
                if ($scope.oppListV2.jsGridInstance === null) {
                    $scope.oppListV2.jsGridInstance = $('#snapcast_oppList_v2');
                }
                $scope.oppListV2.jsGridInstance.jsGrid(configToUse);
            };
            $scope.oppListV2.refreshOppListV2 = function(oppListParams) {
                if ($scope.oppListV2.jsGridInstance) {
                    $scope.oppListV2.jsGridInstance.jsGrid('option', 'data', oppListParams.data);
                } else {
                    $scope.oppListV2.initInstance();
                }
            };
            $scope.oppListV2.getOppItemUpdatingParams = function() {
                return {
                    'UserId': $scope.CurrentLoginUserId,
                    ForecastFamily: $scope.forecastFamily,
                    FiscalQtr: $scope.fiscalQtr
                };
            };
            $scope.oppListV2.convertFieldName = function(field, splitor) {
                return field.replace('fields' + splitor, '');
            };
            $scope.oppListV2.generatesErrorMeesgaeNotify = function(messages) {
                var container = "<div class='error-notify'>";
                var content = "<ul class='error-list'>";
                var covnertedMsgs = Array.isArray(messages) ? messages : [messages];
                for (var i = 0; i < covnertedMsgs.length; i += 1) {
                    content += "<li class='error-list--item' > " + covnertedMsgs[i] + "</li>";
                }
                content += "</ul>";
                container += content + "</div>";
                return container;
            };
            $scope.oppListV2.handlers.getDataRowClass = function(item, itemIndex) {
                var grid = this._gird;
                var classes = " ";
                classes += (item.fields && item.Highlight) ? " high " : " ";
                return classes;
            };
            $scope.oppListV2.handlers.onItemUpdating = function(args) {
                console.log('Call on onItemUpdating');
                console.log(args);
            };
            $scope.oppListV2.handlers.invalidNotify = function(args) //args: errors [], grid {}, item {}, itemIndex, row $("")
            {
                var messages = $.map(args.errors, function(error) {
                    return error.message ? "<b>" + error.field.title + ":</b> " + error.message : null;
                });
                $scope.openErrorNotify("Invalided Fields", messages);
            };
            $scope.oppListV2.utils.toTwoDigts = function(num) {
                return (num > 9) ? num : ('0' + num);
            };
            $scope.oppListV2.utils.toSfdcDateString = function(toConvert) {
                return toConvert.getFullYear() + '-' + $scope.oppListV2.utils.toTwoDigts(toConvert.getMonth() + 1) + '-' + $scope.oppListV2.utils.toTwoDigts(toConvert.getDate());
            };
            $scope.oppListV2.utils.isDate = function(toProcess) {
                try {
                    var test = new Date(toProcess);
                    return true;
                } catch (e) {
                    return false;
                }
            };
            $scope.oppListV2.utils.inDateFields = function(field) {
                for (var loc = 0; loc < $scope.oppListV2.dateFields.length; loc += 1) {
                    if (field === $scope.oppListV2.dateFields[loc]) {
                        return true;
                    }
                }
                return false;
            };
            $scope.oppListV2.utils.copyOppListItem = function(itemToCopy) {
                var copiedResult = {};
                var fieldName = '';
                var fieldValue = '';
                copiedResult.OppId = itemToCopy.OppId;
                copiedResult.SplitId = itemToCopy.SplitId;
                for (var loc = 0; loc < $scope.oppListV2.fieldsToUpdate.length; loc += 1) {
                    fieldName = $scope.oppListV2.fieldsToUpdate[loc];
                    fieldValue = itemToCopy[fieldName];
                    if ($scope.oppListV2.utils.inDateFields(fieldName)) {
                        copiedResult[fieldName] = $scope.oppListV2.utils.toSfdcDateString(new Date(fieldValue));
                    } else {
                        copiedResult[fieldName] = fieldValue;
                    }
                }
                return copiedResult;
            };
            $scope.oppListV2.controller.updateItem = function(item) {
                var copiedItem = $scope.oppListV2.utils.copyOppListItem(item);
                var updateRequest = {
                    oppListItem: copiedItem,
                    params: $scope.oppListV2.getOppItemUpdatingParams()
                };
                ForecastingStatsService.updateOpportunityRecord(updateRequest, function(result, event) {
                    if ($scope.isCalloutSucceeded(event)) {
                        $scope.$apply(function() {
                            if (result.status) {
                                $scope.loadOpportunityListing();
                                return result.oppListItem;
                            } else {
                                $scope.openErrorNotify("Opportunity Update Failed", result.messages[0]);
                                $scope.errorMessage = result.messages[0];
                            }
                        });
                    }
                });
            };
            $scope.editForecast = function() {
                $scope.cancelForecast();
                $scope.forecastSummary.isEditing = true;
                $scope.forecastSummary.editingModal = {
                    QtrCommit: $scope.forecastSummary.data.RecentForecasts[0].QtrCommit,
                    QtrPipeline: $scope.forecastSummary.data.RecentForecasts[0].QtrPipeline,
                    QtrUpside: $scope.forecastSummary.data.RecentForecasts[0].QtrUpside,
                    FYFQ: $scope.fiscalQtr
                };
            };

            $scope.cancelForecast = function() {
                $scope.forecastSummary.isEditing = false;
            };

            $scope.saveForecast = function() {
                $scope.forecastSummary.editingModal.QtrCommit = $scope.enforceNumberValidated($scope.forecastSummary.editingModal.QtrCommit);
                $scope.forecastSummary.editingModal.QtrPipeline = $scope.enforceNumberValidated($scope.forecastSummary.editingModal.QtrPipeline);
                $scope.forecastSummary.editingModal.QtrUpside = $scope.enforceNumberValidated($scope.forecastSummary.editingModal.QtrUpside);

                ForecastingStatsService.SaveForecast(currentViewingUserId, $scope.forecastType, $scope.forecastFamily, $scope.forecastSummary.editingModal, function(result, event) {
                    if ($scope.isCalloutSucceeded(event)) {
                        var scope = angular.element(jQuery("#ngContainer")).scope();
                        scope.$apply(function() {
                            $scope.forecastSummary.data.RecentForecasts[0].QtrCommit = $scope.forecastSummary.editingModal.QtrCommit;
                            $scope.forecastSummary.data.RecentForecasts[0].QtrPipeline = $scope.forecastSummary.editingModal.QtrPipeline;
                            $scope.forecastSummary.data.RecentForecasts[0].QtrUpside = $scope.forecastSummary.editingModal.QtrUpside;
                            var serviceIdentifier = "Summary" + $scope.fiscalQtr + $scope.currentUser;
                            $scope.setCacheValue(serviceIdentifier, $scope.forecastSummary.data);
                        });
                    }
                    $scope.$apply(function() {
                        $scope.forecastSummary.isEditing = false;
                    });
                });
            };

            $scope.enforceNumberValidated = function(value) {
                if (typeof(value) == "string") {
                    var newValue = value.replace(/\$/g, '').replace(/,/g, '').replace(/[KkMm]$/i, '');
                    newValue = parseFloat(newValue);
                    if (value.substr(-1) == 'K' || value.substr(-1) == 'k') {
                        newValue *= 1000;
                    }
                    if (value.substr(-1) == 'M' || value.substr(-1) == 'm') {
                        newValue *= 1000000;
                    }
                    return newValue;
                }
                return value;
            };

            $scope.formatDecimal = function(value, format) {
                if (value == null) {
                    return null;
                } else if (value == 0) {
                    return "0";
                } else if (format == "E") {
                    //exact value, 2 decimals
                    return "$" + $scope.commaFormatted(((value) / 1).toFixed(2));
                } else if (format == "W") {
                    //whole values, 0 decimals
                    return "$" + $scope.commaFormatted(((value) / 1).toFixed(0));
                } else if (format == "K") {
                    //thousand, with 2 decimals
                    var result = "$" + $scope.commaFormatted(((value) / 1000).toFixed(2)) + "K";
                    return result.replace(".00K", "K");
                } else if (format == "M") {
                    //million, with 2 decimals
                    var result = "$" + $scope.commaFormatted(((value) / 1000 / 1000).toFixed(2)) + "M";
                    return result.replace(".00M", "M");
                }
                return "";
            };

            $scope.commaFormatted = function(amount) {
                var delimiter = ","; // replace comma if desired
                var a = amount.split('.', 2)
                var d = (a.length > 1) ? a[1] : '';
                var i = parseInt(a[0]);
                if (isNaN(i)) {
                    return '';
                }
                var minus = '';
                if (i < 0) {
                    minus = '-';
                }
                i = Math.abs(i);
                var n = new String(i);
                var a = [];
                while (n.length > 3) {
                    var nn = n.substr(n.length - 3);
                    a.unshift(nn);
                    n = n.substr(0, n.length - 3);
                }
                if (n.length > 0) {
                    a.unshift(n);
                }
                n = a.join(delimiter);
                if (d.length < 1) {
                    amount = n;
                } else {
                    amount = n + '.' + d;
                }
                amount = minus + amount;
                return amount;
            };

            $scope.formatPercentage = function(value) {
                if (isNaN(value)) {
                    return "";
                }
                var result = value.toFixed(1) + "%";
                return result.replace(".0%", "%");
            };

            $scope.formatDate = function(dateValue) {
                var myDate = new Date(dateValue);
                return myDate.toLocaleDateString();
            };
            $scope.unescape = function(str) {
                if (str) {
                    var initClean = str.replace(/&amp;/g, "&").replace(/&quot;/g, "\"").replace(/&apos;/g, "'").replace(/&lt;/g, "<").replace(/&gt;/g, ">");
                    return $scope.unescape2(initClean);
                }
                return "";
            };
            $scope.escapeEl = document.createElement('textarea');
            $scope.unescape2 = function(input){
                $scope.escapeEl.innerHTML = input;
                return $scope.escapeEl.textContent;
            };
            $scope.buildArray = function(count) {
                var result = [];
                for (var i = 0; i < count; i++) {
                    result.push(i + 1);
                }
                return result;
            };
            $scope.loadAll = function() {
                var subUserPromise = '';

                //Load all subordinate users in the list
                if ($scope.forecastFamily.toLowerCase() == 'zpa') {
                    subUserPromise = $scope.promiseDirectSubUsersWithManagers($scope.currentUser);
                } else {
                    subUserPromise = $scope.promiseDirectSubUsers($scope.currentUser);
                }

                subUserPromise.then(function(subUserResult) {
                    $scope.directSubUsers = subUserResult.subUsers;
                    $scope.loadTeamForecasts();
                });

                $scope.loadForecastSummary();
                $scope.loadOpportunityListing();
            }

            if ($scope.forecastEnabled || $scope.zpaForecastEnabled || $scope.showAsManagerInZPAForecasting) {
                $scope.loadAll();
            } else {
                $scope.errorMessage = "Forecast isn't enabled.";
            }
        })
        .directive('fpDialog', function() {
            return {
                restrict: 'AE',
                replace: true,
                link: function(scope, elem, attrs) {
                    var dialog = new FpDialogBox(elem[0], attrs.fpDialogTitle || 'Dialog', [{
                        label: "Save",
                        isSave: true
                    }, {
                        label: "Cancel",
                        isCancel: true
                    }], attrs.fqContainerClass || null);
                    var content = dialog.dialog;
                    angular.element(jQuery("#ngContainer")).injector().invoke(function($compile) {
                        $compile(content)(scope);
                    });
                    dialog.onSave = function() {
                        scope.saveForecast();
                    };
                }
            };
        });
})();
