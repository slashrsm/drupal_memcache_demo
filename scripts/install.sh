#!/bin/bash
set -e
set -o pipefail

DATABASE_NAME=db
USER_COUNT=5000
CONTENT_COUNT=10000
MAX_COMMENTS=20
USER_PASSWORD=12345

echo "Installing drupal from existing config (devel and memcache installed, anon has 'access user profiles' permission)."
vendor/bin/drush site:install -v minimal --existing-config --yes --sites-subdir=default

echo "Creating ${USER_COUNT} users, this may take a while..."
vendor/bin/drush devel-generate:users ${USER_COUNT}
echo "Creating ${CONTENT_COUNT} nodes with up to ${MAX_COMMENTS} comments each, this may take a while..."
vendor/bin/drush devel-generate:content ${CONTENT_COUNT} ${MAX_COMMENTS}

echo "Setting Drupal usernames and passwords to those that the test expects..."
for i in $(seq 2 5001)
do
  password_hash=`./web/core/scripts/password-hash.sh 12345 | cut -f 3 | cut -d " "  -f 2`
  mysql -e "UPDATE users_field_data SET name='user${i}', pass='${password_hash}' WHERE uid='${i}'"
done

echo "Creating a mysqldump of the drupal install with test data..."
mysqldump --single-transaction ${DATABASE_NAME} | gzip > /var/www/html/drupal_with_test_content.sql.gz
ls -lh /var/www/html/drupal_with_test_content.sql.gz

