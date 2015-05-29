require 'fileutils'

class Renamer
  def initialize(name)
    @name = name.downcase
  end

  def rename
    replace_text_in_files
    rename_project_dir
    rename_project_file
    replace_git_dir
    create_gem_wrappers
  end

  private
  def create_gem_wrappers
    p "Creating rvm helper files"
    FileUtils.cd('..')
    FileUtils.cd(name)
  end

  def replace_git_dir
    p "Removing exisiting .git directory"
    git_dir = get_path('../.git')
    FileUtils.rm_r(git_dir)
    p "Initializing new .git directory"
    system('git init')
  end
  
  def rename_project_dir
    p "Renaming project directory to #{name}"
    rename_file('../..')
  end

  def rename_project_file
    p "Renaming project file to #{name}.rb"
    rename_file('..', '.rb')
  end

  def replace_text_in_files
    p "Replacing text in project files"
    %w[.ruby-gemset testable.rb spec.rb].each do |filename|
      replace_text_in_file(filename)
    end
  end

  def replace_text_in_file(file)
    f = File.read(file)
    f.gsub!('testable', name)
    f.gsub!('Testable', camel_cased(name))
    File.open(file, 'w') { |updated| updated << f }
  end

  def rename_file(base_path, extension = nil)
    base = get_path(base_path)
    File.rename("#{base}/testable#{extension}", "#{base}/#{name}#{extension}")
  end

  def get_path(relative)
    File.expand_path(relative, __FILE__)
  end

  def camel_cased(str)
    str.split('_').map(&:capitalize).join
  end

  def name
    @name
  end
end

updated = ARGV[0]
if updated.nil?
  raise "\n\nUsage: `ruby rename.rb project_name`\n\n"
end

Renamer.new(updated).rename

