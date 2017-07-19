class DecrypterController < ApplicationController
  def decrypt
    path_prefix = "#{Rails.root}/files"
    plain_fname = "#{path_prefix}/uploaded_plain.txt"
    encr_fname = "#{path_prefix}/uploaded_encr.txt"
    decr_fname = "#{path_prefix}/decr.txt"
    FileUtils.cp(params[:plainTextFile].tempfile,plain_fname) if params[:plainTextFile]
    FileUtils.cp(params[:encrFile].tempfile,encr_fname) if params[:encrFile]
    decrypter = Decrypter.new(plain_fname,encr_fname,decr_fname)
    file_json = decrypter.decrypt
    render json: file_json
    # send_file decr_fname
  end
end
