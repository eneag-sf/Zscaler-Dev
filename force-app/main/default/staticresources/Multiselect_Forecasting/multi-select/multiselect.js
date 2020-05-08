(function() {
	angular.module('multiselectmodule', [])

  //from bootstrap-ui typeahead parser
  .factory('optionParser', ['$parse', function ($parse) {

    var TYPEAHEAD_REGEXP = /^\s*(.*?)(?:\s+as\s+(.*?))?\s+for\s+(?:([\$\w][\$\w\d]*))\s+in\s+(.*)$/;

    return {
      parse: function (input) {

        var match = input.match(TYPEAHEAD_REGEXP), modelMapper, viewMapper, source;
        if (!match) {
          throw new Error(
            "Expected typeahead specification in form of '_modelValue_ (as _label_)? for _item_ in _collection_'" +
              " but got '" + input + "'.");
        }

        return {
          itemName: match[3],
          source: $parse(match[4]),
          viewMapper: $parse(match[2] || match[1]),
          modelMapper: $parse(match[1])
        };
      }
    };
  }])

  .directive('multiselect', ['$parse', '$document', '$compile', 'optionParser',

    function ($parse, $document, $compile, optionParser) {
      return {
        restrict: 'E',
        require: 'ngModel',
        link: function (originalScope, element, attrs, modelCtrl) {

          var exp = attrs.options,
            parsedResult = optionParser.parse(exp),
            isMultiple = attrs.multiple ? true : false,
            required = false,
            scope = originalScope.$new(),
            changeHandler = attrs.change || angular.noop;

          scope.items = [];
          scope.header = 'All';
          scope.currentid = attrs.id;
          scope.currentpicklist = attrs.picklistsrc;
          scope.multiple = isMultiple;
          scope.disabled = false;

          originalScope.$on('$destroy', function () {
            scope.$destroy();
          });
		  
		  originalScope.$on(scope.currentid+'_clearall', function (event) {
            scope.uncheckAll();
          });

          var popUpEl = angular.element('<multiselect-popup></multiselect-popup>');

          //required validator
          if (attrs.required || attrs.ngRequired) {
            required = true;
          }
          attrs.$observe('required', function(newVal) {
            required = newVal;
          });

          //watch disabled state
          scope.$watch(function () {
            return $parse(attrs.disabled)(originalScope);
          }, function (newVal) {
            scope.disabled = newVal;
          });

          //watch single/multiple state for dynamically change single to multiple
          scope.$watch(function () {
            return $parse(attrs.multiple)(originalScope);
          }, function (newVal) {
            isMultiple = newVal || false;
          });

          //watch option changes for options that are populated dynamically
          scope.$watch(function () {
            return parsedResult.source(originalScope);
          }, function (newVal) {
            if (angular.isDefined(newVal))
              parseModel();
          });

          //watch model change
          scope.$watch(function () {
            return modelCtrl.$modelValue;
          }, function (newVal, oldVal) {
            //when directive initialize, newVal usually undefined. Also, if model value already set in the controller
            //for preselected list then we need to mark checked in our scope item. But we don't want to do this every time
            //model changes. We need to do this only if it is done outside directive scope, from controller, for example.
            if (angular.isDefined(newVal)) {
              markChecked(newVal);
              scope.$eval(changeHandler);
            }
            getHeaderText();
            modelCtrl.$setValidity('required', scope.valid());
          }, true);

          function parseModel() {
            scope.items.length = 0;
            var model = parsedResult.source(originalScope);
            for (var i = 0; i < model.length; i++) {
              var local = {};
              local[parsedResult.itemName] = model[i];
              scope.items.push({
                label: parsedResult.viewMapper(local),
                model: model[i],
                checked: false
              });
            }
          }

          parseModel();

          element.append($compile(popUpEl)(scope));

          function getHeaderText() {
            if (!modelCtrl.$modelValue || !modelCtrl.$modelValue.length) return scope.header = 'All';
            if (isMultiple) {
              value = '';
              angular.forEach(scope.items, function (item) {
                if (item.checked) value += (item.model) + ',';
              })
              scope.header = value.slice(0, -1);
            } else {
              var local = {};
              local[parsedResult.itemName] = modelCtrl.$modelValue;
              scope.header = parsedResult.viewMapper(local);
            }
          }

          scope.valid = function validModel() {
            if(!required) return true;
            var value = modelCtrl.$modelValue;
            return (angular.isArray(value) && value.length > 0) || (!angular.isArray(value) && value != null);
          };
		  
		  scope.clearselection = function clearsel(){
			if(scope.currentid == 'closingweek'){
				scope.$emit('clearselection', 'closingmonth');
			}else if(scope.currentid == 'closingmonth'){
				scope.$emit('clearselection', 'closingweek');
			}
			if(scope.currentid == 'contractedmonth'){
				scope.$emit('clearselection', 'contractedweek');
			}else if(scope.currentid == 'contractedweek'){
				scope.$emit('clearselection', 'contractedmonth');
			}
		  }

          function selectSingle(item) {
            if (item.checked) {
              scope.uncheckAll();
            } else {
              scope.uncheckAll();
              item.checked = !item.checked;
            }
            setModelValue(false);
          }

          function selectMultiple(item) {
            item.checked = !item.checked;
            setModelValue(true);
          }

          function setModelValue(isMultiple) {
            var value;

            if (isMultiple) {
              value = [];
              angular.forEach(scope.items, function (item) {
                if (item.checked) value.push(item.model);
              })
            } else {
              angular.forEach(scope.items, function (item) {
                if (item.checked) {
                  value = item.model;
                  return false;
                }
              })
            }
            modelCtrl.$setViewValue(value);
          }

          function markChecked(newVal) {
            if (!angular.isArray(newVal)) {
              angular.forEach(scope.items, function (item) {
                if (angular.equals(item.model, newVal)) {
                  item.checked = true;
                  return false;
                }
              });
            } else {
              angular.forEach(newVal, function (i) {
                angular.forEach(scope.items, function (item) {
                  if (angular.equals(item.model, i)) {
                    item.checked = true;
                  }
                });
              });
            }
          }

          scope.checkAll = function () {
            if (!isMultiple) return;
            angular.forEach(scope.items, function (item) {
				if(item.label.toString().indexOf('***') == -1){
					item.checked = true;
				}
            });
            setModelValue(true);
          };
		  
		  scope.processoppty = function () {
            calloppty(currentpicklist);
          };

          scope.uncheckAll = function () {
            angular.forEach(scope.items, function (item) {
              item.checked = false;
            });
            setModelValue(true);
          };

          scope.select = function (item) {
            if (isMultiple === false) {
              selectSingle(item);
              scope.toggleSelect(currentpicklist);
            } else {
              selectMultiple(item);
            }
          }
        }
      };
    }])

  .directive('multiselectPopup', ['$document', function ($document) {
    return {
      restrict: 'E',
      scope: false,
      replace: true,
      templateUrl: RESOURCE_ROOT + '/multi-select/multiselect.tmpl.html',
      link: function (scope, element, attrs) {

        scope.isVisible = false;

        scope.toggleSelect = function (currentpicklist) {
          if (element.hasClass('open')) {
            element.removeClass('open');
            $document.unbind('click',clickHandler);
          } else {
            element.addClass('open');
            scope.focus();
            $document.bind('click', clickHandler);
          }
        };

        function clickHandler(event) {
          if (elementMatchesAnyInArray(event.target, element.find(event.target.tagName)))
            return;
		  scope.clearselection();
          element.removeClass('open');
		  
		  calloppty(scope.currentpicklist);
          $document.unbind('click', clickHandler);
          scope.$digest();
        }
        
        scope.focus = function focus(){
          var searchBox = element.find('input')[0];
          searchBox.focus(); 
        }

        var elementMatchesAnyInArray = function (element, elementArray) {
          for (var i = 0; i < elementArray.length; i++)
            if (element == elementArray[i])
              return true;
          return false;
        }
      }
    }
  }]);
})();