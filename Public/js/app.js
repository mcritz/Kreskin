var store = {
    debug: true,
    state: {
        user: {
            name: '',
            email: '',
            password: '',
            auth_token: ''
        },
        prediction: {
            title: 'Title',
            premise: 'Premise',
            description: 'Description'
        }
    },
    destroyUser() {
      var self = this;
        let userKeys = Object.keys(this.state.user);
        for (tt = 0; tt < userKeys.length; tt++) {
            let thisKey = userKeys[tt];
            self.state.user.thisKey = '';
        }
        GreetingView.updateGreeting;
    }
}

var NewPrediction = new Vue({
    el: '#newprediction',
    data: {
        prediction: store.state.prediction,
        user: store.state.user
    },
    methods: {
        submitPrediction: function() {
            console.log('submitPrediction', this.prediction);
            axios({
                method: 'post',
                url: '/predictions',
                headers: {
                    Authorization: 'Bearer ' + this.user.auth_token
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
            }).catch(error => {
                console.log('fail: submitPrediction', error);
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
        console.log('greetingview', this.user);
        this.updateGreeting();
    },
    methods: {
        updateGreeting: function() {
            console.log('updateGreeting', this.user);
            var self = this;
            if (!!this.user
                && !!this.user.name) {
                self.greeting = "Welcome, " + this.user.name + "!";
            } else {
                self.greeting = "Hi there!";
            }
        }
    }
});

var AccountView = new Vue({
    el: '#account',
    data: {
        loginIsActive: false,
        store: store,
        user: store.state.user
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
            // this.store.destroyUser();
            axios.post('/logout', {

            }).then(response => {
                console.log('logout', response);
                let sessionStore = window.sessionStorage;
                sessionStore.removeItem('user_name');
                sessionStore.removeItem('user_email');
                sessionStore.removeItem('auth_token');

                let userKeys = Object.keys(this.user);
                for (tt = 0; tt < userKeys.length; tt++) {
                    let thisKey = userKeys[tt];
                    this.user[thisKey] = '';
                }

                GreetingView.updateGreeting();
                this.loginIsActive = true;
            }).catch(error => {
                console.log('logout fail', error);
            });
        },
        signup: function(evt) {
            axios.post('/users', {
                email: this.user.email,
                name: this.user.name,
                password: this.user.password
            }).then(response => {
                console.log('signup', response);
                this.login();
            }).catch(error => {
                console.log('fail', error);
            });
        },
        login: function(evt) {
            console.log('login', this.user);
            axios({
                method: 'post',
                url: '/login',
                auth: {
                    username: this.user.email,
                    password: this.user.password
                }
            }).then(response => {
                console.log('login', response);
                this.loginIsActive = false;
                let sessionStore = window.sessionStorage;
                sessionStore.setItem('user_name', this.user.name);
                sessionStore.setItem('user_email', this.user.email);
                sessionStore.setItem('auth_token', response.data.token);
                this.user.auth_token = response.data.token;
                GreetingView.updateGreeting();
            }).catch(error => {
                console.log('failed login', error);
            });
        },
        checkLogin: function() {
            let sessionStore = window.sessionStorage;
            var storedUserName = sessionStore.getItem('user_name');
            var storedEmail = sessionStore.getItem('user_email');
            var storedAuthToken = sessionStore.getItem('auth_token');
            if (!!storedEmail 
                && !!storedAuthToken
                && !!storedUserName) {
                this.user.name = storedUserName;
                this.user.auth_token = storedAuthToken;
                this.user.email = storedEmail;
                GreetingView.updateGreeting();
            } else {
                this.loginIsActive = true;
            }
        }
    }
});

Vue.component('prediction-comp', {
    props: ['prediction'],
    template: 
        '<div v-model="prediction">\
            <h4>{{ prediction.title }}</h4>\
            <p>{{ prediction.premise }}</p>\
            <p>{{ prediction.description }}</p>\
            <div v-if="isOwner()">\
                <button v-if="prediction.isRevealed == false" v-on:click="reveal">Show</button>\
                <button v-if="prediction.isRevealed == true" v-on:click="hide">Hide</button>\
            </div>\
        </div>',
    methods: {
        isOwner: function() {
            return false;
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
        predictions: []
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
            });
        }
    }
});