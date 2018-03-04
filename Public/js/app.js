const CONST = {
    USER_KEY : 'user_'
}

var store = {
    debug: true,
    state: {
        session: {
            isActive: false
        },
        user: {
            name: '',
            email: '',
            password: '',
            auth_token: '',
            id: null
        },
        prediction: {
            title: '',
            premise: '',
            description: ''
        }
    },
    saveUser: function() {
        let sessionStore = window.sessionStorage;
        let userKeys = Object.keys(this.state.user);
        for (var uu = userKeys.length - 1; uu >= 0; uu--) {
            var keyToSave = userKeys[uu];
            var thisValue = this.state.user[keyToSave];
            var nameSpacedKey = CONST.USER_KEY + keyToSave;
            sessionStore.setItem(nameSpacedKey, thisValue);
        }
        return this.state.user;
    },
    loadUser: function() {
        let sessionStore = window.sessionStorage;
        let userKeys = Object.keys(this.state.user);
        console.log('LOAD USER\n', userKeys);
        for (var uk = userKeys.length - 1; uk >= 0; uk--) {
            var savedUserKey = CONST.USER_KEY + userKeys[uk];
            var loadedUserValue = sessionStore.getItem(savedUserKey);
            var thisUserKey = userKeys[uk];
            this.state.user[thisUserKey] = loadedUserValue;
        }
        return this.state.user;
    },
    updateUser: function(newUser) {
        if (this.debug) {
            console.log('setting user old:', this.state.user, '\nNew: ', newUser);
        }

        let userKeys = Object.keys(newUser);
        for (var keyCount = userKeys.length - 1; keyCount >= 0; keyCount--) {
            let thisKey = userKeys[keyCount];
            this.state.user[thisKey] = newUser[thisKey];
        }

        
        GreetingView.updateGreeting();

        return this.state.user;
    },
    destroyUser: function() {
        let self = this;
        let userKeys = Object.keys(self.state.user);
        for (tt = 0; tt < userKeys.length; tt++) {
            let thisKey = userKeys[tt];
            self.state.user[thisKey] = null;
        }
        GreetingView.updateGreeting();
        return this.saveUser();
    }
}

var NewPrediction = new Vue({
    el: '#newprediction',
    data: {
        prediction: store.state.prediction,
        sharedState: store.state
    },
    methods: {
        submitPrediction: function() {
            console.log('submitPrediction', this.prediction);
            axios({
                method: 'post',
                url: '/predictions',
                headers: {
                    Authorization: 'Bearer ' + this.sharedState.user.auth_token
                }, 
                data: {
                    title: this.prediction.title,
                    premise: this.prediction.premise,
                    description: this.prediction.description
                }
            }).then(response => {
                console.log('submitPrediction', response);
                this.prediction = {
                    title : '',
                    premise: '',
                    description: ''
                };
                PredictionsView.fetchData();
                NotificationsView.notifications.push({
                    message: 'Success: Prediction created',
                    type: 'success'
                });
            }).catch(error => {
                console.log('fail: submitPrediction', error);
                NotificationsView.notifications.push({
                    message: 'Error: Prediction failed',
                    type: 'error'
                });
            });
        }
    }
});

var GreetingView = new Vue({
    el: '#greeting',
    data: {
        greeting: 'Welcome!',
        user: store.state.user
    },
    mounted: function() {
        this.updateGreeting();
    },
    methods: {
        updateGreeting: function() {
            if (!!this.user
                && !!this.user.name) {
                this.greeting = "Welcome, " + this.user.name + "!";
            } else {
                this.greeting = "Hi there!";
            }
        }
    }
});

var AccountView = new Vue({
    el: '#account',
    data: {
        sharedState: store.state,
        session: store.state.session
    },
    mounted: function() {
        this.checkLogin();
    },
    methods: {
        ping: function(evt) {
            console.log('clicked');
            console.log('name', this.user.name);
            console.log('email', this.user.email);
            console.log('password', this.user.password);
        },
        logout: function(evt) {
            axios.post('/logout', {

            }).then(response => {
                console.log('logout', response);

                store.destroyUser();
                window.sessionStorage.clear();

                this.session.isActive = false;

                GreetingView.updateGreeting();

                NotificationsView.notifications.push({
                    message: 'Success: Logged out',
                    type: 'success'
                });
            }).catch(error => {
                NotificationsView.notifications.push({
                    message: 'Error: Logout failed',
                    type: 'error'
                });
                console.log('logout fail', error);
            });
        },
        signup: function(evt) {
            axios.post('/users', {
                email: this.user.email,
                name: this.user.name,
                password: this.user.password
            }).then(response => {
                this.login();
            }).catch(error => {
                NotificationsView.notifications.push({
                    message: error.response.data.reason,
                    type: 'error'
                });
            });
        },
        login: function(evt) {
            var self = this;
            console.log('sending login', this.sharedState.user);
            axios({
                method: 'post',
                url: '/login',
                auth: {
                    username: this.sharedState.user.email,
                    password: this.sharedState.user.password
                }
            }).then(response => {
                console.log('login', response);
                var tempUser = response.data.user;

                tempUser.auth_token = response.data.token;

                store.updateUser(tempUser);
                store.saveUser();

                var sessionStore = window.sessionStorage;
                sessionStore.setItem('auth_token', response.data.token);
                self.session.isActive = true;

                GreetingView.updateGreeting();

                NotificationsView.notifications.push({
                    message: 'Login success',
                    type: 'success'
                });
            }).catch(error => {
                self.session.isActive = false;

                NotificationsView.notifications.push({
                    message: error.response.data.reason,
                    type: "error"
                });
                console.log('failed login', error);
            });
        },
        checkLogin: function() {
            var storedUser = store.loadUser();
            if (!!storedUser) {
                console.log('checkLogin pass');
                this.user = storedUser;

                GreetingView.updateGreeting();

                this.session.isActive = true;
            } else {
                console.log('checkLogin fail');
                this.session.isActive = false;
            }
        }
    }
});

Vue.component('prediction-comp', {
    props: [
        'prediction',
        'user'
    ],
    template: 
        '<div class="col-sm-12 col-md-6 col-lg-4 col-xl-3" v-model="prediction">\
            <h4>{{ prediction.title }}</h4>\
            <p>{{ prediction.premise }}</p>\
            <p>{{ prediction.description }}</p>\
            <div v-if="isOwner()">\
                <button v-if="prediction.isRevealed == false" v-on:click="reveal" class="btn btn-sm">Show</button>\
                <button v-if="prediction.isRevealed == true" v-on:click="hide" class="btn btn-sm">Hide</button>\
            </div>\
        </div>',
    methods: {
        isOwner: function() {
            return this.user.id == this.prediction.userId;
        },
        reveal: function(evt) {
            this.prediction.title = this.prediction.title + " (Updating)";
            this.prediction.isRevealed = true;
            this.$emit('reveal');
        },
        hide: function(evt) {
            this.prediction.title = this.prediction.title + " (Updating)";
            this.prediction.isRevealed = false;
            this.$emit('reveal');
        }
    }
});

var PredictionsView = new Vue({
    el: '#predictions',
    data: {
        predictions: [],
        user: store.state.user
    },
    mounted: function () {
        this.fetchData();
    },
    methods: {
        fetchData: function() {
            axios.get('/predictions').then(response => {
                this.predictions = response.data;
            });
        },
        update: function(predix) {
            var self = this;
            var token = window.sessionStorage.getItem('auth_token');
            axios.put('/predictions/' + predix.id,
            {
                isRevealed: predix.isRevealed
            },
            {
                headers: {
                    'Authorization' : 'Bearer ' + token
                }
            })
            .then(function (response) {
                self.fetchData();
            })
            .catch(function (error) {
                self.fetchData();

                var reason = 'Error: Couldn’t update notification. ';
                NotificationsView.notifications.push({
                    message: reason,
                    type: 'error'
                });
            });
        }
    }
});

const NotificationsView = new Vue({
    el: '#notifications',
    data: {
        notifications: []
    },
    mounted: function () {
    },
    methods: {
        notifications: function(options) {
            console.log('addNotification', options);
            var message,
                kind, 
                oid = this.notifications.length;
            if (!!options.message) {
                messages = options.message;
            }
            if (!!options.kind) {
                kind = options.kind;
            }
            this.notifications.push({
                id: oid,
                kind: kind,
                message: message
            });
        }
    },
    watch: {
        // todo: something about id
        // notifications: function(thing) {
        //     thing.id = notifications[notifications.length].id++
        // }
    }
});

Vue.component('notification-comp', {
    props: ['notice'],
    template:
        '<div class="alert" role="alert" v-model="notice">\
            {{ notice.message }}\
            <button type="button" class="close" aria-label="Close" v-on:click="handleClose">\
                <span aria-hidden="true">&times;</span>\
            </button>\
        </div>',
    methods: {
        handleClose: function(notice) {
            this.$emit('dismiss');
        }
    }
});