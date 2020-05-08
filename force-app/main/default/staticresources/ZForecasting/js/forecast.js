(function() {
    angular.module('forecastingApp', ['ngAnimate','multiselectmodule'])
        .filter('getUserLevels', function() {
            return function(data) {
                if (typeof(data) === 'undefined') {
                    return [];
                }

                var levels = [];
                for (var i = data.length - 1; i >= 0; i--) {
                    if (!levels.indexOf(data[i].Level)) {
                        levels.push(data[i].Level);
                    }
                }

                return levels;
            };
        })
        .controller('forecastingCtrl', ['$scope', '$q', '$timeout', '$window', 'getUserLevelsFilter', function($scope, $q, $timeout, $window, getUserLevelsFilter) {
			$scope.name = 'World';
			$scope.toggle = {};
            $scope.toggle.switch = false;
			$scope.notradescription = [];
			$scope.closingweekvals = ['This', 'Next','Previous'];
			$scope.selectedclosingWeekvals = [];
			$scope.cssvals = ['0 - Not Started', '1 - Kick-off Complete (QBR 0)', '2 - Design Complete (0-10% Deployed)', '3 - Secure & Simplify (10-25% deployed)', '4 - Transformation in Progress (25%+ Deployed)', '5 - Transformed'];
			$scope.selectedcssvals = [];
			$scope.csvals = ['Happy', 'No Engagement', 'Unhappy', 'Neutral or Mixed', 'Churn Risk', 'Lost'];
			$scope.selectedcsvals = [];
			$scope.closingMonthvals = ['M1', 'M2','M3'];
			$scope.selectedclosingMonthvals = [];
			$scope.conedweekvals = ['This', 'Next','Previous'];
			$scope.selectedconedweekvals = [];
			$scope.conedmonthvals = ['M1', 'M2','M3'];
			$scope.selectedconedmonthvals = [];
			$scope.notravals = ['On Time', 'Late','Prior Early','Future'];
			$scope.selectednotravals = [];
			$scope.viewvals = ['My Forecast <> RSM', 'Level Minus 1 <> RSM','My Forecast <> Level Minus 1','*** Forecast Based Filters ***','ML Forecast','BC Forecast','WC Forecast','*** Deal Based Filters ***','All Open','Closed Won','Contracts Complete','Commit','Most Likely','Best Case','Pipeline','Closed Lost','*** Other ***','Pushed Deals','Deal Splits'];
			$scope.selectedviewvals = ['All Open'];
			$scope.dealbandvals = ['< $25K', '$25K - $50K', '$50K - $100K','$100K - $250K', '$250K - $1M', '> $1M'];
			$scope.selecteddealbandvals = [];
			$scope.selectedgeovals = [];
			$scope.selectedregionvals = [];
            $scope.week = week;
            $scope.fiscalQtr = fiscalQtr;
            $scope.path = userPath;
            $scope.currentUser = currentViewingUserId;
            $scope.viewNOTRA = viewNOTRA;
            $scope.viewExportToExcel = viewExportToExcel;
            $scope.viewBillings = viewBillings;
            $scope.viewNetNewACV = viewNetNewACV;
            $scope.CurrentLoginUserId = CurrentLoginUserId;
            $scope.CurrentLoginUserName = CurrentLoginUserName;
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
            $scope.UserLevel = UserLevel;
            $scope.CurrentUserLevel = CurrentUserLevel;
            $scope.MyUserLevel = MyUserLevel;
            $scope.LoggedInUserLevel = LoggedInUserLevel;
            $scope.directSubUsers = [];
            $scope.showMyForecastSection = showMyForecastSection;
            $scope.impersonateViewAsUser = impersonateViewAsUser;
            $scope.forecastEnabledForLoggedInUser = forecastEnabledForLoggedInUser;
            $scope.showMyRollupSection = showMyRollupSection;
            $scope.MyUserId = MyUserId;
            $scope.LevelMinusOne = '';
            $scope.LevelMinusOneTitle = '';
            $scope.MyForecastCategoryField = '';
            $scope.LevelMinusOneForecastCategoryField = '';
			
			$scope.$on('clearselection', function(event, data) {
				$scope.$broadcast(data+'_clearall');
			});
			$scope.clearallfilters = function(picklist) {
				$scope.$broadcast('geoval_clearall');
				$scope.$broadcast('regval_clearall');
				$scope.$broadcast('viewvalue_clearall');
				$scope.$broadcast('dealvalue_clearall');
				$scope.$broadcast('custsucstage_clearall');
				$scope.$broadcast('closingmonth_clearall');
				$scope.$broadcast('closingweek_clearall');
				$scope.$broadcast('contractedmonth_clearall');
				$scope.$broadcast('contractedweek_clearall');
				if(picklist != 'notrafilter'){
					$scope.$broadcast('notrafilter_clearall');
					$scope.selectedviewvals = ['All Open'];
				}
			}
			
			$scope.clearnotra = function() {
				$scope.notradescription = [];
				$scope.$broadcast('notrafilter_clearall');
				
			}
			
			$scope.setnotradescription = function() {
				$scope.notradescription = [];
				if($scope.selectednotravals != null && $scope.selectednotravals.indexOf('On Time') != -1){
                    $scope.notradescription.push('On Time:  These are opportunities where the contract end date falls within ' + $scope.fiscalQtr + ', and are included in the ML Forecast.');
                }
				if($scope.selectednotravals != null && $scope.selectednotravals.indexOf('Late') != -1 && $scope.fiscalQtr.indexOf('Q1') == -1){
                    $scope.notradescription.push('Late : These are opportunities where the contract end date is earlier than ' + $scope.fiscalQtr + ', and are included in the ML Forecast.');
                }
				if($scope.selectednotravals != null && $scope.selectednotravals.indexOf('Prior Early') != -1){
                    $scope.notradescription.push('Prior Early : These are opportunties where the contract end date falls within ' + $scope.fiscalQtr + ', but the contracts were closed prior to ' + $scope.fiscalQtr + ' .');
                }
				if($scope.selectednotravals != null && $scope.selectednotravals.indexOf('Future') != -1){
                    $scope.notradescription.push('Future: These are opportunities where the contract end date falls after ' + $scope.fiscalQtr + ', and are included in the ML Forecast.');
                }
			}
            
            if ($scope.MyUserLevel == 'Exec') {
                $scope.MyForecastCategoryField = 'CRO_Forecast_Category__c';
                $scope.LevelMinusOne = 'VP';
                $scope.LevelMinusOneTitle = 'VP';
                $scope.LevelMinusOneForecastCategoryField = 'VP_Forecast_Category__c';
            } else if ($scope.MyUserLevel == 'VP') {
                $scope.MyForecastCategoryField = 'VP_Forecast_Category__c';
                $scope.LevelMinusOne = 'RVP';
                $scope.LevelMinusOneTitle = 'RVP';
                $scope.LevelMinusOneForecastCategoryField = 'RVP_Forecast_Category__c';
            }  else if ($scope.MyUserLevel == 'RVP') {
                $scope.MyForecastCategoryField = 'RVP_Forecast_Category__c';
                $scope.LevelMinusOne = 'Director';
                $scope.LevelMinusOneTitle = 'AD';
                $scope.LevelMinusOneForecastCategoryField = 'AD_Forecast_Category__c';
            } else if ($scope.MyUserLevel == 'Director') {
                $scope.MyForecastCategoryField = 'AD_Forecast_Category__c';
                $scope.LevelMinusOne = 'Manager';
                $scope.LevelMinusOneTitle = 'DM';
                $scope.LevelMinusOneForecastCategoryField = 'DM_Forecast_Category__c';
            } else if ($scope.MyUserLevel == 'Manager') {
                $scope.MyForecastCategoryField = 'DM_Forecast_Category__c';
                $scope.LevelMinusOne = 'Rep';
                $scope.LevelMinusOneTitle = 'Rep';
                $scope.LevelMinusOneForecastCategoryField = 'Forecast_Category__c';
            } else {
                $scope.MyForecastCategoryField = 'Forecast_Category__c';
                $scope.LevelMinusOneForecastCategoryField = 'Forecast_Category__c';
            }

            $scope.calloutErrorOccured = false;
            $scope.userCancel = false;
            $scope.requestInProgress = 0;
            $scope.errorMessage = null;
            $scope.displayFormat = "W";
			$scope.geoandregionmap = geoandregionmap;
			$scope.geovals = [];
			$scope.regionvals = [];
            $scope.forecastSummary = {
                isLoading: false,
                data: {},
                collapsed: false
            };
			$scope.weeklyforecastsummary = {
                isLoading: false,
                data: {},
                collapsed: false
            };
			$scope.monthlyforecastsummary = {
                isLoading: false,
                data: {},
                collapsed: false
            };
			$scope.monthlyforecastsummaryzpa = {
                isLoading: false,
                data: {},
                collapsed: false
            };
            $scope.forecastSummaryZPA = {
                isLoading: false,
                data: {},
                collapsed: false
            };
			$scope.notrasummary = {
                isLoading: false,
                data: {},
                collapsed: false
            };
			
			$scope.netnewacvsummary = {
                isLoading: false,
                data: {},
                collapsed: false
            };
			
			$scope.billingsacvforecast = {
                isLoading: false,
                data: {},
                collapsed: false
            };
			
			$scope.billingsSummary = {
                isLoading: false,
                isEditing: false,
                data: {},
                collapsed: false
            };
			$scope.billingsSummaryEdit = {
                isLoading: false,
                data: {},
                collapsed: false
            };
			
			/*$scope.churnsummary = {
                isLoading: false,
                data: {},
                collapsed: false
            };*/
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
                    isAscendingOrder: false,
                    dealValue: 'All',
					closingMonth: 'All',
					customersuccessstage: 'All',
					customersentiment: 'All',
					closingWeek: 'All',
					Geo: 'All',
					Region: 'All'
                }
            };

            // Opp List Iniline Editting Configs
            $scope.oppListPageSize = 50;
            $scope.inlineEditingState = inlineEditingState;
            $scope.picklistFields = ['Stage', 'PocStatus', 'ForecastCategory', 'MyForecastCategory', 'LevelMinus1ForecastCategory'];
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
                levelMinusOneForecastCategoryField: function() {
                    return $scope.LevelMinusOneForecastCategoryField;
                },
                myForecastCategoryField: function() {
                    return $scope.MyForecastCategoryField;
                },
                errors: [],
                utils: {},
                fieldsToUpdate: ['OppName', 'Amount', 'SplitAmountStamp', 'OppAmountStamp', 'Stage', 'CloseDate', 'NextStep', 'ForecastCategory', 'MyForecastCategory', 'LevelMinus1ForecastCategory', 'PrimaryPartnerId', 'AccountId', 'RecordEditable', 'OwnedByViewingUser', 'MyFCLock', 'OppType', 'OppSplitType'],
                dateFields: ['CloseDate','LastArchWorkshopDate','LastF2FMeetingDate']
            };
			
			$scope.oppname = {
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
			};
			
			$scope.oppamount = {
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
					if (this.editing === true && item.RecordEditable === true && item.AmountEditable === true && item.OwnedByViewingUser === true) {
						return this._editPicker;
					}
					return this.itemTemplate(value);
				}
			};
			
			$scope.renewalACV = {
				name: 'RenewalACV',
				type: 'sfdcCurrency',
				scope: $scope,
				title: 'Renewal ACV',
				align: 'right',
				editing: false,
				sortDependency: 'Opportunity.Renewable_ACV__c',
				sortByDependency: true
			};
			
			$scope.oppstage = {
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
			};
			
			$scope.closedate = {
				name: 'CloseDate',
				type: 'sfdcDate',
				scope: $scope,
				validate: "sfdcDate",
				title: 'Close Date',
				align: 'center',
				sortDependency: 'Opportunity.CloseDate',
				sortByDependency: true,
				editing: true
			};
			
			$scope.myfc = {
				name: 'MyForecastCategory',
				type: 'sfdcPicklist',
				scope: $scope,
				validate: "required",
				options: 'oppPicklistFieldsValues.' + $scope.MyForecastCategoryField,
				optionSplitor: '.',
				valueField: 'value',
				textField: 'label',
				title: 'My FC',
				align: 'center',
				sortDependency: 'Opportunity.' + $scope.MyForecastCategoryField,
				sortByDependency: true,
				editing: true,
				editTemplate: function(value, item) {
					console.log('>>>> this.editControl: ' + this.editControl);
					var $result = this.editControl = this._createSelect(value);
					if (item.RecordEditable === false || this.editing === false)
						return this.itemTemplate.apply(this, arguments);
					(value !== undefined) && $result.val(this.scope.unescape(value));
					return $result;
				}
			};
			
			$scope.nextstep = {
				name: 'NextStep',
				type: 'textarea',
				title: 'Next Step',
				align: 'left',
				sortDependency: 'Opportunity.NextStep',
				sortByDependency: true,
				width: '20%',
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
					if (this.editing === true && item.RecordEditable === true && item.OwnedByViewingUser === true) {
						return $result;
					} else {
						return this.itemTemplate(this.scope.unescape(value));
					}
				}
			};
			
			$scope.primarypartnerId = {
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
			};
			
			$scope.ownerId = {
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
			};
			
			$scope.lastarchworkshopdate = {
				name: 'LastArchWorkshopDate',
				type: 'sfdcDate',
				scope: $scope,
				validate: "sfdcDate",
				title: 'Last AW SCI',
				align: 'center',
				sortDependency: 'Opportunity.Account.Last_Architecture_Workshop_Date__c',
				sortByDependency: true,
				editing: false,
				itemTemplate: function(value, item) {
					if (item.LastArchWorkshopDateCSS  === true){
						var elem = $("<span style='color:red'>").text(this.scope.unescape(value));
						return elem;
					}
					return this.scope.unescape(value);
				}
			};
			
			$scope.pocstatus = {
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
			};
			
			$scope.customersuccessstage = {
				name: 'CustomerSuccessStage',
				type: 'text',
				scope: $scope,
				title: 'Customer Success Stage',
				align: 'center',
				width: '8%',
				editing: false,
				sorting: false,
				itemTemplate: function(value, item){
					return this.scope.unescape(value);
				}
			};
			
			$scope.customersentiment = {
				name: 'CustomerSentiment',
				type: 'text',
				scope: $scope,
				title: 'Customer Sentiment',
				align: 'center',
				width: '8%',
				editing: false,
				sorting: false,
				itemTemplate: function(value, item){
					return this.scope.unescape(value);
				}
			};
			
			$scope.myfclock = {
				name: 'MyFCLock',
				type: 'sfdcCheckbox',
				scope: $scope,
				title: '',
				width: '30px',
				align: 'center',
				sorting: false,
				editing: true,
				itemTemplate: function(value) {
					var elem = $("<input>").prop("type", "checkbox").prop("disabled", "disabled").prop("checked", value).val(value);
					return elem;
				},
				editTemplate: function(value, item) {
					var checkboxValue = !value ? value : false;
					this._editPicker = $("<input>").prop("type", "checkbox").prop("checked", value).val(value);
					if (this.editing === true && item.RecordEditable === true) {
						return this._editPicker;
					}
					return this.itemTemplate;
				},
				insertValue: function() {
					console.log('insert');
					return this._insertPicker.prop('checked');
				},
				editValue: function() {
					console.log('edit');
					console.log(this._editPicker);
					return this._editPicker.prop('checked');
				}
			};
			
			$scope.repfc = {
				name: 'ForecastCategory',
				type: 'sfdcPicklist',
				scope: $scope,
				validate: "required",
				options: 'oppPicklistFieldsValues.Forecast_Category__c',
				optionSplitor: '.',
				valueField: 'value',
				textField: 'label',
				title: 'Rep FC',
				align: 'center',
				sortDependency: 'Opportunity.Forecast_Category__c',
				sortByDependency: true,
				editing: false,
				editTemplate: function(value, item) {
					var $result = this.editControl = this._createSelect(value);
					if (item.RecordEditable === false || item.OwnedByViewingUser == false || this.editing === false)
						return this.itemTemplate.apply(this, arguments);
					(value !== undefined) && $result.val(this.scope.unescape(value));
					return $result;
				}
			};
			
			$scope.levelminuonefc = {
				name: 'LevelMinusOneForecastCategory',
				type: 'sfdcPicklist',
				scope: $scope,
				validate: "required",
				options: 'oppPicklistFieldsValues.' + $scope.LevelMinusOneForecastCategoryField,
				optionSplitor: '.',
				valueField: 'value',
				textField: 'label',
				title: $scope.LevelMinusOneTitle + '\'s FC',
				align: 'center',
				sortDependency: 'Opportunity.' + $scope.LevelMinusOneForecastCategoryField,
				sortByDependency: true,
				editing: false
			};
			
			$scope.lastf2fmeetingdate = {
				name: 'LastF2FMeetingDate',
				type: 'sfdcDate',
				scope: $scope,
				validate: "sfdcDate",
				title: 'Last F2F SCI',
				align: 'center',
				sortDependency: 'Opportunity.Account.Last_F2F_Meeting__c',
				sortByDependency: true,
				editing: false,
				itemTemplate: function(value, item) {
					if (item.LastF2FMeetingDateCSS  === true){
						var elem = $("<span style='color:red'>").text(this.scope.unescape(value));
						return elem;
					}
					return this.scope.unescape(value);
				}
			};
			
			$scope.controlfields = {
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
			};
			
			$scope.contractenddate = {
				name: 'ContractEndDate',
				type: 'sfdcDate',
				scope: $scope,
				validate: "sfdcDate",
				title: 'Contract End Date',
				align: 'center',
				sortDependency: 'Opportunity.Contract_End_Date_New__c',
				sortByDependency: true,
				editing: false
				
			};
            
            
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
                var serviceIdentifier = "ZDirectSubUsers" + userId;
                $scope.callRemoteServiceWithCache(ZForecastingController.GetDirectSubordinateUsers, [userId, $scope.forecastFamily], serviceIdentifier, function(result) {
                    deferred.resolve({
                        userId: userId,
                        subUsers: result
                    });
                });
                return deferred.promise;
            };

            $scope.promiseAllSubUsers = function(userId) {
                var deferred = $q.defer();
                var serviceIdentifier = "ZAllSubUsers" + userId;
                $scope.callRemoteServiceWithCache(ZForecastingController.GetAllSubordinateUsers, [userId, $scope.forecastFamily], serviceIdentifier, function(result) {
                    deferred.resolve({
                        userId: userId,
                        subUsers: result
                    });
                });
                return deferred.promise;
            };

            $scope.promiseDirectSubUsersWithManagers = function(userId) {
                var deferred = $q.defer();
                var serviceIdentifier = "ZAllSubUsers" + userId;
                $scope.callRemoteServiceWithCache(ZForecastingController.GetDirectSubordinateUsersV2, [userId, $scope.forecastFamily], serviceIdentifier, function(result) {
                    deferred.resolve({
                        userId: userId,
                        subUsers: result
                    });
                });
                return deferred.promise;
            };
        
            $scope.promiseGetUser = function(userId) {
                var deferred = $q.defer();
                var serviceIdentifier = "ZGetUser" + userId;
                $scope.callRemoteServiceWithCache(ZForecastingController.GetUser, [userId], serviceIdentifier, function(result) {
                    deferred.resolve({
                        userId: userId,
                        userInfo: result
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
                var serviceIdentifier = "ZSummary" + $scope.fiscalQtr + $scope.currentUser;
                $scope.callRemoteServiceWithCache(ZForecastingStatsService.getForecastSummary, [$scope.currentUser, $scope.CurrentUserLevel, $scope.MyUserLevel, $scope.fiscalQtr, $scope.forecastType, true, $scope.forecastFamily], serviceIdentifier, function(result) {
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
			
			$scope.loadweeklyforecast = function() {
                $scope.weeklyforecastsummary.isLoading = true;
                var serviceIdentifier = "ZSummary-WeeklyForecast" + $scope.fiscalQtr + $scope.currentUser;
                $scope.callRemoteServiceWithCache(ZForecastingStatsService.getWeeklyForecastSummary, [$scope.currentUser, $scope.fiscalQtr, $scope.forecastType, $scope.CurrentUserLevel, $scope.isViewingHistory, $scope.forecastFamily], serviceIdentifier, function(result) {
                    $scope.weeklyforecastsummary.isLoading = false;
                    $scope.weeklyforecastsummary.data = result;
                    setTimeout(function() {
                        $scope.$apply($scope.weeklyforecastsummary);
                    });
                }, {
                    buffer: false,
                    timeout: 60000
                });
            }
			
			$scope.loadmonthlyforecast = function() {
                $scope.monthlyforecastsummary.isLoading = true;
                var serviceIdentifier = "ZSummary-MonthlyForecast" + $scope.fiscalQtr + $scope.currentUser;
                $scope.callRemoteServiceWithCache(ZForecastingStatsService.getMonthlyForecastSummary, [$scope.currentUser, $scope.fiscalQtr, $scope.forecastType, $scope.CurrentUserLevel, $scope.isViewingHistory, $scope.forecastFamily], serviceIdentifier, function(result) {
                    $scope.monthlyforecastsummary.isLoading = false;
                    $scope.monthlyforecastsummary.data = result;
                    setTimeout(function() {
                        $scope.$apply($scope.monthlyforecastsummary);
                    });
                }, {
                    buffer: false,
                    timeout: 60000
                });
            }
			
			$scope.loadmonthlyforecastzpa = function() {
                $scope.monthlyforecastsummaryzpa.isLoading = true;
                var serviceIdentifier = "ZSummary-MonthlyForecastZPA" + $scope.fiscalQtr + $scope.currentUser;
                $scope.callRemoteServiceWithCache(ZForecastingStatsService.getMonthlyForecastSummary, [$scope.currentUser, $scope.fiscalQtr, $scope.forecastType, $scope.CurrentUserLevel, $scope.isViewingHistory, 'ZPA'], serviceIdentifier, function(result) {
                    $scope.monthlyforecastsummaryzpa.isLoading = false;
                    $scope.monthlyforecastsummaryzpa.data = result;
                    setTimeout(function() {
                        $scope.$apply($scope.monthlyforecastsummaryzpa);
                    });
                }, {
                    buffer: false,
                    timeout: 60000
                });
            }
            
            $scope.loadforecastSummaryZPA = function() {
                $scope.forecastSummaryZPA.isLoading = true;
                var serviceIdentifier = "ZSummary-ForecastSummaryZPA" + $scope.fiscalQtr + $scope.currentUser;
                $scope.callRemoteServiceWithCache(ZForecastingStatsService.getForecastSummaryZPA, [$scope.currentUser, $scope.CurrentUserLevel, $scope.MyUserLevel, $scope.fiscalQtr, $scope.forecastType, 'ZPA'], serviceIdentifier, function(result) {
                    $scope.forecastSummaryZPA.isLoading = false;
                    $scope.forecastSummaryZPA.data = result;
                    setTimeout(function() {
                        $scope.$apply($scope.forecastSummaryZPA);
                    });
                }, {
                    buffer: false,
                    timeout: 60000
                });
            }
			
			$scope.loadnetnewacvsummary = function() {
                $scope.netnewacvsummary.isLoading = true;
                var serviceIdentifier = "ZSummary-NETNEWACVSUMMARY" + $scope.fiscalQtr + $scope.currentUser;
                $scope.callRemoteServiceWithCache(ZForecastingStatsService.getNetNewACVSummary, [$scope.currentUser, $scope.CurrentUserLevel, $scope.MyUserLevel, $scope.fiscalQtr, $scope.forecastType, true, $scope.forecastFamily, $scope.isViewingHistory], serviceIdentifier, function(result) {
                    $scope.netnewacvsummary.isLoading = false;
                    $scope.netnewacvsummary.data = result;
                    setTimeout(function() {
                        $scope.$apply($scope.netnewacvsummary);
                    });
                }, {
                    buffer: false,
                    timeout: 60000
                });
            }
			
			$scope.exporttoexcel = function() {
                console.log($scope.opportunityListing.data);
				var request = {
                    UserId: $scope.currentUser,
                    UserLevel: $scope.MyUserLevel,
                    MyUserId: $scope.MyUserId,
                    FiscalQtr: $scope.fiscalQtr,
                    PageIndex: $scope.opportunityListing.filter.pageIndex,
                    Stage: $scope.selectedviewvals,
                    DealValue: $scope.selecteddealbandvals,
                    Probability: $scope.opportunityListing.filter.probability,
                    SortField: $scope.toggle.switch && $scope.opportunityListing.filter.sortField == 'Amount__c' ? 'ZPA_Amount__c' : $scope.opportunityListing.filter.sortField,
                    IsAscendingOrder: $scope.opportunityListing.filter.isAscendingOrder,
                    ForecastType: $scope.forecastType,
                    ForecastFamily: $scope.forecastFamily,
                    impersonateViewAsUser: $scope.impersonateViewAsUser || !$scope.forecastEnabledForLoggedInUser,
					ClosingMonth: $scope.selectedclosingMonthvals,
					ClosingWeek: $scope.selectedclosingWeekvals,
					Geo: $scope.selectedgeovals,
					Region: $scope.selectedregionvals,
					CustomerSuccessStage: $scope.selectedcssvals,
					CustomerSentiment : $scope.selectedcsvals,
					ContractEndDateMonth: $scope.selectedconedmonthvals,
					ContractEndDateWeek: $scope.selectedconedweekvals,
					NOTRAfilter: $scope.selectednotravals,
					showzpa: $scope.toggle.switch,
					isExporttoExcel: true
                };
				assignlist(request, $scope.LevelMinusOneTitle, $scope.viewNOTRA, $scope.opportunityListing.CloseWeekDateRange);
            }
			
			$scope.loadacvforecastbillings = function() {
                $scope.billingsacvforecast.isLoading = true;
                var serviceIdentifier = "ZSummary-acvforecastbillings" + $scope.fiscalQtr + $scope.currentUser;
                $scope.callRemoteServiceWithCache(ZForecastingStatsService.getACVForecastBillings, [$scope.currentUser, $scope.CurrentUserLevel, $scope.MyUserLevel, $scope.fiscalQtr, 'all', true, $scope.forecastFamily], serviceIdentifier, function(result) {
                    $scope.billingsacvforecast.isLoading = false;
                    $scope.billingsacvforecast.data = result;
                    setTimeout(function() {
                        $scope.$apply($scope.billingsacvforecast);
                    });
                }, {
                    buffer: false,
                    timeout: 60000
                });
            }
			
			$scope.editBillingsSummary = function() {
                $scope.billingsSummary.isEditing = true;
                $scope.billingsSummaryEdit.data = $scope.billingsSummary.data;
            }
			
			$scope.saveBillingsSummary = function() {
				$scope.billingsSummaryEdit.data.greaterThanOneYear.billToGoSummary = $scope.enforceNumberValidated($scope.billingsSummary.data.greaterThanOneYear.billToGoSummary);
				$scope.billingsSummaryEdit.data.greaterThanOneYear.firstForecastSummary = $scope.enforceNumberValidated($scope.billingsSummary.data.greaterThanOneYear.firstForecastSummary);
				$scope.billingsSummaryEdit.data.greaterThanOneYear.netsuiteSummary = $scope.enforceNumberValidated($scope.billingsSummary.data.greaterThanOneYear.netsuiteSummary);
				$scope.billingsSummaryEdit.data.greaterThanOneYear.planBillingsSummary = $scope.enforceNumberValidated($scope.billingsSummary.data.greaterThanOneYear.planBillingsSummary);
				$scope.billingsSummaryEdit.data.greaterThanOneYear.priorYearBillingsSummary = $scope.enforceNumberValidated($scope.billingsSummary.data.greaterThanOneYear.priorYearBillingsSummary);
				$scope.billingsSummaryEdit.data.annual.billToGoSummary = $scope.enforceNumberValidated($scope.billingsSummary.data.annual.billToGoSummary);
				$scope.billingsSummaryEdit.data.annual.firstForecastSummary = $scope.enforceNumberValidated($scope.billingsSummary.data.annual.firstForecastSummary);
				$scope.billingsSummaryEdit.data.annual.netsuiteSummary = $scope.enforceNumberValidated($scope.billingsSummary.data.annual.netsuiteSummary);
				$scope.billingsSummaryEdit.data.annual.planBillingsSummary = $scope.enforceNumberValidated($scope.billingsSummary.data.annual.planBillingsSummary);
				$scope.billingsSummaryEdit.data.annual.priorYearBillingsSummary = $scope.enforceNumberValidated($scope.billingsSummary.data.annual.priorYearBillingsSummary);
				$scope.billingsSummaryEdit.data.lessThanOneYear.billToGoSummary = $scope.enforceNumberValidated($scope.billingsSummary.data.lessThanOneYear.billToGoSummary);
				$scope.billingsSummaryEdit.data.lessThanOneYear.firstForecastSummary = $scope.enforceNumberValidated($scope.billingsSummary.data.lessThanOneYear.firstForecastSummary);
				$scope.billingsSummaryEdit.data.lessThanOneYear.netsuiteSummary = $scope.enforceNumberValidated($scope.billingsSummary.data.lessThanOneYear.netsuiteSummary);
				$scope.billingsSummaryEdit.data.lessThanOneYear.planBillingsSummary = $scope.enforceNumberValidated($scope.billingsSummary.data.lessThanOneYear.planBillingsSummary);
				$scope.billingsSummaryEdit.data.lessThanOneYear.priorYearBillingsSummary = $scope.enforceNumberValidated($scope.billingsSummary.data.lessThanOneYear.priorYearBillingsSummary);
                ZForecastingStatsService.SaveBillingsSummary($scope.fiscalQtr, $scope.billingsSummaryEdit.data, function(result, event) {
                    if ($scope.isCalloutSucceeded(event)) {
                        var scope = angular.element(jQuery("#ngContainer")).scope();
                        scope.$apply(function() {
							$scope.loadbillingsSummary();
                            var serviceIdentifier = "ZSummary-saveBillingsSummary" + $scope.fiscalQtr + $scope.currentUser;
                            $scope.setCacheValue(serviceIdentifier, $scope.billingsSummary.data);
                        });
                    }
                });
            };
			
			$scope.loadbillingsSummary = function() {
                $scope.billingsSummary.isLoading = true; 
                var serviceIdentifier = "ZSummary-billingsSummary" + $scope.fiscalQtr + $scope.currentUser;
                $scope.callRemoteServiceWithCache(ZForecastingStatsService.getBillingsSummary, [$scope.fiscalQtr], serviceIdentifier, function(result) {
                    $scope.billingsSummary.isLoading = false;
                    $scope.billingsSummary.data = result;
					$scope.billingsSummary.isEditing = false;
                    setTimeout(function() {
                        $scope.$apply($scope.billingsSummary);
                    });
                }, {
                    buffer: false,
                    timeout: 60000,
					escape: false
                });
            }
			
			$scope.loadnotra = function() {
                $scope.notrasummary.isLoading = true;
                var serviceIdentifier = "ZSummary-NOTRA" + $scope.fiscalQtr + $scope.currentUser;
                $scope.callRemoteServiceWithCache(ZForecastingStatsService.getNOTRASummary, [$scope.currentUser, $scope.fiscalQtr, $scope.CurrentUserLevel], serviceIdentifier, function(result) {
                    $scope.notrasummary.isLoading = false;
                    $scope.notrasummary.data = result;
                    setTimeout(function() {
                        $scope.$apply($scope.notrasummary);
                    });
                }, {
                    buffer: false,
                    timeout: 60000,
					escape: false
                });
            }
			
			/*$scope.loadchurn = function() {
                $scope.churnsummary.isLoading = true;
                var serviceIdentifier = "ZSummary-CHURN" + $scope.fiscalQtr + $scope.currentUser;
                $scope.callRemoteServiceWithCache(ZForecastingStatsService.getDealChurnSummary, [$scope.currentUser, $scope.fiscalQtr, $scope.CurrentUserLevel], serviceIdentifier, function(result) {
                    $scope.churnsummary.isLoading = false;
                    $scope.churnsummary.data = result;
                    setTimeout(function() {
                        $scope.$apply($scope.churnsummary);
                    });
                }, {
                    buffer: false,
                    timeout: 60000
                });
            }*/
			
			$scope.loadgeovals = function() {
				$scope.geovals = [];
				var georegvals = $scope.geoandregionmap;
				for (val in georegvals) {
					if(val != 'All'){
						$scope.geovals.push(val);
					}
				}
			}
			$scope.loadregvals = function(geoval) {
				$scope.regionvals = [];
				var georegvals = $scope.geoandregionmap;
				if(geoval != undefined && geoval != null && geoval != ''){
					for(var i=0; i <georegvals[geoval].length; i++){
						if(georegvals[geoval][i] != 'All'){
							$scope.regionvals.push(georegvals[geoval][i]);
						}
					}
					
				}
			}
			
			$scope.loadregvalsmulti = function() {
				
				var georegvals = $scope.geoandregionmap;
				if($scope.selectedgeovals != undefined && $scope.selectedgeovals != null && $scope.selectedgeovals.length > 0){
					$scope.regionvals = [];
					for(var k=0; k <$scope.selectedgeovals.length; k++){
						for(var i=0; i <georegvals[$scope.selectedgeovals[k]].length; i++){
							if(georegvals[$scope.selectedgeovals[k]][i] != 'All'){
								$scope.regionvals.push(georegvals[$scope.selectedgeovals[k]][i]);
							}
						}
					}
				}else if($scope.selectedgeovals.length == 0){
					$scope.loadregvals('All');
				}
			}

            $scope.loadTeamForecasts = function() {
                for (var i = 0; i < $scope.directSubUsers.length; i++) {
                    $scope.teamForecasts.isLoading = true;
                    var uid = $scope.directSubUsers[i].UserId;
                    var level = $scope.directSubUsers[i].Level;
                    var serviceIdentifier = "ZSummary" + $scope.fiscalQtr + uid;
                    var includeSubordinates = uid == $scope.currentUser ? false : true;
                    $scope.callRemoteServiceWithCache(ZForecastingStatsService.getForecastSummary, [uid, level, $scope.MyUserLevel, $scope.fiscalQtr, $scope.forecastType, includeSubordinates, 'ZIA'], serviceIdentifier, function(result) {
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
                            !total.TotalPipeline ? total.TotalPipeline = member.TotalPipeline : total.TotalPipeline += member.TotalPipeline || 0;
                            !total.TotalQTDBooking ? total.TotalQTDBooking = member.MySummary.QTDClosedTotal : total.TotalQTDBooking += member.MySummary.QTDClosedTotal || 0;
                            !total.TotalMLRollup ? total.TotalMLRollup = member.MySummary.MostLikelyTotal : total.TotalMLRollup += member.MySummary.MostLikelyTotal || 0;
                            !total.TotalBCRollup ? total.TotalBCRollup = member.MySummary.BestCaseTotal : total.TotalBCRollup += member.MySummary.BestCaseTotal || 0;
                            !total.TotalWCRollup ? total.TotalWCRollup = member.MySummary.WorstCaseTotal : total.TotalWCRollup += member.MySummary.WorstCaseTotal || 0;
                            if (member.UserId != $scope.currentUser) {
                                !total.QTRQuota ? total.QTRQuota = member.QTRQuota : total.QTRQuota += member.QTRQuota || 0;
                                !total.TotalMyForecast ? total.TotalMyForecast = member.MyForecast : total.TotalMyForecast += member.MyForecast || 0;
                            }
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
				document.getElementById('loaderimg').style.display = 'inline';
                var request = {
                    UserId: $scope.currentUser,
                    UserLevel: $scope.MyUserLevel,
                    MyUserId: $scope.MyUserId,
                    FiscalQtr: $scope.fiscalQtr,
                    PageIndex: $scope.opportunityListing.filter.pageIndex,
                    Stage: $scope.selectedviewvals,
                    DealValue: $scope.selecteddealbandvals,
                    Probability: $scope.opportunityListing.filter.probability,
                    SortField: $scope.toggle.switch && $scope.opportunityListing.filter.sortField == 'Amount__c' ? 'ZPA_Amount__c' : $scope.opportunityListing.filter.sortField,
                    IsAscendingOrder: $scope.opportunityListing.filter.isAscendingOrder,
                    ForecastType: $scope.forecastType,
                    ForecastFamily: $scope.forecastFamily,
                    impersonateViewAsUser: $scope.impersonateViewAsUser || !$scope.forecastEnabledForLoggedInUser,
					ClosingMonth: $scope.selectedclosingMonthvals,
					ClosingWeek: $scope.selectedclosingWeekvals,
					Geo: $scope.selectedgeovals,
					Region: $scope.selectedregionvals,
					CustomerSuccessStage: $scope.selectedcssvals,
					CustomerSentiment: $scope.selectedcsvals,
					ContractEndDateMonth: $scope.selectedconedmonthvals,
					ContractEndDateWeek: $scope.selectedconedweekvals,
					NOTRAfilter: $scope.selectednotravals,
					showzpa: $scope.toggle.switch,
					isExporttoExcel: false
                };

                ZForecastingStatsService.GetOpportunityListing(request, function(result, event) {
                    if ($scope.isCalloutSucceeded(event)) {
						document.getElementById('loaderimg').style.display = 'none';
						$scope.opportunityListing.isLoading = false;
                        $scope.opportunityListing.data = result.Opportunities;
                        $scope.opportunityListing.hasPrevious = result.HasPrevious;
                        $scope.opportunityListing.hasNext = result.HasNext;
                        $scope.opportunityListing.pageCount = result.PageCount;
                        $scope.opportunityListing.pageIndex = result.PageIndex;
                        $scope.opportunityListing.totalOppAmount = result.totalOppAmount;
                        $scope.opportunityListing.recordCount = result.RecordCount;
                        $scope.opportunityListing.CloseWeekDateRange = result.CloseWeekDateRange;
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
                    'UserId': $scope.MyUserId,
                    'UserLevel': $scope.MyUserLevel,
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
                ZForecastingStatsService.updateOpportunityRecord(updateRequest, function(result, event) {
                    if ($scope.isCalloutSucceeded(event)) {
                        $scope.$apply(function() {
                            if (result.status) {
                                $scope.loadOpportunityListing();
                                $scope.loadweeklyforecast();
                                $scope.loadmonthlyforecast();
								if($scope.forecastType == 'new-upsell'){
									$scope.loadmonthlyforecastzpa();
									$scope.loadforecastSummaryZPA();
								}
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
                    Amount: $scope.forecastSummary.data.MyForecast,
                    SFID: $scope.forecastSummary.data.MyForecastSFID == undefined ? null : $scope.forecastSummary.data.MyForecastSFID,
                    Locked: $scope.forecastSummary.data.Locked,
                    FYFQ: $scope.fiscalQtr,
                    Comments: $scope.forecastSummary.data.Comments
                };
            };
			
			$scope.editForecastWeeklyComments = function() {
                $scope.cancelForecastWeeklyComments();
                $scope.forecastSummary.isEditingWeeklyComments = true;
                $scope.forecastSummary.editingModalWeeklyComments = {
					SFID: $scope.forecastSummary.data.MyForecastSFID == undefined ? null : $scope.forecastSummary.data.MyForecastSFID,
                    FYFQ: $scope.fiscalQtr,
					WeeklyComments: $scope.forecastSummary.data.WeeklyComments
                };
            };
			
			$scope.cancelForecastWeeklyComments = function() {
                $scope.forecastSummary.isEditingWeeklyComments = false;
            };
			
			$scope.saveForecastWeeklyComments = function() {
				$scope.forecastSummary.editingModalWeeklyComments.WeeklyComments = $scope.forecastSummary.editingModal.WeeklyComments != undefined ? $scope.forecastSummary.editingModal.WeeklyComments : '';

                ZForecastingStatsService.SaveForecastWeeklyComments($scope.currentUser, $scope.fiscalQtr, $scope.forecastType, $scope.forecastFamily, $scope.forecastSummary.editingModalWeeklyComments.WeeklyComments, $scope.forecastSummary.editingModalWeeklyComments.SFID, function(result, event) {
                    if ($scope.isCalloutSucceeded(event)) {
                        var scope = angular.element(jQuery("#ngContainer")).scope();
                        scope.$apply(function() {
                            $scope.forecastSummary.data.WeeklyComments = $scope.forecastSummary.editingModalWeeklyComments.WeeklyComments;
                            var serviceIdentifier = "ZSummary-WeeklyComments" + $scope.fiscalQtr + $scope.currentUser;
                            $scope.setCacheValue(serviceIdentifier, $scope.forecastSummary.data);
                        });
                    }
                    $scope.$apply(function() {
                        $scope.forecastSummary.isEditingWeeklyComments = false;
                    });
                });
            };
			
			$scope.editPriorYrClosedYTD = function() {
                $scope.cancelPriorYrClosedYTD();
                $scope.forecastSummary.isEditingPriorYrClosedYTD = true;
                $scope.forecastSummary.editingModalPriorYrClosedYTD = {
					SFID: $scope.forecastSummary.data.MyForecastSFID == undefined ? null : $scope.forecastSummary.data.MyForecastSFID,
                    FYFQ: $scope.fiscalQtr,
					PriorYrClosedYTD: $scope.billingsacvforecast.data.PriorYrClosedYTD
                };
            };
			
			$scope.cancelPriorYrClosedYTD = function() {
                $scope.forecastSummary.isEditingPriorYrClosedYTD = false;
            };
			
			$scope.savePriorYrClosedYTD = function() {
				$scope.forecastSummary.editingModalPriorYrClosedYTD.PriorYrClosedYTD = $scope.enforceNumberValidated($scope.forecastSummary.editingModalPriorYrClosedYTD.PriorYrClosedYTD);

                ZForecastingStatsService.SaveYonYGrowth($scope.currentUser, $scope.fiscalQtr, $scope.forecastType, $scope.forecastFamily, $scope.forecastSummary.editingModalPriorYrClosedYTD.PriorYrClosedYTD, function(result, event) {
                    if ($scope.isCalloutSucceeded(event)) {
                        var scope = angular.element(jQuery("#ngContainer")).scope();
                        scope.$apply(function() {
                            $scope.billingsacvforecast.data.PriorYrClosedYTD = $scope.forecastSummary.editingModalPriorYrClosedYTD.PriorYrClosedYTD;
							$scope.loadacvforecastbillings();
                            var serviceIdentifier = "ZSummary-PriorYrClosedYTD" + $scope.fiscalQtr + $scope.currentUser;
                            $scope.setCacheValue(serviceIdentifier, $scope.forecastSummary.data);
                        });
                    }
                    $scope.$apply(function() {
                        $scope.forecastSummary.isEditingPriorYrClosedYTD = false;
                    });
                });
            };
			
			$scope.editnotracomments = function() {
                $scope.cancelnotracomments();
                
                $scope.notrasummary.editingModal = {
                    comments: $scope.notrasummary.data.comments
                };
				$scope.notrasummary.isEditingComments = true;
            };
			
			$scope.editnotraadjustments = function() {
                $scope.cancelnotraadjustments();
                
                $scope.notrasummary.editingModal = {
                    renewalAdjustment: $scope.notrasummary.data.renewalAdjustment,
                };
				$scope.notrasummary.isEditingAdjustments = true;
            };
			
			$scope.cancelnotracomments = function() {
                $scope.notrasummary.isEditingComments = false;
            };
			
			$scope.cancelnotraadjustments = function() {
                $scope.notrasummary.isEditingAdjustments = false;
            };
			
			$scope.savenotracomments = function() {
				$scope.notrasummary.editingModal.comments = $scope.notrasummary.editingModal.comments != undefined ? $scope.notrasummary.editingModal.comments : '';

                ZForecastingStatsService.saveNotraComments($scope.currentUser, $scope.fiscalQtr, $scope.CurrentUserLevel, $scope.notrasummary.editingModal.comments, function(result, event) {
                    if ($scope.isCalloutSucceeded(event)) {
                        var scope = angular.element(jQuery("#ngContainer")).scope();
                        scope.$apply(function() {
                            $scope.notrasummary.data.comments = $scope.notrasummary.editingModal.comments;
                            var serviceIdentifier = "ZSummary-NOTRACommentsedit" + $scope.fiscalQtr + $scope.currentUser;
                            $scope.setCacheValue(serviceIdentifier, $scope.notrasummary.data);
							$scope.loadnotra();
                        });
                    }
                    $scope.$apply(function() {
                        $scope.notrasummary.isEditingComments = false;
                    });
                });
            };
			
			$scope.savenotraadjustments = function() {
				$scope.notrasummary.editingModal.renewalAdjustment = $scope.enforceNumberValidated($scope.notrasummary.editingModal.renewalAdjustment);

                ZForecastingStatsService.saveRenewalAdjustment($scope.currentUser, $scope.fiscalQtr, $scope.CurrentUserLevel, $scope.notrasummary.editingModal.renewalAdjustment, function(result, event) {
                    if ($scope.isCalloutSucceeded(event)) {
                        var scope = angular.element(jQuery("#ngContainer")).scope();
                        scope.$apply(function() {
                            $scope.notrasummary.data.renewalAdjustment = $scope.notrasummary.editingModal.renewalAdjustment;
                            var serviceIdentifier = "ZSummary-NOTRAAdjustmentedit" + $scope.fiscalQtr + $scope.currentUser;
                            $scope.setCacheValue(serviceIdentifier, $scope.notrasummary.data);
							$scope.loadnotra();
                        });
                    }
                    $scope.$apply(function() {
                        $scope.notrasummary.isEditingAdjustments = false;
                    });
                });
            };
        
            $scope.updateForecastNumber = function() {
                if ($scope.forecastSummary.isEditing == true
                   && $scope.forecastSummary.editingModal != undefined) {
                    var mostLikelyTotal = $scope.forecastSummary.data.MySummary.MostLikelyTotal != undefined && $scope.forecastSummary.data.MySummary.MostLikelyTotal != null ?  $scope.forecastSummary.data.MySummary.MostLikelyTotal : 0;
                    $scope.forecastSummary.editingModal.Amount = $scope.forecastSummary.editingModal.Locked == true ? $scope.forecastSummary.editingModal.Amount : mostLikelyTotal || 0;
                }
            }
			
			
            
            $scope.cancelForecast = function() {
                $scope.forecastSummary.isEditing = false;
            };

            $scope.saveForecast = function() {
                $scope.forecastSummary.editingModal.Amount = $scope.enforceNumberValidated($scope.forecastSummary.editingModal.Amount);
                $scope.forecastSummary.editingModal.Comments = $scope.forecastSummary.editingModal.Comments != undefined ? $scope.forecastSummary.editingModal.Comments : '';

                ZForecastingStatsService.SaveForecast($scope.currentUser, $scope.fiscalQtr, $scope.forecastType, $scope.forecastFamily, $scope.forecastSummary.editingModal.Amount, $scope.forecastSummary.editingModal.Locked, $scope.forecastSummary.editingModal.Comments, $scope.forecastSummary.editingModal.SFID, function(result, event) {
                    if ($scope.isCalloutSucceeded(event)) {
                        var scope = angular.element(jQuery("#ngContainer")).scope();
                        scope.$apply(function() {
                            $scope.forecastSummary.data.MyForecast = $scope.forecastSummary.editingModal.Amount;
                            $scope.forecastSummary.data.Locked = $scope.forecastSummary.editingModal.Locked;
                            $scope.forecastSummary.data.Comments = $scope.forecastSummary.editingModal.Comments;
//                            $scope.forecastSummary.data.RecentForecasts[0].QtrPipeline = $scope.forecastSummary.editingModal.QtrPipeline;
//                            $scope.forecastSummary.data.RecentForecasts[0].QtrUpside = $scope.forecastSummary.editingModal.QtrUpside;
                            var serviceIdentifier = "ZSummary" + $scope.fiscalQtr + $scope.currentUser;
                            $scope.setCacheValue(serviceIdentifier, $scope.forecastSummary.data);
                        });
                    }
                    $scope.$apply(function() {
                        $scope.forecastSummary.isEditing = false;
                    });
                });
            };
            $scope.isValidDecimals = function() {
                for (var i=0; i<arguments.length; i++) {
                    if (arguments[i] == undefined || arguments[i] == null || arguments[i] == '' || isNaN(arguments[i])) {
                        return false;
                    }
                }
                return true;
            }
            
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
					if(newValue == null || newValue == undefined || newValue == '' || isNaN(newValue)){
						newValue = 0.0;
					}
                    return newValue;
                }
				if(value == null || value == undefined || isNaN(value)){
					value = 0.0;
				}
                return value;
            };

            $scope.formatDecimal = function(value, format) {
                if (value == null) {
                    return null;
                } else if (value == 0) {
                    return "0";
                } else if (value == 'NA') {
                    return "NA";
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
			
			$scope.formatPercentagerounded = function(value) {
                if (isNaN(value)) {
                    return "";
                }else if(value == null) {
                    return null;
                }
                var result = Math.round(value) + "%";
                return result;
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
            $scope.buildSubUserLevelList = function(level) {
                var levelList = [];
                if (level == 'Exec') {
                    levelList.push('VP');
                }
                if (level == 'Exec' || level == 'VP') {
                    levelList.push('RVP');
                }
                if (level == 'Exec' || level == 'VP' || level == 'RVP') {
                    levelList.push('Director');
                }
                if (level == 'Exec' || level == 'VP' || level == 'RVP' || level == 'Director') {
                    levelList.push('Manager');
                }
                if (level == 'Exec' || level == 'VP' || level == 'RVP' || level == 'Director' || level == 'Manager') {
                    levelList.push('Rep');
                }
                return levelList;
            }
			
			$scope.loadbillings = function(){
				$scope.loadacvforecastbillings();
				$scope.loadbillingsSummary();
			}
            $scope.loadAll = function() {
                var subUserPromise = '';

                //Load all subordinate users in the list
                if ($scope.forecastFamily.toLowerCase() == 'zpa') {
                    subUserPromise = $scope.promiseDirectSubUsersWithManagers($scope.currentUser);
                } else {
                    subUserPromise = $scope.promiseDirectSubUsers($scope.currentUser);
                }

                subUserPromise.then(function(subUserResult) {
                    if (subUserResult.subUsers.length > 0) {
                        var getUserPromise = $scope.promiseGetUser($scope.currentUser);
                        
                        getUserPromise.then(function (result) {
                            $scope.directSubUsers = $scope.directSubUsers.concat(subUserResult.subUsers);
                            $scope.directSubUsers.push(result.userInfo);
                            $scope.loadTeamForecasts();
                        });
                    }
                });

                var mySubUserPromise = $scope.promiseDirectSubUsers($scope.MyUserId);
                
                mySubUserPromise.then(function(subUserResult) {
                    var tempRoleList = [];
                    for (var i=subUserResult.subUsers.length - 1; i>=0; i--) {
                        if (tempRoleList.indexOf(subUserResult.subUsers[i].Level) == -1
                           && subUserResult.subUsers[i].UserId != $scope.currentUser) {
                            tempRoleList.push(subUserResult.subUsers[i].Level);
                        }
                    }

                    var levelList = $scope.buildSubUserLevelList($scope.MyUserLevel);
                    for (var i = 0; i<levelList.length; i++) {
                        if (tempRoleList.indexOf(levelList[i]) != -1) {
                            $scope.LevelMinusOne = levelList[i];
                            break;
                        }
                    }
                    if ($scope.LevelMinusOne == 'VP') {
                        $scope.LevelMinusOneTitle = 'VP';
                        $scope.LevelMinusOneForecastCategoryField = 'VP_Forecast_Category__c';
                    } if ($scope.LevelMinusOne == 'RVP') {
                        $scope.LevelMinusOneTitle = 'RVP';
                        $scope.LevelMinusOneForecastCategoryField = 'RVP_Forecast_Category__c';
                    } else if ($scope.LevelMinusOne == 'Director') {
                        $scope.LevelMinusOneTitle = 'AD';
                        $scope.LevelMinusOneForecastCategoryField = 'AD_Forecast_Category__c';
                    } else if ($scope.LevelMinusOne == 'Manager') {
                        $scope.LevelMinusOneTitle = 'DM';
                        $scope.LevelMinusOneForecastCategoryField = 'DM_Forecast_Category__c';
                    } else if ($scope.LevelMinusOne == 'Rep') {
                        $scope.LevelMinusOneTitle = 'Rep';
                        $scope.LevelMinusOneForecastCategoryField = 'Forecast_Category__c';
                    }
                    
					if($scope.forecastType == 'all'){
						$scope.oppListV2.oppListv2Fields = [];
						$scope.oppListV2.oppListv2Fields.push($scope.oppname);
						$scope.oppListV2.oppListv2Fields.push($scope.oppamount);
						$scope.oppListV2.oppListv2Fields.push($scope.oppstage);
						$scope.oppListV2.oppListv2Fields.push($scope.pocstatus);
						$scope.oppListV2.oppListv2Fields.push($scope.closedate);
						if ($scope.MyUserLevel !== 'Rep') { 
							$scope.oppListV2.oppListv2Fields.push($scope.repfc);
						}
						if ($scope.LevelMinusOne != 'Rep' && $scope.MyUserLevel != 'Rep') {
							$scope.oppListV2.oppListv2Fields.push($scope.levelminuonefc);
						}
						$scope.oppListV2.oppListv2Fields.push($scope.myfc);
						if ($scope.MyUserLevel !== 'Rep') { 
							$scope.oppListV2.oppListv2Fields.push($scope.myfclock);
						}
						
						$scope.oppListV2.oppListv2Fields.push($scope.nextstep);
						$scope.oppListV2.oppListv2Fields.push($scope.primarypartnerId);
						$scope.oppListV2.oppListv2Fields.push($scope.ownerId);
						$scope.oppListV2.oppListv2Fields.push($scope.lastarchworkshopdate);
						$scope.oppListV2.oppListv2Fields.push($scope.lastf2fmeetingdate);
						$scope.oppListV2.oppListv2Fields.push($scope.controlfields);
                    }else if($scope.forecastType == 'new'){
						$scope.oppListV2.oppListv2Fields = [];
						$scope.oppListV2.oppListv2Fields.push($scope.oppname);
						$scope.oppListV2.oppListv2Fields.push($scope.oppamount);
						$scope.oppListV2.oppListv2Fields.push($scope.oppstage);
						$scope.oppListV2.oppListv2Fields.push($scope.pocstatus);
						$scope.oppListV2.oppListv2Fields.push($scope.closedate);
						if ($scope.MyUserLevel !== 'Rep') { 
							$scope.oppListV2.oppListv2Fields.push($scope.repfc);
						}
						if ($scope.LevelMinusOne != 'Rep' && $scope.MyUserLevel != 'Rep') {
							$scope.oppListV2.oppListv2Fields.push($scope.levelminuonefc);
						}
						$scope.oppListV2.oppListv2Fields.push($scope.myfc);
						if ($scope.MyUserLevel !== 'Rep') { 
							$scope.oppListV2.oppListv2Fields.push($scope.myfclock);
						}
						
						$scope.oppListV2.oppListv2Fields.push($scope.nextstep);
						$scope.oppListV2.oppListv2Fields.push($scope.primarypartnerId);
						$scope.oppListV2.oppListv2Fields.push($scope.ownerId);
						$scope.oppListV2.oppListv2Fields.push($scope.lastarchworkshopdate);
						$scope.oppListV2.oppListv2Fields.push($scope.lastf2fmeetingdate);
						$scope.oppListV2.oppListv2Fields.push($scope.controlfields);
                    }else if($scope.forecastType == 'new-upsell'){
						$scope.oppListV2.oppListv2Fields = [];
						$scope.oppListV2.oppListv2Fields.push($scope.oppname);
						$scope.oppListV2.oppListv2Fields.push($scope.oppamount);
						$scope.oppListV2.oppListv2Fields.push($scope.oppstage);
						$scope.oppListV2.oppListv2Fields.push($scope.pocstatus);
						$scope.oppListV2.oppListv2Fields.push($scope.closedate);
						if ($scope.MyUserLevel !== 'Rep') { 
							$scope.oppListV2.oppListv2Fields.push($scope.repfc);
						}
						if ($scope.LevelMinusOne != 'Rep' && $scope.MyUserLevel != 'Rep') {
							$scope.oppListV2.oppListv2Fields.push($scope.levelminuonefc);
						}
						$scope.oppListV2.oppListv2Fields.push($scope.myfc);
						if ($scope.MyUserLevel !== 'Rep') { 
							$scope.oppListV2.oppListv2Fields.push($scope.myfclock);
						}
						
						$scope.oppListV2.oppListv2Fields.push($scope.nextstep);
						$scope.oppListV2.oppListv2Fields.push($scope.primarypartnerId);
						$scope.oppListV2.oppListv2Fields.push($scope.ownerId);
						$scope.oppListV2.oppListv2Fields.push($scope.lastarchworkshopdate);
						$scope.oppListV2.oppListv2Fields.push($scope.lastf2fmeetingdate);
						$scope.oppListV2.oppListv2Fields.push($scope.controlfields);
                    }else if($scope.forecastType == 'upsell'){
						$scope.oppListV2.oppListv2Fields = [];
						$scope.oppListV2.oppListv2Fields.push($scope.oppname);
						$scope.oppListV2.oppListv2Fields.push($scope.oppamount);
						$scope.oppListV2.oppListv2Fields.push($scope.oppstage);
						$scope.oppListV2.oppListv2Fields.push($scope.pocstatus);
						$scope.oppListV2.oppListv2Fields.push($scope.closedate);
						if ($scope.MyUserLevel !== 'Rep') { 
							$scope.oppListV2.oppListv2Fields.push($scope.repfc);
						}
						if ($scope.LevelMinusOne != 'Rep' && $scope.MyUserLevel != 'Rep') {
							$scope.oppListV2.oppListv2Fields.push($scope.levelminuonefc);
						}
						$scope.oppListV2.oppListv2Fields.push($scope.myfc);
						if ($scope.MyUserLevel !== 'Rep') { 
							$scope.oppListV2.oppListv2Fields.push($scope.myfclock);
						}
						
						$scope.oppListV2.oppListv2Fields.push($scope.nextstep);
						$scope.oppListV2.oppListv2Fields.push($scope.primarypartnerId);
						$scope.oppListV2.oppListv2Fields.push($scope.ownerId);
						$scope.oppListV2.oppListv2Fields.push($scope.lastarchworkshopdate);
						$scope.oppListV2.oppListv2Fields.push($scope.lastf2fmeetingdate);
						$scope.oppListV2.oppListv2Fields.push($scope.controlfields);
                    }else if($scope.forecastType == 'renewal'){
		    	$scope.loadnotra();
						$scope.oppListV2.oppListv2Fields = [];
						$scope.oppListV2.oppListv2Fields.push($scope.oppname);
						$scope.oppListV2.oppListv2Fields.push($scope.oppamount);
						$scope.oppListV2.oppListv2Fields.push($scope.renewalACV);
						$scope.oppListV2.oppListv2Fields.push($scope.oppstage);
						/*$scope.oppListV2.oppListv2Fields.push($scope.customersuccessstage);*/
						$scope.oppListV2.oppListv2Fields.push($scope.customersentiment);
						$scope.oppListV2.oppListv2Fields.push($scope.closedate);
						$scope.oppListV2.oppListv2Fields.push($scope.contractenddate);
						if ($scope.MyUserLevel !== 'Rep') { 
							$scope.oppListV2.oppListv2Fields.push($scope.repfc);
						}
						if ($scope.LevelMinusOne != 'Rep' && $scope.MyUserLevel != 'Rep') {
							$scope.oppListV2.oppListv2Fields.push($scope.levelminuonefc);
						}
						$scope.oppListV2.oppListv2Fields.push($scope.myfc);
						if ($scope.MyUserLevel !== 'Rep') { 
							$scope.oppListV2.oppListv2Fields.push($scope.myfclock);
						}
						
						$scope.oppListV2.oppListv2Fields.push($scope.nextstep);
						$scope.oppListV2.oppListv2Fields.push($scope.primarypartnerId);
						$scope.oppListV2.oppListv2Fields.push($scope.ownerId);
						$scope.oppListV2.oppListv2Fields.push($scope.controlfields);
                    }
					
					$("#snapcast_oppList_v2").jsGrid("reset");
					$scope.oppListV2.initInstance();
                    $scope.loadForecastSummary();
                    $scope.loadweeklyforecast();
                    $scope.loadmonthlyforecast();
					if($scope.forecastType == 'new-upsell'){
						$scope.loadmonthlyforecastzpa();
						$scope.loadforecastSummaryZPA();
					}
                    
                    //$scope.loadchurn();
					$scope.loadgeovals();
					$scope.loadregvals('All');
                    $scope.loadOpportunityListing();
					if($scope.forecastType == 'new-upsell'){
						$scope.loadnetnewacvsummary();
					}
					
                });              
            }

            if (($scope.forecastEnabled || $scope.zpaForecastEnabled || $scope.showAsManagerInZPAForecasting) && $scope.forecastType != 'billings') {
                $scope.loadAll();
            } else if(($scope.forecastEnabled || $scope.zpaForecastEnabled || $scope.showAsManagerInZPAForecasting) && $scope.forecastType == 'billings'){
                $scope.loadbillings();
            } else{
                $scope.errorMessage = "Forecast isn't enabled.";
            }
        }])
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
