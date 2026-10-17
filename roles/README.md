# roles

Create the two roles here, from the repository root:

    cd roles
    ansible-galaxy role init mariadb
    ansible-galaxy role init wordpress
    cd ..

Then, in each role:

- replace `meta/main.yml` with `reference/meta-main.yml`;
- delete what you do not use (`tests/`, `vars/`, `files/`, `README.md`):
  ansible-lint checks every file that is left.
