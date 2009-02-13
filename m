From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] User namespaces: Only put the userns when we unhash the
	uid
Date: Sat, 14 Feb 2009 00:48:42 +0900
Message-ID: <2f11576a0902130748h313864b6sa50ad038ab011fc0@mail.gmail.com>
References: <20090213140421.5698.86876.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760357AbZBMPsz@vger.kernel.org>
In-Reply-To: <20090213140421.5698.86876.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Cc: torvalds@osdl.org, jmorris@namei.sys, akpm@linux-foundation.org, serue@us.ibm.com, mingo@elte.hu, linux-kernel@vger.kernel.org, vegard.nossum@gmail.com, containers@lists.osdl.org, snakebyte@gmx.de
List-Id: containers.vger.kernel.org

> From: Serge E. Hallyn <serue@us.ibm.com>
>
> uids in namespaces other than init don't get a sysfs entry.
>
> For those in the init namespace, while we're waiting to remove
> the sysfs entry for the uid the uid is still hashed, and
> alloc_uid() may re-grab that uid without getting a new
> reference to the user_ns, which we've already put in free_user
> before scheduling remove_user_sysfs_dir().
>
> Reported-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
> Acked-by: David Howells <dhowells@redhat.com>
> Tested-by: Ingo Molnar <mingo@elte.hu>

ok, thanks good patch.
  Tested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
