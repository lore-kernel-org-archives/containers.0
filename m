From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch -mm 0/4] mqueue namespace
Date: Fri, 20 Jun 2008 12:11:26 -0700
Message-ID: <m18wwzrkf5.fsf@frodo.ebiederm.org>
References: <20071128163728.177495768@fr.ibm.com>
	<m11w2syfmk.fsf@frodo.ebiederm.org>
	<20080620145031.GA30800@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755916AbYFTTVY@vger.kernel.org>
In-Reply-To: <20080620145031.GA30800@us.ibm.com> (Serge E. Hallyn's message of
	"Fri, 20 Jun 2008 09:50:31 -0500")
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, Cedric Le Goater <clg@fr.ibm.com>, Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Pavel Emelianov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue@us.ibm.com> writes:

>
> It is unfortunate that two actions are needed to properly complete the
> unshare, and we had definately talked about just using the mount before.
> I forget why we decided it wasn't practical, so maybe what you describe
> solves it...

What is worse, and I don't see a way around it: Is that we don't have
any callbacks to check where things are mounted.  So we can't ensure the
proper kind of filesystem is mounted in the right place.

That is there is too much freedom in the mount apis to allow for reliable
operation.

> But at least the current patch reuses CLONE_NEWIPC for posix ipc, which
> also seems to make sense.

Sort of.  I'm really annoyed with whoever did the posix mqueue support.
Adding the magic syscall that has to know the internal mount instead of
requiring the thing be mounted somewhere and just rejecting filedescriptors
for the wrong sorts of files.

Eric
