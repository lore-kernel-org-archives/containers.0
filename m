From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH 0/2] netns: fix for NULL-dereference in ipv6 code
Date: Thu, 14 Aug 2008 15:27:19 -0400
Message-ID: <48A48717.4020609@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Hi,

When fixing the NULL-dereference of the idev in rt6_fill_node(), I
noticed that dev_net() doesn't handle a NULL argument either.  These two
patches fix that, as well as add a network namespace argument to
rt6_fill_node() and ipv6_dev_get_saddr().

-Brian

