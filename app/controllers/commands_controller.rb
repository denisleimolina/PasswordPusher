class CommandsController < ApplicationController
  # Some random images featuring Stan (Instana)
  STAN_URLS = [
    'https://s3.amazonaws.com/instana/stan+the+author.jpg',
    'https://s3.amazonaws.com/instana/Stan+billboard.jpg',
    'https://s3.amazonaws.com/instana/stan+on+ghost+tv.gif',
    'https://s3.amazonaws.com/instana/Stan+in+coffee.jpg',
    'https://s3.amazonaws.com/instana/stan+interview.jpg',
    'https://s3.amazonaws.com/instana/stasrtup-instana.jpg'
  ].freeze

  RANDOM_THINGS = ['🦄', '(👍≖‿‿≖)👍 👍(≖‿‿≖👍)', '¯\_(ツ)_/¯ ', ' (╯︵╰,)',
                   'ಥ_ಥ', '♪┏(°.°)┛┗(°.°)┓┗(°.°)┛┏(°.°)┓ ♪',
                   '┻━┻ ︵ヽ(`Д´)ﾉ︵﻿ ┻━┻', 'ᕙ(^▿^-ᕙ)',
                   '─=≡Σ((( つ◕ل͜◕)つ', '＼（＾ ＾）／', 'Yᵒᵘ Oᶰˡʸ Lᶤᵛᵉ Oᶰᶜᵉ',
                   '◕_◕', ' -`ღ´-', '(-(-_(-_-)_-)-)', '⁀⊙﹏☉⁀'].freeze

  # Rough (& incomplete) list of passwords that should never be used.
  # Feel free to send PRs to add to this list although we'll never be
  # comprehensive here.  We can't save everyone from bad passwords.
  BAD_PASSWORDS = %w[1234 12345 123456 1234567 password
                     qwerty football baseball welcome abc123
                     dragon secret solo princess letmein
                     welcome asdf].freeze

  def create
    if !params.key?(:command) || !params.key?(:text) || params[:command] != '/pwpush'
      render plain: "Unknown command: #{params.inspect}", layout: false
      return
    end

    secret, opts = params[:text].split(' ')
    if opts
      days, views = opts.split(',')
    end

    if ["help", '-h', 'usage'].include?(secret.downcase)
      render plain: "Uso / pwpush <senha> [dias,visualizações]", layout: false
      return
    elsif BAD_PASSWORDS.include?(secret.downcase)
      render plain: "Vamos lá. Você realmente quer usar essa senha? Faça um pouco de esforço e tente novamente.", layout: false
      return
    elsif ["april1st", "easter", "egg", "picklerick"].include?(secret.downcase)
      render plain: RANDOM_THINGS.sample, layout: false
      return
    elsif ["instana"].include?(secret.downcase)
      render plain: STAN_URLS.sample, layout: false
      return
    end

    days ||= EXPIRE_AFTER_DAYS_DEFAULT
    views ||= EXPIRE_AFTER_VIEWS_DEFAULT

    @password = Password.new
    @password.expire_after_days = days
    @password.expire_after_views = views
    @password.deletable_by_viewer = DELETABLE_BY_VIEWER_PASSWORDS

    # Encrypt the passwords
    @key = EzCrypto::Key.with_password CRYPT_KEY, CRYPT_SALT
    @password.payload = @key.encrypt64(secret)

    @password.url_token = rand(36**16).to_s(36)
    @password.validate!

    if @password.save
      message ="Senha enviada com #{days} dias e #{views} expiração de visualizações:" +
                "#{request.env["rack.url_scheme"]}://#{request.env['HTTP_HOST']}/p/#{@password.url_token}"
      render plain: message, layout: false
    else
      render plain: @password.errors, layout: false
    end
  end
end
