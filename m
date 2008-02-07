From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH][DOCUMENTATION] Minimal controller code for a quick start
Date: Thu, 7 Feb 2008 12:45:18 -0800
Message-ID: <6599ad830802071245r321efddat89a17b091cb5db4b@mail.gmail.com>
References: <47AB25AD.30400@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761345AbYBGUpd@vger.kernel.org>
In-Reply-To: <47AB25AD.30400@openvz.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

On Feb 7, 2008 7:37 AM, Pavel Emelyanov <xemul@openvz.org> wrote:
> The Documentation/cgroups.txt file contains the info on how
> to write some controller for cgroups subsystem, but even with
> this, one need to write quite a lot of code before developing
> the core (or copy-n-paste it from some other place).

Good idea.

> +
> +static ssize_t foo_bar_read(struct cgroup *cg, struct cftype *cft,
> +               struct file *file, char __user *userbuf,
> +               size_t nbytes, loff_t *ppos)
> +{
> +       struct foo_cgroup *foo;
> +
> +       foo = foo_from_cgroup(cg);
> +
> +       /*
> +        * produce some output
> +        */
> +
> +       return nbytes;
> +}
> +
> +static ssize_t foo_bar_write(struct cgroup *cg, struct cftype *cft,
> +               struct file *file, const char __user *userbuf,
> +               size_t nbytes, loff_t *ppos)
> +{
> +       struct foo_cgroup *foo;
> +
> +       foo = foo_from_cgroup(cg);
> +
> +       /*
> +        * read and tune the foo
> +        */
> +
> +       return nbytes;
> +}
> +
> +static struct cftype foo_files[] = {
> +       {
> +               .name = "bar",
> +               .read = foo_bar_read,
> +               .write = foo_bar_write,
> +       },
> +};

Can you structure this example so as to encourage people to use the
more formatted read/write routines, such as read_int64 and
write_int64?

> +
> +static struct cgroup_subsys_state *foo_create(struct cgroup_subsys *cs,
> +               struct cgroup *cg)
> +{
> +       struct foo_cgroup *foo;
> +

Maybe add a comment here that mentions that if your cgroup needs very
early initialization, you can check for cg->parent being NULL, and
return a statically-constructed structure here. (And set
foo_subsys.early_init = 1)

Paul
