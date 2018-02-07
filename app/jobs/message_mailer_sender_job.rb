# This job allows asynchronus creation of a pdf-file for a plan assigned to a message and sends this plan multiple
#    times.

class MessageMailerSenderJob < ApplicationJob

  # Use the default mailers-queue also used by "normal" ActiveMailer-jobs.
  queue_as :mailers

  # Actually sends the message.
  def perform(message)
    plan = nil

    # Check if a plan is present and if that is the case, generate a pdf-file from it.
    if message.plan
      view = ApplicationController.new.render_to_string(template: 'admin/plans/show.pdf.haml',
        layout: 'layouts/pdf.html.haml', locals: { :@plan => message.plan })
      plan = WickedPdf.new.pdf_from_string(view, orientation: 'Landscape', encoding: 'UTF-8')
    end

    # Send the message to each assigned server.
    message.to.each do |server|
      MessageMailer.global_mail(server, message, plan).deliver_now
    end
  end

end
