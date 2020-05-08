(function() {
    angular.module('dashboardApp', ['ngAnimate'])
    .controller('dashboardCtrl', function($scope, $q, $timeout) {
		
    $scope.path = userPath;
                $scope.currentUser = currentViewingUserId;
                $scope.dashboardType = dashboardType;
                $scope.forecastEnabled = forecastEnabled;
                $scope.forecastType = forecastType;
                $scope.cuurentFiscalQtr = currentQuarter;
                $scope.directSubUsers = [];
                $scope.requestInProgress = 0;
                $scope.errorMessage = null;
                $scope.calloutErrorOccured = false;
                $scope.displayFormat = "W";
                $scope.teamForecasts = { isLoading: false, data: [], total: {}, collapsed: false };
                $scope.teamFunnelAch = { isLoading: false, data: [], total: {}, collapsed: false };
                $scope.sourceFunnel = {isLoading: false, data: [],total: {}}
                $scope.funnelChangeWOW = {isLoading: false, data: []}
                $scope.funnelDistWOW = {isLoading: false, data: []}
                $scope.fiscalQtr = firstQuarter;
				$scope.funnelDistFiscalQtr = fiscalQtr;
				$scope.sourceSummary = {isLoading: false, data: [],total: {}}
                $scope.fourQtrSourceSummary = {isLoading: false, data: [],total: {}}
                $scope.promiseDirectSubUsers = function(userId) {
                var deferred = $q.defer();
                var serviceIdentifier = "DirectSubUsersList" + userId;
                $scope.callRemoteServiceWithCache(PerformanceController.GetDirectSubordinateUsers, [userId], serviceIdentifier, function(result) {
                    deferred.resolve({userId: userId, subUsers: result});
                    });
                    return deferred.promise;
                };
                
                
                $scope.getCacheValue = function(key, defaultValue) {
                    if(typeof(Storage)!=="undefined") {
                        key = "SNAPF." + key;
                        var value = sessionStorage.getItem(key);
                        if(value == null) {
                            return defaultValue;
                        }
                        return JSON.parse(value);
                        } else {
                        return defaultValue;
                        }
                    }

                $scope.setCacheValue = function(key, value) {
                    if(typeof(Storage)!=="undefined") {
                        key = "SNAPF." + key;
                        try {
                            return sessionStorage.setItem(key, JSON.stringify(value));
                        } catch(err) {
                            sessionStorage.removeItem(key);
                        }
                    }
                }
                
                $scope.isCalloutSucceeded = function(event) {
                    if(event.status == true) {
                        return true;
                    }
                    else  {
                        if($scope.calloutErrorOccured == false && $scope.userCancel == false)  {
                            $scope.errorMessage = "Error occured. Please try refreshing the page. ";
                            if(event.message) {
                                $scope.errorMessage += "The error message is: " + event.message;
                            }
                        }
                        $scope.calloutErrorOccured = true;
                        return false;
                    }
                };
                
                
                $scope.callRemoteServiceWithCache = function(serviceName, parameters, identifier, callback, config) {
                    $scope.requestInProgress++;
                    var cachedValue = $scope.getCacheValue(identifier, null);
                    if(cachedValue != null) {
                        callback.call($scope, cachedValue);
                    }
                    if(parameters == null) {
                        parameters = [];
                    }
                    var callbackWrap = function(result, event) {
                    
                        $scope.requestInProgress--;
                        if($scope.isCalloutSucceeded(event)) {
                            $scope.setCacheValue(identifier, result);
                            callback.call($scope, result);
                        }
                    };
                    parameters.push(callbackWrap);
                    if(config) {
                        parameters.push(config);
                    }
                    try {
                        serviceName.apply($scope, parameters);
                    } catch(e) {
                        callbackWrap(null, {status: false});
                    }
                };
                
                
             
            
            $scope.loadTeamForecasts = function() {
                for(var i = 0; i < $scope.directSubUsers.length; i++) {
                    $scope.teamForecasts.isLoading = true;
                    var uid = $scope.directSubUsers[i].UserId;
                    var serviceIdentifier = "TeamSummary" + $scope.fiscalQtr + uid;
                    $scope.callRemoteServiceWithCache(PerformanceStatService.GetForecastSummary, [uid, $scope.fiscalQtr, $scope.forecastType], serviceIdentifier, function(result) {
                        var isExisted = false;
                        for(var i = 0; i < $scope.teamForecasts.data.length; i++)  {
                            if($scope.teamForecasts.data[i].UserId == result.UserId) {
                                $scope.teamForecasts.data[i] = angular.copy(result);
                                isExisted = true;
                                break;
                            }
                        }
                        if(!isExisted) {
                            $scope.teamForecasts.data.push(angular.copy(result));
                        }
                        
                        $scope.teamForecasts.total = {};
                        for(var i = 0; i < $scope.teamForecasts.data.length; i++)  {
                            if($scope.currentUser == $scope.teamForecasts.data[i].UserId){
                                $scope.teamForecasts.total = $scope.teamForecasts.data[i];
                                break;
                            }
                        }
                        
                        $scope.teamForecasts.isLoading = false;
                        setTimeout(function(){ $scope.$apply($scope.teamForecasts); });
                    }, { buffer: false, timeout: 60000 });
                }
                
            }

            $scope.loadTeamFunnelAch = function() {
                for(var i = 0; i < $scope.directSubUsers.length; i++) {
                    $scope.teamFunnelAch.isLoading = true;
                    var uid = $scope.directSubUsers[i].UserId;
                    var serviceIdentifier = "TeamFunnelAch" + $scope.fiscalQtr + uid;
                    $scope.callRemoteServiceWithCache(PerformanceStatService.GetFunnelAchievement, [uid, $scope.fiscalQtr, $scope.forecastType], serviceIdentifier, function(result) {
                        var isExisted = false;
                        for(var i = 0; i < $scope.teamFunnelAch.data.length; i++)  {
                            if($scope.teamFunnelAch.data[i].UserId == result.UserId) {
                                $scope.teamFunnelAch.data[i] = angular.copy(result);
                                isExisted = true;
                                break;
                            }
                        }
                        if(!isExisted) {
                            $scope.teamFunnelAch.data.push(angular.copy(result));
                        }
                        
                        $scope.teamFunnelAch.total = {};
                        for(var i = 0; i < $scope.teamFunnelAch.data.length; i++)  {
                            if($scope.currentUser == $scope.teamFunnelAch.data[i].UserId){
                                $scope.teamFunnelAch.total = $scope.teamFunnelAch.data[i];
                                break;
                            }
                        }
                        
                        $scope.teamFunnelAch.isLoading = false;
                        setTimeout(function(){ $scope.$apply($scope.teamFunnelAch); });
                    }, { buffer: false, timeout: 60000 });
                }
                
            }
            
            $scope.loadSourceFunnel = function(){
                $scope.sourceFunnel.isLoading = true;
                var serviceIdentifier = "SourceFunnel" +$scope.currentUser;
                    $scope.callRemoteServiceWithCache(PerformanceStatService.LoadSourceFunnelData, [$scope.forecastType, $scope.currentUser], serviceIdentifier, function(result) {
                        var isExisted = false;
                        if($scope.sourceFunnel.data.length == 0){
                            for(var i = 0; i < result.length; i++)  {
                                $scope.sourceFunnel.data.push(result[i])
                            }
                        }else{
                            $scope.sourceFunnel.data = [];
                            for(var i = 0; i < result.length; i++)  {
                                $scope.sourceFunnel.data.push(result[i])
                            }   
                        }
						$scope.sourceFunnel.total = {};
						
						for(var i = 0; i < $scope.sourceFunnel.data.length; i++) {
                            var member = $scope.sourceFunnel.data[i];
                            var total = $scope.sourceFunnel.total;
							
							
                            !total.closedwonQTD? total.closedwonQTD = member.closedwonQTD : total.closedwonQTD += member.closedwonQTD || 0;
                            !total.totalClosedWon ? total.totalClosedWon = member.totalClosedWon : total.totalClosedWon += member.totalClosedWon || 0;
                            !total.closedwonWOW ? total.closedwonWOW = member.closedwonWOW : total.closedwonWOW += member.closedwonWOW || 0;
                            !total.totalClosedWonWOW ? total.totalClosedWonWOW = member.totalClosedWonWOW : total.totalClosedWonWOW += member.totalClosedWonWOW || 0;
                            !total.commitQTD ? total.commitQTD = member.commitQTD : total.commitQTD += member.commitQTD || 0;
                            !total.commitWOW ? total.commitWOW = member.commitWOW : total.commitWOW += member.commitWOW || 0;
                            !total.totalCommit ? total.totalCommit = member.totalCommit : total.totalCommit += member.totalCommit || 0;
                            !total.totalCommitWOW ? total.totalCommitWOW = member.totalCommitWOW : total.totalCommitWOW += member.totalCommitWOW || 0;
							
                            !total.upsideQTD ? total.upsideQTD = member.upsideQTD : total.upsideQTD += member.upsideQTD || 0;
                            !total.upsideWOW ? total.upsideWOW = member.upsideWOW : total.upsideWOW += member.upsideWOW || 0;
                            !total.totalUpside ? total.totalUpside = member.totalUpside : total.totalUpside += member.totalUpside || 0;
                            !total.totalUpsideWOW ? total.totalUpsideWOW = member.totalUpsideWOW : total.totalUpsideWOW += member.totalUpsideWOW || 0;
                            
                        }
                        $scope.sourceFunnel.isLoading = false;
                        setTimeout(function(){ $scope.$apply($scope.sourceFunnel); });
                    }, { buffer: false, timeout: 60000 });
            }
            
            $scope.loadSourceSummary = function(){
                $scope.sourceSummary.isLoading = true;
                var serviceIdentifier = "sourceSummary" +$scope.currentUser;
                    $scope.callRemoteServiceWithCache(PerformanceStatService.GetSourceSummary, [$scope.currentUser, $scope.forecastType], serviceIdentifier, function(result) {
                        var isExisted = false;
                        if($scope.sourceSummary.data.length == 0){
                            for(var i = 0; i < result.length; i++)  {
                                $scope.sourceSummary.data.push(result[i])
                            }
                        }else{
                            $scope.sourceSummary.data = [];
                            for(var i = 0; i < result.length; i++)  {
                                $scope.sourceSummary.data.push(result[i])
                            }   
                        }
                        
                        $scope.sourceSummary.total = {};
                        
                        for(var i = 0; i < $scope.sourceSummary.data.length; i++) {
                            var member = $scope.sourceSummary.data[i];
                            var total = $scope.sourceSummary.total;
                            !total.firstQtrPipeline? total.firstQtrPipeline = member.firstQtrPipeline : total.firstQtrPipeline += member.firstQtrPipeline || 0;
                            !total.firstQtrQuota ? total.firstQtrQuota = member.firstQtrQuota : total.firstQtrQuota  || 0;
                            !total.secondQtrPipeline ? total.secondQtrPipeline = member.secondQtrPipeline : total.secondQtrPipeline += member.secondQtrPipeline || 0;
                            !total.secondQtrQuota ? total.secondQtrQuota = member.secondQtrQuota : total.secondQtrQuota  || 0;
                            !total.thirdQtrPipeline ? total.thirdQtrPipeline = member.thirdQtrPipeline : total.thirdQtrPipeline += member.thirdQtrPipeline || 0;
                            !total.thirdQtrQuota ? total.thirdQtrQuota = member.thirdQtrQuota : total.thirdQtrQuota  || 0;
                            !total.fourthQtrPipeline ? total.fourthQtrPipeline = member.fourthQtrPipeline : total.fourthQtrPipeline += member.fourthQtrPipeline || 0;
                            !total.fourthQtrQuota ? total.fourthQtrQuota = member.fourthQtrQuota : total.fourthQtrQuota  || 0;
                            
                            
                        }
                                
                        $scope.sourceSummary.isLoading = false;
                        setTimeout(function(){ $scope.$apply($scope.sourceSummary); });
                    }, { buffer: false, timeout: 60000 });
            }
            
            $scope.loadFourQtrSourceSummary = function(){
                $scope.fourQtrSourceSummary.isLoading = true;
                var serviceIdentifier = "fourQtrSourceSummary" +$scope.currentUser;
                    $scope.callRemoteServiceWithCache(PerformanceStatService.getFourQtrSourceWOW, [$scope.forecastType, $scope.currentUser ], serviceIdentifier, function(result) {
                        var isExisted = false;
                        if($scope.fourQtrSourceSummary.data.length == 0){
                            for(var i = 0; i < result.length; i++)  {
                                $scope.fourQtrSourceSummary.data.push(result[i])
                            }
                        }else{
                            $scope.fourQtrSourceSummary.data = [];
                            for(var i = 0; i < result.length; i++)  {
                                $scope.fourQtrSourceSummary.data.push(result[i])
                            }   
                        }    
                        
                        $scope.fourQtrSourceSummary.total = {};
                        
                        for(var i = 0; i < $scope.fourQtrSourceSummary.data.length; i++) {
                            var member = $scope.fourQtrSourceSummary.data[i];
                            var total = $scope.fourQtrSourceSummary.total;
                            !total.thisWeek? total.thisWeek = member.thisWeek : total.thisWeek += member.thisWeek || 0;
                            !total.lastWeek ? total.lastWeek = member.lastWeek : total.lastWeek += member.lastWeek || 0;
                            !total.priorWeek ? total.priorWeek = member.priorWeek : total.priorWeek += member.priorWeek || 0;
                        }
                            
                        
                        $scope.fourQtrSourceSummary.isLoading = false;
                        setTimeout(function(){ $scope.$apply($scope.fourQtrSourceSummary); });
                    }, { buffer: false, timeout: 60000 });
            }
            
            
            $scope.loadFunnelChangeWOW = function(){
                $scope.funnelChangeWOW.isLoading = true;
                var serviceIdentifier = "funnelChangeWOW" +$scope.currentUser;
                    $scope.callRemoteServiceWithCache(PerformanceStatService.LoadFunnelWOWChange, [$scope.forecastType, $scope.currentUser], serviceIdentifier, function(result) {
                        var isExisted = false;
                        if($scope.funnelChangeWOW.data.length == 0){
                            for(var i = 0; i < result.length; i++)  {
                                $scope.funnelChangeWOW.data.push(result[i])
                            }
                        }else{
                            $scope.funnelChangeWOW.data = [];
                            for(var i = 0; i < result.length; i++)  {
                                $scope.funnelChangeWOW.data.push(result[i])
                            }   
                        }

                        $scope.funnelChangeWOW.isLoading = false;
                        setTimeout(function(){ $scope.$apply($scope.funnelChangeWOW); });
                    }, { buffer: false, timeout: 60000 });
            }
            
            
            $scope.commaFormatted = function(amount) {
                var delimiter = ","; // replace comma if desired
                var a = amount.split('.',2)
                var d = (a.length > 1)?a[1]:'';
                var i = parseInt(a[0]);
                if(isNaN(i)) { return ''; }
                var minus = '';
                if(i < 0) { minus = '-'; }
                i = Math.abs(i);
                var n = new String(i);
                var a = [];
                while(n.length > 3)
                {
                    var nn = n.substr(n.length-3);
                    a.unshift(nn);
                    n = n.substr(0,n.length-3);
                }
                if(n.length > 0) { a.unshift(n); }
                n = a.join(delimiter);
                if(d.length < 1) { amount = n; }
                else { amount = n + '.' + d; }
                amount = minus + amount;
                return amount;
            };
            
            $scope.formatDecimal = function(value, format) {
                if(value == null) {
                    return null;
                } else if(value == 0) {
                    return "0";
                } else if(format == "E") {
                    //exact value, 2 decimals
                    return "$" + $scope.commaFormatted(((value)/1).toFixed(2));
                } else if(format == "W") {
                    //whole values, 0 decimals
                    return "$" + $scope.commaFormatted(((value)/1).toFixed(0));
                } else if(format == "K") {
                    //thousand, with 2 decimals
                    var result = "$" + $scope.commaFormatted(((value)/1000).toFixed(2)) + "K";
                    return result.replace(".00K", "K");
                } else if(format == "M") {
                    //million, with 2 decimals
                    var result = "$" + $scope.commaFormatted(((value)/1000/1000).toFixed(2)) + "M";
                    return result.replace(".00M", "M");
                }
                return "";
            };

            $scope.formatPercentage = function(value) {
                if(isNaN(value)) {
                    return "";
                }
                var result = value.toFixed(1) + "%";
                return result.replace(".0%", "%");
            };

            $scope.formatCoverage = function(value) {
                if(isNaN(value)) {
                    return "";
                }
                var result = value.toFixed(1) + "x";
                return result.replace(".0x", "x");
            };
            
            $scope.loadFunnelDistWOW = function(){
                $scope.funnelDistWOW.isLoading = true;
                var serviceIdentifier = "funnelDistWOW" +$scope.currentUser;
                    $scope.callRemoteServiceWithCache(PerformanceStatService.loadWOWFunnelDistribution, [$scope.forecastType, $scope.currentUser, $scope.funnelDistFiscalQtr], serviceIdentifier, function(result) {
                        var isExisted = false;
                        if($scope.funnelDistWOW.data.length == 0){
                            for(var i = 0; i < result.length; i++)  {
                                $scope.funnelDistWOW.data.push(result[i])
                            }
                        }else{
                            $scope.funnelDistWOW.data = [];
                            for(var i = 0; i < result.length; i++)  {
                                $scope.funnelDistWOW.data.push(result[i])
                            }   
                        }    
                        $scope.funnelDistWOW.isLoading = false;
                        setTimeout(function(){ $scope.$apply($scope.funnelDistWOW); });
                    }, { buffer: false, timeout: 60000 });
            }
            
            $scope.loadAll = function() {
                var directsubUserPromise = $scope.promiseDirectSubUsers($scope.currentUser);
                directsubUserPromise.then(function(subUserResult) {
                    $scope.directSubUsers = subUserResult.subUsers;
                    $scope.loadTeamForecasts();
                    $scope.loadTeamFunnelAch();
                });
                $scope.loadSourceFunnel();
                $scope.loadFunnelChangeWOW();
                $scope.loadFunnelDistWOW();
                $scope.loadSourceSummary();
                $scope.loadFourQtrSourceSummary();
                
            }
            
            
            
                
                if($scope.forecastEnabled) {
                    $scope.loadAll();
                }
                else {
                    $scope.errorMessage = "Dashboard isn't enabled.";
                }
			});
})();