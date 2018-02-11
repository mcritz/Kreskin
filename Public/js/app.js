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
            title: 'prediction title',
            premise: 'Premise',
            description: 'Description'
        }
    },
    setMessageAction(newValue) {
        if (this.debug) console.log('setMessageAction triggered with', newValue)
        this.state.message = newValue
    },
    clearMessageAction() {
        if (this.debug) console.log('clearMessageAction triggered')
        this.state.message = ''
    }
}

var NewPrediction = new Vue({
    el: '#newprediction',
    data: {
        prediction: store.state.prediction
    },
    mounted: function() {
        console.log('NewPrediction mounted');
    },
    methods: {
        submitPrediction: function() {
            console.log('submitPrediction', this.prediction);
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
            console.log('updateGreeting', this.user);
            var self = this;
            if (this.user.name) {
                self.greeting = "Welcome, " + this.user.name;
            } else {
                self.greeting = "Hi there!";
            }
        }
    }
});

var LoginView = new Vue({
    el: '#signup',
    data: {
        loginIsActive: false,
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
                let localStore = window.localStorage;
                localStore.setItem('user_name', this.user.name);
                localStore.setItem('user_email', this.user.email);
                localStore.setItem('auth_token', response.data.token);
                this.user.auth_token = response.data.token;
                GreetingView.updateGreeting();
            }).catch(error => {
                console.log('failed login', error);
            });
        },
        checkLogin: function() {
            let localStore = window.localStorage;
            var storedUserName = localStore.getItem('user_name');
            var storedEmail = localStore.getItem('user_email');
            var storedAuthToken = localStore.getItem('auth_token');
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
        var self = this;
        self.fetchData();
    },
    methods: {
        fetchData: function() {
            axios.get('/predictions').then(response => {
                this.predictions = response.data;
            });
        },
        ping: function(param) {
            console.log('clicked');
        },
        update: function(predix) {
            var self = this;
            var token = window.localStorage.getItem('auth_token');
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
        },
        reverseMessage: function () {
            this.message = this.message.split('').reverse().join('')
        }
    }
});