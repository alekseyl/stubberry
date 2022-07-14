# 0.3.0
* rubocop-shopify added as a base linter
* assertion for method called rewritten to use stub_must under the hood
* DRYied some methods to Stubberry module methods
* introduced ruby 3.0 kwargs compatible signatures 


# 0.2.0
* new module with assertion methods added 
* assert_method_called added, this is a flow assertion, you can check the params, and you can check that method was called inside the block, 
  without stubbing objects and interfering with the original flow 
* minimal ruby version set to 2.5 ( so we can replace indirect invocations via send(:*_method ) to direct invocations )
* singleton_classes is now properly cleared after, see PR: https://github.com/seattlerb/minitest/pull/891
* some methods got '__' prefixes, just to prevent naming collisions  
  

# 0.1.1
* initial gem release
* Stubberry::Object module with stub_must, stub_must_not, stub_must_all, stub_if_* methods
* Stubberry::ActiveRecord easy id based stubbing active record objects inside some actions flow 