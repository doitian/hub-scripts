# GitHub Scripts

All the scripts read [Github personal access
token](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line#creating-a-token) from environment variable `GITHUB_TOKEN`. It can be set in `.env` file:

```
GITHUB_TOKEN=""
```

## console.rb

Start a pry console, the client is available as the global variable `$github`.

## batch-cards.rb

```
batch-cards.rb cards.json
```

Add cards into a board in batch. The JSON file format looks like:

```
{
  "12345": [
    123,
    "example note"
  ]
}
```

Where the key is the column id, which can be get from the copied column link.
For example the column id of `https://github.com/github/hub/projects/1#column-1391000` is 1391000.

Each element of the value array is a card. The element can be either an
integer or a string.

- If the element is an integer, it is considered as the issue ID. The issue with the ID will be added to the column. **Pay attention that**, issue ID is different from the issue number displayed in the web page. 
- If the element is a string, a card is created in the column with the string
  as the content.

## export-column.rb

```
export-column.rb column template.erb
```

Export a project column using an ERB template. See the example
template `template/column_item.erb`.


## export-issues.rb

```
export-issues.rb user/repo
```

Export issues to JSON into directory `out` organized by repository. It also stores a timestamp, and
only export new issues when timestamp file is found.

## export-labels.rb

```
export-labels.rb user/repo
```

Export labels to JSON into directory `out` organized by repository. The JSON
file can later be used in `import-labels.rb`.


## import-labels.rb

```
import-labels.rb user/repo issues.json
```

Import labels from JSON into repository.


## transfer-issue.rb

```
transfer-issue.rb from_repo to_repo number...
```

Example:
Transfer #100 #101 and #102 from `user1/repo1` to `user2/repo2`

```
transfer-issue.rb user1/repo1 user2/repo2 100 101 102
```

The difference with the GitHub "Transfer Issue" feature is that:

- The script preserves labels.
- It does not delete the old issue. Instead, the script adds the URL of the transferred issue
  to the old issue as a comment and closes the old issue.
- It does not transfer comments.
