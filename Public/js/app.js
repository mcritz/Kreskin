var LoginView = new Vue({
    el: '\#signup',
    data: {
        loginIsActive: false,
        user: {
            name: '',
            email: '',
            password: '',
            authToken: ''
        }
    },
    mounted: function() {
        var self = this;
        self.checkLogin();
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
                window.localStorage.setItem('user_email', this.user.email);
                window.localStorage.setItem('auth_token', response.data.token);
            }).catch(error => {
                console.log('failed login', error);
            });
        },
        checkLogin: function() {
            var storedEmail = window.localStorage.getItem('user_email');
            var storedAuthToken = window.localStorage.getItem('auth_token');
            var storedUserID = window.localStorage.getItem('user_id');
            if (!!storedEmail 
                && !!storedAuthToken
                && !!storedUserID) {
                this.user.authToken = storedAuthToken;
                this.user.email = storedEmail;
                this.user.id = storedId;
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