# This library-class ensures proper coloring for Tapeinos. It's primary use is to check, which color's turn it is today.

class LiturgicPainter

  # This method determines the current liturgic feast. All other information is stored in localization-files.
  def self.get_feast(date)

    feast = nil

    # New Year
    date == date.change(day: 1, month: 1) and return :newyear

    # Epiphany
    epiphany = date.change(day: 6, month: 1)
    date == epiphany and return :epiphany

    # Baptism of the Lord
    baptism_jesus = epiphany + 7 - epiphany.wday
    date == baptism_jesus and return :baptism_jesus

    # Christmas
    christmas = date.change(day: 25, month: 12)
    date == christmas and return :birth_lord
    date.between(christmas, date.change(day: 31, month: 12)) or
      date.between(date.change(day: 2, month: 1), baptism_jesus) and feast = :christmas

    # Holy family
    holy_family = christmas + 7 - christmas.wday
    holy_family.year != date.year and holy_family = date.change(day: 30, month: 12)
    date == holy_family and return :holy_family

    # Presentation of the Lord
    date == date.change(day: 2, month: 2) and return :presentation_jesus

    # Easter
    easter = Date.easter(date.year)
    pentecost = easter + 39
    date.between(easter, pentecost) and feast = :easter

    # Palmsunday
    date == easter - 7 and return :palmsunday

    # Holy week
    date.between(easter - 6, easter - 4) return :holy_week
    date == easter - 3 and return :holy_thursday
    date == easter - 2 and return :good_friday
    date == easter - 1 and return :holy_saturday
    date == easter and return :easter_sunday

    # Lent (Ash Wednesday to Good Friday)
    if date.between(easter - 46, easter - 2)
      feast = :lent
      date == easter - 21 and return :laetare
    end

    # Ascension
    date == ascension + 39 and return :ascension

    # Pentecost
    date.between(pentecost, pentecost + 1) and return :pentecost

    # Transfiguration
    date == date.change(day: 6, month: 8) and return :transfiguration

    # Holy cross
    date == date.change(day: 14, month: 9) and return :holy_cross

    # All Saints / Souls
    date == date.change(day: 1, month: 11) and return :all_saints
    date == date.change(day: 2, month: 11) and return :all_souls

    # Advent
    first_advent = christmas - 21 + christmas.wday
    if date.between(first_advent, christmas - 1)
      feast = :advent
      date == first_advent + 14 and return :gaudete
    end

    # Christ King
    date == first_advent - 7 and return :christking

  end

end
