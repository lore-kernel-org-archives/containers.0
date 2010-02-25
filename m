From: Dan Smith <danms@us.ibm.com>
Subject: C/R: Checkpoint and restore network namespaces and devices
Date: Thu, 25 Feb 2010 12:43:09 -0800
Message-ID: <1267130595-23637-1-git-send-email-danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: containers@lists.osdl.org
Cc: benjamin.thery@bull.net, den@openvz.org, ebiederm@xmission.com, davem@davemloft.net, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

This patch set adds checkpoint/restart support for network namespaces,
as well as the network devices within.  Currently supports veth, macvlan,
and loopback device types.

Includes the latest feedback and the new macvlan bits.  Rebased on Oren's
official v19.  Changes detailed per patch.

