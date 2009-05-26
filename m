From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 0/8] a start to credentials c/r
Date: Tue, 26 May 2009 12:32:42 -0500
Message-ID: <20090526173242.GA13757@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linux Containers <containers@lists.osdl.org>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Following is the next version of the credentials c/r patchset,
on top of the c/r patchset at
git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git

It implements checkpoint and restart of user, user namespaces,
groups, supplementary groups, and struct cred.

There is a question as to what to do about LSM data at
restart.  Right now I'm ignoring it, which means that
prepare_creds() should ensure that the restart tasks get
the context of the task calling sys_restart().  I
suspect the right thing to do is to add two new LSM
hooks, one which checks current's authorization to
restart from the checkpoint file, and one which determines
the task->cred->security filed based upon any of:
	1. current_security() of the task calling sys_restart()
	2. the task->cred->security checkpointed in the ckpt file
	3. the ->security of the checkpoint file

Oren, I think this version has all the changes you asked
for except for restoring cred info for sysvipc.

thanks,
-serge
