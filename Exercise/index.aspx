<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="index.aspx.cs" Inherits="Exercise.index" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Home</title>
    <%-- #bootstrap include --%>
    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
    <%--endregion--%>

    <%-- angularjs & route --%>
    <script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.7.7/angular.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.7.7/angular-route.min.js"></script>

</head>
<body ng-app="gitApp" ng-cloak>
    <form id="form1" runat="server">
        <div class="container" style="margin: 5%">
            <div ng-view ng-controller="myCtrl">
            </div>
        </div>
    </form>
</body>
<script>
    var app = angular.module("gitApp", ["ngRoute"]);
    app.config(function ($routeProvider) {
        $routeProvider
            .when("/", {
                disableCache: true,
                templateUrl: "fragment/account.html?v=1"
            })
            .when("/user/:user", {
                disableCache: true,
                templateUrl: "fragment/repository.html?v=1"
            })
            .when("/repository/:user/:repository", {
                disableCache: true,
                templateUrl: "fragment/file.html?v=1"
            })
    });
    app.controller('myCtrl', function ($scope, $http, $location, $routeParams, $route) {
        $scope.itemsPerPage = 10;
        $scope.currentPage = 1;
        $scope.stack = [];
        $scope.before = "";
        $scope.$on('$routeChangeSuccess', function (event, current) {
            $scope.currentPage = 1;
            if (current.$$route.templateUrl.replace("?v=1", "") == "fragment/repository.html") {
                $scope.load_repo(current.params.user);
            }
            if (current.$$route.templateUrl.replace("?v=1", "") == "fragment/file.html") {
                $scope.repository_now = current.params.repository;
                $scope.load_file(current.params.user + "/" + current.params.repository);
            }
        });
        $scope.search_by_change = function (text) {
            $scope.loading = true;
            $http.get("https://api.github.com/search/users?q=" + text.git_search_user)
                .then(function (response) {
                    $scope.loading = false;
                    $scope.account_list = response.data.items;
                });
        }
        $scope.load_repo = function (user) {
            $scope.loading = true;
            $http.get("https://api.github.com/users/" + user + "/repos")
                .then(function (response) {
                    $scope.loading = false;
                    $scope.repo_list = response.data;
                });

        }
        $scope.load_file = function (repo) {
            $scope.loading = true;
            $scope.before = "https://api.github.com/repos/" + repo + "/contents/";
            $http.get("https://api.github.com/repos/" + repo + "/contents/")
                .then(function (response) {
                    $scope.loading = false;
                    $scope.file_list = response.data;
                });
        }
        $scope.deeppath = function (link, infolder) {
            if (infolder) {
                url = link;
                $scope.stack.push($scope.before);
                $scope.before = link;
            }
            else {
                url = $scope.stack.pop();
            }
            console.log($scope.stack)
            $scope.loading = true;
            $http.get(url)
                .then(function (response) {
                    $scope.loading = false;
                    $scope.file_list = response.data;
                });
        }
        $scope.to_repo = function (user) {
            $location.path('/user/' + user);
        }
        $scope.to_file = function (path) {
            $location.path('/repository/' + path);
        }
        $scope.round = function (float) {
            if (float == 0) float = 1;
            return Math.ceil(float);
        }
    });
</script>
</html>
