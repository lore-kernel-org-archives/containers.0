Return-Path: <SRS0=pmWk=IR=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A64AC433E0
	for <containers@archiver.kernel.org>; Fri, 19 Mar 2021 11:04:12 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id DF9D564F04
	for <containers@archiver.kernel.org>; Fri, 19 Mar 2021 11:04:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF9D564F04
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 9580F8316A;
	Fri, 19 Mar 2021 11:04:11 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id p0XysOikD8TY; Fri, 19 Mar 2021 11:04:10 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id 819B182B9F;
	Fri, 19 Mar 2021 11:04:08 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 5E6DFC000B;
	Fri, 19 Mar 2021 11:04:08 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [IPv6:2605:bc80:3010::133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 6C13DC0001
 for <containers@lists.linux-foundation.org>;
 Fri, 19 Mar 2021 11:04:06 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id 5931F400A8
 for <containers@lists.linux-foundation.org>;
 Fri, 19 Mar 2021 11:04:06 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id MesmEWz2LLt9
 for <containers@lists.linux-foundation.org>;
 Fri, 19 Mar 2021 11:04:05 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by smtp2.osuosl.org (Postfix) with ESMTPS id 0234F4011A
 for <containers@lists.linux-foundation.org>;
 Fri, 19 Mar 2021 11:04:04 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1lNCv7-0003Du-Rl; Fri, 19 Mar 2021 11:03:57 +0000
Date: Fri, 19 Mar 2021 12:03:56 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Sargun Dhillon <sargun@sargun.me>
Subject: Re: seccomp: Delay filter activation
Message-ID: <20210319110356.p4jtyvzuuwwixq5g@wittgenstein>
References: <CAMp4zn9oEb6bJJLQWjSE1AFg6TqwkF3FOvFk2VSkKd+0Kj7TCg@mail.gmail.com>
 <20210301110907.2qoxmiy55gpkgwnq@wittgenstein>
 <20210301132156.in3z53t5xxy3ity5@wittgenstein>
 <202103011515.3A941F6@keescook>
 <20210318145454.d2xbetk2werv7j2u@wittgenstein>
 <20210318203912.GA26982@ircssh-2.c.rugged-nimbus-611.internal>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210318203912.GA26982@ircssh-2.c.rugged-nimbus-611.internal>
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

On Thu, Mar 18, 2021 at 08:39:13PM +0000, Sargun Dhillon wrote:
> On Thu, Mar 18, 2021 at 03:54:54PM +0100, Christian Brauner wrote:
> > Sorry, I just found that mail.
> > 
> > On Mon, Mar 01, 2021 at 03:44:06PM -0800, Kees Cook wrote:
> > > On Mon, Mar 01, 2021 at 02:21:56PM +0100, Christian Brauner wrote:
> > > > On Mon, Mar 01, 2021 at 12:09:09PM +0100, Christian Brauner wrote:
> > > > > On Sat, Feb 20, 2021 at 01:31:57AM -0800, Sargun Dhillon wrote:
> > > > > > We've run into a problem where attaching a filter can be quite messy
> > > > > > business because the filter itself intercepts sendmsg, and other
> > > > > > syscalls related to exfiltrating the listener FD. I believe that this
> > > > > > problem set has been brought up before, and although there are
> > > > > > "simpler" methods of exfiltrating the listener, like clone3 or
> > > > > > pidfd_getfd, but these are still less than ideal.
> > > 
> > > I'm trying to make sure I understand: the target process would like to
> > > have a filter attached that blocks sendmsg, but that would mean it has
> > > no way to send the listener FD to its manager?
> > 
> > With pidfd_getfd() that wouldn't be a problem, I think which is what I
> > was trying to say. Unless the supervising task doen't have enough
> > privilege over the supervised task which seems like an odd scenario but
> > is technically possible, I guess.
> > 
> > > 
> > > And you'd want to have listening working for sendmsg (otherwise you
> > > could do it with two filters, I imagine)?
> > > 
> > > > > 	int fd_filter = seccomp(SECCOMP_SET_MODE_FILTER, SECCOMP_FILTER_DETACHED, &prog);
> > > > > 
> > > > > 	BARRIER_WAIT_SETUP_DONE;
> > > > > 
> > > > > 	int ret = seccomp(SECCOMP_ATTACH_FILTER, 0, INT_TO_PTR(fd_listener));
> > > > 
> > > > This obviously should've been sm like:
> > > > 
> > > > struct seccomp_filter_attach {
> > > > 	union {
> > > > 		__s32 pidfd;
> > > > 		__s32 pid;
> > > > 	};
> > > > 	__u32 fd_filter;
> > > > };
> > > > 
> > > > and then
> > > > 
> > > > int ret = seccomp(SECCOMP_ATTACH_FILTER, 0, seccomp_filter_attach);
> > > 
> > > Given the difficulty with TSYNC, I'm not excited about adding an
> > > "apply this filter to another process" API. :)
> > 
> > Just to give a more complete reason for suggesting something like this
> > without trying to argue that we must have this:
> > 
> > seccomp() has so far been an API that is caller-centric and by that I
> > mean that the caller loaded it's seccomp profile and sandboxed itself. As
> > such seccomp is an example of "caller-managed" security. This security
> > model has obvious advantages and fits into the general fork()-like world
> > of unix. But imho that self-management model breaks down as soon as a
> > file descriptor that can be used to refer to the object in question
> > enters into the picture. For seccomp this "breaking point" was the
> > seccomp notifier fd.
> > 
> > Because with the introduction of that fd we have introduced the concept
> > of supervisor and supervisee for seccomp which imho didn't really exist
> > in the same way before. It's pretty obvious from the type of language
> > that we now use both in userspace and in kernelspace when we talk about
> > the seccomp notifier.
> > 
> > At the current point we're somewhere in the middle between caller-managed
> > and supervised seccomp which brings up funny probelms and edge-cases.
> > One of them most obvious examples is in fact the question how to get the
> > seccomp notify fd out of the supervised task. This clearly points to the
> > fact that we're missing one of the fundamentals of an fd-based
> > supervision model: open(). This is why I was suggesting the
> > SECCOMP_ATTACH_FILTER command. It's in a sense an open-call for the
> > seccomp notify fd.
> > 
> > That all being said I know that it can be weird to implement this and if
> > you prefer we go with another simpler model to work around such things
> > than I fully understand.
> > 
> > Christian
> 
> So, beyond clone3 to get pidfds being kind of awkward, how do you see this

Afaict we're talking about getting a file descriptor out of another
task. So just for my understanding what does clone3()'s way of returning
pidfds have to do with this and why is returning a pidfd in clone3()
awkward?

> pattern actually working? How does the filter installer let the supervisor

Sorry, what pattern are you referring to, i.e. is this a
critique/questions of my attach api proposal or of my statement about
using pidfd_getfd() to retrieve the fd? I think I'm just a little
confused about where you chose to place your reply in the thread. :)
Just to reiterate briefly: my preferred variant is to have an api
similar to what I proposed above where we can essentially prepare a
filter for another task and attach it to that task. In that model the fd
is retrieved directly by the supervisor without any need for cooperation
from the supervisee. After that you just need simply barriers (pipe,
socket etc.) to synchronize with the supervisee. For example, a
supervise does all the setup it wants and then sends a message over a
socket or pipe to the supervisor signaling it's ready and then the parent
attaches the child to its seccomp filter via some form of the command I
proposed above.

> know that it's ready for extraction? pause() + signaling the parent?

> 
> In the case that you're not fork-execing, how do you communicate to the 
> notifier? My coworkers have been working on this code, where they need to 
> connect to a daemon that does the supervision, and it's gnarly[1]. They're 
> looking at adding sendmsg to the filter list, and that complicates things.
> 
> I think that pidfd_getfd works well if the child has some way to signal to the 
> parent that it's ready and that the filter has been installed, but when your 
> filter intercepts connect, and sendmsg, and the supervisor is not your parent 
> (and your parent is some compiled, COTS software), it becomes complicated to 
> handle this.
> 
> I believe that the OCI spec[2] is going to run into this class of problem unless 
> we introduce an out of band signaling mechanism. I think a valid way to handle 
> this is do a send() of the fd number (literal), and wait for the other side to 
> pidfd_getfd the seccomp filter, and wait for the socket to be closed to continue,
> but I think we should maybe create an example (I volunteer) showing how to do this.

So at first it seems were looking at very different cases here:

- Supervisor and supervisee do not have a child-parent relationship
- Supervisor and supervisee do have a child-parent relationship

But in both scenarios you must have a way for the supervisor and
supervisee to communicate with each other. If you don't then I'd be
curious how you manage to supervise the setup process of the supervisee
even independent of the seccomp notifier. (Your first link seems to show
a non-child-parent supervisor-supervisee relationship and you
communicate  between supervisor and supervisee via a socket.)

I think you have two immediate ways of solving this problem (Possibly
more but I would need to think a bit more and I think that the two
solutions would solve most cases.):
1. Send the fd number and use pidfd_getfd() (Which is also what Rodrigo
   mentioned.).
   This can technically be a problem when somehow the supervisee is
   blocked from using any kind of write method to a pipe which I find to
   be a very artifical example.
   And in fact looking at [1] runC is writing to a fifo after the
   seccomp profile has been loaded so a similar method of telling the
   parent which fd number to retrieve should always work.
2. Use a shared memory location: Have the supervisor create a file
   created via memfd_create(). Send that fd to the supervisee. (Make the
   fd close-on-exec in case you for some reason want to block close()
   which again looking at [1] would mean you'd violate assumptions about
   what syscalls are available after loading the seccomp profile.)
   Have the supervisee mmap() that location (In case you're blocking
   write which again, doesn't work with current assumption.). Have it
   load it's seccomp profile. Write the fd number to that memory
   location. The mmap() memory will be cleared on exec so no need to
   have munmap() available.

But again, I prefer a model I suggested above.

[1]: https://github.com/opencontainers/runc/blob/4d4d19ce528ac40cc357ef92cd3a6931dba19316/libcontainer/standard_init_linux.go#L192

Christian
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
