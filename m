From: dlezcano@fr.ibm.com
Subject: [net-2.6.24][NETNS][patch 0/1] fix allnoconfig compilation erro
Date: Thu, 13 Sep 2007 08:01:51 +0200
Message-ID: <20070913060151.898030855@mai.toulouse-stg.fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: davem@davemloft.net
Cc: ebiederm@xmission.com, containers@lists.osdl.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

fixes a compilation issue when allnoconfig is used.
 - init_net is unresolved.

-- 
