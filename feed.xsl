<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:atom="http://www.w3.org/2005/Atom" exclude-result-prefixes="atom">
  <xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes" />
  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
        <title>Web Feed • <xsl:value-of select="atom:feed/atom:title"/>
        </title>
        <link rel="stylesheet" href="/stylesheet.css" />
        <style type="text/css">
          body {
            max-width: 768px;
            margin: 0 auto;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI",
              Helvetica, Arial, sans-serif, "Apple Color Emoji",
              "Segoe UI Emoji", "Segoe UI Symbol";
            font-size: 16px;
            line-height: 1.5em;
            background-color: #222;
            color: white;
          }
          section {
            margin: 30px 15px;
          }
          h1 {
            font-size: 2em;
            margin: 0.67em 0;
            line-height: 1.125em;
          }
          h2 {
            border-bottom: 1px solid #eaecef;
            padding-bottom: 0.3em;
          }
          .alert {
            background: #fff5b1;
            color: black;
            padding: 4px 12px;
            margin: 0 -12px;
            border-radius: 8px;
            box-shadow: 0 4px 4px rgba(0, 0, 0, 0.15);
          }
          .alert a {
            color: blue;
          }
          .alert a:visited {
            color: purple;
          }
          .entry h3 {
            margin-bottom: 0;
          }
          .entry p {
            margin: 4px 0;
          }

          header {
            text-align: center;
            position: relative;
            margin: 0;
            padding: 0;
            background: none;
          }

          header h1 {
            font-style: italic;
            font-family: Georgia, serif;
            padding-bottom: 0.25rem;
            border-bottom: 1px dashed var(--border-colour);
          }

          header a {
            color: #5bf;
          }
          header a:visited {
            color: #5bf;
          }
        </style>
      </head>
      <body>
        <section>
          <xsl:apply-templates select="atom:feed" />
        </section>
        <section>
          <h2>Posts</h2>
          <xsl:apply-templates select="atom:feed/atom:entry" />
        </section>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="atom:feed">
    <header>
        <h1>changelog for <a href="./">alifeee.net</a> (web feed)</h1>
    </header>

    <section>
      <div class="alert">
        <p>
          <strong>This is a web feed</strong>, also known as an RSS feed.
          <strong>Subscribe</strong> by copying the URL from the address bar into a feed reader app. I use <a href="https://github.com/spacecowboy/Feeder">Feeder</a>!
        </p>
      </div>
    </section>

    <h2>What is an RSS feed?</h2>
    From
    <a href="https://gist.github.com/andrewstiefel/57a0a400aa2deb6c9fe18c6da4e16e0f">andrewstiefel's gist.</a
    >
    <p>
      An RSS feed is a data format that contains the latest content from a
      website, blog, or podcast. You can use feeds to
      <strong>subscribe</strong> to websites and get the
      <strong>latest content in one place</strong>.
    </p>
    <ul>
      <li>
        <strong>Feeds put you in control.</strong> Unlike social media apps,
        there is no algorithm deciding what you see or read. You always get the
        latest content from the creators you care about.
      </li>
      <li>
        <strong>Feed are private by design.</strong> No one owns web feeds, so
        no one is harvesting your personal information and profiting by selling
        it to advertisers.
      </li>
      <li>
        <strong>Feeds are spam-proof.</strong> Had enough? Easy, just
        unsubscribe from the feed.
      </li>
    </ul>
    <p>
      All you need to do to get started is to add the URL (web address) for this
      feed to a special app called a newsreader. Visit
      <a href="https://aboutfeeds.com/">About Feeds</a> to get started with
      newsreaders and subscribing. It’s free.
    </p>
  </xsl:template>

  <xsl:template match="atom:entry">
    <div class="entry">
      <h3>
        <a>
          <xsl:attribute name="href">
            <xsl:value-of select="atom:id" />
          </xsl:attribute>
          <xsl:value-of select="atom:title" />
        </a>
      </h3>
      <p>
        <xsl:value-of select="atom:summary" disable-output-escaping="yes" />
      </p>
      <small> Published: <xsl:value-of select="atom:updated" />
      </small>
    </div>
  </xsl:template>
</xsl:stylesheet>
