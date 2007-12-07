From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] net: move trie_local and trie_main into the
 proc iterator
Date: Fri, 07 Dec 2007 00:48:11 -0800 (PST)
Message-ID: <20071207.004811.07703526.davem@davemloft.net>
References: <20071206150012.GA22475@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20071206150012.GA22475@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: den@openvz.org
Cc: containers@lists.osdl.org, devel@openvz.org, netdev@vger.kernel.org, ebiederm@xmission.com
List-Id: containers.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 6 Dec 2007 18:00:12 +0300

> From: Eric W. Biederman <ebiederm@xmission.com>
> 
> We only use these variables when displaying the trie in proc so
> place them into the iterator to make this explicit.  We should
> probably do something smarter to handle the CONFIG_IP_MULTIPLE_TABLES
> case but at least this makes it clear that the silliness is limited
> to the display in /proc.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied.
