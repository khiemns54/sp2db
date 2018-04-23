namespace :sp2db do
  [
    :sp_to_csv,
    :sp_to_db,
    :csv_to_db
  ].each do |meth|
    task meth => :environment do |task, args|
      tables = args.extras
      Sp2db.send meth, *tables
    end
  end
end
