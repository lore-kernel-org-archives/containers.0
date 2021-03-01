Return-Path: <SRS0=ByLK=H7=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6332C433DB
	for <containers@archiver.kernel.org>; Mon,  1 Mar 2021 13:22:10 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 67E5A64DA1
	for <containers@archiver.kernel.org>; Mon,  1 Mar 2021 13:22:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67E5A64DA1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id 123594F150;
	Mon,  1 Mar 2021 13:22:10 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 4s6rHx32Zs-U; Mon,  1 Mar 2021 13:22:08 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp4.osuosl.org (Postfix) with ESMTP id ABA694F14C;
	Mon,  1 Mar 2021 13:22:08 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 91A4DC000B;
	Mon,  1 Mar 2021 13:22:08 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 6880FC0001
 for <containers@lists.linux-foundation.org>;
 Mon,  1 Mar 2021 13:22:07 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id 49616606DC
 for <containers@lists.linux-foundation.org>;
 Mon,  1 Mar 2021 13:22:07 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id PjB2Tblnltww
 for <containers@lists.linux-foundation.org>;
 Mon,  1 Mar 2021 13:22:06 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by smtp3.osuosl.org (Postfix) with ESMTPS id 16F98606D6
 for <containers@lists.linux-foundation.org>;
 Mon,  1 Mar 2021 13:22:05 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1lGiUn-0000AB-AK; Mon, 01 Mar 2021 13:21:57 +0000
Date: Mon, 1 Mar 2021 14:21:56 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Sargun Dhillon <sargun@sargun.me>
Subject: Re: seccomp: Delay filter activation
Message-ID: <20210301132156.in3z53t5xxy3ity5@wittgenstein>
References: <CAMp4zn9oEb6bJJLQWjSE1AFg6TqwkF3FOvFk2VSkKd+0Kj7TCg@mail.gmail.com>
 <20210301110907.2qoxmiy55gpkgwnq@wittgenstein>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210301110907.2qoxmiy55gpkgwnq@wittgenstein>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Kees Cook <keescook@chromium.org>,
 Keerti Lakshminarayan <keerti@netflix.com>,
 Linux Containers List <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Hariharan Ananthakrishnan <hari@netflix.com>,
 Kyle Anderson <kylea@netflix.com>, Andy Lutomirski <luto@amacapital.net>
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Mon, Mar 01, 2021 at 12:09:09PM +0100, Christian Brauner wrote:
> On Sat, Feb 20, 2021 at 01:31:57AM -0800, Sargun Dhillon wrote:
> > We've run into a problem where attaching a filter can be quite messy
> > business because the filter itself intercepts sendmsg, and other
> > syscalls related to exfiltrating the listener FD. I believe that this
> > problem set has been brought up before, and although there are
> > "simpler" methods of exfiltrating the listener, like clone3 or
> > pidfd_getfd, but these are still less than ideal.
> 
> (You really like sending patches and discussion points in the middle of
> the merge window. :D I think everyone's panicked about getting their PRs
> in shape so it's not unlikely that this sometimes gets lost on the list. :))
> 
> It hasn't been a huge problem for us, especially since we added
> pidfd_getfd() this seemed like a straightforward problem to solve by
> selecting a fix fd number that is to be used for the listener. But I can
> see why it is annoying.
> 
> > 
> > One of the ideas that's been talked about (I want to say back at LSS
> > NA) is the idea of "delayed activation". I was thinking that it might
> > be nice to have a mechanism to do delayed attach, either activated on
> > execve / fork, or an ioctl on the listenerfd to activate the filter
> > and have a flag like SECCOMP_FILTER_FLAG_NEW_LISTENER_INACTIVE, which
> > indicates that the listener should be setup, but not enforcing, and
> > another ioctl to activate it.
> > 
> > The later approach is preferred due to simplicity, but I can see a
> > situation where you could accidentally get into a state where the
> > filter is not being enforced. Additionally, this may have unforeseen
> > implications with CRIU.
> 
> (If you were to expose an ioctl() that allows userspace to query the
> notifer state then CRIU shouldn't have a problem restoring the notifier
> in the correct state. Right now it doesn't do anyting fancy about the
> notifier, it just restores the task with the filter. It just has to
> learn about the new feature and that's fine imho.)
> 
> > 
> > I'm curious whether this is a problem others share, and whether any of
> > the aforementioned approaches seem reasonable.
> 
> So when I originally suggested the delayed activation I I had another
> related idea that I think I might have mentioned too: if we're already
> considering delaying filter activation I like to discuss the possibility
> of attaching a seccomp filter to a task.
> 
> Right now, if one task wants to attach to another task they need to
> recreate the whole seccomp filter and load it. That's not just pretty
> expensive but also only works if you have access to the rules that the
> filter was generated with. For container that's usually some sort of
> pseudo seccomp filter configuration language dumped into a config file
> from which it can be read.
> 
> So right now the status quo is:
> 
> struct sock_filter filter[] = {
>         BPF_STMT(BPF_LD|BPF_W|BPF_ABS, offsetof(struct seccomp_data, nr)),
>         BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, nr, 0, 1),
>         BPF_STMT(BPF_RET|BPF_K, SECCOMP_RET_USER_NOTIF), /* Get me a listener fd */
>         BPF_STMT(BPF_RET|BPF_K, SECCOMP_RET_ALLOW),
> };
> struct sock_fprog prog = {
>         .len = (unsigned short)ARRAY_SIZE(filter),
>         .filter = filter,
> };
> int fd = seccomp(SECCOMP_SET_MODE_FILTER, flags, &prog);
> 
> and then the caller must send the fd to the manager or the manager uses
> pidfd_getfd().
> 
> But, why not get a bit crazy^wcreative; especially since seccomp() is
> already a multiplexer. We introduce a new seccomp flag:
> 
> #define SECCOMP_FILTER_DETACHED
> 
> and a new seccomp command:
> 
> #define SECCOMP_ATTACH_FILTER
> 
> And now we could do something like:
> 
> pid_t pid = fork();
> if (pid < 0)
> 	return;
> 
> if (pid == 0) {
> 	// do stuff
> 	BARRIER_WAKE_SETUP_DONE;
> 
> 	// do more unrelated stuff
> 
> 	BARRIER_WAIT_SECCOMP_FILTER;
> 	execve(exec-something);
> } else {
> 	
> 	int fd_filter;
> 
> 	struct sock_filter filter[] = {
> 	        BPF_STMT(BPF_LD|BPF_W|BPF_ABS, offsetof(struct seccomp_data, nr)),
> 	        BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, nr, 0, 1),
> 	        BPF_STMT(BPF_RET|BPF_K, SECCOMP_RET_ALLOW),
> 	};
> 	
> 	struct sock_fprog prog = {
> 	        .len = (unsigned short)ARRAY_SIZE(filter),
> 	        .filter = filter,
> 	};
> 	
> 	int fd_filter = seccomp(SECCOMP_SET_MODE_FILTER, SECCOMP_FILTER_DETACHED, &prog);
> 
> 	BARRIER_WAIT_SETUP_DONE;
> 
> 	int ret = seccomp(SECCOMP_ATTACH_FILTER, 0, INT_TO_PTR(fd_listener));

This obviously should've been sm like:

struct seccomp_filter_attach {
	union {
		__s32 pidfd;
		__s32 pid;
	};
	__u32 fd_filter;
};

and then

int ret = seccomp(SECCOMP_ATTACH_FILTER, 0, seccomp_filter_attach);

> 
> 	BARRIER_WAKE_SECCOMP_FILTER;
> }
> 
> And now you have attached a filter to another task. This would be super
> elegant for a container manager. The container manager could also stash
> the filter fd and when attaching to a container the manager can send the
> attaching task the fd and the attaching task can do:
> 
> int ret = seccomp(SECCOMP_ATTACH_FILTER, 0, INT_TO_PTR(fd_filter));
> 
> too and would be attached to the same filter as the target task.
> 
> And for the listener fd case a container manager could simply set
> SECCOMP_RET_USER_NOTIF as before
> 
> 	struct sock_filter filter[] = {
> 	        BPF_STMT(BPF_LD|BPF_W|BPF_ABS, offsetof(struct seccomp_data, nr)),
> 	        BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, nr, 0, 1),
> 		BPF_STMT(BPF_RET|BPF_K, SECCOMP_RET_USER_NOTIF),
> 	        BPF_STMT(BPF_RET|BPF_K, SECCOMP_RET_ALLOW),
> 	};
> 
> and now fd_filter simply functions as the notifier fd after
> seccomp(SECCOMP_ATTACH_FILTER) that's basically the fancy version of my
> delayed notifier activiation idea.
> 
> I'm sure there's nastiness to figure out but I would love to see
> something like this.
> 
> Christian
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
