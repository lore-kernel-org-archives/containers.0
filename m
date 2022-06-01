Received: from mail-ej1-f43.google.com (mail-ej1-f43.google.com [209.85.218.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A14837E
	for <containers@lists.linux.dev>; Wed,  1 Jun 2022 16:45:36 +0000 (UTC)
Received: by mail-ej1-f43.google.com with SMTP id fu3so3472088ejc.7
        for <containers@lists.linux.dev>; Wed, 01 Jun 2022 09:45:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=sm/cES+pkDaSks5uDugp823Ct/h/91frIrCS39haBeI=;
        b=U+W2VnjjiSr/t1zwPDQhof68HxSYrjuFmU4KxvbNwAxMXa7BqM5kLE36ZdtINvTa34
         ojgk21vPuSmXj7NWL6elHx902k/NPV1EXQtsu1yPF8OkeGmVnGeJAX/sH0BCmE4pp1ZT
         26spaIH9P5OU5fZ1Ek/Wd5EQ3UMh+JGqR4Idc=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=sm/cES+pkDaSks5uDugp823Ct/h/91frIrCS39haBeI=;
        b=KaUOUCPLv/AsBLDf57QImqikHnIQPExQqT2W5D8mPehTKcsE6yf+WdOWgyDjLayR2O
         rvJKREmqN3liIsMm0PMjDKjOpKxc0AY/69dWzKmPOx46FDbUH1ojI3h9eXskAU+Z3BDT
         LMD4YUxUtw8UHfvC6BE4kxYgAEGQDBL/oo+Ubw4vOlBeZhqDGOpKsAZ7XcPVtOS03k/5
         6SN6wZRPa1zJfgu887qai4lcGaixbC6c/EBrrZ8P9pYQ9nGtoQrLlaTFivqzn0pRviXw
         E9uyFSFP53Ranw5v1zZtVz8td/9VOE4QS5CM5MZTSvf5dh9Zl2N8LeLozX+IMeLMy13O
         /eBw==
X-Gm-Message-State: AOAM530NK+IU6Y4wVfN6GE476VDMxLPsfAZhPm2Pdko6CAoEYHbx3TCE
	RyvIlqJCVszKkQMoUD9AO+TzlbMiArGZ8FU/
X-Google-Smtp-Source: ABdhPJzmrU5sJ2Aje5b3k8LOASKY84SihRGKJ3TxVyrCvCQEBtHfRoCtUDrAIwMnEMkqlIkKV/ILiA==
X-Received: by 2002:a17:906:8416:b0:705:6a1b:e8ef with SMTP id n22-20020a170906841600b007056a1be8efmr372423ejx.614.1654101934711;
        Wed, 01 Jun 2022 09:45:34 -0700 (PDT)
Received: from mail-wm1-f50.google.com (mail-wm1-f50.google.com. [209.85.128.50])
        by smtp.gmail.com with ESMTPSA id 8-20020a170906300800b00704dccefd2bsm880178ejz.204.2022.06.01.09.45.32
        for <containers@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 01 Jun 2022 09:45:32 -0700 (PDT)
Received: by mail-wm1-f50.google.com with SMTP id z17so1301565wmf.1
        for <containers@lists.linux.dev>; Wed, 01 Jun 2022 09:45:32 -0700 (PDT)
X-Received: by 2002:a7b:c409:0:b0:397:8536:d558 with SMTP id
 k9-20020a7bc409000000b003978536d558mr295369wmi.38.1654101932086; Wed, 01 Jun
 2022 09:45:32 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <CAHk-=whi2SzU4XT_FsdTCAuK2qtYmH+-hwi1cbSdG8zu0KXL=g@mail.gmail.com>
 <cover.1654086665.git.legion@kernel.org> <857cb160a981b5719d8ed6a3e5e7c456915c64fa.1654086665.git.legion@kernel.org>
In-Reply-To: <857cb160a981b5719d8ed6a3e5e7c456915c64fa.1654086665.git.legion@kernel.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Jun 2022 09:45:15 -0700
X-Gmail-Original-Message-ID: <CAHk-=wjJ2CP0ugbOnwAd-=Cw0i-q_xC1PbJ-_1jrvR-aisiAAA@mail.gmail.com>
Message-ID: <CAHk-=wjJ2CP0ugbOnwAd-=Cw0i-q_xC1PbJ-_1jrvR-aisiAAA@mail.gmail.com>
Subject: Re: [RFC PATCH 2/4] sysctl: ipc: Do not use dynamic memory
To: Alexey Gladkov <legion@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, 
	"Eric W . Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Christian Brauner <brauner@kernel.org>, Iurii Zaikin <yzaikin@google.com>, 
	Kees Cook <keescook@chromium.org>, Linux Containers <containers@lists.linux.dev>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Luis Chamberlain <mcgrof@kernel.org>, 
	Vasily Averin <vvs@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"

On Wed, Jun 1, 2022 at 6:20 AM Alexey Gladkov <legion@kernel.org> wrote:
>
> Dynamic memory allocation is needed to modify .data and specify the per
> namespace parameter. The new sysctl API is allowed to get rid of the
> need for such modification.

Ok, this is looking better. That said, a few comments:

>
> diff --git a/ipc/ipc_sysctl.c b/ipc/ipc_sysctl.c
> index ef313ecfb53a..833b670c38f3 100644
> --- a/ipc/ipc_sysctl.c
> +++ b/ipc/ipc_sysctl.c
> @@ -68,26 +68,94 @@ static int proc_ipc_sem_dointvec(struct ctl_table *table, int write,
>         return ret;
>  }
>
> +static inline void *data_from_ns(struct ctl_context *ctx, struct ctl_table *table);
> +
> +static int ipc_sys_open(struct ctl_context *ctx, struct inode *inode, struct file *file)
> +{
> +       struct ipc_namespace *ns = current->nsproxy->ipc_ns;
> +
> +       // For now, we only allow changes in init_user_ns.
> +       if (ns->user_ns != &init_user_ns)
> +               return -EPERM;
> +
> +#ifdef CONFIG_CHECKPOINT_RESTORE
> +       int index = (ctx->table - ipc_sysctls);
> +
> +       switch (index) {
> +               case IPC_SYSCTL_SEM_NEXT_ID:
> +               case IPC_SYSCTL_MSG_NEXT_ID:
[...]

I don't think you actually even compile-tested this, because you're
using these IPC_SYSCTL_SEM_NEXT_ID etc enums before you even declared
them later in the same file.

> +static ssize_t ipc_sys_read(struct ctl_context *ctx, struct file *file,
> +                    char *buffer, size_t *lenp, loff_t *ppos)
> +{
> +       struct ctl_table table = *ctx->table;
> +       table.data = data_from_ns(ctx, ctx->table);
> +       return table.proc_handler(&table, 0, buffer, lenp, ppos);
> +}

Can we please fix the names and the types of this new 'ctx' structure?

Yes, yes, I know the old legacy "sysctl table" is horribly named, and
uses "ctl_table".

But let's just write it out. It's not some random control table for
anything. It's a very odd and specific thing: "sysctl". Let's use the
full name.

Also, Please just make that "ctl_data" member in that "ctl_context"
struct not just have a real name, but a real type. Make it literally
be

    struct ipc_namespace *ipc_ns;

and if we end up with other things wanting other pointers, just add a
new one (or make a union if we care about the size of that allocation,
which I don't see any reason we'd do when it's literally just like a
couple of pointers in size).

There is no reason to have some pseudo-generic "void *ctl_data" that
makes it ambiguous and allows for type confusion and isn't
self-documenting. I'd rather have a properly typed pointer that is
just initialized to NULL and is not always used or needed, but always
has a clear case for *what* it would be used for.

Yes, yes, we have f_private etc for things that are really very very
generic and have arbitrary users. But 'sysctl' is not that kind of
truly generic use.

I wish we didn't have that silly "create a temporary ctl_table entry"
either, and I wish it was properly named. But it's not worth the
pointless churn to fix old bad interfaces. But the new ones should
have better names, and try to avoid those bad old decisions.

But yeah, I think this all is a step in the right direction. And maybe
some of those cases and old 'ctl_table' things can be migrated to just
using individual read() functions entirely. The whole 'ctl_table'
model was broken, and came from the bad old days with an actual
'sysctl()' system call.

Because I think it would be lovely if people would move away from the
'sysctl table' approach entirely for cases where that makes sense, and
these guys that already need special handling are very much in that
situation.

          Linus
