const LOFTER_COOKIE = process.env.LOFTER_COOKIE || '';

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { article_url, liker_blog } = req.body;

  if (!article_url || !liker_blog) {
    return res.status(400).json({ error: '缺少参数' });
  }

  if (!LOFTER_COOKIE) {
    return res.status(500).json({ error: '服务端未配置LOFTER Cookie' });
  }

  try {
    // Normalize liker blog URL for comparison
    // e.g. "https://xxx.lofter.com/" → "xxx.lofter.com"
    let likerDomain = '';
    try {
      const u = new URL(liker_blog);
      likerDomain = u.hostname;
    } catch {
      likerDomain = liker_blog.replace(/^https?:\/\//, '').replace(/\/.*$/, '');
    }

    // Fetch the article page with login cookie
    const resp = await fetch(article_url, {
      headers: {
        'Cookie': LOFTER_COOKIE,
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml',
        'Accept-Language': 'zh-CN,zh;q=0.9',
      },
      redirect: 'follow',
    });

    const html = await resp.text();

    if (html.length < 10000) {
      return res.status(502).json({ error: '获取文章页失败（可能是Cookie过期）', htmlSize: html.length });
    }

    // Parse the notes section - extract all liker blog links
    // Format: <a href="//username.lofter.com/" title="username - time">
    const noteRegex = /<li class="note[^"]*"[^>]*>[\s\S]*?<a\s+href="\/\/([^"]+)"\s+title="([^"]+)"/g;
    let match;
    const likers = [];
    while ((match = noteRegex.exec(html)) !== null) {
      const blogDomain = match[1]; // e.g. "pingpangdaguoshou.lofter.com"
      const titleInfo = match[2]; // e.g. "乒乓大国手 - 11小时前"
      likers.push({ blog: blogDomain, title: titleInfo });
    }

    // Check if liker's blog domain is in the list
    const found = likers.some(l => l.blog === likerDomain);

    return res.status(200).json({
      verified: found,
      liker_count: likers.length,
      likers: likers.slice(0, 10).map(l => l.title.split(' - ')[0]),
      liker_domain: likerDomain,
    });

  } catch (err) {
    return res.status(500).json({ error: '验证失败: ' + err.message });
  }
}
