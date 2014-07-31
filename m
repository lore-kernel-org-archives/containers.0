From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 5/5] mnt: Add tests for unprivileged remount cases
	that have found to be faulty
Date: Thu, 31 Jul 2014 15:52:29 -0700
Message-ID: <87fvhhdtua.fsf@x220.int.ebiederm.org>
References: <20140724194920.GU26600@ubuntumail>
	<CAOP=4wh-AXf7qPy0rPaQ6RFbbJGRWKo0h1Rn=9vLUeJ6b6Q7YA@mail.gmail.com>
	<8738dqh2j1.fsf@x220.int.ebiederm.org> <20140725060810.GC31313@1wt.eu>
	<877g2xou2u.fsf@x220.int.ebiederm.org>
	<87r415nf3k.fsf_-_@x220.int.ebiederm.org>
	<874my1neyr.fsf_-_@x220.int.ebiederm.org>
	<CAOP=4wj7m+w4aDJCuQaf3r9aFraPN1SvPgFSz=_UNkyC8gEHyQ@mail.gmail.com>
	<87ppgnjyx4.fsf_-_@x220.int.ebiederm.org>
	<87vbqfijq0.fsf_-_@x220.int.ebiederm.org>
	<20140731224818.GA7954@ubuntumail>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140731224818.GA7954@ubuntumail> (Serge Hallyn's message of
	"Thu, 31 Jul 2014 22:48:18 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Lutomirski <andy-RHosVwM/Cj8@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Willy Tarreau <w@1wt.eu>, security-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> 
>> Kenton Varda <kenton-AuYgBwuPrUQTaNkGU808tA@public.gmane.org> discovered that by remounting a
>> read-only bind mount read-only in a user namespace the
>> MNT_LOCK_READONLY bit would be cleared, allowing an unprivileged user
>> to the remount a read-only mount read-write.
>> 
>> Upon review of the code in remount it was discovered that the code allowed
>> nosuid, noexec, and nodev to be cleared.  It was also discovered that
>> the code was allowing the per mount atime flags to be changed.
>> 
>> The first naive patch to fix these issues contained the flaw that using
>> default atime settings when remounting a filesystem could be disallowed.
>> 
>> To avoid this problems in the future add tests to ensure unprivileged
>> remounts are succeeding and failing at the appropriate times.
>> 
>> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>
> one nit below
>
> Acked-by: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>

>> +#ifndef CLONE_NEWSNS
>
> Could cause build error in some places...  missspelled NEW S NS above.
>
>> +# define CLONE_NEWNS 0x00020000
>> +#endif

You are right that is an embarrassing typo.  I wonder how that ever
happened.  I will take care of that.

Eric
