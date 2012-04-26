From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 27/43] userns: Use uid_eq gid_eq helpers when comparing
	kuids and kgids in the vfs
Date: Wed, 25 Apr 2012 22:33:06 -0700
Message-ID: <m1wr53f46l.fsf@fess.ebiederm.org>
References: <m11unyn70b.fsf@fess.ebiederm.org>
	<1333862139-31737-27-git-send-email-ebiederm@xmission.com>
	<20120418190337.GE5186@mail.hallyn.com>
	<m1sjfx2950.fsf@fess.ebiederm.org>
	<20120426001101.GA10308@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120426001101.GA10308-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Thu, 26 Apr 2012 00:11:01 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
>> 
>> > Quoting Eric W. Beiderman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> >> From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> >> 
>> >> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> >> ---
>> >>  fs/attr.c                |    8 ++++----
>> >>  fs/exec.c                |   10 +++++-----
>> >>  fs/fcntl.c               |    6 +++---
>> >>  fs/ioprio.c              |    4 ++--
>> >>  fs/locks.c               |    2 +-
>> >>  fs/namei.c               |    8 ++++----
>> >>  include/linux/quotaops.h |    4 ++--
>> >>  7 files changed, 21 insertions(+), 21 deletions(-)
>> >> 
>> 
>> >> @@ -2120,7 +2120,7 @@ void do_coredump(long signr, int exit_code, struct pt_regs *regs)
>> >>  	if (__get_dumpable(cprm.mm_flags) == 2) {
>> >>  		/* Setuid core dump mode */
>> >>  		flag = O_EXCL;		/* Stop rewrite attacks */
>> >> -		cred->fsuid = 0;	/* Dump root private */
>> >> +		cred->fsuid = GLOBAL_ROOT_UID;	/* Dump root private */
>> >
>> > Sorry, one more - can this be the per-ns root uid?  The coredumps should
>> > be ok to belong to privileged users in the namespace right?
>> 
>> I'm not certain it was clear when you were looking at this that
>> this is about dumping core from suid applications, not normal
>> applications. 
>> 
>>  Looking at the code in commoncap and commit_creds it looks like it is a
>> bug that we don't call set_dumpable(new, suid_dumpable) in common cap
>> when we use file capabilities.  I might be wrong but I think we escape
>
> We do, check kernel/cred.c:commit_creds().  So long as the new permitted
> set is not a subset of the old one.
>
> Tested it to make absolutely sure.  When I add file capabilities to a
> program that otherwise dumps core (int *x = 0; *x = 0;), core dumps are
> no longer generated.

Thanks for testing.  Just reading through I was not certain if we had
the change in creds that commit_creds needed to trigger the set_dumpable
logic.

Eric
