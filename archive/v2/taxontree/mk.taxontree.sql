DROP TABLE IF EXISTS taxonomy_tree;

create table taxonomy_tree (
       taxon_id varchar(7),
       tree_id varchar(400),
       taxon_id_species varchar(7),
       taxon_name varchar(200),
       rank varchar(30),
       taxon_group varchar(30)
);

load data infile './taxonomy.tree.tab' into table taxonomy_tree;
