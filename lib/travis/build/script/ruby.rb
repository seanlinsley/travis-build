module Travis
  module Build
    class Script
      class Ruby < Script
        DEFAULTS = {
          rvm:     'default',
          gemfile: 'Gemfile'
        }

        include Jdk

        def export
          super
          set 'TRAVIS_RUBY_VERSION', config[:rvm], echo: false
        end

        def setup
          super
          setup_ruby
          setup_bundler
        end

        def announce
          super
          cmd 'ruby --version'
          cmd 'gem --version'
          cmd 'rvm --version'
        end

        def install
          gemfile? then: "bundle install #{config[:bundler_args]}", fold: 'install'
        end

        def script
          gemfile? then: 'bundle exec rake', else: 'rake'
        end

        private

          def setup_ruby
            cmd "rvm use #{ruby_version} --install --binary --fuzzy"
          end

          def setup_bundler
            gemfile? do |sh|
              set 'BUNDLE_GEMFILE', "$PWD/#{config[:gemfile]}"
            end
          end

          def gemfile?(*args, &block)
            self.if "-f #{config[:gemfile]}", *args, &block
          end

          def uses_java?
            config[:rvm] =~ /jruby/i
          end

          def uses_jdk?
            uses_java? && super
          end

          def ruby_version
            ruby_version = config[:rvm].to_s.gsub(/-(1[89]|20)mode$/, '-d\1')
            ruby_version.gsub(/^rbx-d(\d{2})$/, 'rbx-weekly-d\1')
          end
      end
    end
  end
end
