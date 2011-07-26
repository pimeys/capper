# helper method to load a block into the capistrano namespace
class Capper
  def self.load(&block)
    Capistrano::Configuration.instance(true).load(&block)
  end
end
