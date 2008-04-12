From: sukadev@us.ibm.com
Subject: [PATCH 0/4] Helper patches for PTY namespaces
Date: Sat, 12 Apr 2008 10:29:33 -0700
Message-ID: <20080412172933.GA19295@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756218AbYDLRbT@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Cc: serue@us.ibm.com, matthltc@us.ibm.com, "Eric W. Biederman" <ebiederm@xmission.com>, hpa@zytor.com, Pavel Emelyanov <xemul@openvz.org>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


Some simple helper patches to enable implementation of multiple PTY
(or device) namespaces.

	[PATCH 1/4]: Propagate error code from devpts_pty_new
	[PATCH 2/4]: Factor out PTY index allocation
	[PATCH 3/4]: Move devpts globals into init_pts_ns
	[PATCH 3/4]: Enable multiple mounts of /dev/pts

This patchset is based on earlier versions developed by Serge Hallyn
and Matt Helsley.
