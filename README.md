# Stubberry
Pay attention it has 2Bs and 2Rs in naming :)

This gem is planned to be an ultimate sweet collection of stubbing methods for any kinds of testing.
Any new cool stubbing suggestions are welcome.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stubberry'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install stubberry

## Usage

Version 0.1 of this gem has two cool sets of stub methods Stubberry::Object and Stubberry::ActiveRecord


### Stubberry::Object

Set of stubbing methods added to an Object class hence available for any class or its instances. 

```ruby

# a copy/paste of an Objects stub method enriched with
# raise error functionality whenever stubbed method wasn't called
# stub_must( name, val_or_callable, *block_args )

test 'check call params with a call must happened' do 
  class_or_obj.stub_must(:run, -> ( param ) {
    # Now you can be sure: either you have an expected param, OR 
    # if call didn't happened you will see a StandardError raised 
    assert_equal( param, 1 )
  } ) { class_or_obj.run(1) }
end

```

Rem: I know about Mock object, but I don't like it. You may consider approach with mock/verify better or more object oriented e.t.c. 
But I do like an error to be aligned to the check, running mock.verify some place after check did happened, feels unnatural and uncomfortable to me

```ruby
# the reverse method of stub_must -- will raise an issue whenever method
# was called inside a stubbing block, ensures that flow didn't reach given method 
# stub_must_not( name, message = nil ) 
test 'call must not happened' do
  class_or_obj.stub_must_not(:run) { class_or_obj.call(1) }
end

# just for fun multiple stub_must in one call 
# stub_must_all( name_to_var_or_callable, &block )
test 'all calls should happened' do
  class_or_obj.stub_must_all(
    run: true,
    call: -> (param) { assert_equal(param, 1) }
  ) do 
    class_or_obj.call(1)
    class_or_obj.run(args)
  end
end

# stub only if respond_to otherwise just execute block. 
# It's a really rare case, I used only once for incompatible gems versions test 
# 
# stub_if_def(name, val_or_callable, *block_args, &block)
test 'all calls should happened' do
  class_or_obj.stub_if_def( :not_def, -> (param) { assert_equal(param, :param) } ) do
    # when there is nothing to stub, just yield
    :just_yield_this_without_stubbing
  end
end

# stub_must_if_def(name, val_or_callable, *block_args, &block)
# same as above but with stub_must under the hood
```

### Stubberry::ActiveRecord

Easy stubbing for ActiveRecord objects, you just need the id and Stubberry will do the rest.
The cool stuff about these stubbing methods is an independence from the way object retrieved. 
You can get object via find, where or any relation, it doesn't matter.
Stubbing is based on after_find callback, so whenever object instantiated 
it will be properly stubbed.

```ruby
# you can stub active record object attributes with stub_orm_attr

test 'object attributes will be stubbed in relations' do 
  Comment.stub_orm_attr(1, {body: 'ola!'} ) do 
    assert_equal( 'ola!', User.first.comments.where(id: 1).take.body )
    assert_equal( 'ola!', Comment.find(1).body )
  end
end

# you can stub active record object method with stub_orm_method
test 'object with a given id got method stubbed' do
  Comment.stub_orm_method(1, join: -> ( other ) {
    assert_equal( other.id, 2 )
  } ) do
    User.first.comments.where(id: 1).each{ _1.join( Comment.find(2) ) }
  end
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alekseyl/stubberry. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/stubberry/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Stubberry project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/stubberry/blob/master/CODE_OF_CONDUCT.md).
