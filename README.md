# BugzillaMirrorClient

The BugzillaMirrorClient Gem provides a ruby library access to the [Bugzilla
Mirror REST API](https://github.com/ManageIQ/bugzilla_mirror).

## Installation

Add this line to your application's Gemfile:

    gem 'bugzilla_mirror_client'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bugzilla_mirror_client

## Usage

```
require 'bugzilla_mirror_client'

def show_response(response)
  if response.status
    puts "Request Succeeded"
    puts "Result: #{response.result}" 
  else
    puts "Request Failed"
    puts "Code: #{response.code} Message: #{response.message}"
  end
end
  
### BugzillaMirrorClient user and password is required for Updates only

client = BugzillaMirrorClient.new("http://bugzilla_mirror_host:5000",
                          "bz_account@comp.com",
                          "bz_password")

# Get a complete issue
show_response client.get(12345)

# Get certain attributes of an issue
show_response client.get(12345, "attributes" => "summary,status,assigned_to")

# Fetch multiple issues
show_response client.get([100001, 100002, 100003])

# Search issues with parameters
show_response client.search("attributes" => "summary,status,assigned_to",
                            "search" => "assigned_to=johndoe@comp.com")

# Search issues with paging
show_response client.search("attributes" => "summary,status,assigned_to",
                            "offset" => 100,
                            "limit"  => 10)

# Search issues with Paging and Attribute Sorting
show_response client.search("attributes" => "summary,status,assigned_to",
                            "offset"     => 100,
                            "limit"      => 10,
                            "sort_by"    => "summary",
                            "sort_order" => "asc")
 
# Search with Expanding Results
show_response client.search("attributes" => "summary,status,assigned_to",
                            "search"     => "assigned_to=johndoe@comp.com",
                            "expand"     => "associations")   
                            
# Search with SQL filter and Exanding Results
show_response client.search("attributes" => "summary,status,assigned_to,severity",
                            "search"     => "assigned_to=johndoe@comp.com",
                            "sqlfilter"  => "summary LIKE '%feature%'"",
                            "expand"     => "associations")
                            
# Search showing flags
show_response client.search("attributes" => "summary,status,assigned_to,flags",
                            "search"     => "status=ON_DEV")

# Refreshing a single issue from Bugzilla
show_response client.refresh(100201)

# Updating a couple of attributes in an issue
data = {
         "url" => "http://data_for_issue",
         "priority" => "medium"
       }
show_response client.update(12345, data)   

# Adding a single non-private comment to an issue
data = {
         "comment" => "this comment added via the bugzilla_mirror_client"
       }
show_response client.update(12345, data)  

# Updating data and adding a private comment
data = {
         "priority" => "high",
         "comment"  => {
           "text"    => "this comment also added via the bugzilla_mirror_client",
           "private" => true
         }
       }
show_response client.update(12345, data)  

# Deleting and Setting flags
data = {
         "priority" => "medium",
         "flags"    => {
           "pm_ack"    => "",  # Blank will delete the flag.
           "devel_ack" => "+"
         }
       }
show_response client.update(12345, data)    
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
