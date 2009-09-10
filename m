From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 0/4] LSM checkpoint/restart: introduction
Date: Thu, 10 Sep 2009 15:22:19 -0500
Message-ID: <20090910202219.GA6778@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>
List-Id: containers.vger.kernel.org


Following is a respin of the LSM checkpoint/restart patchset,
hopefully addressing most of the feedback I've gotten.

The patchset includes one (1/4) patch which is not directly
LSM-related, one (2/4) which implements the generic LSM c/r
support, one (3/4) implementing support for Smack, one
(4/4) implementing support for SELinux, and one (1/1)
updating the userspace program which initiates restart.

At this point I'm hoping to get some acks and get them pushed
to the c/r kernel tree, which is branch ckpt-v17-dev in
git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git/.  Comments
are of course appreciated.  Once they sit in the tree for a bit,
I'll tackle the socket related LSM c/r.

thanks,
-serge
