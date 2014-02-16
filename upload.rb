# -*- coding: utf-8 -*-
require '/mnt/sd/sources/twitter.rb'
require '/mnt/sd/sources/post_to_box.rb'

Twitter.new.post('Upload program is launched!')
PostToBox.new.execute