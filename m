From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch -mm 2/4] mqueue namespace : add unshare support
Date: Thu, 29 Nov 2007 08:03:44 -0700
Message-ID: <m1y7chccvj.fsf@ebiederm.dsl.xmission.com>
References: <20071128163728.177495768@fr.ibm.com>
	<20071128164349.196734045@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932294AbXK2PGb@vger.kernel.org>
In-Reply-To: <20071128164349.196734045@fr.ibm.com>> (Cedric Le Goater's
	message of "Wed, 28 Nov 2007 17:37:30 +0100")
Sender: linux-kernel-owner@vger.kernel.org
To: Cedric Le Goater <clg@fr.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Pavel Emelianov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

Cedric Le Goater <clg@fr.ibm.com> writes:

> From: Cedric Le Goater <clg@fr.ibm.com>
>
> This patch includes the mqueue namespace in the nsproxy object. It  
> also adds the support of unshare() and clone() with a new clone flag 
> CLONE_NEWMQ (1 bit left in the clone flags !)
>
> CLONE_NEWMQ is required to be cloned or unshared along with CLONE_NEWNS.
> This is to make sure that no user mounts of the internal mqueue fs
> are left behind when the last task exits. 

Sounds reasonable.  It would be cool if we didn't have to do this.
(Why isn't the mqueue fs not MS_NOUSER?)  Ah well.

I'm not certain about requiring CLONE_NEWNS but it looks to be
ugly if we try and work it the other way.

> It's totally harmless for the moment because the current code still 
> uses the default mqueue namespace object 'init_mq_ns' 

I don't believe the harmless part.  Creating new objects should really
come after we have the code to really make them work.  In some sense
the next patch which makes this work causes ABI breakage.  Closely
packed together it doesn't matter but...

Eric
