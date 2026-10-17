# Reference files

Boilerplate you do not have to write from scratch. Copy each file into the
right role's `templates/` folder (or `meta/`), then replace every value marked
TODO with a variable. The handout says which role each file belongs to.

| File | Goes to | Replace |
| --- | --- | --- |
| `60-cao.cnf.j2` | `roles/mariadb/templates/` | the bind address |
| `nginx-wordpress.conf.j2` | `roles/wordpress/templates/` | the web root, the PHP version |
| `wp-config.php.j2` | `roles/wordpress/templates/` | database settings, the secret seed |
| `meta-main.yml` | `roles/<role>/meta/main.yml` | the description |
