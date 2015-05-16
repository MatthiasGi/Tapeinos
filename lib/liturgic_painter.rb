# This library-class ensures proper coloring for Tapeinos. It's primary use is to check, which color's turn it is today.

class LiturgicPainter

  # This method determines the current liturgic feast. All other information is stored in localization-files.
  def self.get_liturgy(date)

    feast = :default

    # New Year
    date == date.change(day: 1, month: 1) and return default_liturgy(:newyear)

    # Epiphany
    epiphany = date.change(day: 6, month: 1)
    date == epiphany and return default_liturgy(:epiphany)

    # Baptism of the Lord
    baptism_jesus = epiphany + 7 - epiphany.wday
    date == baptism_jesus and return default_liturgy(:baptism_jesus)

    # Christmas
    christmas = date.change(day: 25, month: 12)
    date == christmas and return default_liturgy(:birth_lord)
    date.between?(christmas, date.change(day: 31, month: 12)) or
      date.between?(date.change(day: 2, month: 1), baptism_jesus) and feast = :christmas

    # Holy family
    holy_family = christmas + 7 - christmas.wday
    holy_family.year != date.year and holy_family = date.change(day: 30, month: 12)
    date == holy_family and return default_liturgy(:holy_family)

    # Presentation of the Lord
    date == date.change(day: 2, month: 2) and return default_liturgy(:presentation_jesus)

    # Easter
    easter = Date.easter(date.year)
    pentecost = easter + 49
    date.between?(easter, pentecost) and feast = :easter

    # Palmsunday
    date == easter - 7 and return default_liturgy(:palmsunday)

    # Holy week
    date.between?(easter - 6, easter - 4) and return default_liturgy(:holy_week)
    date == easter - 3 and return default_liturgy(:holy_thursday)
    date == easter - 2 and return default_liturgy(:good_friday)
    date == easter - 1 and return default_liturgy(:holy_saturday)
    date == easter and return default_liturgy(:easter_sunday)

    # Lent (Ash Wednesday to Good Friday)
    if date.between?(easter - 46, easter - 2)
      feast = :lent
      date == easter - 21 and return default_liturgy(:laetare)
    end

    # Ascension
    date == easter + 39 and return default_liturgy(:ascension)

    # Pentecost
    date.between?(pentecost, pentecost + 1) and return default_liturgy(:pentecost)

    # Corpus Christi
    date == easter + 60 and return default_liturgy(:corpus_christi)

    # Transfiguration
    date == date.change(day: 6, month: 8) and return default_liturgy(:transfiguration)

    # Holy cross
    date == date.change(day: 14, month: 9) and return default_liturgy(:holy_cross)

    # All Saints / Souls
    date == date.change(day: 1, month: 11) and return default_liturgy(:all_saints)
    date == date.change(day: 2, month: 11) and return default_liturgy(:all_souls)

    # Advent
    first_advent = christmas - 21 - christmas.wday
    if date.between?(first_advent, christmas - 1)
      feast = :advent
      date == first_advent + 14 and return default_liturgy(:gaudete)
    end

    # Christ King
    date == first_advent - 7 and return default_liturgy(:christking)

    # If sunday: lower priority feasts don't count
    liturgy = default_liturgy(feast)
    date.wday == 0 and return liturgy

    # Lower priority, dynamic feasts
    I18n.t("feasts.dates.#{date.month}.#{date.day}", default: liturgy)

  end

  private

  # Bare minimum feast that is returned if everything other fails.
  @@default = I18n.t('feasts.defaults.default', default: { color: 'black', title: '', description: '' })

  # Creates the liturgy-object for feasts in the default-queue.
  def self.default_liturgy(feast)
    I18n.t("feasts.defaults.#{feast}", default: @@default)
  end

end
