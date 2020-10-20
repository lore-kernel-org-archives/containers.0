Return-Path: <SRS0=SoaA=D3=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E42FC4363A
	for <containers@archiver.kernel.org>; Tue, 20 Oct 2020 14:26:40 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6771422244
	for <containers@archiver.kernel.org>; Tue, 20 Oct 2020 14:26:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6771422244
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id DB66386D0D;
	Tue, 20 Oct 2020 14:26:38 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 0lhFhpQrRBoA; Tue, 20 Oct 2020 14:26:37 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id C042086D0C;
	Tue, 20 Oct 2020 14:26:37 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A4CF7C088B;
	Tue, 20 Oct 2020 14:26:37 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id C7F82C0051
 for <containers@lists.linux-foundation.org>;
 Tue, 20 Oct 2020 14:26:36 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id B4F7C869FD
 for <containers@lists.linux-foundation.org>;
 Tue, 20 Oct 2020 14:26:36 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id nzghXO-9GZcX
 for <containers@lists.linux-foundation.org>;
 Tue, 20 Oct 2020 14:26:36 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id EE77A86508
 for <containers@lists.linux-foundation.org>;
 Tue, 20 Oct 2020 14:26:35 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kUsau-0000Dv-Ju; Tue, 20 Oct 2020 14:26:32 +0000
Date: Tue, 20 Oct 2020 16:26:32 +0200
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Giuseppe Scrivano <gscrivan@redhat.com>
Subject: Re: [PATCH v2 1/2] fs, close_range: add flag CLOSE_RANGE_CLOEXEC
Message-ID: <20201020142632.7wllfigtfgqzoou4@wittgenstein>
References: <20201019102654.16642-1-gscrivan@redhat.com>
 <20201019102654.16642-2-gscrivan@redhat.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201019102654.16642-2-gscrivan@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org,
 linux@rasmusvillemoes.dk, linux-kernel@vger.kernel.org,
 viro@zeniv.linux.org.uk
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

On Mon, Oct 19, 2020 at 12:26:53PM +0200, Giuseppe Scrivano wrote:
> When the flag CLOSE_RANGE_CLOEXEC is set, close_range doesn't
> immediately close the files but it sets the close-on-exec bit.
> 
> It is useful for e.g. container runtimes that usually install a
> seccomp profile "as late as possible" before execv'ing the container
> process itself.  The container runtime could either do:
>   1                                  2
> - install_seccomp_profile();       - close_range(MIN_FD, MAX_INT, 0);
> - close_range(MIN_FD, MAX_INT, 0); - install_seccomp_profile();
> - execve(...);                     - execve(...);
> 
> Both alternative have some disadvantages.
> 
> In the first variant the seccomp_profile cannot block the close_range
> syscall, as well as opendir/read/close/... for the fallback on older
> kernels).
> In the second variant, close_range() can be used only on the fds
> that are not going to be needed by the runtime anymore, and it must be
> potentially called multiple times to account for the different ranges
> that must be closed.
> 
> Using close_range(..., ..., CLOSE_RANGE_CLOEXEC) solves these issues.
> The runtime is able to use the open fds and the seccomp profile could
> block close_range() and the syscalls used for its fallback.

I see, so you want those fds to be closed after exec but still use them
before. Yeah, this is a good use-case. (I proposed this extension quite a
while ago when we started discussing this syscall. Thanks for working
ont this!)

> 
> Signed-off-by: Giuseppe Scrivano <gscrivan@redhat.com>
> ---
>  fs/file.c                        | 44 ++++++++++++++++++++++++--------
>  include/uapi/linux/close_range.h |  3 +++
>  2 files changed, 37 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/file.c b/fs/file.c
> index 21c0893f2f1d..0295d4f7c5ef 100644
> --- a/fs/file.c
> +++ b/fs/file.c
> @@ -672,6 +672,35 @@ int __close_fd(struct files_struct *files, unsigned fd)
>  }
>  EXPORT_SYMBOL(__close_fd); /* for ksys_close() */
>  
> +static inline void __range_cloexec(struct files_struct *cur_fds,
> +				   unsigned int fd, unsigned int max_fd)
> +{
> +	struct fdtable *fdt;
> +
> +        if (fd > max_fd)
> +		return;

Looks like formatting issues here.

> +
> +	spin_lock(&cur_fds->file_lock);
> +	fdt = files_fdtable(cur_fds);
> +	bitmap_set(fdt->close_on_exec, fd, max_fd - fd + 1);

I think that this is ok and that there's no reason to make this anymore
complex unless we somehow really see performance issues which I doubt.

If Al is ok with doing it this way and doesn't see any obvious issues
I'll be taking this for some testing and would come back to ack this and
pick it up.

> +	spin_unlock(&cur_fds->file_lock);
> +}
> +
> +static inline void __range_close(struct files_struct *cur_fds, unsigned int fd,
> +				 unsigned int max_fd)
> +{
> +	while (fd <= max_fd) {
> +		struct file *file;
> +
> +		file = pick_file(cur_fds, fd++);
> +		if (!file)
> +			continue;
> +
> +		filp_close(file, cur_fds);
> +		cond_resched();
> +	}
> +}
> +
>  /**
>   * __close_range() - Close all file descriptors in a given range.
>   *
> @@ -687,7 +716,7 @@ int __close_range(unsigned fd, unsigned max_fd, unsigned int flags)
>  	struct task_struct *me = current;
>  	struct files_struct *cur_fds = me->files, *fds = NULL;
>  
> -	if (flags & ~CLOSE_RANGE_UNSHARE)
> +	if (flags & ~(CLOSE_RANGE_UNSHARE | CLOSE_RANGE_CLOEXEC))
>  		return -EINVAL;
>  
>  	if (fd > max_fd)
> @@ -725,16 +754,11 @@ int __close_range(unsigned fd, unsigned max_fd, unsigned int flags)
>  	}
>  
>  	max_fd = min(max_fd, cur_max);
> -	while (fd <= max_fd) {
> -		struct file *file;
>  
> -		file = pick_file(cur_fds, fd++);
> -		if (!file)
> -			continue;
> -
> -		filp_close(file, cur_fds);
> -		cond_resched();
> -	}
> +	if (flags & CLOSE_RANGE_CLOEXEC)
> +		__range_cloexec(cur_fds, fd, max_fd);
> +	else
> +		__range_close(cur_fds, fd, max_fd);
>  
>  	if (fds) {
>  		/*
> diff --git a/include/uapi/linux/close_range.h b/include/uapi/linux/close_range.h
> index 6928a9fdee3c..2d804281554c 100644
> --- a/include/uapi/linux/close_range.h
> +++ b/include/uapi/linux/close_range.h
> @@ -5,5 +5,8 @@
>  /* Unshare the file descriptor table before closing file descriptors. */
>  #define CLOSE_RANGE_UNSHARE	(1U << 1)
>  
> +/* Set the FD_CLOEXEC bit instead of closing the file descriptor. */
> +#define CLOSE_RANGE_CLOEXEC	(1U << 2)
> +
>  #endif /* _UAPI_LINUX_CLOSE_RANGE_H */
>  
> -- 
> 2.26.2
> 
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
