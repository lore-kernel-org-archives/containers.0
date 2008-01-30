From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] reject '\n' in a cgroup name
Date: Wed, 30 Jan 2008 10:32:15 +0900
Message-ID: <20080130103215.ac42254e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080124052049.A2A8A1E3C0D@siro.lan>
	<6599ad830801272349p4b076ba5u8c491a92128fb1a9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830801272349p4b076ba5u8c491a92128fb1a9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, 27 Jan 2008 23:49:04 -0800
"Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> Looks sensible - maybe we should ban all characters not in [a-zA-Z0-9._-] ?
> 
Hmm, ' ' (white space) please.

but it seems that the cgroup rejects multibyte charactor names. 
(I myself don't like it but..)

So, please add a section for 'acceptable names for cgroup' to cgroup
documentation.

Thanks,
-Kame


> Paul
> 
> On Jan 23, 2008 9:20 PM, YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:
> > hi,
> >
> > the following patch rejects '\n' in a cgroup name.
> > otherwise /proc/$$/cgroup is not parsable.
> >
> > example:
> >         imawoto% cat /proc/$$/cgroup
> >         memory:/
> >         imawoto% mkdir -p "
> >         memory:/foo"
> >         imawoto% echo $$ >| "
> >         memory:/foo/tasks"
> >         imawoto% cat /proc/$$/cgroup
> >         memory:/
> >         memory:/foo
> >         imawoto%
> >
> > YAMAMOTO Takashi
> >
> >
> > Signed-off-by: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
> > ---
> >
> > --- linux-2.6.24-rc8-mm1/kernel/cgroup.c.BACKUP 2008-01-23 14:43:29.000000000 +0900
> > +++ linux-2.6.24-rc8-mm1/kernel/cgroup.c        2008-01-24 13:56:28.000000000 +0900
> > @@ -2216,6 +2216,10 @@ static long cgroup_create(struct cgroup
> >         struct cgroup_subsys *ss;
> >         struct super_block *sb = root->sb;
> >
> > +       /* reject a newline.  otherwise /proc/$$/cgroup is not parsable. */
> > +       if (strchr(dentry->d_name.name, '\n'))
> > +               return -EINVAL;
> > +
> >         cgrp = kzalloc(sizeof(*cgrp), GFP_KERNEL);
> >         if (!cgrp)
> >                 return -ENOMEM;
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo-Bw31MaZKKs0EbZ0PF+XxCw@public.gmane.org  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org"> email-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org </a>
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo-Bw31MaZKKs0EbZ0PF+XxCw@public.gmane.org  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org"> email-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org </a>
> 
