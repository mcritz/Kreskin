Vue.component('prediction-comp', {
    props: ['prediction'],
    template: 
        '<div v-model="prediction">\
            <h4>{{ prediction.title }}</h4>\
            <p>{{ prediction.premise }}</p>\
            <p>{{ prediction.description }}</p>\
            <button v-if="prediction.isRevealed == false" v-on:click="reveal">Show</button>\
            <button v-if="prediction.isRevealed == true" v-on:click="hide">Hide</button>\
        </div>',
    methods: {
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