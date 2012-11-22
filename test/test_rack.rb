require 'helper'
require 'rack/mock'
require 'obscenity/rack'

class TestRack < Test::Unit::TestCase

  context "Rack::Obscenity" do
    setup do
      @env     = {}
      @body    = 'hello'
      @status  = 200
      @headers = { 'Content-Type' => 'text/plain' }
      @app     = lambda { |env| [@status, @headers, [@body]] }
    end

    def mock_env(options = {})
      @env = Rack::MockRequest.env_for('/', options)
    end

    def middleware(options = {})
      Rack::Obscenity.new(@app, options)
    end

    def get(params = {})
      { 'QUERY_STRING' => Rack::Utils.build_query(params) }
    end

    def get_response_params
      Rack::Utils.parse_query(@env['QUERY_STRING'], "&")
    end

    def post(params = {})
      { 'rack.input' => StringIO.new(Rack::Utils.build_query(params)) }
    end

    def post_response_params
      Rack::Utils.parse_query(@env['rack.input'].read, "&")
    end

    def assert_success_response(status, headers, body)
      assert_equal @status, status
      assert_equal @headers, headers
      assert_equal [@body], body
    end

    context "default configuration" do
      should "not evaluate the profanity of parameters" do
        app = middleware
        status, headers, body = app.call(mock_env)
        assert_success_response status, headers, body
      end
    end

    context "rejecting requests" do
      should "not reject if parameter values don't contain profanity" do
        app = middleware(reject: true)
        status, headers, body = app.call(mock_env(get(foo: 'bar')))
        assert_success_response status, headers, body
      end

      should "reject if GET parameter values contain profanity" do
        app = middleware(reject: true)
        status, headers, body = app.call(mock_env(get(foo: 'bar', baz: 'shit')))
        assert_equal 422, status
        assert_equal [''], body
      end

      should "reject if POST parameter values contain profanity" do
        app = middleware(reject: true)
        status, headers, body = app.call(mock_env(post(foo: 'bar', baz: 'ass')))
        assert_equal 422, status
        assert_equal [''], body
      end

      should "reject if given parameter values contain profanity" do
        app = middleware(reject: { params: [:foo] })
        [ get(foo: 'ass', baz: 'shit'),
          post(foo: 'ass').merge(get(foo: 'nice', baz: 'shit'))
        ].each do |options|
          status, headers, body = app.call(mock_env(options))
          assert_equal 422, status
          assert_equal [''], body
        end
      end

      should "not reject if other parameter values contain profanity" do
        app = middleware(reject: { params: [:foo] })
        status, headers, body = app.call(mock_env(get(foo: 'nice', baz: 'shit')))
        assert_success_response status, headers, body
      end

      should "reject if parameter values contain profanity" do
        app = middleware(reject: { params: :all })
        status, headers, body = app.call(mock_env(get(foo: 'ass')))
        assert_equal 422, status
        assert_equal [''], body
      end

      should "reject if parameter values contain profanity and display a custom message" do
        app = middleware(reject: { message: "We don't accept profanity" })
        status, headers, body = app.call(mock_env(get(foo: 'ass')))
        assert_equal 422, status
        assert_equal ["We don't accept profanity"], body
      end

      should "reject if parameter values contain profanity and render a custom file" do
        app = middleware(reject: { path: "test/static/422.html" })
        status, headers, body = app.call(mock_env(get(foo: 'ass')))
        assert_equal 422, status
        assert_equal ["We don't accept profanity"], body
      end

      should "reject parameter values when they're a hash and contain profanity" do
        app = middleware(reject: true)
        status, headers, body = app.call(mock_env(get(foo: 'clean', bar: {one: 'ass'})))
        assert_equal 422, status
        assert_equal [''], body
      end
    end

    context "sanitizing requests" do
      should "not sanitize if parameter values don't contain profanity" do
        app = middleware(sanitize: true)
        status, headers, body = app.call(mock_env(get(foo: 'bar')))
        assert_success_response status, headers, body
        request_params = get_response_params
        assert_equal 'bar', request_params['foo']
      end

      should "sanitize if GET parameter values contain profanity" do
        app = middleware(sanitize: true)
        status, headers, body = app.call(mock_env(get(foo: 'bar', baz: 'shit')))
        assert_success_response status, headers, body
        request_params = get_response_params
        assert_equal 'bar', request_params['foo']
        assert_equal '$@!#%', request_params['baz']
      end

      should "sanitize if POST parameter values contain profanity" do
        app = middleware(sanitize: true)
        status, headers, body = app.call(mock_env(post(foo: 'bar', baz: 'ass')))
        assert_success_response status, headers, body
        request_params = post_response_params
        assert_equal 'bar', request_params['foo']
        assert_equal '$@!#%', request_params['baz']
      end

      should "not sanitize if other parameter values contain profanity" do
        app = middleware(sanitize: { params: [:foo] })
        status, headers, body = app.call(mock_env(get(foo: 'nice', baz: 'shit')))
        assert_success_response status, headers, body
        request_params = get_response_params
        assert_equal 'nice', request_params['foo']
        assert_equal 'shit', request_params['baz']
      end

      should "sanitize if parameter values contain profanity" do
        app = middleware(sanitize: { params: :all })
        status, headers, body = app.call(mock_env(get(foo: 'ass')))
        assert_success_response status, headers, body
        request_params = get_response_params
        assert_equal '$@!#%', request_params['foo']
      end

      should "sanitize the title using the :garbled replacement" do
        app = middleware(sanitize: { replacement: :garbled })
        status, headers, body = app.call(mock_env(get(foo: 'ass')))
        assert_success_response status, headers, body
        request_params = get_response_params
        assert_equal '$@!#%', request_params['foo']
      end

      should "sanitize the title using the :stars replacement" do
        app = middleware(sanitize: { replacement: :stars })
        status, headers, body = app.call(mock_env(get(foo: 'ass')))
        assert_success_response status, headers, body
        request_params = get_response_params
        assert_equal '***', request_params['foo']
      end

      should "sanitize the title using the :vowels replacement" do
        app = middleware(sanitize: { replacement: :vowels })
        status, headers, body = app.call(mock_env(get(foo: 'ass')))
        assert_success_response status, headers, body
        request_params = get_response_params
        assert_equal '*ss', request_params['foo']
      end

      should "sanitize the title using the :nonconsonants replacement" do
        app = middleware(sanitize: { replacement: :nonconsonants })
        status, headers, body = app.call(mock_env(get(foo: '5hit')))
        assert_success_response status, headers, body
        request_params = get_response_params
        assert_equal '*h*t', request_params['foo']
      end

      should "sanitize the title using a custom replacement" do
        app = middleware(sanitize: { replacement: "[censored]" })
        status, headers, body = app.call(mock_env(get(foo: 'text with ass')))
        assert_success_response status, headers, body
        request_params = get_response_params
        assert_equal 'text with [censored]', request_params['foo']
      end
    end
  end

end
