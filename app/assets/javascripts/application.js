// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap-sprockets
//= require chosen-jquery
//
//= require_tree .
//
//= require jquery.dataTables.js
//= require dataTables.bootstrap.js
//
//= require cocoon

var ready = function() {

  // If a user clicks on a table-row with a link contained in it, the link should be triggered.
  $('.table-rows-link tr').click(function(event) {
    if (event.target instanceof HTMLAnchorElement) return;
    $('a', this)[0].click();
  });

  // If a user clicks on an table-row with a checkbox, the checkbox should be activated.
  // The row kind of reacts like a big label for the checkbox.
  $('.table-rows-checkbox tr').click(function(event) {
    if (event.target.type == 'checkbox') return;
    $(':checkbox', this).trigger('click');
  });

  // Highlight selected rows with a bootstrap-green-shade for even clearer feedback.
  $checkboxes = $('.table-rows-checkbox input[type="checkbox"]')
  $checkboxes.change(function (e) {
    $(this).closest('tr').toggleClass('success', $(this).is(':checked'));
  });
  $checkboxes.each(function (e) {
    if ($(this).is(':checked')) $(this).closest('tr').addClass('success');
  })

  // Allow the CSS to react on javascript-enabled browsers.
  $(document.body).addClass('js-enabled');

  // Adds super-duper table-functionality to tables with the class `.table-data`.
  var $table = $('.table-data');
  var sort_column = $table.data('sort-column') || 0;
  var sort_order = $table.data('sort-order');
  if (sort_order != 'desc') sort_order = 'asc';
  $table.DataTable({
    columnDefs: [{ orderable: false, searchable: false, targets: -1 }],
    order: [[sort_column, sort_order]],
    language: {
      "sEmptyTable":   	"Keine Daten in der Tabelle vorhanden",
      "sInfo":         	"_START_ bis _END_ von _TOTAL_ Einträgen",
      "sInfoEmpty":    	"0 bis 0 von 0 Einträgen",
      "sInfoFiltered": 	"(gefiltert von _MAX_ Einträgen)",
      "sInfoPostFix":  	"",
      "sInfoThousands":  	".",
      "sLengthMenu":   	"_MENU_ Einträge anzeigen",
      "sLoadingRecords": 	"Wird geladen...",
      "sProcessing":   	"Bitte warten...",
      "sSearch":       	"Suchen",
      "sZeroRecords":  	"Keine Einträge vorhanden.",
      "oPaginate": {
          "sFirst":    	"Erste",
          "sPrevious": 	"Zurück",
          "sNext":     	"Nächste",
          "sLast":     	"Letzte"
      },
      "oAria": {
          "sSortAscending":  ": aktivieren, um Spalte aufsteigend zu sortieren",
          "sSortDescending": ": aktivieren, um Spalte absteigend zu sortieren"
      }
    }
  });
  $table.wrap('<div class="table-responsive"></div>');

  // Load the custom locale for the chosen-plugin.
  $('.chosen-select').chosen({
    allow_single_deselect: true,
    no_results_text: chosen_locale['no_results_text'],
    placeholder_text_multiple: chosen_locale['placeholder_text_multiple'],
    placeholder_text_single: chosen_locale['placeholder_text_single']
  });

};

$(document).ready(ready);
$(document).on('page:load', ready);
