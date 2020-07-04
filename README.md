# Twitter Thread Getter

Given a tweet ID this script will:

1. fetch all replies to that thread using the twitter API
2. resolve any t.co urls to the original url
3. fetch the referenced URLS and extract the Title page (or title from meta tag for Youtube urls)
4. collate stats about the referenced urls counting up how many times each url is referenced, and also recording the twitter handles of people who referenced each url

Logging output is sent to STDERR

Program output is sent to STDOUT in the form of a CSV file

## Dependencies

- ruby
- `t` gem (`gem install t`)

## Authentication

You must authenticate to twitter using the `t` command line program to set up your twitter credentials. See https://github.com/sferik/t#configuration for details

## Usage

```
$ ./bin/collate_stats 1278537744352862208 > stats.csv
I, [2020-07-04T12:02:22.400613 #80901]  INFO -- : Fetching tweets...
I, [2020-07-04T12:02:22.838022 #80901]  INFO -- : Collating tweets in 20 threads

```

## Errors

If you exceed your rate limit you may get

```
...request.rb:97:in `fail_or_return_response_body': Rate limit exceeded (Twitter::Error::TooManyRequests)
```

