class Language < ActiveRecord::Base
  attr_accessible :name, :code

  has_many :resources

  before_save :update_resource_lang

  def save_lang(resource, resource_language)
    a = ['en','fr','zh']
    if a.include?(resource_language)

      language = Language.find_by_code(resource_language)
      resource.language_id = language.id
      if resource.save
        puts "I saved?"
      end

    end

  end

  def update_resource_lang
    require 'nokogiri'
    require 'open-uri'
    require 'uri'

    DetectLanguage.configure do |config|
      config.api_key = "927256800b03882160b17f08badd5e7f"
    end
    count = 0
    resources = Resource.where("language_id IS NULL")
    resources.each do | resource |
      count = count+1
      puts ("count: %s" % count)
      #Resource.find(11819) do | resource |
      #resource = Resource.find(self.id)
      puts resource.id

      if !resource.download_url.blank?
        url = resource.download_url
      else
        url = resource.source_url
      end

      if (!url.nil?) and (url =~ URI::regexp)

        begin
          file = open(url)
          if url =~ (/\A(http:\/\/+).+(\.pdf)\z/)
            begin
              reader = PDF::Reader.new(file)
              page = reader.page(1)
              text = page.text
              puts text
              begin
                resource_language = DetectLanguage.simple_detect(text)
                puts resource_language
                save_lang(resource, resource_language)
              rescue EOFError
                puts "encountered EOFError"
              end
            rescue PDF::Reader::MalformedPDFError => e
              if e.message
                # handle 404 error
              else
                raise e
              end
            end

          else
            whole_doc = Nokogiri::HTML(file)

            if !whole_doc.nil?
              whole_doc.css('script').remove
              whole_doc.css('style').remove
              whole_doc.xpath('//body').each do | doc |
                doc = doc.inner_html.encode('utf-8')
                doc_string = doc.to_s
                begin
                  clean_page = ActionView::Base.full_sanitizer.sanitize(doc_string)
                  clean_page = clean_page.split.join(" ")
                  clean_page = clean_page.delete! '&#160;'
                  puts clean_page
                  resource_language = DetectLanguage.simple_detect(clean_page)
                  puts resource_language
                  save_lang(resource, resource_language)
                rescue ArgumentError
                  puts 'Could not sanitize. Probably due to: invalid byte sequence in UTF-8'
                end
                #if !clean_page.nil?

                #clean_page = clean_page.delete! '·'

                #if !clean_page.nil?
                #clean_page = clean_page.delete! '•'
                #clean_page = clean_page.delete! '”'
                #clean_page = clean_page.delete! '“'
                # clean_page = clean_page.delete! '©'
                #clean_page = clean_page.delete! '"'
                #clean_page = clean_page.delete! '、'
                #clean_page = clean_page.delete! '一'
                #clean_page = clean_page.delete! '-'
                #clean_page = clean_page.delete! '：'
                #clean_page = clean_page.sub(/《[^()]*》/, '' )
                #clean_page = clean_page.sub(/《[^()]*》/, '' )
                ##clean_page = clean_page.sub(/【[^()]*】/, '' )
                #clean_page = clean_page.sub(/：[^()]*：/, '' )
                #clean_page = clean_page.sub(/\|[^()]*\|/, '' )
                #clean_page = ActionController::Base.helpers.strip_tags(doc_string)
                #clean_page = Sanitize.clean(doc_string)
                #clean_page = doc_string
                #clean_page = "29年9月29日 发布 科技 欢迎您 设置登出 登入新手指南免费注册您的反馈 文章 日期 电子邮件 密码 记住我 帮我找回密码 首页  专题报道 专题报导 23年中国两会 22中国年度报告 中共十八大 与FT共进午餐 有色眼镜 热门文章 热门文章 周 月 季度 年度 会议活动 会议活动 近期活动 往期活动 赞助活动 关于我们 会员服务 会员服务 会员信息中心 社区 FT商学院 英语学习 英语学习 每日英语 金融英语速读 FT.com 图辑 职业机会 中国  政经 商业 金融市场 股市 房地产 社会与文化 社会与文化 剃刀边缘 观点 观点 媒体札记 中国纪事 远观中国 第三眼 全球  美国 英国 亚太 欧洲 欧洲 欧元区危机 美洲 非洲 经济  全球经济 中国经济 贸易 环境 环境 中外对话 城市未来 能源未来 经济评论 经济评论 马丁沃尔夫 吉莲邰蒂 卧底经济学家 亲爱的经济学家 天则横议 CMRC朗润经济评论 经济观察者 经济人 金融市场  股市 外汇 债市 大宗商品 金融市场数据 商业  金融 金融 金融危机 银行业未来 资本主义未来 科技 汽车 房地产 农林 能源 工业和采矿 航空和运输 医药 娱乐 零售和消费品 传媒和文化 工具 工具 移动应用大全 基本设置 修改头像 邮件订阅 同步微博 我的评论 管理收藏 关注我们 关注我们 新浪微博 腾讯微博 网易微博 搜狐微博 QQ空间 新浪博客 搜狐博客 网易博客 人人网 FaceBook Twitter Google+ 观点  Lex专栏 A-List 专栏 分析 评论 社评 书评 读者有话说 管理  FT商学院 FT商学院 互动教程 商业教育 商学院排名 职场 职场 露西凯拉韦专栏  汤姆博格斯 尼日利亚拉各斯报道 字号 最大 较大 默认 较小 最小 背景                     英文 对照 评论 打印 电邮 收藏   家中国国有石油公司正与尼日利亚谈判，以收购些世界上储量最丰富的油田区块的大宗股份，若交易成功，此举将超过中国政府以往争取获得海外原油资源的努力。 上述投标将使中方与西方石油集团展开竞争，其中包括壳牌(Shell)、雪佛龙(Chevron)、道达尔(Total)和埃克森美孚(ExxonMobil)，这些公司拥有23个相关区块的部分或全部控制权及经营权。共有份执照现在需要更新。 中国三大能源集团之的中海油(CNOOC)，正寻求获得亿桶石油的储量，相当于尼日利亚已探明储量的六分之。尼日利亚是撒哈拉以南非洲最大的产油国，也是美国的重要石油供应来源之。 尼日利亚总统奥马鲁亚拉杜瓦(Umaru Yar'Adua)的办公室致中海油代表Sunrise的封信中，透露了相关谈判细节，英国得到了此信的份副本。中方提出的总价没有披露，尽管从某些细节看，该数字约为3亿美元。石油行业的些高管称，谈判的总额高达5亿美元。 亚拉杜瓦的名发言人表示：我们不仅在与Sunrise/中海油谈判，也在与业内的其他所有利益相关者谈判。联邦政府还没有在这个问题上做出任何最终决定。 这份日期为8月3日的信函称，最初的出价是不可接受的，但补充道：若贵方修改后的出价令人满意，贵方对所有竞拍区块的兴趣将得到考虑。 有关尼日利亚政府将如何向中海油分配这些区块的股份，外界尚不得而知，目前不清楚这是否将涉及迫使西方集团放弃股份。 这些事有严重的法律影响。你不想闹上法庭，但如果真到了那个地步，你也没有什么选择，名石油业知情人士表示。 中国在尼日利亚获得重大立足点的努力，突显其在全球各地争取获得能源资源的长远雄心的规模。迄今中国的投资有相当大部分投入勘探，这与尼日利亚的情况形成反差，尼日利亚的这些油田区块已经投产或即将投产。 尼日利亚总统的经济顾问塔尼穆雅库布(Tanimu Yakubu)表示，中国也许无法从谈判中得到任何接近亿桶的储量。他补充说：我们希望留住自己的老朋友。 不过，雅库布告诉英国，中方的确在提议支付数倍于现有生产商[为获得执照]而承诺的数额……我们乐于见到这种竞争。 壳牌在尼日利亚的负责人巴兹尔奥米依(Basil Omiyi)表示：这些区块正在积极的勘探、开发和开采过程中，相关工作大多是由政府拥有多数股权、壳牌负责经营的合资企业进行的。中海油拒绝置评。 译者/和风 相关文章： Lex专栏：忙碌的新兴市场掠食者 2-3- 加纳拟阻挠埃克森美孚投资Jubilee油田 29--3 中国须担心尼日利亚政局 29-- 尼日利亚叛乱组织反对中海油竞购油田 29-9-3 分析：中西相争尼日利亚 29-9-3 汤姆博格斯上篇文章： 中国将提前向中非发展基金追加注资 29-3-7 本文涉及话题：中海油 尼日利亚 海外收购 排序:时间倒序 时间升序 热门程度 我发表的评论评论总数 [查看评论] FT中文网欢迎读者发表评论，部分评论会被选进 栏目。我们保留编辑与出版的权利。 匿名发表 将评论同步到微博 小提示:设置个头像，将会使您发表的评论更容易受到大家关注。点此马上设置 请登录输入评论 电子邮件:     密码: 免费注册 未经英国 书面许可，对于英国 拥有版权和/或其他知识产权的任何内容，任何人不得复制、转载、摘编或在非FT中文网（或：英国 中文网）所属的服务器上做镜像或以其他任何方式进行使用。已经英国 授权使用作品的，应在授权范围内使用。 相关文章 Lex专栏：忙碌的新兴市场掠食者 加纳拟阻挠埃克森美孚投资Jubilee油田 中国须担心尼日利亚政局 尼日利亚叛乱组织反对中海油竞购油田 分析：中西相争尼日利亚 /7FT商学院 英语速读：雨天基金与英国银行业 英语速读：巴菲特口味的收购 英语速读：经济自由主义地基牢固 英语速读：加拿大对外资关上大门？ /2 十大热门文章 天 周 月 视频 北京前市长陈希同病故 日元贬值可能导致中国资产泡沫破裂 中国心态：自信与不安并存 何为新型大国关系？ 温哥华的陪读妈妈 最适合创业的八个行业 美中首脑衬衣峰会 美国学者眼中的中美关系 媒体札记：光伏战 中国：欧盟应认清自己衰落现实 为金家王朝善后 当中国遭遇最难就业季 中国式购房的尴尬 媒体札记：求助的代价 领土争端应交由国际仲裁 中国择友新标准 中国海军回访美国专属经济区 刚需是否意味买房？ 媒体札记：流氓燕 北京前市长陈希同病故 中国政治变革的隐含逻辑 分析：中国房价再升背后的原因 禁止中国入内的俱乐部？ 日本为何突然奋起？ 为金家王朝善后 从住院的老干部谈起 中国式购房的尴尬 不小心当了十三姨太 媒体札记：宪政梦醒 媒体札记：国两制 欧逸文 中国正在输掉货币战争？ 中国水危机 3年见淘金热 更多排行榜 ﻿ 评论最多文章 更多排行榜 视频 威尼斯双年展作品：谷歌砖 威尼斯双年展作品：威尼斯的海水 ﻿ 关注我们 了解更多 FT中文网专栏 会员服务 社区 会员信息中心 会议活动 金融速读训练 图辑 RSS Twitter官方帐户 新浪微博官方帐户 手机站 邮件服务 我的评论 管理收藏 FT专栏作家 马丁沃尔夫 露西凯拉韦 约翰奥瑟兹 戴维皮林 卧底经济学家 吉莲邰蒂 吉迪恩拉赫曼 约翰加普 菲利普斯蒂芬斯 斯特凡斯特恩 约翰凯 克莱夫克鲁克 塞缪尔布里坦 约翰普伦德 亲爱的经济学家 卢克约翰逊 钱眼太太 简氏酒庄 相关链接 培生集团 金融时报英文版 DK中国 纽约金融学院 Edexcel 培生教育 Pearson VUE Pearson PTE 企鹅中国 关于我们 加入我们 问题回馈 联系方式 合作伙伴 服务条款 广告业务 版权声明 最新动态  The Financial Times Ltd 23 FT and 'Financial Times' are trademarks of The Financial Times Ltd."

                #puts doc
                #puts clean_page.full_lang  # Causing html error
                #puts DetectLanguage.detect(clean_page)

                #end
              end
            end
          end


            #puts doc.encoding
        rescue SocketError, OpenURI::HTTPError
          puts "Socket/Http Error :("
          end
        end
      end
    end
  end
end
