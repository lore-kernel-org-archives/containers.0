From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 0/25] Sysfs cleanups & tagged directory support
Date: Wed, 08 Aug 2007 10:37:10 -0600
Message-ID: <m1hcnac79l.fsf@ebiederm.dsl.xmission.com>
References: <11860582832964-git-send-email-htejun@gmail.com>
	<m1643rkqb6.fsf@ebiederm.dsl.xmission.com>
	<20070808093815.0935a18e@gondolin.boeblingen.de.ibm.com>
	<m1bqdifowo.fsf@ebiederm.dsl.xmission.com>
	<20070808095432.4a520735@gondolin.boeblingen.de.ibm.com>
	<m17io6foh8.fsf@ebiederm.dsl.xmission.com>
	<20070808103759.0850383c@gondolin.boeblingen.de.ibm.com>
	<20070808161631.1ccf27fd@gondolin.boeblingen.de.ibm.com>
	<46B9D4B8.4050201@gmail.com>
	<20070808165027.29af40b5@gondolin.boeblingen.de.ibm.com>
	<46B9D961.4000902@gmail.com>
	<m1r6medpxl.fsf@ebiederm.dsl.xmission.com>
	<46B9DDA1.1080704@gmail.com> <46B9DE5E.7050406@suse.de>
	<m11weednul.fsf@ebiederm.dsl.xmission.com> <46B9E948.8080605@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46B9E948.8080605-l3A5Bk7waGM@public.gmane.org> (Tejun Heo's message of "Thu, 09 Aug
	2007 01:03:20 +0900")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <teheo-l3A5Bk7waGM@public.gmane.org>
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, gregkh-l3A5Bk7waGM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, Cornelia Huck <cornelia.huck-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Tejun Heo <teheo-l3A5Bk7waGM@public.gmane.org> writes:

> Hello,
>
> Eric W. Biederman wrote:
>>> More specifically, d_off field.  It's a bit twisted.  For the last
>>> entry, filp->f_pos gets written into the field and gets wrapped while
>>> being copied out to userland or in glibc.
>> 
>> That could do it, and glibc is crunching it.  Oh well, it is
>> easy enough to avoid as long as our inode numbers are small which
>> the idr allocator seems to ensure.
>
> Yeah, now I think about it.  glibc throws out entries which don't fit in
> the data structure specified by the called API, so it probably threw out
> the last entry which has UINT_MAX in d_off which doesn't fit in the
> readdir() return structure.  Using INT_MAX should be just fine as IDA
> always allocates the first empty slot.  We can add paranoia check in ino
> allocation path.

Sounds reasonable.  Annoying but reasonable.

Eric
