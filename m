From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH] ptrace: allow restriction of ptrace scope
Date: Thu, 17 Jun 2010 17:50:43 -0500
Message-ID: <20100617225043.GA2492@hallyn.com>
References: <20100616221833.GM24749@outflux.net>
 <m1hbl1eta6.fsf@fess.ebiederm.org>
 <20100617165940.GU24749@outflux.net>
 <m1typ175ip.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1typ175ip.fsf@fess.ebiederm.org>
Sender: linux-doc-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Kees Cook <kees.cook@canonical.com>, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Andrew Morton <akpm@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Dave Young <hidave.darkstar@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Roland McGrath <roland@redhat.com>, Oleg Nesterov <oleg@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, David Howells <dhowells@redhat.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-doc@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm@xmission.com):
> Kees Cook <kees.cook@canonical.com> writes:
> Somewhere Serge has a git tree where he started making the capabilities

FWIW I believe the latest one is

	http://git.kernel.org/?p=linux/kernel/git/sergeh/linux-cr.git;a=shortlog;h=refs/heads/userns.feb16.1

I (/we) should get back to that...  Though waiting for certain other
bits to settle (i.e. tagged sysfs and user-ns-safe SCM_CREDENTIALS)
isn't a bad thing.

-serge
