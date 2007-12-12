From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] netns: network namespace was passed into
 dev_getbyhwaddr but not used
Date: Wed, 12 Dec 2007 10:50:22 -0800 (PST)
Message-ID: <20071212.105022.221007365.davem@davemloft.net>
References: <20071212110517.GA11626@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20071212110517.GA11626@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: den@openvz.org
Cc: containers@lists.osdl.org, devel@openvz.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Wed, 12 Dec 2007 14:05:17 +0300

> netns: network namespace was passed into dev_getbyhwaddr but not used
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied.

Please always put the subsystem name in the headline in
all capitals and surround it with brackets, like this:

[NETNS]: Blah blah blah.

Also treat the description line as a true English sentence, this means
capitalize the first word and put a period at the end of it.  This is
a changelog message for a professional piece of software, not some
"innanet" slang talk on some IRC channel. :-)

I make these edits to every one of your patch submissions and it's
getting tiring, I hoped you would notice this yourself before my
needing to tell you about it explicitly :-)
