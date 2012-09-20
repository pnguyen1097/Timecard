_.templateSettings = {
     evaluate : /\{\[([\s\S]+?)\]\}/g,
     interpolate : /\{\{([\s\S]+?)\}\}/g
};

var Timecard = (function() {

    var Models = (function() {

        var Entry = Backbone.Model.extend({
            url: function() {
                if (this.id != undefined) {
                    return this.collection.baseURL + "/" + this.id;
                } else {
                    return this.collection.baseURL;
                }
            },
            initialize: function() {
                this.selected = false;
            },
            totalHour: function() {
                return moment(this.get(time_out)).diff(moment(diff.get(time_in)));
            },
            templateData: function() {
                var json = this.toJSON();
                var data = {};
                data['date'] = moment(json.time_in).format("MMM DD");
                data['time_in'] = moment(json.time_in).format("h:mma");
                data['time_out'] = moment(json.time_out).format("h:mma");
                data['comment'] = json.comment; 
                data['total'] = Math.round((moment(json.time_out).diff(moment(json.time_in)) / 1000 / 60 / 60) * 10) / 10;
                if (data['total'] > 1) {
                    data['totalUnit'] = 'hrs';
                } else {
                    data['totalUnit'] = 'hr';
                }
                return data;
            }
        });
        
        var PageData = Backbone.Model.extend({
            url: function() {
                var array = this.baseURL.split("?");
                var url = array[0] + "/pages?" + array[1];
                return url;
            },
        });

        return {
            Entry: Entry,
            PageData: PageData
        }
    })();

    var Collections = (function() {

        var Entries = Backbone.Collection.extend({
            model: Models.Entry,
            initialize: function(options) {
                this.baseURL = options.baseURL;
                this.page = 1;
                this.query = "";
                this.dateRange = null;
                this.on('add', this.refetch, this);
                this.on('change:page', this.fetch);
            },
            url: function() {
                result = this.baseURL + "?page=" + this.page;
                if (this.query != "") {
                    result += "&q=" + this.query;
                }
                if (this.dateRange != null) {
                    result += "&daterange=" + this.dateRangeStr();
                }
                return result;
            },
            comparator: function(entry) {
                return 0 - moment(entry.get('time_in')).unix();
            },
            refetch: function(model, collection, options) {
                var oldModels = _.clone(this.models);
                this.fetch();
                if (this.models != oldModels) {
                    this.trigger("differ", model, options.index);
                }
            },
        });


        return {
            Entries: Entries
        }
    })();

    var Views = (function() {

        var MasterView = Backbone.View.extend({
            el: $('#masterView'),
            events: {
                "click #btnAdd": "showAdd",
                "click #btnDelete": "showDelete",
            },

            initialize: function(options) {
                this.collection = options.collection;
                this.EntryTable = new EntriesTable({collection: this.collection});
                this.PageView = new PageView({table: this.EntryTable});
                this.SearchView = new SearchView({table: this.EntryTable});
                this.EntryTable.on('render', this.PageView.render, this.PageView);
            },
            render: function() {
            },

            showAdd: function() {
                var newDialog = new AddView({collection: this.collection});
                newDialog.render();
            },
            showDelete: function() {
                var deleteDialog = new DeleteView({collection: this.collection});
                deleteDialog.render();
            }

        });

        var EntriesTable = Backbone.View.extend({
            el: $('#entryTable'),
            initialize: function() {
                this.collection.on('differ', this.addOne, this); 
                this.collection.on('reset', this.render, this);
            },
            render: function() {
                this.trigger('render');
                this.$el.find('tbody').hide();
                this.$el.find('tbody').empty();
                if (this.collection.models.length > 0) {
                    _.each(this.collection.models, function(entry) {
                        this.renderEach(entry);
                    }, this);

                } else {
                    this.$el.find('tbody').append("<tr><td colspan=6 class='emptyMsg'>Nothing was found...</td></tr>");
                }
                this.$el.find('tbody').fadeIn(500);
                return this;
            },
            renderEach: function(entry, index) {
                var entryView = new Entry({
                    model: entry
                });
                if (index == null) {
                    this.$el.find('tbody').append((entryView.render().el));
                } else {
                    if (index == 0) {
                        this.$el.find('tbody').prepend(entryView.render().el).children().eq(0).hide().delay(1000).fadeIn(1000);
                    } else {
                        this.$el.find('tbody').children().eq(index).before(entryView.render().el).prev().hide().delay(1000).fadeIn(1000);
                    }
                }
            },
            addOne: function(model, index) {
                this.renderEach(model, index);
            },
        });

        var Entry = Backbone.View.extend({
            template: "<td class='check'><input type='checkbox' class='checkbox'/></td>" +
                        "<td class='date'>{{date}}</td>" +
                        "<td class='in'>{{time_in}}</td>" +
                        "<td class='out'>{{time_out}}</td>" +
                        "<td class='total'>{{total}} {{totalUnit}}</td>" +
                        "<td class='comment'>{{comment}}</td>",
            tagName: "tr",
            events: {
                "click td": "toggleSelect",
                "dblclick td": "showEdit",
            },
            initialize: function(options) {
                this.model.selected = options.selected || false
                this.model.on('change', this.render, this);
                this.model.on('destroy', this.destroy, this);
            },
            render: function() {
                var data = this.model.templateData();
                this.$el.html(_.template(this.template, data));
                if (this.model.selected) {
                    this.$el.find("input[type='checkbox']").attr("checked", "checked");
                } else {
                    this.$el.find("input[type='checkbox']").removeAttr("checked");
                }
                return this;
            },
            toggleSelect: function() {
                this.setSelect(!this.model.selected);
            },
            setSelect: function(selected) {
                this.model.selected = selected;
                if (this.model.selected) {
                    this.$el.addClass('selected');
                    this.$el.find("input[type='checkbox']").attr('checked', true);
                } else {
                    this.$el.removeClass('selected');
                    this.$el.find("input[type='checkbox']").attr('checked', false);
                }
            },
            destroy: function() {
                this.$el.delay(5000).fadeOut(2000).remove();
            },
            showEdit: function() {
                this.setSelect(true);
                var editView = new EditView({model: this.model});
                editView.render();
            }
        });

        var EditView = Backbone.View.extend({
            template: "<div class='modal-header'>" +
                "<button type='button' class='btnClose close' aria-hidden='true'>&times;</button>" +
                "<h2>Edit Entry</h2>" +
                "</div>" +
                "<div class='modal-body'>" +
                "<div class='row-fluid'>" +
                "<div class='span3'>" +
                "<label>Date: </label> " +
                "<input type='text' class='newDate input-small' value='{{date}}'/>" +
                "</div>" +
                "<div class='span3'>" +
                "<label>Time in: </label> " +
                "<input placeholder='' id='time_in' type='text' title='Example: 01:14pm' class='time input-small' value='{{time_in}}'/>" +
                "</div>" +
                "<div class='span3'>" +
                " <label> Time out: </label> " +
                "<input placeholder='' id='time_out' type='text' title='Example: 01:14pm' class='time input-small' value='{{time_out}}'/>" +
                "</div>" +
                "<div class='span3'>" +
                " <label> Total: </label> " +
                "<span id='total' type='text'>{{total}} {{totalUnit}}</span>" +
                "</div>" +
                "</div>" +
                "<div class='row-fluid'>" +
                "<div class='span12'>" +
                "<label>Comment:</label>" +
                "<input class='input-block-level newComment' maxlength=50 value='{{comment}}'/>" +
                "</div>" +
                "</div>" +
                "</div>" +
                "<div class='modal-footer'>" +
                "<a href='#' class='btn btnClose'>Close</a>" +
                "<a href='#' class='btn btn-primary' id='btnSave'>Save changes</a>" +
                "</div>",
            events: {
                "click .btnClose": "close",
                "click #btnSave": "save",
                "change .time": "recalculateTotal",
                "select .time": "recalculateTotal",
                "click .time": "suggest",
            },
            tagName: "div",
            className: "newEntryDialog modal hide fade",
            initialize: function() {
                this.timeArray = [];
                for (var z = 0; z < 2; z++ ) {
                    if (z == 0) {
                        var am = "am";
                    } else {
                        var am = "pm";
                    }

                    for (var i = 6; i < 18; i++) {
                        if (i >= 12) {
                            if (z == 0) {
                                am = "pm";
                            } else {
                                am = "am";
                            }
                        }
                        t = i % 12;

                        if (t == 0) {
                            t = 12;
                        } else if (t < 10) {
                            var leadingZero = "0";
                        } else {
                            var leadingZero = "";
                        }
                        this.timeArray.push(leadingZero + t + ":00" + am);
                        this.timeArray.push(leadingZero + t + ":30" + am);
                    }
                }
                _.bindAll(this, "recalculateTotal");
            },
            render: function() {
                this.$el.html(this.template);
                $('body').append(this.$el);
                this.$el.modal();
                var data = this.model.templateData();
                data['date'] = moment(this.model.get('time_in')).format("MM/DD/YYYY");
                this.$el.html(_.template(this.template, data));
                this.$el.find('.time').autocomplete({source: this.timeArray, minLength: 0, change: this.recalculateTotal});
                this.$el.find('.newDate').datepicker();
            },
            recalculateTotal: function(e) {
                var that = this;
                //Delay to get the text values properly
                setTimeout(function() {
                    that.$el.find(".time").removeClass('error');
                    var time_in = moment(that.$el.find("#time_in").val(), "hh:mma");
                    var time_out = moment(that.$el.find("#time_out").val(), "hh:mma");
                    if ( (time_in != null) && (time_out != null)) {
                        var total = time_out.diff(time_in) / 1000 / 60 / 60;
                        if (total > 1) {
                            var unit = "hrs";
                        } else {
                            var unit = "hr";
                        }
                        that.$el.find("#total").html(total.toFixed(1)+" "+unit);
                    }
                }, 50);
            },
            suggest: function(e) {
                var that = e.currentTarget;
                $(that).autocomplete("search", "");

            },
            close: function() {
                this.$el.modal('hide');
                this.undelegateEvents();
                this.$el.removeData().unbind();
                this.remove();
            },
            save: function() {
                var date = moment(this.$el.find(".newDate").val(), "MM/DD/YYYY");
                var time_in = moment(this.$el.find("#time_in").val(), "hh:mma");
                var time_out = moment(this.$el.find("#time_out").val(), "hh:mma");
                //check if filled out
                if ( (date == null) || (time_in == null) || (time_out == null)) {
                    alert("All of the fields are required.");
                    return;
                }
                var total = time_out.diff(time_in) / 1000 / 60 / 60;
                var conf = true;
                //check if logging 0 hour.
                if (total <= 0) {
                    var conf = confirm("You're logging 0 hour or a negative time. Are you sure you want to continue?");
                }
                if (!conf) {
                    return;
                }
                this.close();

                //build model hash
                var model = {};
                model['time_in'] = time_in.date(date.date()).month(date.month()).year(date.year()).toDate().toJSON();
                model['time_out'] = time_out.date(date.date()).month(date.month()).year(date.year()).toDate().toJSON();
                model['comment'] = this.$el.find('input.newComment').val();

                this.model.save(model);
                this.model.selected = true;

            },
        });

        var AddView = Backbone.View.extend({
            template: "<div class='modal-header'>" +
                "<button type='button' class='btnClose close' aria-hidden='true'>&times;</button>" +
                "<h2>New Entry</h2>" +
                "</div>" +
                "<div class='modal-body'>" +
                "<div class='row-fluid'>" +
                "<div class='span3'>" +
                "<label>Date: </label> " +
                "<input type='text' class='newDate input-small'/>" +
                "</div>" +
                "<div class='span3'>" +
                "<label>Time in: </label> " +
                "<input placeholder='' id='time_in' type='text' title='Example: 01:14pm' class='time input-small' />" +
                "</div>" +
                "<div class='span3'>" +
                " <label> Time out: </label> " +
                "<input placeholder='' id='time_out' type='text' title='Example: 01:14pm' class='time input-small' />" +
                "</div>" +
                "<div class='span3'>" +
                " <label> Total: </label> " +
                "<span id='total' type='text'>0 hr</span>" +
                "</div>" +
                "</div>" +
                "<div class='row-fluid'>" +
                "<div class='span12'>" +
                "<label>Comment:</label>" +
                "<input class='input-block-level newComment' maxlength=50 />" +
                "</div>" +
                "</div>" +
                "</div>" +
                "<div class='modal-footer'>" +
                "<a href='#' class='btn btnClose'>Close</a>" +
                "<a href='#' class='btn btn-primary' id='btnSave'>Save changes</a>" +
                "</div>",
            events: {
                "click .btnClose": "close",
                "click #btnSave": "save",
                "change .time": "recalculateTotal",
                "select .time": "recalculateTotal",
                "click .time": "suggest",
            },
            tagName: "div",
            className: "newEntryDialog modal hide fade",
            initialize: function() {
                this.timeArray = [];
                for (var z = 0; z < 2; z++ ) {
                    if (z == 0) {
                        var am = "am";
                    } else {
                        var am = "pm";
                    }

                    for (var i = 6; i < 18; i++) {
                        if (i >= 12) {
                            if (z == 0) {
                                am = "pm";
                            } else {
                                am = "am";
                            }
                        }
                        t = i % 12;
                        
                        if (t == 0) {
                            t = 12;
                        } else if (t < 10) {
                            var leadingZero = "0";
                        } else {
                            var leadingZero = "";
                        }
                        this.timeArray.push(leadingZero + t + ":00" + am);
                        this.timeArray.push(leadingZero + t + ":30" + am);
                    }
                }
                _.bindAll(this, "recalculateTotal");
            },
            render: function() {
                this.$el.html(this.template);
                $('body').append(this.$el);
                this.$el.modal();
                this.$el.find('.newDate').val(moment().format("MM/DD/YYYY"));
                this.$el.find('.time').val(moment().format("hh:mma"));
                this.$el.find('.time').autocomplete({source: this.timeArray, minLength: 0, change: this.recalculateTotal});
                this.$el.find('.newDate').datepicker();
            },
            recalculateTotal: function(e) {
                var that = this;
                //Delay to get the text values properly
                setTimeout(function() {
                    that.$el.find(".time").removeClass('error');
                    var time_in = moment(that.$el.find("#time_in").val(), "hh:mma");
                    var time_out = moment(that.$el.find("#time_out").val(), "hh:mma");
                    if ( (time_in != null) && (time_out != null)) {
                        var total = time_out.diff(time_in) / 1000 / 60 / 60;
                        if (total > 1) {
                            var unit = "hrs";
                        } else {
                            var unit = "hr";
                        }
                        that.$el.find("#total").html(total.toFixed(1)+" "+unit);
                    }
                }, 50);
            },
            suggest: function(e) {
                var that = e.currentTarget;
                $(that).autocomplete("search", "");

            },
            close: function() {
                this.$el.modal('hide');
                this.undelegateEvents();
                this.$el.removeData().unbind();
                this.remove();
            },
            save: function() {
                var date = moment(this.$el.find(".newDate").val(), "MM/DD/YYYY");
                var time_in = moment(this.$el.find("#time_in").val(), "hh:mma");
                var time_out = moment(this.$el.find("#time_out").val(), "hh:mma");
                //check if filled out
                if ( (date == null) || (time_in == null) || (time_out == null)) {
                    alert("All of the fields are required.");
                    return;
                }
                var total = time_out.diff(time_in) / 1000 / 60 / 60;
                var conf = true;
                //check if logging 0 hour.
                if (total <= 0) {
                    var conf = confirm("You're logging 0 hour or a negative time. Are you sure you want to continue?");
                }
                if (!conf) {
                    return;
                }
                this.close();

                //build model hash
                var model = {};
                model['time_in'] = time_in.date(date.date()).month(date.month()).year(date.year()).toDate().toJSON();
                model['time_out'] = time_out.date(date.date()).month(date.month()).year(date.year()).toDate().toJSON();
                model['comment'] = this.$el.find('input.newComment').val();

                this.collection.create(model);

            },
        });

        var DeleteView = Backbone.View.extend({
            template: "<div class='modal-header'>" +
                "<button type='button' class='btnClose close' aria-hidden='true'>&times;</button>" +
                "<h2>Delete Entries</h2>" +
                "</div>" +
                "<div class='modal-body'>" +
                "<p>{{msg}}</p>" +
                "</div>" +
                "<div class='modal-footer'>" +
                "<a href='#' class='btn btnClose'>Close</a>" +
                "<a href='#' class='btn btn-primary' id='btnDelete'>Delete</a>" +
                "</div>",
            events: {
                "click .btnClose": "close",
                "click #btnDelete": "delete",
            },
            tagName: "div",
            className: "deleteEntryDialog modal hide fade",
            close: function() {
                this.$el.modal('hide');
                this.undelegateEvents();
                this.$el.removeData().unbind();
                this.remove();
            },
            render: function() {
                var countSelected = 0;
                _.each(this.collection.models, function(model) {
                    if (model.selected) {
                        countSelected++;
                    }
                }, this);
                if (countSelected > 0) {
                    if (countSelected > 1) {
                        var msg = {msg: "Are you sure you want to delete these entries?"};
                    } else {
                        var msg = {msg: "Are you sure you want to delete this entry?"};
                    }
                } else {
                    var msg = {msg: "No entries was selected."};
                }
                this.$el.html(_.template(this.template, msg));
                if (countSelected == 0) {
                    this.$el.find("#btnDelete").hide();
                }
                $('body').append(this.$el);
                this.$el.modal();
            },
            delete: function() {
                this.close();
                var toDelete = [];
                _.each(this.collection.models, function(model) {
                    if (model.selected) {
                        toDelete.push(model);
                    }
                });
                _.each(toDelete, function(model) {
                    model.destroy();
                });
            },
        });

        var PageView = Backbone.View.extend({
            el: $("#pageView"), 
            initialize: function(opts) {
                this.table = opts.table;
                this.model = new Models.PageData();
                this.model.on('change', this.changePage, this);
                this.table.collection.on('change', this.changePage, this);
            },
            events: {
                "click #btnPrevious": "previous",
                "click #btnNext": "next",
            },
            render: function() {
                this.getPageData();
                var total = this.model.get('total') || 0;
                if (this.table.collection.page == 1) {
                    this.$el.find("#btnPrevious").addClass('disabled');
                } else {
                    this.$el.find("#btnPrevious").removeClass('disabled');
                }
                if (this.table.collection.page >= total) {
                    this.$el.find("#btnNext").addClass('disabled');
                } else {
                    this.$el.find("#btnNext").removeClass('disabled');
                }
            },
            changePage: function() {
                this.$el.find("#btnCurrentPage").text(this.table.collection.page + "/" + this.model.get('total'));
                this.render();
            },
            getPageData: function() {
                this.model.baseURL = this.table.collection.url();
                this.model.fetch();
            },
            previous: function(e) {
                if ($(e.currentTarget).hasClass('disabled')) {
                    return;
                }
                this.table.collection.page--;
                this.table.collection.trigger('change:page');
                this.changePage();
            },
            next: function(e) {
                if ($(e.currentTarget).hasClass('disabled')) {
                    return;
                }
                this.table.collection.page++;
                this.table.collection.trigger('change:page');
                this.changePage();
            },
        });

        var SearchView = Backbone.View.extend({
            el: $("#searchView"),
            initialize: function(opts) {
                this.table = opts.table;
            },
            events: {
                "click #btnSearch": "search",
                "click #btnClear": "clear",
            },
            search: function() {
                if (this.$el.find('input').val() == "") {
                    this.clear();
                    return;
                }
                if (this.$el.find("#btnClear").length == 0) {
                    this.$el.find("#btnSearch").after("<button title='Clear search' id='btnClear' class='btn'><i class='icon-remove'></i></button>");
                }
                this.table.collection.page=1;
                this.table.collection.trigger('change:page');
                this.table.collection.query = this.$el.find('input').val();
                this.table.collection.fetch();
            },
            clear: function() {
                this.$el.find("#btnClear").remove();
                this.$el.find('input').val("");
                this.table.collection.query = "";
                this.table.collection.fetch();
            },
        });

        return {
            MasterView: MasterView,
        }
    })();

    var masterCollection = new Collections.Entries({baseURL: '/main/api/project/1/entry'});
    var masterView = new Views.MasterView({collection: masterCollection});

    return {
        masterCollection: masterCollection,
        masterView: masterView
    }
})();
