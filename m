From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 11/11] sysfs: user namespaces: fix bug with clone(CLONE_NEWUSER) with fairsched
Date: Wed, 25 Jun 2008 14:11:39 -0700
Message-ID: <m1wskd43uc.fsf@frodo.ebiederm.org>
References: <20080618170729.808539948@theryb.frec.bull.fr>
	<20080618170731.746054454@theryb.frec.bull.fr>
	<485F0812.4090903@gmail.com> <20080625184409.GA8353@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755252AbYFYVVh@vger.kernel.org>
In-Reply-To: <20080625184409.GA8353@us.ibm.com> (Serge E. Hallyn's message of
	"Wed, 25 Jun 2008 13:44:09 -0500")
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Tejun Heo <htejun@gmail.com>, Benjamin Thery <benjamin.thery@bull.net>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue@us.ibm.com> writes:

> Except the sysfs mount holds no refcount on the userns.  So as long as we
> do the ida tagging as you suggested in your response to patch 6, there
> should be no reference to the user_ns left in sysfs code.
>
> The extra reference in patch #9 is for a light ref on the network
> namespace.  I'm still not sure that needs to be there, since if the
> network namespace goes away, it will properly unregister its sysfs
> mounts.  Eric, Benjamin, I really don't see any use for the hold_net()
> from sysfs.  What is it doing?

Mostly just being a sanity check.  We can remove that if it easier.

Eric
