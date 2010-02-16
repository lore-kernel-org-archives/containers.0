From: Dan Smith <danms@us.ibm.com>
Subject: Network device and namespace checkpoint/restart (v3)
Date: Tue, 16 Feb 2010 08:03:02 -0800
Message-ID: <1266336187-19105-1-git-send-email-danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: containers@lists.osdl.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

This patch set adds checkpoint/restart support for network namespaces,
as well as the network devices within.  Currently supports veth and loopback
device types.

Minor changes this time around, based on feedback from the previous
posting.  Changes are detailed per-patch, and a new one at the end
adds a checkpoint handler for SIT devices (which does the bare minimum
so that we can fail when a device has no support).

