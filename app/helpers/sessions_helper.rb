module SessionsHelper
  def log_in(annotator)
    session[:annotator_id] = annotator.id
  end

  def remember(annotator)
    annotator.remember
    cookies.permanent.signed[:annotator_id] = annotator.id
    cookies.permanent[:remember_token] = annotator.remember_token
  end

  def current_annotator
    if (annotator_id = session[:annotator_id])
      @current_annotator ||= Annotator.find_by(id: annotator_id)
    elsif (annotator_id = cookies.signed[:annotator_id])
      annotator = Annotator.find_by(id: annotator_id)
      if annotator && annotator.authenticated?(cookies[:remember_token])
        log_in annotator
        @current_annotator = annotator
      end
    end
  end

  def logged_in?
    !current_annotator.nil?
  end

  def forget(annotator)
    annotator.forget
    cookies.delete(:annotator_id)
    cookies.delete(:remember_token)
  end

  def log_out
    forget(current_annotator)
    session.delete(:annotator_id)
    @current_annotator = nil
  end
end
