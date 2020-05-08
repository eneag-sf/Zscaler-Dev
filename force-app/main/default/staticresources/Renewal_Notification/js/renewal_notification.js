(function() {
    angular.module('renewalApp', ['ngAnimate','multiselectmodule'])
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
        .controller('renewalCtrl', ['$scope', '$q', '$timeout', '$window', 'getUserLevelsFilter', function($scope, $q, $timeout, $window, getUserLevelsFilter) {
			$scope.name = 'World';
			$scope.selectedTab = selectedTab;
			
			$scope.dealbandvals = ['< $25K', '$25K - $50K', '$50K - $100K','$100K - $250K', '$250K - $1M', '> $1M'];
			$scope.selecteddealbandvals = [];
			
			$scope.sendnotification = ['Yes', 'No'];
			$scope.selectedsendnotification = [];
			
			$scope.FCvals = ['Omitted', 'Pipeline', 'Most Likely','Best Case','Commit','Closed'];
			$scope.selectedFCvals = [];
			
			$scope.dayspastduevals = ['1-10','11-20','21-30','30+'];
			$scope.selecteddayspastduevals = [];
			
			$scope.noOfExtensionvalsset = NumberofExtensionsSet;
			$scope.noOfExtensionvals = [];
			$scope.selectednoOfExtensionvals = [];
			
			$scope.selectedgeovals = [];
			$scope.selectedrepvals = [];
			
			$scope.loadOpportunityListing = function() {
                var request = {
					SelectedTab: selectedTab,
                    DealValue: $scope.selecteddealbandvals,
                    SendNotif: $scope.selectedsendnotification,
                    FCValue: $scope.selectedFCvals,
                    DaysPastDue: $scope.selecteddayspastduevals,
                    NumExtension: $scope.selectednoOfExtensionvals,
                    RepValue: $scope.selectedrepvals
                };
                filteroppty(JSON.stringify(request));
            }
            
			
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
			
			
			$scope.showgeorepfilter = showGEOfilter;
			$scope.geoandrepmap = geoandrepmap;
			$scope.geovals = [];
			$scope.repvals = [];
            

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

			
			$scope.loadgeovals = function() {
				$scope.geovals = [];
				var georegvals = $scope.geoandrepmap;
				for (val in georegvals) {
					if(val != 'All'){
						$scope.geovals.push(val);
					}
				}
			}
			
			/*$scope.loaddayspastduevals = function() {
				$scope.dayspastduevals = [];
				
				angular.forEach(DaysPastDueSet, function(test) { $scope.dayspastduevals.push(test); });
			}*/
			
			
			$scope.loadnoOfExtensionvals = function() {
				$scope.noOfExtensionvals = [];
				angular.forEach(NumberofExtensionsSet, function(test) { $scope.noOfExtensionvals.push(test); });
			}
			
			$scope.loadregvals = function(geoval) {
				$scope.repvals = [];
				var georegvals = $scope.geoandrepmap;
				if(geoval != undefined && geoval != null && geoval != ''){
					for(var i=0; i <georegvals[geoval].length; i++){
						if(georegvals[geoval][i] != 'All'){
							$scope.repvals.push(georegvals[geoval][i]);
						}
					}
				}
			}
			
			$scope.loadregvalsmulti = function() {
				
				var georegvals = $scope.geoandrepmap;
				if($scope.selectedgeovals != undefined && $scope.selectedgeovals != null && $scope.selectedgeovals.length > 0){
					$scope.repvals = [];
					for(var k=0; k <$scope.selectedgeovals.length; k++){
						for(var i=0; i <georegvals[$scope.selectedgeovals[k]].length; i++){
							if(georegvals[$scope.selectedgeovals[k]][i] != 'All'){
								$scope.repvals.push(georegvals[$scope.selectedgeovals[k]][i]);
							}
						}
					}
				}else if($scope.selectedgeovals.length == 0){
					$scope.loadregvals('All');
				}
			}

            $scope.openErrorNotify = function(title, messages) {
                var content = $scope.oppListV2.generatesErrorMeesgaeNotify(messages);
                $scope.oppListV2.errors = messages;
                $window.FpDialogBox.openWithContent('oppList2ErrorNotify', content);
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
                    levelList.push('Director');
                }
                if (level == 'Exec' || level == 'VP' || level == 'Director') {
                    levelList.push('Manager');
                }
                if (level == 'Exec' || level == 'VP' || level == 'Director' || level == 'Manager') {
                    levelList.push('Rep');
                }
                return levelList;
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
