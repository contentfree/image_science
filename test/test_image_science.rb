require 'test/unit/testcase'
require 'test/unit' if $0 == __FILE__
require 'image_science'

class TestImageScience < Test::Unit::TestCase
  def deny x; assert ! x; end

  def setup
    @path = 'test/pix.png'
    @tmppath = 'test/pix-tmp.png'
    @h = @w = 50
  end

  def teardown
    File.unlink @tmppath if File.exist? @tmppath
  end

  def test_class_with_image
    ImageScience.with_image @path do |img|
      assert_kind_of ImageScience, img
      assert_equal @h, img.height
      assert_equal @w, img.width
      assert img.save(@tmppath)
    end

    assert File.exists?(@tmppath)

    ImageScience.with_image @tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal @h, img.height
      assert_equal @w, img.width
    end
  end

  def test_class_with_image_missing
    assert_raises TypeError do
      ImageScience.with_image @path + "nope" do |img|
        flunk
      end
    end
  end

  def test_class_with_image_missing_with_img_extension
    assert_nil ImageScience.with_image("nope#{@path}") do |img|
      flunk
    end
  end

  def test_resize
    ImageScience.with_image @path do |img|
      img.resize(25, 25) do |thumb|
        assert thumb.save(@tmppath)
      end
    end

    assert File.exists?(@tmppath)

    ImageScience.with_image @tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 25, img.height
      assert_equal 25, img.width
    end
  end

  def test_resize_floats
    ImageScience.with_image @path do |img|
      img.resize(25.2, 25.7) do |thumb|
        assert thumb.save(@tmppath)
      end
    end

    assert File.exists?(@tmppath)

    ImageScience.with_image @tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 25, img.height
      assert_equal 25, img.width
    end
  end

  def test_resize_zero
    assert_raises ArgumentError do
      ImageScience.with_image @path do |img|
        img.resize(0, 25) do |thumb|
          assert thumb.save(@tmppath)
        end
      end
    end

    deny File.exists?(@tmppath)

    assert_raises ArgumentError do
      ImageScience.with_image @path do |img|
        img.resize(25, 0) do |thumb|
          assert thumb.save(@tmppath)
        end
      end
    end

    deny File.exists?(@tmppath)
  end

  def test_resize_negative
    assert_raises ArgumentError do
      ImageScience.with_image @path do |img|
        img.resize(-25, 25) do |thumb|
          assert thumb.save(@tmppath)
        end
      end
    end

    deny File.exists?(@tmppath)

    assert_raises ArgumentError do
      ImageScience.with_image @path do |img|
        img.resize(25, -25) do |thumb|
          assert thumb.save(@tmppath)
        end
      end
    end

    deny File.exists?(@tmppath)
  end
  
  def test_rotate
    @path = 'test/ruby.jpg'
    @tmppath = 'test/ruby-tmp.jpg'
    
    ImageScience.with_image @path do |img|
      img.rotate(90) do |rotated|
        assert rotated.save(@tmppath)
      end
    end
    
    ImageScience.with_image @tmppath do |img|
      assert_equal 70, img.width
      assert_equal 50, img.height
    end
  end
  
  def test_rotate_float
    @path = 'test/ruby.jpg'
    @tmppath = 'test/ruby-tmp.jpg'
    
    ImageScience.with_image @path do |img|
      img.rotate(90.0) do |rotated|
        assert rotated.save(@tmppath)
      end
    end
  end
  
  def test_rotate_jpg
    @path = 'test/ruby.jpg'
    @tmppath = 'test/ruby-tmp.jpg'
    
    ImageScience.with_image @path do |img|
      assert_equal 50, img.width
      assert_equal 70, img.height
    end
    
    ImageScience.rotate_jpg( @path, @tmppath, true )
    ImageScience.with_image @tmppath do |img|
      assert_not_equal 50, img.width # Just test for not_equal because rotate_jpg might shave off pixels since we're not setting the 'perfect' parameter in the method call
      assert_not_equal 70, img.height
    end
  end
  
  def test_rotate_jpg_without_file
    @path = 'test/FAKE.jpg'
    @tmppath = 'test/ruby-tmp.jpg'
    
    assert_raises RuntimeError do
      ImageScience.rotate_jpg( @path, @tmppath, true ) 
    end
    
    deny File.exists?(@tmppath)
  end
  
  # The test file is 50x70 and won't rotate absolutely losslessly. FreeImage chops 
  # off 6 pixels from the left hand side. See the docs for rotate_jpg for more info.
  def test_perfect_rotate_jpg
    @path = 'test/ruby.jpg'
    @tmppath = 'test/ruby-tmp.jpg'
    
    assert_raises RuntimeError do
      ImageScience.rotate_jpg( @path, @tmppath, true, true ) 
    end
    
    deny File.exists?(@tmppath)
  end
end
