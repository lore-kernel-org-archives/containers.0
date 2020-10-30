Return-Path: <SRS0=hUL4=EF=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D751C4741F
	for <containers@archiver.kernel.org>; Fri, 30 Oct 2020 20:27:31 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 593362076D
	for <containers@archiver.kernel.org>; Fri, 30 Oct 2020 20:27:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=sargun.me header.i=@sargun.me header.b="JcmDIem2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 593362076D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id B31DA230FE;
	Fri, 30 Oct 2020 20:27:29 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id f-W34cvRLdaO; Fri, 30 Oct 2020 20:27:26 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id A46632048E;
	Fri, 30 Oct 2020 20:27:26 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 8E39FC088B;
	Fri, 30 Oct 2020 20:27:26 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 16CC1C0051
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 20:27:26 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 05EE486C39
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 20:27:26 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id xwK01GeN15Vy
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 20:27:25 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-il1-f196.google.com (mail-il1-f196.google.com
 [209.85.166.196])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id ECFB586C2F
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 20:27:24 +0000 (UTC)
Received: by mail-il1-f196.google.com with SMTP id k1so7574635ilc.10
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 13:27:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:content-transfer-encoding:in-reply-to
 :user-agent; bh=kuTknbqhK1g3g34Id4lOLSPvzBLGm3ypK3b32iZifKg=;
 b=JcmDIem2DY8j3ivVnlrkMam0ek18/0CnWlwG377b0w6s30XPah+BB6apss2qjDJPk/
 tRger9u7a/DBnbP+UE3nY2Ufv8AUayYoWm/SMtrKLpqy+0YSc9ENcNtPcbaU2PY2mMUp
 N9a+88Sznpph7Deu3XgNM6Wo7kwi7Z1TZAzEk=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:content-transfer-encoding
 :in-reply-to:user-agent;
 bh=kuTknbqhK1g3g34Id4lOLSPvzBLGm3ypK3b32iZifKg=;
 b=ebEJNl+7Js0fdID2iSMcoci/I7WHZ1QJeJt0XeXe/N9paBfFfNjaRr89rQ1l00v+PJ
 2TJDRMbhS9VQ6m4sNdJA0aLxDPAGMEkc/FgZDZrxdXQpInlaQIUVD7/T1mWkHDIkC1P7
 OAYAKp19BxZQAH2KeD3L3m+VtYOTpQRMX8zi2hP5AcJWxBZ8Q4RdKyS7IX2Fwfi1kpLY
 zB/NM4EWbF3Tn22mbGMM8psZrC4uL8ytdBarLcPf+5Ev6eMuk7qVnAlJzlY+sTaEucit
 wkx9/RX97WiaPC+9KapHcfgOUWv28N/NgyS3yvIUSoBi+4ES4fhrzEemeODSHx86mXsn
 Nj1w==
X-Gm-Message-State: AOAM531bO2Z5/0NzfSdhZeMVmanyEX0q+CJtU0wDSyRXBkvo/mWorPs3
 l5oKcFiMkswVy+3YCZb/XsOVHQ==
X-Google-Smtp-Source: ABdhPJwdWv9Z3WhLsQ1bfA8nV/BDPpM8CGlCQuuS505gefn5JvsbjjIaN6ZFze/YAovCoe5uvhzl1g==
X-Received: by 2002:a05:6e02:52c:: with SMTP id
 h12mr3133023ils.196.1604089643962; 
 Fri, 30 Oct 2020 13:27:23 -0700 (PDT)
Received: from ircssh-2.c.rugged-nimbus-611.internal
 (80.60.198.104.bc.googleusercontent.com. [104.198.60.80])
 by smtp.gmail.com with ESMTPSA id r17sm4934936iov.7.2020.10.30.13.27.23
 (version=TLS1_2 cipher=ECDHE-ECDSA-CHACHA20-POLY1305 bits=256/256);
 Fri, 30 Oct 2020 13:27:23 -0700 (PDT)
Date: Fri, 30 Oct 2020 20:27:21 +0000
From: Sargun Dhillon <sargun@sargun.me>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page [v2]
Message-ID: <20201030202720.GA4088@ircssh-2.c.rugged-nimbus-611.internal>
References: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
 <20201029085312.GC29881@ircssh-2.c.rugged-nimbus-611.internal>
 <48e5937b-80f5-c48b-1c67-e8c9db263ca5@gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <48e5937b-80f5-c48b-1c67-e8c9db263ca5@gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>, linux-man <linux-man@vger.kernel.org>,
 Robert Sesek <rsesek@google.com>,
 Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, lkml <linux-kernel@vger.kernel.org>,
 Alexei Starovoitov <ast@kernel.org>, bpf <bpf@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>,
 Christian Brauner <christian@brauner.io>
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
Precedence: list
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Thu, Oct 29, 2020 at 09:37:21PM +0100, Michael Kerrisk (man-pages) wrote:
> Hello Sargun,,
> =

> On 10/29/20 9:53 AM, Sargun Dhillon wrote:
> > On Mon, Oct 26, 2020 at 10:55:04AM +0100, Michael Kerrisk (man-pages) w=
rote:
> =

> [...]
> =

> >>    ioctl(2) operations
> >>        The following ioctl(2) operations are provided to support secco=
mp
> >>        user-space notification.  For each of these operations, the fir=
st
> >>        (file descriptor) argument of ioctl(2) is the listening file
> >>        descriptor returned by a call to seccomp(2) with the
> >>        SECCOMP_FILTER_FLAG_NEW_LISTENER flag.
> >>
> >>        SECCOMP_IOCTL_NOTIF_RECV
> >>               This operation is used to obtain a user-space notificati=
on
> >>               event.  If no such event is currently pending, the
> >>               operation blocks until an event occurs.  The third
> >>               ioctl(2) argument is a pointer to a structure of the
> >>               following form which contains information about the even=
t.
> >>               This structure must be zeroed out before the call.
> >>
> >>                   struct seccomp_notif {
> >>                       __u64  id;              /* Cookie */
> >>                       __u32  pid;             /* TID of target thread =
*/
> >>                       __u32  flags;           /* Currently unused (0) =
*/
> >>                       struct seccomp_data data;   /* See seccomp(2) */
> >>                   };
> >>
> >>               The fields in this structure are as follows:
> >>
> >>               id     This is a cookie for the notification.  Each such
> >>                      cookie is guaranteed to be unique for the
> >>                      corresponding seccomp filter.
> >>
> >>                      =B7 It can be used with the
> >>                        SECCOMP_IOCTL_NOTIF_ID_VALID ioctl(2) operation
> >>                        to verify that the target is still alive.
> >>
> >>                      =B7 When returning a notification response to the
> >>                        kernel, the supervisor must include the cookie
> >>                        value in the seccomp_notif_resp structure that =
is
> >>                        specified as the argument of the
> >>                        SECCOMP_IOCTL_NOTIF_SEND operation.
> >>
> >>               pid    This is the thread ID of the target thread that
> >>                      triggered the notification event.
> >>
> >>               flags  This is a bit mask of flags providing further
> >>                      information on the event.  In the current
> >>                      implementation, this field is always zero.
> >>
> >>               data   This is a seccomp_data structure containing
> >>                      information about the system call that triggered
> >>                      the notification.  This is the same structure that
> >>                      is passed to the seccomp filter.  See seccomp(2)
> >>                      for details of this structure.
> >>
> >>               On success, this operation returns 0; on failure, -1 is
> >>               returned, and errno is set to indicate the cause of the
> >>               error.  This operation can fail with the following error=
s:
> >>
> >>               EINVAL (since Linux 5.5)
> >>                      The seccomp_notif structure that was passed to the
> >>                      call contained nonzero fields.
> >>
> >>               ENOENT The target thread was killed by a signal as the
> >>                      notification information was being generated, or
> >>                      the target's (blocked) system call was interrupted
> >>                      by a signal handler.
> >>
> > =

> > I think I commented in another thread somewhere that the supervisor is =
not =

> > notified if the syscall is preempted. Therefore if it is performing a =

> > preemptible, long-running syscall, you need to poll
> > SECCOMP_IOCTL_NOTIF_ID_VALID in the background, otherwise you can
> > end up in a bad situation -- like leaking resources, or holding on to
> > file descriptors after the program under supervision has intended to
> > release them.
> =

> It's been a long day, and I'm not sure I reallu understand this.
> Could you outline the scnario in more detail?
> =

S: Sets up filter + interception for accept
T: socket(AF_INET, SOCK_STREAM, 0) =3D 7
T: bind(7, {127.0.0.1, 4444}, ..)
T: listen(7, 10)
T: pidfd_getfd(T, 7) =3D 7 # For the sake of discussion.
T: accept(7, ...)
S: Intercepts accept
S: Does accept in background
T: Receives signal, and accept(...) responds in EINTR
T: close(7)
S: Still running accept(7, ....), holding port 4444, so if now T retries
   to bind to port 4444, things fail.

> > A very specific example is if you're performing an accept on behalf
> > of the program generating the notification, and the program intends
> > to reuse the port. You can get into all sorts of awkward situations
> > there.
> =

> [...]
> =

See above

> > 	SECCOMP_IOCTL_NOTIF_ADDFD (Since Linux v5.9)
> > 		This operations is used by the supervisor to add a file
> > 		descriptor to the process that generated the notification.
> > 		This can be used by the supervisor to enable "emulation"
> > 		[Probably a better word] of syscalls which return file
> > 		descriptors, such as socket(2), or open(2).
> > =

> > 		When the file descriptor is received by the process that
> > 		is associated with the notification / cookie, it follows
> > 		SCM_RIGHTS like semantics, and is evaluated by MAC.
> =

> I'm not sure what you mean by SCM_RIGHTS like semantics. Do you mean,
> the file descriptor refers to the same open file description
> ('struct file')?
> =

> "is evaluated by MAC"... Do you mean something like: the FD is =

> subject  to LSM checks?
> =

The same model of SCM_RIGHTS, where it's checked against LSMs in the same w=
ay, =

and if your lsm hooks in, it'll activate the same hook as moving the file v=
ia =

SCM_RIGHTS would trigger. Also, SCM_RIGHTS does result in some aspects of t=
he fd =

being shared and others being different (like flags). Perhaps there's a bet=
ter =

term to describe these semantics.

RE: Evaluated by MAC - yes, checked by LSMs.

> > 		In addition, if it is a socket, it inherits the cgroup
> > 		v1 classid and netprioidx of the receiving process.
> > =

> > 		The argument of this is as follows:
> > =

> > 			struct seccomp_notif_addfd {
> > 				__u64 id;
> > 				__u32 flags;
> > 				__u32 srcfd;
> > 				__u32 newfd;
> > 				__u32 newfd_flags;
> > 			};
> > =

> > 		id
> > 			This is the cookie value that was obtained using
> > 			SECCOMP_IOCTL_NOTIF_RECV.
> > =

> > 		flags
> > 			A bitmask that includes zero or more of the
> > 			SECCOMP_ADDFD_FLAG_* bits set
> > =

> > 			SECCOMP_ADDFD_FLAG_SETFD - Use dup2 (or dup3?)
> > 				like semantics when copying the file
> > 				descriptor.
> > =

> > 		srcfd
> > 			The file descriptor number to copy in the
> > 			supervisor process.
> > =

> > 		newfd
> > 			If the SECCOMP_ADDFD_FLAG_SETFD flag is specified
> > 			this will be the file descriptor that is used
> > 			in the dup2 semantics. If this file descriptor
> > 			exists in the receiving process, it is closed
> > 			and replaced by this file descriptor in an
> > 			atomic fashion. If the copy process fails
> > 			due to a MAC failure, or if srcfd is invalid,
> > 			the newfd will not be closed in the receiving
> > 			process.
> =

> Great description!
> =

> > 			If SECCOMP_ADDFD_FLAG_SETFD it not set, then
> > 			this value must be 0.
> > =

> > 		newfd_flags
> > 			The file descriptor flags to set on
> > 			the file descriptor after it has been received
> > 			by the process. The only flag that can currently
> > 			be specified is O_CLOEXEC.
> > =

> > 		On success, this operation returns the file descriptor
> > 		number in the receiving process. On failure, -1 is returned.
> > =

> > 		It can fail with the following error codes:
> > =

> > 		EINPROGRESS
> > 			The cookie number specified hasn't been received
> > 			by the listener
> =

> I don't understand this. Can you say more about the scenario?
> =


This should not really happen. But if you do a ADDFD(...), on a notificatio=
n =

*before* you've received it, you will get this error. So for example,
--> epoll(....) -> returns
--> RECV(...) cookie id is 777
--> epoll(...) -> returns
<-- ioctl(ADDFD, id =3D 778) # Notice how we haven't done a receive yet
    where we've received a notification for 778.

> > 		ENOENT
> > 			The cookie number is not valid. This can happen
> > 			if a response has already been sent, or if the
> > 			syscall was interrupted
> > =

> > 		EBADF
> > 			If the file descriptor specified in srcfd is
> > 			invalid, or if the fd is out of range of the
> > 			destination program.
> =

> The piece "or if the fd is out of range of the destination
> program" is not clear to me. Can you say some more please.
> =


IIRC the maximum fd range is specific in proc by some sysctl named
nr_open. It's also evaluated against RLIMITs, and nr_max.

If nr-open (maximum fds open per process, iiirc) is 1000, even
if 10 FDs are open, it wont work if newfd is 1001.

> > 		EINVAL
> > 			If flags or new_flags were unrecognized, or
> > 			if newfd is non-zero, and SECCOMP_ADDFD_FLAG_SETFD
> > 			has not been set.
> > =

> > 		EMFILE
> > 			Too many files are open by the destination process.
> > =

> > 		[there's other error codes possible, like from the LSMs
> > 		 or if memory can't be read / written or ebusy]
> > 		 =

> > Does this help?
> =

> It's a good start!
> =

> Thanks,
> =

> Michael
> =

> =

> -- =

> Michael Kerrisk
> Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
> Linux/UNIX System Programming Training: http://man7.org/training/
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
