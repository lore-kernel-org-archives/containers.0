From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [RFC patch 0/2] posix mqueue namespace (v12)
Date: Wed, 17 Dec 2008 11:55:13 -0600
Message-ID: <20081217175513.GA23291@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751780AbYLQRzb@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: lkml <linux-kernel@vger.kernel.org>
Cc: Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Posix message queue support in ipc namespaces has had
several submissions by various people.  Hopefully this
version, based on code by both Cedric Le Goater and
Nadia Derbey has a shot at making it upstream.

To create a new ipc namespace with posix mq support, you
would

	unshare(CLONE_NEWIPC|CLONE_NEWNS);
	umount /dev/mqueue
	mount -t mqueue mqueue /dev/mqueue

It's perfectly valid to do vfs operations on files
in another ipc_namespace's /dev/mqueue, but any use
of mq_open(3) and friends will act in your own ipc_ns.

thanks,
-serge
