From: Dan Smith <danms@us.ibm.com>
Subject: C/R: Network namespace and device support (v2)
Date: Fri, 22 Jan 2010 13:09:49 -0800
Message-ID: <1264194592-7529-1-git-send-email-danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: containers@lists.osdl.org
Cc: netdev@vger.kernel.org, orenl@librato.com
List-Id: containers.vger.kernel.org

This set adds support for checkpointing network namespaces and devices,
with in-kernel restart.

Basic support includes veth pair and loopback adapters and allows me to
checkpoint and restart a containerized copy of sendmail with a veth
bridged to a physical network.  Follow-on work is detailed in the header
of the last patch.

Changes in v2 only to the final patch, detailed there.

