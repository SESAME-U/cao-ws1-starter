# Workshop 1 submission

Fill in every line marked `ANSWER:` (one to four sentences each). Write the answer on the same line, right after `ANSWER:`; for pasted output, add a short summary there and paste the output below. Push before the start of the week 5 session.

## Targets

- Path used (azure or local): ANSWER:

## Design

1. Your two roles use their own names for the same database (for example `mariadb_db_name` and `wordpress_db_name`). Where are they connected, and why not use one shared name inside both roles?
   ANSWER:

2. Which tasks of your wordpress role use `ansible.builtin.command`, and how did you keep each of them idempotent?
   ANSWER:

3. What does `hostvars[groups['db'][0]]['internal_address']` return on your setup? Why does WordPress use it rather than `ansible_host`?
   ANSWER:

## Results

4. Paste the PLAY RECAP of your second run.
   ANSWER:

5. Describe one thing that did not work the first time, and how you found the cause.
   ANSWER:

## Cleanup

- Azure resource group deleted, or local containers removed (yes/no): ANSWER:
