const LOFTER_COOKIE = 'usertrack=3MUhQWpHbSqbrh9vPAr6Ag==; JSESSIONID-WLF-XXD=1a0fa0cfbe483ee89724840ba113e72f733f81ea289c8b5616c66cba85b4b4d8da24a82c857930888a4288d4de74ff7333063e5706558ef777a44075d955409724dc3ae4b12ebeda1030afbb04c67a70c508fb32eb5c2f72517dd89a53564ba7efaf9a5806357076b6a5eff3bb2aa9ea02a7ab7aa9009d5c3c67167558fbb01dffb9fb3c; LOFTER-PHONE-LOGINNUM=15643110242; LOFTER-PHONE-LOGIN-FLAG=1; LOFTER-PHONE-LOGIN-AUTH=qLGJVi-GFGBGp2HtSeDbNgVxzJ3ocO8bScklIbDDAPBlcjpXLdBbcpfFHomzUBdhfNLdNm-puzQPuy4BhCNqSkzyu-bV-Q9I; token=qLGJVi-GFGBGp2HtSeDbNgVxzJ3ocO8bScklIbDDAPBlcjpXLdBbcpfFHomzUBdhfNLdNm-puzQPuy4BhCNqSkzyu-bV-Q9I; phone=15643110242; deviceid=2b9ea7c7-ae0c-4bd2-844b-6808a21be7c7; __LOFTER_TRACE_UID=98961F987C884958807D866329075BD5#2888385206#14; firstentry=%2Fblogindex.do%3FloftBlogName%3Dpingpangdaguoshou%26|; reglogin_isLoginFlag=1; reglogin_isLoginFlag=1; regtoken=2000; hb_MA-BFD7-963BF6846668_source=pingpangdaguoshou.lofter.com; NEWTOKEN=OTUzNTk0N2NjMWE2M2NjNTA3NDc5YzRlMDk0MWQ0OTg1OTJhNjVmOWM4ZTg3MDllMjUxNDYyNWQ1MzI5NDAzMGMyYjIyMWJmZGQ0OGZhZDA1Yjk5ZDQxNDgxMDczMmJj';

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.status(200).end();

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { article_url, liker_name } = req.body;

  if (!article_url || !liker_name) {
    return res.status(400).json({ error: '缺少参数' });
  }

  try {
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
      return res.status(502).json({ error: 'Cookie可能已过期，请联系管理员更新', htmlSize: html.length });
    }

    // Extract liker names from title attributes: "显示名 - 时间"
    // Also try href-based extraction as fallback
    const noteRegex = /<a\s+[^>]*href="\/\/[^"]*lofter\.com\/?"[^>]*title="([^"]+)"/g;
    let match;
    const likerNames = [];
    while ((match = noteRegex.exec(html)) !== null) {
      const titleAttr = match[1];
      const name = titleAttr.split(' - ')[0].trim();
      if (name) likerNames.push(name);
    }

    // Match by display name (case-insensitive, trimmed)
    const found = likerNames.some(n => n === liker_name.trim());

    return res.status(200).json({
      verified: found,
      liker_count: likerNames.length,
      likers: [...new Set(likerNames)].slice(0, 20),
      liker_name: liker_name,
    });

  } catch (err) {
    return res.status(500).json({ error: '验证失败: ' + err.message });
  }
}
