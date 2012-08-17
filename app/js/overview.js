_.templateSettings = {
     evaluate : /\{\[([\s\S]+?)\]\}/g,
     interpolate : /\{\{([\s\S]+?)\}\}/g
};

var Overview = (function($) {

    var Models = (function() {
        var Project = Backbone.Model.extend({});

        return {
            Project: Project
        }
    })();

    var Collections = (function() {
        var Projects = Backbone.Collection.extend({
            model: Models.Project,
            url: '/main/api/project',
            comparator: function(item) {
                return (0 - Date.parse(item.get('last_entry_updated_at')).getTime());
            },
        });

        return {
            Projects: Projects
        }
    })();
    
    var Views = (function() {

        var projectTemplate = "<table class='table table-bordered'>" +  
                    "<thead><tr><th colspan=2><h2>{{project_name}}</h2>" + 
                    "<div class='btn-group'>" +
                    "<a rel='tooltip' data-original-title='Edit' title='Edit' class='btn btnEdit' ><i class='icon-edit'></i></a>" +
                    "<a class='btn btnDelete' rel='tooltip' title='Delete' data-original-title='Delete'><i class='icon-trash'></i></a></div>" +
                    "</th></tr></thead>"+
                    "<tbody>" + 
                    "<tr><td colspan=2>{{comment}}</td></tr>" +
                    "<tr><td>For</td><td>{{forText}}</td></tr>" +
                    "<tr><td>Number of entries:</td><td><strong>{{numberOfEntries}}</strong></td></tr>" +
                    "<tr><td>Total hours:</td><td><strong><big>{{totalHours}}</big></strong></td></tr>" +
                    "<tr><td>Last updated:</td><td>{{last_entry_updated_at}}</td></tr>" +
                    "</tbody>" +
                    "</table>";

        var Project = Backbone.View.extend({
            template: projectTemplate,
            tagName: "div",
            className: 'span5',

            events: {
                "click .btnEdit": "showEdit",
                "click .btnDelete": "showDelete",
            },

            initialize: function() {
                _.bindAll(this, 'showEdit', 'showDelete', 'remove', 'render', 'update');
                this.model.on('change', this.update);
                this.model.on('destroy', this.remove);
            },

            render: function() {
                var data = this.model.toJSON();
                data.forText = data.for;
                if (data.forText == "") {
                    data.forText = "no one";
                }
                if (data.comment == "") {
                    data.comment = "<em>no description</em>"
                }
                data.last_entry_updated_at = Date.parse(data.last_entry_updated_at).toString("h:mm tt on M/dd/yyyy");
                this.$el.html(_.template(this.template, data));
                return this;
            },

            showEdit: function() {
                new EditProject({model: this.model});
            },

            showDelete: function() {
                new DeleteProject({model: this.model});
            },

            remove: function() {
                this.undelegateEvents();
                this.$el.delay(500).fadeOut(500).remove();
            },

            update: function() {
                this.render();
                this.$el.find('table').css('background-color','#a6ffaa').animate({backgroundColor: $('body').css('background-color')}, 2000)
                .delay(2000).css('background-color', 'transparent');
            },
        });

        var Projects = Backbone.View.extend({
            el: $('#masterView'),
            initialize: function(options) {
                _.bindAll(this, 'newProject');
                this.collection = options.collection
                this.collection.on("reset", this.render, this);
                this.collection.on("add", this.addProject, this);
            },

            events: {
                "click .btnNew": "newProject",
            },

            render: function(models) {
                models = this.collection.models
                this.$el.find('#projectHanger').empty();
                if (models.length > 0) {
                    _.each(models, function(item) {
                        this.renderEach(item);
                    }, this);
                } else {
                    this.$el.find('#projectHanger').append($("<div class='span10'>You don&rsquo;t have any projects yet.</div>"));
                }
            },

            renderEach: function(item, index) {
                var itemView = new Project({
                    model: item
                });
                if (index == null) {
                    this.$el.find('#projectHanger').append(itemView.render().el);
                } else {
                    if (index == 0) {
                        this.$el.find('#projectHanger').prepend(itemView.render().el);
                    } else {
                        this.$el.find('#projectHanger').children().eq(index).before(itemView.render().el);
                    }
                }
                itemView.$el.hide().delay(this.collection.indexOf(item) * 100).fadeIn(500);
            },

            newProject: function() {
                new CreateProject({collection: this.collection});
            },

            addProject: function(model,collection,options) {
                this.renderEach(model, options.index);
            },
        });

        var EditProject = Backbone.View.extend({
            template: "" +
                "<div class='modal-header'>" +
                "<button type='button' class='close btnClose'>×</button>" +
                "<h1>Edit {{project_name}}</h1>" +
                "</div>" +
                "<div class='modal-body'>" +
                "<label for='name'>Name:</label>" +
                "<input class='input-xlarge' type='text' name='name' maxlength='50' value='{{project_name}}' />" +
                "<label for='for'>For:</label>" +
                "<input class='input-xlarge'  type='text' name='for' maxlength='50' value='{{forText}}' />" +
                "<label for='comment'>Comment</label>" +
                "<input class='input-block-level' type='text' name='comment' maxlength='60' value='{{comment}}' />" +
                "</div>" +
                "<div class='modal-footer'>" +
                "<a href='#' class='btn btnClose'>Close</a>" +
                "<a href='#' class='btn btnSaveChanges btn-primary'>Save changes</a>" +
                "</div>",
            tagName: 'div',
            className: 'modal hide',
            events: {
                "click .btnClose": 'close',
                "click .btnSaveChanges": 'saveChanges',
            },
            initialize: function() {
                _.bindAll(this, 'close', 'saveChanges');
                this.render();
            },

            render: function() {
                var data = this.model.toJSON();
                data.forText = data.for;
                this.$el.html(_.template(this.template, data));
                this.$el.appendTo($('body'));
                this.$el.modal();
            },

            close: function() {
                this.$el.modal('hide');
                this.undelegateEvents();
                this.$el.removeData().unbind();
                this.remove();
            },

            saveChanges: function() {
                this.model.save({
                    "project_name": this.$el.find("[name='name']").val(),
                    "for": this.$el.find("[name='for']").val(),
                    "comment": this.$el.find("[name='comment']").val()
                });
                this.close();
            },

        });

        var DeleteProject = Backbone.View.extend({
            template: "" +
                "<div class='modal-header'>" +
                "<button type='button' class='close btnClose'>×</button>" +
                "<h1>Delete {{project_name}}</h1>" +
                "</div>" +
                "<div class='modal-body'>" +
                "<p>Are you sure you would like to delete this project?</p>" +
                "<p>Deleting it will delete all {{numberOfEntries}} belongings to this project.</p>" +
                "<p><span class='label label-important'>Warning! All deletions are permanents</span></p>" +
                "<div class='modal-footer'>" +
                "<a href='#' class='btn btnClose'>No, just kidding.</a>" +
                "<a href='#' class='btn btnDelete btn-primary'>Yeah, delete it!</a>" +
                "</div>",
            tagName: 'div',
            className: 'modal hide',
            events: {
                "click .btnClose": 'close',
                "click .btnDelete": 'delete',
            },
            initialize: function() {
                _.bindAll(this, 'close', 'delete');
                this.render();
            },

            render: function() {
                var data = this.model.toJSON();
                if (data.numberOfEntries > 1) {
                    data.numberOfEntries = data.numberOfEntries + " entries";
                } else {
                    data.numberOfEntries = data.numberOfEntries + " entry";
                }
                this.$el.html(_.template(this.template, data));
                this.$el.appendTo($('body'));
                this.$el.modal();
            },

            close: function() {
                this.$el.modal('hide');
                this.undelegateEvents();
                this.$el.removeData().unbind();
                this.remove();
            },

            delete: function() {
                this.model.destroy();
                this.close();
            },

        });

        var CreateProject = Backbone.View.extend({
            template: "" +
                "<div class='modal-header'>" +
                "<button type='button' class='close btnClose'>×</button>" +
                "<h1>New Project</h1>" +
                "</div>" +
                "<div class='modal-body'>" +
                "<label for='name'>Name:</label>" +
                "<input class='input-xlarge' type='text' name='name' maxlength='50' />" +
                "<label for='for'>For:</label>" +
                "<input class='input-xlarge'  type='text' name='for' maxlength='50' />" +
                "<label for='comment'>Comment</label>" +
                "<input class='input-block-level' type='text' name='comment' maxlength='60' />" +
                "</div>" +
                "<div class='modal-footer'>" +
                "<a href='#' class='btn btnClose'>Close</a>" +
                "<a href='#' class='btn btnCreate btn-primary'>Create</a>" +
                "</div>",
            tagName: 'div',
            className: 'modal hide',
            events: {
                "click .btnClose": 'close',
                "click .btnCreate": 'create',
            },
            initialize: function() {
                _.bindAll(this, 'close', 'create');
                this.render();
            },

            render: function() {
                this.$el.html(this.template);
                this.$el.appendTo($('body'));
                this.$el.modal();
            },

            close: function() {
                this.$el.modal('hide');
                this.undelegateEvents();
                this.$el.removeData().unbind();
                this.remove();
            },

            create: function() {
                if (this.$el.find("[name='name']").val() == "") {
                    this.$el.find("[name='name']").addClass('error');
                    this.$el.find("[for='name']").addClass('error');
                    alert('A project name is required');
                    return;
                }
                var name = this.$el.find("[name='name']").val();
                var forText = this.$el.find("[name='for']").val();
                var comment = this.$el.find("[name='comment']").val();
                this.collection.create({
                    'project_name': name,
                    'for': forText,
                    'comment': comment
                }, {wait: true});
                this.close();
            },

        });

        return {
            Projects: Projects
        }

    })();

    var masterCollection = new Collections.Projects;
    var masterView = new Views.Projects({collection: masterCollection});

    return {
        masterView: masterView,
        masterCollection: masterCollection
    }

})(jQuery);
